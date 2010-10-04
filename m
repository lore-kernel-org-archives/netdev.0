From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCHv4 net-next-2.6 1/5] XFRM,IPv6: Remove xfrm_spi_hash() dependency on destination address
Date: Mon, 04 Oct 2010 22:51:38 +0200
Message-ID: <8739sl8yw5.fsf@small.ssi.corp>
References: <cover.1286139128.git.arno@natisbad.org>
	<5a0e320544e253cc903cfd3292600b6bec044a5f.1286139129.git.arno@natisbad.org>
	<20101004083306.GA17939@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:48240 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932514Ab0JDUvm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 16:51:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Mon, Oct 04, 2010 at 08:25:07AM +0200, Arnaud Ebalard wrote:
>>
>> At the moment, Linux XFRM stack includes the address when computing
>> the hash to perform state lookup by SPI. This patch changes XFRM
>> state hash computation to prevent destination address to be
>> used. This will later allow finding states for packets w/ mangled
>> destination addresses.
>
> I'm fine with doing this for inbound SAs.  However, I can't see
> how we can do this for outbound SAs where the SPI is chosen by
> the remote end.

The change *does not* make the lookup in the hash table rely only on the
spi, i.e. __xfrm_state_lookup() is still passed the address. It only
removes the destination address from the computation of the hash. This
allows passing NULL to __xfrm_state_lookup() specifically for input path
and make the lookup only based on the SPI. The destination address check
is done later (possibly after IRO remapping).

Except if I really missed something, this has no impact on outbound SA
(other hashtables are used in that case). 

> Incidentally, it appears that our hash could do with some
> strengthening.

After the change, xfrm_spi_hash() would contain:

 	unsigned int h = (__force u32)spi ^ proto;
        return  ((h ^ (h >> 10) ^ (h >> 20)) & hmask)

which seems to spread the bits h correctly into hmask bits (I mean for
the effort ;-) ). Are you thinking about something like changing the
shifts based on the length of the mask?

Cheers,

a+
