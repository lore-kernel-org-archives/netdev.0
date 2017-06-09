From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net v2] net: ipmr: Fix some mroute forwarding issues in
 vrf's
Date: Fri, 9 Jun 2017 08:54:05 -0600
Message-ID: <212ffd99-b2aa-3fad-b042-2b4b0435223d@gmail.com>
References: <20170609142259.24423-1-sharpd@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Donald Sharp <sharpd@cumulusnetworks.com>, netdev@vger.kernel.org,
        Thomas.Winter@alliedtelesis.co.nz, nikolay@cumulusnetworks.com,
        yotamg@mellanox.com, idosch@mellanox.com, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36461 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751646AbdFIOyI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 10:54:08 -0400
Received: by mail-pf0-f193.google.com with SMTP id y7so8802231pfd.3
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 07:54:08 -0700 (PDT)
In-Reply-To: <20170609142259.24423-1-sharpd@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/9/17 8:22 AM, Donald Sharp wrote:
> @@ -988,7 +988,16 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
>  
>  			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
>  		} else {
> -			ip_mr_forward(net, mrt, skb, c, 0);
> +                        struct net_device *dev = skb->dev;
> +
> +                        if (netif_is_l3_master(dev)) {
> +                                dev = __dev_get_by_index(net, IPCB(skb)->iif);
> +                                if (!dev) {
> +                                        kfree_skb(skb);
> +                                        continue;
> +                                }
> +                        }
> +                        ip_mr_forward(net, mrt, dev, skb, c, 0);
>  		}
>  	}
>  }

What about changing ipmr_cache_unresolved to take the dev it looked up
already and then have ipmr_cache_unresolved reset skb->dev to it (and
reset skb->skb_iff to dev->ifindex) when queuing to the unresolved list?
Since this path does not have a local delivery, resetting the skb->dev
will be fine and it avoids this second lookup using IPCB(skb)->iif:

@@ -1073,7 +1073,7 @@ static int ipmr_cache_report(struct mr_table *mrt,

 /* Queue a packet for resolution. It gets locked cache entry! */
 static int ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi,
-                                struct sk_buff *skb)
+                                struct sk_buff *skb, struct net_device
*dev)
 {
        const struct iphdr *iph = ip_hdr(skb);
        struct mfc_cache *c;
@@ -1130,6 +1130,10 @@ static int ipmr_cache_unresolved(struct mr_table
*mrt, vifi_t vifi,
                kfree_skb(skb);
                err = -ENOBUFS;
        } else {
+               if (dev) {
+                       skb->dev = dev;
+                       skb->skb_iif = dev->ifindex;
+               }
                skb_queue_tail(&c->mfc_un.unres.unresolved, skb);
                err = 0;
        }


Combined with Thomas' earlier change this check in ip_mr_forward becomes:

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 9374b99c7c17..1393a4d18a9a 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1853,13 +1853,7 @@ static void ip_mr_forward(struct net *net, struct
mr_table *mrt,
        }

        /* Wrong interface: drop packet and (maybe) send PIM assert. */
-       if (mrt->vif_table[vif].dev != skb->dev) {
-               struct net_device *mdev;
-
-               mdev = l3mdev_master_dev_rcu(mrt->vif_table[vif].dev);
-               if (mdev == skb->dev)
-                       goto forward;
-
+       if (mrt->vif_table[vif].dev != dev) {
                if (rt_is_output_route(skb_rtable(skb))) {
                        /* It is our own packet, looped back.
                         * Very complicated situation...
