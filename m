From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH BUGFIX ] ipv6: fix the bug of address check
Date: Mon, 17 May 2010 10:31:34 -0700
Message-ID: <20100517103134.06160257@nehalam>
References: <4BF1354A.3060003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42235 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754244Ab0EQRbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 13:31:40 -0400
In-Reply-To: <4BF1354A.3060003@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 May 2010 20:23:38 +0800
Shan Wei <shanwei@cn.fujitsu.com> wrote:

> 
> If there are several IPv6 addresses with same hash value in hashlist,
> and they are all not matched with addr argument.
> In this case, ipv6_chk_addr() should return 0.
> 
> This bug is introduced by commit c2e21293c054817c42eb5fa9c613d2ad51954136
> (title: ipv6: convert addrconf list to hlist).
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
>  net/ipv6/addrconf.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 3984f52..d8e5907 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1291,7 +1291,7 @@ int ipv6_chk_addr(struct net *net, struct in6_addr *addr,
>  	}
>  	rcu_read_unlock_bh();
>  
> -	return ifp != NULL;
> +	return node != NULL;
>  }
>  EXPORT_SYMBOL(ipv6_chk_addr);
>  

Why not this instead. I don't like depending on the value of the
loop variable in the hlist_for_each()

--- a/net/ipv6/addrconf.c	2010-05-17 10:27:58.218628126 -0700
+++ b/net/ipv6/addrconf.c	2010-05-17 10:29:46.012198338 -0700
@@ -1274,7 +1274,7 @@ static int ipv6_count_addresses(struct i
 int ipv6_chk_addr(struct net *net, struct in6_addr *addr,
 		  struct net_device *dev, int strict)
 {
-	struct inet6_ifaddr *ifp = NULL;
+	struct inet6_ifaddr *ifp;
 	struct hlist_node *node;
 	unsigned int hash = ipv6_addr_hash(addr);
 
@@ -1283,15 +1283,16 @@ int ipv6_chk_addr(struct net *net, struc
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr) &&
-		    !(ifp->flags&IFA_F_TENTATIVE)) {
-			if (dev == NULL || ifp->idev->dev == dev ||
-			    !(ifp->scope&(IFA_LINK|IFA_HOST) || strict))
-				break;
+		    !(ifp->flags&IFA_F_TENTATIVE) &&
+		    (dev == NULL || ifp->idev->dev == dev ||
+		     !(ifp->scope&(IFA_LINK|IFA_HOST) || strict))) {
+			rcu_read_unlock_bh();
+			return 1;
 		}
 	}
-	rcu_read_unlock_bh();
 
-	return ifp != NULL;
+	rcu_read_unlock_bh();
+	return 0;
 }
 EXPORT_SYMBOL(ipv6_chk_addr);
 


-- 
