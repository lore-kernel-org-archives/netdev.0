From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net] ip: make IP identifiers less predictable
Date: Sat, 26 Jul 2014 14:21:01 +0200
Message-ID: <1406377261.22881.36.camel@localhost>
References: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1406317840.3363.106.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1406327752.14815.8.camel@localhost>
	 <1406357505.12728.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jeffrey Knockel <jeffk@cs.unm.edu>,
	"Jedidiah R. Crandall" <crandall@cs.unm.edu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Willy Tarreau <w@1wt.eu>, security@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:55512 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751317AbaGZMVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2014 08:21:07 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway1.nyi.internal (Postfix) with ESMTP id 0652B225DF
	for <netdev@vger.kernel.org>; Sat, 26 Jul 2014 08:21:03 -0400 (EDT)
In-Reply-To: <1406357505.12728.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sa, 2014-07-26 at 08:51 +0200, Eric Dumazet wrote:
> On Sat, 2014-07-26 at 00:35 +0200, Hannes Frederic Sowa wrote:
> > On Fr, 2014-07-25 at 21:50 +0200, Eric Dumazet wrote:
> > > diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> > > index cb9df0eb4023..73372e8016b9 100644
> > > --- a/net/ipv6/ip6_output.c
> > > +++ b/net/ipv6/ip6_output.c
> > > @@ -545,6 +545,7 @@ static void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
> > >  	net_get_random_once(&ip6_idents_hashrnd, sizeof(ip6_idents_hashrnd));
> > >  
> > >  	hash = __ipv6_addr_jhash(&rt->rt6i_dst.addr, ip6_idents_hashrnd);
> > > +	hash ^= __ipv6_addr_jhash(&rt->rt6i_src.addr, fhdr->nexthdr);
> > 
> > I am not sure if we should hash fhdr->nexthdr for IPv6.
> > 
> 
> It seemed a reasonable idea to me ;)

To me, too. ;)

> > If you look at the reassembly engine, we compare protocol value for IPv4
> > but not for IPv6 (we even don't save it).
> 
> That is linux, what about other reassembly engines ?

The protocol id should be used in the reassembly process for ipv4, but
not for ipv6. Linux is completely rfc compliant in this regard (RFC 815
and others).

> > Even if we only transmit packets with UDP protocol type we might end up
> > having an extension header right after the fragmentation header of
> > another type later in the flow. We can end up using a different bucket
> > and thus reusing a fragmentation id wich has been seen before in this
> > flow possibly resulting in reassembly issues.
> 
> This seems to point a bug in our reassembly unit then ? It seems to rely
> on senders being linux based or something.

I don't think so.

The buckets aren't synchronized in any way. If we fragment an IPv6-UDP
stream towards a destination and some of those packets have extension
headers behind the fragment header we end up using a different bucket
which might contain an already used fragmentation id in this flow. The
reassembly engine does not match on protocol id, so it is possible that
we reassemble not matching fragments. This cannot happen with ipv4,
protocol id will always stay the same and should always be used during
reassembly.

Btw., does someone see a problem if we nuke out the ip ids before
attaching the headers to an icmp error message? We might also prevent
leaking IP ids to wrong hosts.

> Anyway, I'll send a v3 without netxdhr, ipv6 guys will make net-next
> patches if needed.

I'll have a look.

I played around with an idea of my own. These are just some snippets
from a user space implementation, comments inline:

Basically the idea is to use a symmetric block cipher with very small
block size to encrypt fragmentation ids.

We put a linear increasing counter (per host) into a symmetric block
cipher of a very small block size, for IPv6 (32 bit block size) I found
RC5 (warning: patent encumbered) to be reasonable albeit it normally
does not get used with 32 bit block sizes in real world. It may also be
possible to use it with 16 bit block sizes for IPv4. I can do so if
people like it.

The result is a perfect permutation to use for fragmentation ids (no
repeating values until the bucket counter wraps around) without the
possibility that someone can guess the next fragment id or infer
anything from it.

I only wonder if this has a too high impact performance wise.

I tried to clean up the code from the original RC5 paper and make it
undefined free and easy to integrate into the kernel.

static u32 frag_id_encrypt(u32 counter)
{
	int i;
	u16 A = counter >> 16;
	u16 B = counter & 0xffffU;

	A += S[0];
	B += S[1];

	for (i = 1; i <= ROUNDS; i++) {
		A = roll_l16(A ^ B, B);
		A += S[2 * i];
		B = roll_l16(B ^ A, A);
		B += S[2 * i + 1];
	}
	return (u32)A << 16 | B;
}

/* done once during boot up */
static void rc5_setup(void)
{
	int cnt;
	unsigned char key[KEY_BYTES] = {0};

	int  i, j;
	u16 A, B;

	u16 expanded_key[KEY_WORDS] = {0};

	srand(time(NULL));

	for (cnt = 0; cnt < KEY_BYTES; cnt++)
		key[cnt] = 0;

	for (cnt = KEY_BYTES - 1; cnt >= 0; cnt--)
		expanded_key[cnt/WORD_BYTES] =
			roll_l16(expanded_key[cnt/WORD_BYTES], 8) + key[cnt];

	S[0] = P16;
	for (cnt = 1; cnt < S_SIZE; cnt++)
		S[cnt] = S[cnt - 1] + Q16;

	i = 0;
	j = 0;
	A = 0;
	B = 0;

	for (cnt = 0; cnt < 3 * MAX(S_SIZE, KEY_WORDS); cnt++) {
		A = roll_l16(S[i] + (u16)(A + B), 3);
		S[i] = A;

		B = roll_l16(expanded_key[j] + (u16)(A + B), A + B);
		expanded_key[j] = B;

		i = (i+1) % S_SIZE;
		j = (j+1) % KEY_WORDS;
	}
}


Additional helpers so the code does compile (hmm, gcc does not see that
in can use roll instructions :( ):

static u16 roll_l16(u16 x, u16 roll)
{
	u16 l,r;
	roll &= WORD_BITS - 1;

	if (roll == 0)
		return x;

	assert(roll > 0);
	assert(roll < 16);

	l = x << roll;
	r = x >> (WORD_BITS - roll);
	return l | r;
}

static u16 roll_r16(u16 x, u16 roll)
{
	u16 l, r;
	roll &= WORD_BITS - 1;

	if (roll == 0)
		return x;

	assert(roll > 0);
	assert(roll < 16);

	l = x << (WORD_BITS - roll);
	r = x >> roll;
	return l | r;
}


<<< constants; should be at the top >>>
#define WORD_BYTES (sizeof(u16))
#define WORD_BITS (WORD_BYTES * CHAR_BIT)

#define ROUNDS 12
#define S_SIZE (2 * (ROUNDS + 1))

#define KEY_BYTES 16
#define KEY_WORDS (((KEY_BYTES-1)/WORD_BYTES) + 1)

static const u16 P16 = 0xb7e1;
static const u16 Q16 = 0x9e37;

/* constant after initialization __read_mostly */
static u16 S[S_SIZE] = {0};

<<< stuff end >>>

Bye,
Hannes
a
