From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH BUG-FIX] ipv6: allow to send packet after receiving
	ICMPv6 Too Big message with MTU field less than  IPV6_MIN_MTU
Date: Mon, 19 Apr 2010 11:55:35 +0800
Message-ID: <20100419035535.GA7011@gondor.apana.org.au>
References: <4BCBC6CE.9020302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>,
	=?utf-8?B?6a2P5YuH5Yab?= <yjwei@cn.fujitsu.com>,
	vladislav.yasevich@hp.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, Patrick McHardy <kaber@trash.net>,
	eric.dumazet@gmail.com, sri@us.ibm.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:47729 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753021Ab0DSD42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 23:56:28 -0400
Content-Disposition: inline
In-Reply-To: <4BCBC6CE.9020302@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 19, 2010 at 10:58:22AM +0800, Shan Wei wrote:
> 
> According to RFC2460, PMTU is set to the IPv6 Minimum Link
> MTU (1280) and a fragment header should always be included
> after a node receiving Too Big message reporting PMTU is
> less than the IPv6 Minimum Link MTU.
> 
> After receiving a ICMPv6 Too Big message reporting PMTU is
> less than the IPv6 Minimum Link MTU, sctp *can't* send any
> data/control chunk that total length including IPv6 head 
> and IPv6 extend head is less than IPV6_MIN_MTU(1280 bytes).
> 
> The failure occured in p6_fragment(), about reason 
> see following(take SHUTDOWN chunk for example):
> sctp_packet_transmit (SHUTDOWN chunk, len=16 byte)
> |------sctp_v6_xmit (local_df=0)
>    |------ip6_xmit
>        |------ip6_output (dst_allfrag is ture)
>            |------ip6_fragment
> 
> In ip6_fragment(), for local_df=0, drops the the packet
> and returns EMSGSIZE.
> 
> The patch fixes it with adding check length of skb->len.
> In this case, Ipv6 not to fragment upper protocol data,
> just only add a fragment header before it. 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

The patch looks good to me.

If we wanted to optimise the allfrags case it may be better
to reserve the space beforehand and generate the fragment header
at the same time as we're doing the IPv6 header.

But it can't be all that important as it's been broken for so
many years.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
