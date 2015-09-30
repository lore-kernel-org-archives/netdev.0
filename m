From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 1/6] openvswitch: Pass net into ovs_vport_output
Date: Wed, 30 Sep 2015 16:25:31 -0500
Message-ID: <1443648336-31741-1-git-send-email-ebiederm@xmission.com>
References: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When struct net starts being passed through the ipv4 and ipv6 fragment
routines ovs_vport_output will need to take a net parameter.
Prepare ovs_vport_output before that is needed and introduce
ovs_vport_output_skk for the call sites that still need the old
calling conventions.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/openvswitch/actions.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 315f5330b6e5..f00c641ecd93 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -620,7 +620,7 @@ static int set_sctp(struct sk_buff *skb, struct sw_flow_key *flow_key,
 	return 0;
 }
 
-static int ovs_vport_output(struct sock *sock, struct sk_buff *skb)
+static int ovs_vport_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct ovs_frag_data *data = this_cpu_ptr(&ovs_frag_data_storage);
 	struct vport *vport = data->vport;
@@ -645,6 +645,11 @@ static int ovs_vport_output(struct sock *sock, struct sk_buff *skb)
 	ovs_vport_send(vport, skb);
 	return 0;
 }
+static int ovs_vport_output_sk(struct sock *sk, struct sk_buff *skb)
+{
+	struct net *net = dev_net(skb_dst(skb)->dev);
+	return ovs_vport_output(net, sk, skb);
+}
 
 static unsigned int
 ovs_dst_get_mtu(const struct dst_entry *dst)
@@ -700,7 +705,7 @@ static void ovs_fragment(struct vport *vport, struct sk_buff *skb, u16 mru,
 		skb_dst_set_noref(skb, &ovs_dst);
 		IPCB(skb)->frag_max_size = mru;
 
-		ip_do_fragment(skb->sk, skb, ovs_vport_output);
+		ip_do_fragment(skb->sk, skb, ovs_vport_output_sk);
 		refdst_drop(orig_dst);
 	} else if (ethertype == htons(ETH_P_IPV6)) {
 		const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
@@ -722,7 +727,7 @@ static void ovs_fragment(struct vport *vport, struct sk_buff *skb, u16 mru,
 		skb_dst_set_noref(skb, &ovs_rt.dst);
 		IP6CB(skb)->frag_max_size = mru;
 
-		v6ops->fragment(skb->sk, skb, ovs_vport_output);
+		v6ops->fragment(skb->sk, skb, ovs_vport_output_sk);
 		refdst_drop(orig_dst);
 	} else {
 		WARN_ONCE(1, "Failed fragment ->%s: eth=%04x, MRU=%d, MTU=%d.",
-- 
2.2.1

