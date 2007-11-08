From: osprey67 <osprey67@yahoo.com>
Subject: [PATCH 04/05] ipv6: RFC4214 Support (2)
Date: Thu, 08 Nov 2007 12:41:48 -0800
Message-ID: <4733748C.70602@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp128.plus.mail.mud.yahoo.com ([209.191.106.159]:38394 "HELO
	smtp128.plus.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1760662AbXKHUlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 15:41:51 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fred L. Templin <osprey67@yahoo.com>

This is experimental support for the Intra-Site Automatic
Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
the SIT module, and is configured using the unmodified
"ip" utility with device names beginning with: "isatap".

The following diffs are specific to the Linux 2.6.24-rc2
kernel distribution.

Signed-off-by: Fred L. Templin <osprey67@yahoo.com>

---

--- linux-2.6.24-rc2/net/ipv6/sit.c.orig        2007-11-08 12:03:41.000000000 -0800
+++ linux-2.6.24-rc2/net/ipv6/sit.c     2007-11-08 08:31:08.000000000 -0800
@@ -16,6 +16,7 @@
   *     Changes:
   * Roger Venning <r.venning@telstra.com>:      6to4 support
   * Nate Thompson <nate@thebog.net>:            6to4 support
+ * Fred L. Templin <fltemplin@acm.org>:                isatap support
   */

  #include <linux/module.h>
@@ -154,6 +155,14 @@ static struct ip_tunnel * ipip6_tunnel_l
         struct net_device *dev;
         char name[IFNAMSIZ];

+#if defined(CONFIG_IPV6_ISATAP)
+       /* ISATAP (RFC4214) - router address in daddr */
+       if (!strncmp(parms->name, "isatap", 6)) {
+               parms->i_key = parms->iph.daddr;
+               parms->iph.daddr = remote = 0;
+       }
+#endif
+
         for (tp = __ipip6_bucket(parms); (t = *tp) != NULL; tp = &t->next) {
                 if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr)
                         return t;
@@ -182,6 +191,11 @@ static struct ip_tunnel * ipip6_tunnel_l
         dev->init = ipip6_tunnel_init;
         nt->parms = *parms;

+#if defined(CONFIG_IPV6_ISATAP)
+       if (!strncmp(dev->name, "isatap", 6))
+               dev->priv_flags |= IFF_ISATAP;
+#endif
+
         if (register_netdevice(dev) < 0) {
                 free_netdev(dev);
                 goto failed;
@@ -382,6 +396,47 @@ static int ipip6_rcv(struct sk_buff *skb
                 IPCB(skb)->flags = 0;
                 skb->protocol = htons(ETH_P_IPV6);
                 skb->pkt_type = PACKET_HOST;
+#if defined(CONFIG_IPV6_ISATAP)
+               /* ISATAP (RFC4214) - check source address */
+               if (tunnel->dev->priv_flags & IFF_ISATAP) {
+                       struct neighbour *neigh;
+                       struct dst_entry *dst;
+                       struct flowi fl;
+                       struct in6_addr *addr6;
+                       struct ipv6hdr *iph6;
+
+                       /* from ISATAP router */
+                       if (iph->saddr == tunnel->parms.i_key) goto accept;
+
+                       iph6 = ipv6_hdr(skb);
+                       addr6 = &iph6->saddr;
+
+                       /* from legitimate previous hop */
+                       memset(&fl, 0, sizeof(fl));
+                       fl.proto = iph6->nexthdr;
+                       ipv6_addr_copy(&fl.fl6_dst, addr6);
+                       fl.oif = tunnel->dev->ifindex;
+                       security_skb_classify_flow(skb, &fl);
+
+                       if (!(dst = ip6_route_output(NULL, &fl)) ||
+                            (dst->dev != tunnel->dev) ||
+                            ((neigh = dst->neighbour) == NULL)) goto drop;
+
+                       addr6 = (struct in6_addr*)&neigh->primary_key;
+
+                       if (!(ipv6_addr_is_isatap(addr6)) ||
+                            (addr6->s6_addr32[3] != iph->saddr)) {
+drop:
+                               tunnel->stat.rx_errors++;
+                               read_unlock(&ipip6_lock);
+                               dst_release(dst);
+                               kfree_skb(skb);
+                               return 0;
+                       }
+                       dst_release(dst);
+               }
+accept:
+#endif
                 tunnel->stat.rx_packets++;
                 tunnel->stat.rx_bytes += skb->len;
                 skb->dev = tunnel->dev;
@@ -444,6 +499,31 @@ static int ipip6_tunnel_xmit(struct sk_b
         if (skb->protocol != htons(ETH_P_IPV6))
                 goto tx_error;

+#if defined(CONFIG_IPV6_ISATAP)
+       /* ISATAP (RFC4214) - must come before 6to4 */
+       if (dev->priv_flags & IFF_ISATAP) {
+               struct neighbour *neigh = NULL;
+
+               if (skb->dst)
+                       neigh = skb->dst->neighbour;
+
+               if (neigh == NULL) {
+                       if (net_ratelimit())
+                               printk(KERN_DEBUG "sit: nexthop == NULL\n");
+                       goto tx_error;
+               }
+
+               addr6 = (struct in6_addr*)&neigh->primary_key;
+               addr_type = ipv6_addr_type(addr6);
+
+               if ((addr_type & IPV6_ADDR_UNICAST) &&
+                    ipv6_addr_is_isatap(addr6))
+                       dst = addr6->s6_addr32[3];
+               else
+                       goto tx_error;
+       }
+#endif /* CONFIG_IPV6_ISATAP */
+
         if (!dst)
                 dst = try_6to4(&iph6->daddr);

