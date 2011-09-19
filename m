From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: PATCH Question, Firewall mark inherit for ip6_tunnel
Date: Mon, 19 Sep 2011 10:47:28 +0200
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903109@ESESSCMS0356.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:55488 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790Ab1ISJCb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 05:02:31 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,
For a year ago you send an untested patch to Anders Franzen 
I think the subject was "not possible to do policy routing for next hop on tunnels."

The patch have been used since that and it works perfectly,
I made some minor changes to reflect the flowi changes.

Would it be possible for you to submit that patch, since (I guess) you are the author 
I can prepare it if you want.
The included patch is for  linux-3.0.4

Regards
Hans Schillstrom

diff --git a/include/linux/ip6_tunnel.h b/include/linux/ip6_tunnel.h
index acb9ad6..bf22b03 100644
--- a/include/linux/ip6_tunnel.h
+++ b/include/linux/ip6_tunnel.h
@@ -16,6 +16,8 @@
 #define IP6_TNL_F_MIP6_DEV 0x8
 /* copy DSCP from the outer packet */
 #define IP6_TNL_F_RCV_DSCP_COPY 0x10
+/* copy fwmark from inner packet */
+#define IP6_TNL_F_USE_ORIG_FWMARK 0x20
 
 struct ip6_tnl_parm {
        char name[IFNAMSIZ];    /* name of tunnel device */
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 36c2842..64be21c 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -897,7 +897,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
        int err = -1;
        int pkt_len;
 
-       if ((dst = ip6_tnl_dst_check(t)) != NULL)                                                                                                        
+       if (!fl6->flowi6_mark && (dst = ip6_tnl_dst_check(t)) != NULL)                                                                                   
                dst_hold(dst);                                                                                                                           
        else {                                                                                                                                           
                dst = ip6_route_output(net, NULL, fl6);                                                                                                  
@@ -955,7 +955,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,                                                                                        
                skb = new_skb;                                                                                                                           
        }                                                                                                                                                
        skb_dst_drop(skb);                                                                                                                               
-       skb_dst_set(skb, dst_clone(dst));                                                                                                                
+       skb_dst_set(skb, fl6->flowi6_mark ? dst : dst_clone(dst));                                                                                       
                                                                                                                                                         
        skb->transport_header = skb->network_header;                                                                                                     
                                                                                                                                                         
@@ -987,7 +987,9 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,                                                                                        
                stats->tx_errors++;                                                                                                                      
                stats->tx_aborted_errors++;                                                                                                              
        }                                                                                                                                                
-       ip6_tnl_dst_store(t, dst);                                                                                                                       
+       if (!fl6->flowi6_mark)                                                                                                                           
+               ip6_tnl_dst_store(t, dst);                                                                                                               
+                                                                                                                                                        
        return 0;                                                                                                                                        
 tx_err_link_failure:
        stats->tx_carrier_errors++;
@@ -1023,6 +1025,8 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
        if ((t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS))
                fl6.flowlabel |= htonl((__u32)iph->tos << IPV6_TCLASS_SHIFT)
                                          & IPV6_TCLASS_MASK;
+       if ((t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK))
+               fl6.flowi6_mark = skb->mark;
 
        err = ip6_tnl_xmit2(skb, dev, dsfield, &fl6, encap_limit, &mtu);
        if (err != 0) {
@@ -1073,7 +1077,8 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
                fl6.flowlabel |= (*(__be32 *) ipv6h & IPV6_TCLASS_MASK);
        if ((t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL))
                fl6.flowlabel |= (*(__be32 *) ipv6h & IPV6_FLOWLABEL_MASK);
-
+       if ((t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK))
+               fl6.flowi6_mark = skb->mark;
        err = ip6_tnl_xmit2(skb, dev, dsfield, &fl6, encap_limit, &mtu);
        if (err != 0) {
                if (err == -EMSGSIZE)
-- 
1.7.4.4
