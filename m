From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 08/15] ipv4: Kill routes during PMTU/redirect updates.
Date: Wed, 18 Jul 2012 12:15:44 -0700
Message-ID: <1342638944.2013.10.camel@joe2Laptop>
References: <20120718.112356.1409220904008377845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41951 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753282Ab2GRTPp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 15:15:45 -0400
In-Reply-To: <20120718.112356.1409220904008377845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 11:23 -0700, David Miller wrote:
> Mark them obsolete so there will be a re-lookup to fetch the
> FIB nexthop exception info.
[]
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
[]
> @@ -716,8 +717,8 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
>  					fnhe->fnhe_gw = new_gw;
>  				spin_unlock_bh(&fnhe_lock);
>  			}
> -			rt->rt_gateway = new_gw;
> -			rt->rt_flags |= RTCF_REDIRECTED;
> +			if (kill_route)
> +				rt->dst.obsolete = -2;

Perhaps -2 should be a #define?

Perhaps struct dst_entry.obsolete could be a char instead of
a short and a pad byte could added for some future use.

Maybe:

 include/net/dst.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 5161046..6c40490 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -65,7 +65,8 @@ struct dst_entry {
 	unsigned short		pending_confirm;
 
 	short			error;
-	short			obsolete;
+	char			obsolete;
+	char			__pad3;
 	unsigned short		header_len;	/* more space at head required */
 	unsigned short		trailer_len;	/* space to reserve at tail */
 #ifdef CONFIG_IP_ROUTE_CLASSID
