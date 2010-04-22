From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH BUG-FIX] ipv6: allow to send packet after receiving
 ICMPv6 Too Big message with MTU field less than IPV6_MIN_MTU
Date: Wed, 21 Apr 2010 22:48:46 -0700 (PDT)
Message-ID: <20100421.224846.78174700.davem@davemloft.net>
References: <4BCBC6CE.9020302@cn.fujitsu.com>
	<20100419035535.GA7011@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, yoshfuji@linux-ipv6.org,
	yjwei@cn.fujitsu.com, vladislav.yasevich@hp.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@trash.net, eric.dumazet@gmail.com, sri@us.ibm.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34543
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752052Ab0DVFsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 01:48:42 -0400
In-Reply-To: <20100419035535.GA7011@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 19 Apr 2010 11:55:35 +0800

> On Mon, Apr 19, 2010 at 10:58:22AM +0800, Shan Wei wrote:
>> 
>> According to RFC2460, PMTU is set to the IPv6 Minimum Link
>> MTU (1280) and a fragment header should always be included
>> after a node receiving Too Big message reporting PMTU is
>> less than the IPv6 Minimum Link MTU.
>> 
>> After receiving a ICMPv6 Too Big message reporting PMTU is
>> less than the IPv6 Minimum Link MTU, sctp *can't* send any
>> data/control chunk that total length including IPv6 head 
>> and IPv6 extend head is less than IPV6_MIN_MTU(1280 bytes).
>> 
>> The failure occured in p6_fragment(), about reason 
>> see following(take SHUTDOWN chunk for example):
>> sctp_packet_transmit (SHUTDOWN chunk, len=16 byte)
>> |------sctp_v6_xmit (local_df=0)
>>    |------ip6_xmit
>>        |------ip6_output (dst_allfrag is ture)
>>            |------ip6_fragment
>> 
>> In ip6_fragment(), for local_df=0, drops the the packet
>> and returns EMSGSIZE.
>> 
>> The patch fixes it with adding check length of skb->len.
>> In this case, Ipv6 not to fragment upper protocol data,
>> just only add a fragment header before it. 
>> 
>> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> 
> The patch looks good to me.
> 
> If we wanted to optimise the allfrags case it may be better
> to reserve the space beforehand and generate the fragment header
> at the same time as we're doing the IPv6 header.
> 
> But it can't be all that important as it's been broken for so
> many years.

Right, I've applied Shan's patch, thanks.
