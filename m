From: Brian Haley <brian.haley@hp.com>
Subject: Re: OOPS, ip -f inet6 route get fec0::1, linux-2.6.26,	ip6_route_output,
 rt6_fill_node+0x175
Date: Fri, 08 Aug 2008 00:57:11 -0400
Message-ID: <489BD227.6000209@hp.com>
References: <9F6ACAE02B6DD040A1E259977622CFDB033590C3@oslexcp1.eu.tandberg.int> <20080807203748.GA5196@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030209010905020208020707"
Cc: John Gumb <john.gumb@tandberg.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:36559 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbYHHE5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 00:57:43 -0400
In-Reply-To: <20080807203748.GA5196@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030209010905020208020707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Alexey Dobriyan wrote:
> On Thu, Aug 07, 2008 at 07:00:56PM +0200, John Gumb wrote:
>> Scenario: no ipv6 default route set.
> 
>> # ip -f inet6 route get fec0::1
>>
>> BUG: unable to handle kernel NULL pointer dereference at 00000000
>> IP: [<c0369b85>] rt6_fill_node+0x175/0x3b0
>> EIP is at rt6_fill_node+0x175/0x3b0
> 
> 0xffffffff80424dd3 is in rt6_fill_node (net/ipv6/route.c:2191).
> 2186                    } else
> 2187    #endif
> 2188                            NLA_PUT_U32(skb, RTA_IIF, iif);
> 2189            } else if (dst) {
> 2190                    struct in6_addr saddr_buf;
> 2191      ====>         if (ipv6_dev_get_saddr(ip6_dst_idev(&rt->u.dst)->dev,
> 					       ^^^^^^^^^^^^^^^^^^^^^^^^
> 					       		NULL
> 
> 2192                                           dst, 0, &saddr_buf) == 0)
> 2193                            NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
> 2194            }

The commit that changed this can't be reverted easily, but the patch 
below works for me.

Fix NULL de-reference in rt6_fill_node() when there's no IPv6 input 
device present in the dst entry.

Signed-off-by: Brian Haley <brian.haley@hp.com>



--------------030209010905020208020707
Content-Type: text/x-patch;
 name="idev.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="idev.patch"

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5a3e87e..303a245 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2188,7 +2188,8 @@ static int rt6_fill_node(struct sk_buff *skb, struct rt6_info *rt,
 			NLA_PUT_U32(skb, RTA_IIF, iif);
 	} else if (dst) {
 		struct in6_addr saddr_buf;
-		if (ipv6_dev_get_saddr(ip6_dst_idev(&rt->u.dst)->dev,
+		struct inet6_dev *idev = ip6_dst_idev(&rt->u.dst);
+		if (ipv6_dev_get_saddr(idev ? idev->dev : NULL,
 				       dst, 0, &saddr_buf) == 0)
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}

--------------030209010905020208020707--
