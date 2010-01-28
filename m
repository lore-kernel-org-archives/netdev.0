From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Subject: Re: [PATCH] sctp: IPsec rules are ineffective with ipv6
Date: Thu, 28 Jan 2010 16:41:59 +0100
Message-ID: <4B61B047.10908@dev.6wind.com>
References: <4B6049EB.8030803@dev.6wind.com> <20100128.055148.127214200.davem@davemloft.net> <4B61AC22.2050907@hp.com>
Reply-To: nicolas.dichtel@dev.6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030602040500020400070202"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:43294 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755328Ab0A1PmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2010 10:42:10 -0500
In-Reply-To: <4B61AC22.2050907@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030602040500020400070202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

What about this one?

Only compilation tested.

xfrm_lookup() is missing in IPv6 output path. Call it when dst is build. Initial 
patch was written by Junwei Zhang <junwei.zhang@6wind.com>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Le 28.01.2010 16:24, Vlad Yasevich a écrit :
> 
> David Miller wrote:
>> From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
>> Date: Wed, 27 Jan 2010 15:12:59 +0100
>>
>>> xfrm_lookup() is missing in sctp_v6_xmit(), add it.
>>>
>>> Signed-off-by: Junwei Zhang <junwei.zhang@6wind.com>
>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Doing this every transmit packet is overkill.
>>
>> Whatever calculates the route that ends up in skb_dst(skb)
>> should be making this xfrm_lookup() call, not here.
>>
> 
> 
> Hmm.. Interesting.  Looks like ip_route_output_key() will
> do xfrm_lookup for you, but there is no ipv6 route lookup call
> that will do the same thing.
> 
> I guess we'll need to add an xfrm_lookup call in sctp_v6_get_dst().
> 
> -vlad

--------------030602040500020400070202
Content-Type: text/x-diff;
 name="x2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x2.diff"

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index cc50fbe..4081ffb 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -258,13 +258,14 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 	}
 
 	dst = ip6_route_output(&init_net, NULL, &fl);
-	if (!dst->error) {
-		struct rt6_info *rt;
-		rt = (struct rt6_info *)dst;
-		SCTP_DEBUG_PRINTK("rt6_dst:%pI6 rt6_src:%pI6\n",
-			&rt->rt6i_dst.addr, &rt->rt6i_src.addr);
-		return dst;
-	}
+	if (!dst->error)
+		if (xfrm_lookup(&init_net, &dst, &fl, asoc ? asoc->base.sk : NULL, 0) >= 0) {
+			struct rt6_info *rt;
+			rt = (struct rt6_info *)dst;
+			SCTP_DEBUG_PRINTK("rt6_dst:%pI6 rt6_src:%pI6\n",
+				&rt->rt6i_dst.addr, &rt->rt6i_src.addr);
+			return dst;
+		}
 	SCTP_DEBUG_PRINTK("NO ROUTE\n");
 	dst_release(dst);
 	return NULL;

--------------030602040500020400070202--
