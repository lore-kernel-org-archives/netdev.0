From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 07/12] openvswitch: Use ether_addr_copy
Date: Fri, 16 May 2014 14:07:34 -0700
Message-ID: <1400274459-56304-8-git-send-email-jesse@nicira.com>
References: <1400274459-56304-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1400274459-56304-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

It's slightly smaller/faster for some architectures.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/actions.c      |  4 ++--
 net/openvswitch/flow.c         | 16 ++++++++--------
 net/openvswitch/flow_netlink.c | 12 ++++++------
 3 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 2c77e7b..c36856a 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -134,8 +134,8 @@ static int set_eth_addr(struct sk_buff *skb,
 
 	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_ALEN * 2);
 
-	memcpy(eth_hdr(skb)->h_source, eth_key->eth_src, ETH_ALEN);
-	memcpy(eth_hdr(skb)->h_dest, eth_key->eth_dst, ETH_ALEN);
+	ether_addr_copy(eth_hdr(skb)->h_source, eth_key->eth_src);
+	ether_addr_copy(eth_hdr(skb)->h_dest, eth_key->eth_dst);
 
 	ovs_skb_postpush_rcsum(skb, eth_hdr(skb), ETH_ALEN * 2);
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 2998989..332aa01 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -372,14 +372,14 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
 			    && opt_len == 8) {
 				if (unlikely(!is_zero_ether_addr(key->ipv6.nd.sll)))
 					goto invalid;
-				memcpy(key->ipv6.nd.sll,
-				    &nd->opt[offset+sizeof(*nd_opt)], ETH_ALEN);
+				ether_addr_copy(key->ipv6.nd.sll,
+						&nd->opt[offset+sizeof(*nd_opt)]);
 			} else if (nd_opt->nd_opt_type == ND_OPT_TARGET_LL_ADDR
 				   && opt_len == 8) {
 				if (unlikely(!is_zero_ether_addr(key->ipv6.nd.tll)))
 					goto invalid;
-				memcpy(key->ipv6.nd.tll,
-				    &nd->opt[offset+sizeof(*nd_opt)], ETH_ALEN);
+				ether_addr_copy(key->ipv6.nd.tll,
+						&nd->opt[offset+sizeof(*nd_opt)]);
 			}
 
 			icmp_len -= opt_len;
@@ -439,8 +439,8 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 	 * header in the linear data area.
 	 */
 	eth = eth_hdr(skb);
-	memcpy(key->eth.src, eth->h_source, ETH_ALEN);
-	memcpy(key->eth.dst, eth->h_dest, ETH_ALEN);
+	ether_addr_copy(key->eth.src, eth->h_source);
+	ether_addr_copy(key->eth.dst, eth->h_dest);
 
 	__skb_pull(skb, 2 * ETH_ALEN);
 	/* We are going to push all headers that we pull, so no need to
@@ -538,8 +538,8 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 				key->ip.proto = ntohs(arp->ar_op);
 			memcpy(&key->ipv4.addr.src, arp->ar_sip, sizeof(key->ipv4.addr.src));
 			memcpy(&key->ipv4.addr.dst, arp->ar_tip, sizeof(key->ipv4.addr.dst));
-			memcpy(key->ipv4.arp.sha, arp->ar_sha, ETH_ALEN);
-			memcpy(key->ipv4.arp.tha, arp->ar_tha, ETH_ALEN);
+			ether_addr_copy(key->ipv4.arp.sha, arp->ar_sha);
+			ether_addr_copy(key->ipv4.arp.tha, arp->ar_tha);
 		}
 	} else if (key->eth.type == htons(ETH_P_IPV6)) {
 		int nh_len;             /* IPv6 Header + Extensions */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 7bd09b7..5511ad1 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -986,8 +986,8 @@ int ovs_nla_put_flow(const struct sw_flow_key *swkey,
 		goto nla_put_failure;
 
 	eth_key = nla_data(nla);
-	memcpy(eth_key->eth_src, output->eth.src, ETH_ALEN);
-	memcpy(eth_key->eth_dst, output->eth.dst, ETH_ALEN);
+	ether_addr_copy(eth_key->eth_src, output->eth.src);
+	ether_addr_copy(eth_key->eth_dst, output->eth.dst);
 
 	if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
 		__be16 eth_type;
@@ -1059,8 +1059,8 @@ int ovs_nla_put_flow(const struct sw_flow_key *swkey,
 		arp_key->arp_sip = output->ipv4.addr.src;
 		arp_key->arp_tip = output->ipv4.addr.dst;
 		arp_key->arp_op = htons(output->ip.proto);
-		memcpy(arp_key->arp_sha, output->ipv4.arp.sha, ETH_ALEN);
-		memcpy(arp_key->arp_tha, output->ipv4.arp.tha, ETH_ALEN);
+		ether_addr_copy(arp_key->arp_sha, output->ipv4.arp.sha);
+		ether_addr_copy(arp_key->arp_tha, output->ipv4.arp.tha);
 	}
 
 	if ((swkey->eth.type == htons(ETH_P_IP) ||
@@ -1147,8 +1147,8 @@ int ovs_nla_put_flow(const struct sw_flow_key *swkey,
 				nd_key = nla_data(nla);
 				memcpy(nd_key->nd_target, &output->ipv6.nd.target,
 							sizeof(nd_key->nd_target));
-				memcpy(nd_key->nd_sll, output->ipv6.nd.sll, ETH_ALEN);
-				memcpy(nd_key->nd_tll, output->ipv6.nd.tll, ETH_ALEN);
+				ether_addr_copy(nd_key->nd_sll, output->ipv6.nd.sll);
+				ether_addr_copy(nd_key->nd_tll, output->ipv6.nd.tll);
 			}
 		}
 	}
-- 
1.9.1
