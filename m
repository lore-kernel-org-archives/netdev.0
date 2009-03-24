From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 23/41: print the list of register loggers
Date: Tue, 24 Mar 2009 15:03:37 +0100 (MET)
Message-ID: <20090324140333.31401.13004.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit c7a913cd5535554d6f5d5e1f5ef46c4307cf2afc
Author: Eric Leblond <eric@inl.fr>
Date:   Mon Mar 16 14:55:27 2009 +0100

    netfilter: print the list of register loggers
    
    This patch modifies the proc output to add display of registered
    loggers. The content of /proc/net/netfilter/nf_log is modified. Instead
    of displaying a protocol per line with format:
    	proto:logger
    it now displays:
    	proto:logger (comma_separated_list_of_loggers)
    NONE is used as keyword if no logger is used.
    
    Signed-off-by: Eric Leblond <eric@inl.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index a228b5f..4fcbcc7 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -154,13 +154,37 @@ static int seq_show(struct seq_file *s, void *v)
 {
 	loff_t *pos = v;
 	const struct nf_logger *logger;
+	struct nf_logger *t;
+	int ret;
 
 	logger = rcu_dereference(nf_loggers[*pos]);
 
 	if (!logger)
-		return seq_printf(s, "%2lld NONE\n", *pos);
+		ret = seq_printf(s, "%2lld NONE (", *pos);
+	else
+		ret = seq_printf(s, "%2lld %s (", *pos, logger->name);
+
+	if (ret < 0)
+		return ret;
+
+	mutex_lock(&nf_log_mutex);
+	list_for_each_entry(t, &nf_loggers_l[*pos], list[*pos]) {
+		ret = seq_printf(s, "%s", t->name);
+		if (ret < 0) {
+			mutex_unlock(&nf_log_mutex);
+			return ret;
+		}
+		if (&t->list[*pos] != nf_loggers_l[*pos].prev) {
+			ret = seq_printf(s, ",");
+			if (ret < 0) {
+				mutex_unlock(&nf_log_mutex);
+				return ret;
+			}
+		}
+	}
+	mutex_unlock(&nf_log_mutex);
 
-	return seq_printf(s, "%2lld %s\n", *pos, logger->name);
+	return seq_printf(s, ")\n");
 }
 
 static const struct seq_operations nflog_seq_ops = {
