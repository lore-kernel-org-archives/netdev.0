From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [nf-next PATCH] netfilter: Extend SYNPROXY with a --continue option
Date: Wed, 28 Aug 2013 17:26:55 +0200
Message-ID: <20130828152549.8250.97982.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, as@one.com, Jesper Dangaard Brouer <brouer@redhat.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	"Patrick McHardy" <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Packets reaching SYNPROXY are default dropped, as they are most likely
invalid (given the state matching).  In other configurations it might
be beneficial to let packet not consumed by SYNPROXY (SYN and ACK) to
continue being processed by the stack.

Introducing a --continue option/flag for the SYNPROXY target to allow
these unmatched packets to continue being processed.  This would also
help in debugging the module via LOG.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
Comment:
 This patch depend on the one send earlier, and I also have the
 userspace iptables part ready, if this patch is received positively

 include/uapi/linux/netfilter/xt_SYNPROXY.h |    1 +
 net/ipv4/netfilter/ipt_SYNPROXY.c          |    9 ++++++++-
 net/ipv6/netfilter/ip6t_SYNPROXY.c         |    9 ++++++++-
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/netfilter/xt_SYNPROXY.h b/include/uapi/linux/netfilter/xt_SYNPROXY.h
index 2d59fba..6b788bc 100644
--- a/include/uapi/linux/netfilter/xt_SYNPROXY.h
+++ b/include/uapi/linux/netfilter/xt_SYNPROXY.h
@@ -6,6 +6,7 @@
 #define XT_SYNPROXY_OPT_SACK_PERM	0x04
 #define XT_SYNPROXY_OPT_TIMESTAMP	0x08
 #define XT_SYNPROXY_OPT_ECN		0x10
+#define XT_SYNPROXY_OPT_CONTINUE	0x20
 
 struct xt_synproxy_info {
 	__u8	options;
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 90e489e..3a09759 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -285,9 +285,16 @@ synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 					  XT_SYNPROXY_OPT_ECN);
 
 		synproxy_send_client_synack(skb, th, &opts);
-	} else if (th->ack && !(th->fin || th->rst || th->syn))
+		return NF_DROP;
+
+	} else if (th->ack && !(th->fin || th->rst || th->syn)) {
 		/* ACK from client */
 		synproxy_recv_client_ack(snet, skb, th, &opts, ntohl(th->seq));
+		return NF_DROP;
+	}
+
+	if (info->options & XT_SYNPROXY_OPT_CONTINUE)
+		return XT_CONTINUE;
 
 	return NF_DROP;
 }
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index a5af0bf..02f41fa 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -300,9 +300,16 @@ synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 					  XT_SYNPROXY_OPT_ECN);
 
 		synproxy_send_client_synack(skb, th, &opts);
-	} else if (th->ack && !(th->fin || th->rst || th->syn))
+		return NF_DROP;
+
+	} else if (th->ack && !(th->fin || th->rst || th->syn)) {
 		/* ACK from client */
 		synproxy_recv_client_ack(snet, skb, th, &opts, ntohl(th->seq));
+		return NF_DROP;
+	}
+
+	if (info->options & XT_SYNPROXY_OPT_CONTINUE)
+		return XT_CONTINUE;
 
 	return NF_DROP;
 }

