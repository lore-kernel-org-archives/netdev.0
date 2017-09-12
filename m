From: oc <oc@yunify.com>
Subject: Subject: [PATCH] vxlan: only reduce known arp boardcast request to
 support, virtual IP
Date: Tue, 12 Sep 2017 11:26:49 +0800
Message-ID: <2c1bfd7d-5fe7-d492-2396-71deaeb14244@yunify.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jbenc@redhat.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        oc@yunify.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [139.198.2.84] ([139.198.2.84]:48776 "EHLO yunify.com"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751004AbdILDcM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 11 Sep 2017 23:32:12 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The purpose of vxlan arp reduce feature is to reply the boardcast
arp request in vtep instead of sending it out to save traffic.
The current implemention drops arp packet, if the ip cannot be
found in neigh table. In the case of virtual IP address, user
defines IP address without management from SDN controller. The IP
address does not exist in neigh table, so the arp boardcast request
from a client can not be sent to the server who owns the virtual IP
address.

This patch allow the arp request to be sent out if:
1. not arp boardcast request
2. cannot be found in neigh table
3. arp record status is not NUD_CONNECTED

The user defined of virtual IP address works while arp reduce still
suppress the arp boardcast for IP address managed by SDN controller
with this patch.

Signed-off-by: Chen Haiquan <oc@yunify.com>
---
  drivers/net/vxlan.c | 26 +++++++++++++++++++-------
  1 file changed, 19 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d7c49cf1d5e9..913b838b260b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1473,7 +1473,7 @@ static int arp_reduce(struct net_device *dev, 
struct sk_buff *skb, __be32 vni)
          parp->ar_op != htons(ARPOP_REQUEST) ||
          parp->ar_hln != dev->addr_len ||
          parp->ar_pln != 4)
-        goto out;
+        return 1;
      arpptr = (u8 *)parp + sizeof(struct arphdr);
      sha = arpptr;
      arpptr += dev->addr_len;    /* sha */
@@ -1494,7 +1494,7 @@ static int arp_reduce(struct net_device *dev, 
struct sk_buff *skb, __be32 vni)

          if (!(n->nud_state & NUD_CONNECTED)) {
              neigh_release(n);
-            goto out;
+            return 1;
          }

          f = vxlan_find_mac(vxlan, n->ha, vni);
@@ -1526,6 +1526,10 @@ static int arp_reduce(struct net_device *dev, 
struct sk_buff *skb, __be32 vni)
          };

          vxlan_ip_miss(dev, &ipa);
+        return 1;
+    } else {
+        /* broadcast unknown arp */
+        return 1;
      }
  out:
      consume_skb(skb);
@@ -1642,7 +1646,7 @@ static int neigh_reduce(struct net_device *dev, 
struct sk_buff *skb, __be32 vni)
      msg = (struct nd_msg *)(iphdr + 1);
      if (msg->icmph.icmp6_code != 0 ||
          msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION)
-        goto out;
+        return 1;

      if (ipv6_addr_loopback(daddr) ||
          ipv6_addr_is_multicast(&msg->target))
@@ -1656,7 +1660,7 @@ static int neigh_reduce(struct net_device *dev, 
struct sk_buff *skb, __be32 vni)

          if (!(n->nud_state & NUD_CONNECTED)) {
              neigh_release(n);
-            goto out;
+            return 1;
          }

          f = vxlan_find_mac(vxlan, n->ha, vni);
@@ -1684,6 +1688,10 @@ static int neigh_reduce(struct net_device *dev, 
struct sk_buff *skb, __be32 vni)
          };

          vxlan_ip_miss(dev, &ipa);
+        return 1;
+    } else {
+        /* broadcast unknown neigh */
+        return 1;
      }

  out:
@@ -2266,8 +2274,10 @@ static netdev_tx_t vxlan_xmit(struct sk_buff 
*skb, struct net_device *dev)

      if (vxlan->cfg.flags & VXLAN_F_PROXY) {
          eth = eth_hdr(skb);
-        if (ntohs(eth->h_proto) == ETH_P_ARP)
-            return arp_reduce(dev, skb, vni);
+        if (ntohs(eth->h_proto) == ETH_P_ARP){
+            if (NETDEV_TX_OK == arp_reduce(dev, skb, vni))
+                return NETDEV_TX_OK;
+        }
  #if IS_ENABLED(CONFIG_IPV6)
          else if (ntohs(eth->h_proto) == ETH_P_IPV6) {
              struct ipv6hdr *hdr, _hdr;
@@ -2275,7 +2285,9 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, 
struct net_device *dev)
                                skb_network_offset(skb),
                                sizeof(_hdr), &_hdr)) &&
                  hdr->nexthdr == IPPROTO_ICMPV6)
-                return neigh_reduce(dev, skb, vni);
+                if (NETDEV_TX_OK == neigh_reduce(dev,
+                                 skb, vni))
+                    return NETDEV_TX_OK;
          }
  #endif
      }
-- 
2.7.4
