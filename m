From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/32] netfilter: conntrack: warn the user if there is a better helper to use
Date: Mon, 15 Jun 2015 23:25:58 +0200
Message-ID: <1434403589-24796-2-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

After db29a9508a92 ("netfilter: conntrack: disable generic tracking for
known protocols"), if the specific helper is built but not loaded
(a standard for most distributions) systems with a restrictive firewall
but weak configuration regarding netfilter modules to load, will
silently stop working.

This patch then puts a warning message so the sysadmin knows where to
start looking into. It's a pr_warn_once regardless of protocol itself
but it should be enough to give a hint on where to look.

Cc: Florian Westphal <fw@strlen.de>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_generic.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 60865f1..2281be4 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -90,7 +90,13 @@ static int generic_packet(struct nf_conn *ct,
 static bool generic_new(struct nf_conn *ct, const struct sk_buff *skb,
 			unsigned int dataoff, unsigned int *timeouts)
 {
-	return nf_generic_should_process(nf_ct_protonum(ct));
+	bool ret;
+
+	ret = nf_generic_should_process(nf_ct_protonum(ct));
+	if (!ret)
+		pr_warn_once("conntrack: generic helper won't handle protocol %d. Please consider loading the specific helper module.\n",
+			     nf_ct_protonum(ct));
+	return ret;
 }
 
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
-- 
1.7.10.4

