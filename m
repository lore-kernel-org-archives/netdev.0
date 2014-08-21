From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net] openvswitch: fix panic with multiple vlan
	headers
Date: Thu, 21 Aug 2014 21:33:44 +0200
Message-ID: <b490744c980813b54d54f628c719e03cdb143302.1408649593.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
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

When there are multiple vlan headers present in a received frame, the first
one is put into vlan_tci and protocol is set to ETH_P_8021Q. Anything in the
skb beyond the VLAN TPID may be still non-linear, including the inner TCI
and ethertype. While ovs_flow_extract takes care of IP and IPv6 headers, it
does nothing with ETH_P_8021Q. Later, if OVS_ACTION_ATTR_POP_VLAN is
executed, __pop_vlan_tci pulls the next vlan header into vlan_tci.

This leads to two things:

1. Part of the resulting ethernet header is in the non-linear part of the
   skb. When eth_type_trans is called later as the result of
   OVS_ACTION_ATTR_OUTPUT, kernel BUGs in __skb_pull. Also, __pop_vlan_tci
   is in fact accessing random data when it reads past the TPID.

2. network_header points into the ethernet header instead of behind it.
   mac_len is set to a wrong value (10), too.

Reported-by: Yulong Pei <ypei-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/actions.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index fe5cda0deb39..5231652a95d9 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -42,6 +42,9 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 
 static int make_writable(struct sk_buff *skb, int write_len)
 {
+	if (!pskb_may_pull(skb, write_len))
+		return -ENOMEM;
+
 	if (!skb_cloned(skb) || skb_clone_writable(skb, write_len))
 		return 0;
 
@@ -70,6 +73,8 @@ static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
 
 	vlan_set_encap_proto(skb, vhdr);
 	skb->mac_header += VLAN_HLEN;
+	if (skb_network_offset(skb) < ETH_HLEN)
+		skb_set_network_header(skb, ETH_HLEN);
 	skb_reset_mac_len(skb);
 
 	return 0;
-- 
1.8.3.1
