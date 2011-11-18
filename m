From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: Occasional oops with IPSec and IPv6.
Date: Fri, 18 Nov 2011 22:06:47 +0200
Message-ID: <4EC6BAD7.3010200@iki.fi>
References: <20111117190925.GA23214@elliptictech.com> <20111118162709.GA8342@elliptictech.com> <1321634378.3277.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4EC6A38E.6060404@iki.fi> <20111118192639.GA10531@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53294 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234Ab1KRUGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 15:06:53 -0500
Received: by bke11 with SMTP id 11so3856206bke.19
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2011 12:06:52 -0800 (PST)
In-Reply-To: <20111118192639.GA10531@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2011 09:26 PM, Nick Bowler wrote:
> On 2011-11-18 20:27 +0200, Timo Ter=E4s wrote:
>> On 11/18/2011 06:39 PM, Eric Dumazet wrote:
>>> Le vendredi 18 novembre 2011 =E0 11:27 -0500, Nick Bowler a =E9crit=
 :
>>>> On 2011-11-17 14:09 -0500, Nick Bowler wrote:
>>>>> One of the tests we do with IPsec involves sending and receiving =
UDP
>>>>> datagrams of all sizes from 1 to N bytes, where N is much larger =
than
>>>>> the MTU.  In this particular instance, the MTU is 1500 bytes and =
N is
>>>>> 10000 bytes.  This test works fine with IPv4, but I'm getting an
>>>>> occasional oops on Linus' master with IPv6 (output at end of emai=
l).  We
>>>>> also run the same test where N is less than the MTU, and it does =
not
>>>>> trigger this issue.  The resulting fallout seems to eventually lo=
ck up
>>>>> the box (although it continues to work for a little while afterwa=
rds).
>>>>>
>>>>> The issue appears timing related, and it doesn't always occur.  T=
his
>>>>> probably also explains why I've not seen this issue before now, a=
s we
>>>>> recently upgraded all our lab systems to machines from this centu=
ry
>>>>> (with newfangled dual core processors).  This also makes it somew=
hat
>>>>> hard to reproduce, but I can trigger it pretty reliably by runnin=
g 'yes'
>>>>> in an ssh session (which doesn't use IPsec) while running the tes=
t:
>>>>> it'll usually trigger in 2 or 3 runs.  The choice of cipher suite
>>>>> appears to be irrelevant.
> [...]
>>> Please note commit 80c802f307 added a known bug, fixed in commit
>>> 0b150932197b (xfrm: avoid possible oopse in xfrm_alloc_dst)
>>>
>>> Given commit 80c802f307 complexity, we can assume other bugs are to=
 be
>>> fixed as well.
> [...]
>> This looks quite different. And I've been trying to figure out what
>> causes this. However, the OOPS happens at ip6_fragment(), indicating
>> that there was not enough allocated headroom (skb underrun). My init=
ial
>> thought is ipv6 bug that just got uncovered by my commit; especially
>> since ipv4 side is happy. But I haven't yet been able to figure this=
 one
>> out.
>>
>> Could you also try Herbert's latest patch set:
>>   [0/6] Replace LL_ALLOCATED_SPACE to allow needed_headroom adjustme=
nt
>>
>> This changes how the headroom is calculated, and *might* fix this is=
sue
>> too if it's caused by the same SMP race condition which got uncovere=
d by
>> my other commit earlier.
>=20
> I applied all six of those patches, but I still see a crash.  However=
,
> the call trace seems to be slightly different.  I've appended the tra=
ce
> from the run with these paches applied, just in case it's significant=
=2E
>=20
> NOTE: I did not carefully look at the traces of all the crashes I've
> triggered.  This particular backtrace could potentially have appeared
> before applying these patches and I would not have noticed.

It's still headroom underrun.

I'm not too familiar with the relevant IPv6 code, but it seems to be
mostly modelled after the IPv4 side. Looking at the back trace offset
inside ipv6_fragment, I'd say it was taking the "fast path" for
constructing the fragments. So first guess is that the headroom check
for allowing fast path to happen is not right.

Since the code seems to be treating separately hlen and struct frag_hdr=
,
I'm wondering if the following patch would be in place?

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1c9bf8b..c35d9fc 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -675,7 +675,7 @@ int ip6_fragment(struct sk_buff *skb, int
(*output)(struct sk_buff *))
 			/* Correct geometry. */
 			if (frag->len > mtu ||
 			    ((frag->len & 7) && frag->next) ||
-			    skb_headroom(frag) < hlen)
+			    skb_headroom(frag) < hlen + sizeof(struct frag_hdr))
 				goto slow_path_clean;

 			/* Partially cloned skb? */


Alternatively, we could just run the "slow path" unconditionally with
the test load to see if it fixes the issue. At least that'd be pretty
good test if it's a problem in the ipv6 fragmentation code or something
else.

- Timo
