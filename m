From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 2/2] geneve: Add Geneve GRO support
Date: Tue, 30 Dec 2014 19:10:16 -0800
Message-ID: <1419995416-29987-2-git-send-email-jesse@nicira.com>
References: <1419995416-29987-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Joe Stringer <joestringer@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:36672 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751374AbaLaDK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 22:10:26 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so20467667pad.41
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 19:10:25 -0800 (PST)
In-Reply-To: <1419995416-29987-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>

This results in an approximately 30% increase in throughput
when handling encapsulated bulk traffic.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/ipv4/geneve.c | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 95 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 394a200..19e256e 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -149,6 +149,99 @@ int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
 }
 EXPORT_SYMBOL_GPL(geneve_xmit_skb);
 
+static int geneve_hlen(struct genevehdr *gh)
+{
+	return sizeof(*gh) + gh->opt_len * 4;
+}
+
+static struct sk_buff **geneve_gro_receive(struct sk_buff **head,
+					   struct sk_buff *skb)
+{
+	struct sk_buff *p, **pp = NULL;
+	struct genevehdr *gh, *gh2;
+	unsigned int hlen, gh_len, off_gnv;
+	const struct packet_offload *ptype;
+	__be16 type;
+	int flush = 1;
+
+	off_gnv = skb_gro_offset(skb);
+	hlen = off_gnv + sizeof(*gh);
+	gh = skb_gro_header_fast(skb, off_gnv);
+	if (skb_gro_header_hard(skb, hlen)) {
+		gh = skb_gro_header_slow(skb, hlen, off_gnv);
+		if (unlikely(!gh))
+			goto out;
+	}
+
+	if (gh->ver != GENEVE_VER || gh->oam)
+		goto out;
+	gh_len = geneve_hlen(gh);
+
+	hlen = off_gnv + gh_len;
+	if (skb_gro_header_hard(skb, hlen)) {
+		gh = skb_gro_header_slow(skb, hlen, off_gnv);
+		if (unlikely(!gh))
+			goto out;
+	}
+
+	flush = 0;
+
+	for (p = *head; p; p = p->next) {
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		gh2 = (struct genevehdr *)(p->data + off_gnv);
+		if (gh->opt_len != gh2->opt_len ||
+		    memcmp(gh, gh2, gh_len)) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+	}
+
+	type = gh->proto_type;
+
+	rcu_read_lock();
+	ptype = gro_find_receive_by_type(type);
+	if (ptype == NULL) {
+		flush = 1;
+		goto out_unlock;
+	}
+
+	skb_gro_pull(skb, gh_len);
+	skb_gro_postpull_rcsum(skb, gh, gh_len);
+	pp = ptype->callbacks.gro_receive(head, skb);
+
+out_unlock:
+	rcu_read_unlock();
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	return pp;
+}
+
+static int geneve_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	struct genevehdr *gh;
+	struct packet_offload *ptype;
+	__be16 type;
+	int gh_len;
+	int err = -ENOSYS;
+
+	udp_tunnel_gro_complete(skb, nhoff);
+
+	gh = (struct genevehdr *)(skb->data + nhoff);
+	gh_len = geneve_hlen(gh);
+	type = gh->proto_type;
+
+	rcu_read_lock();
+	ptype = gro_find_complete_by_type(type);
+	if (ptype != NULL)
+		err = ptype->callbacks.gro_complete(skb, nhoff + gh_len);
+
+	rcu_read_unlock();
+	return err;
+}
+
 static void geneve_notify_add_rx_port(struct geneve_sock *gs)
 {
 	struct sock *sk = gs->sock->sk;
@@ -278,8 +371,8 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 
 	/* Initialize the geneve udp offloads structure */
 	gs->udp_offloads.port = port;
-	gs->udp_offloads.callbacks.gro_receive = NULL;
-	gs->udp_offloads.callbacks.gro_complete = NULL;
+	gs->udp_offloads.callbacks.gro_receive  = geneve_gro_receive;
+	gs->udp_offloads.callbacks.gro_complete = geneve_gro_complete;
 
 	spin_lock(&gn->sock_lock);
 	hlist_add_head_rcu(&gs->hlist, gs_head(net, port));
-- 
1.9.1
