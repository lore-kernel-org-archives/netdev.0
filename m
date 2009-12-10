From: chavey@google.com
Subject: [PATCH] netfilter: Fix compiler warning.
Date: Thu, 10 Dec 2009 13:44:50 -0800
Message-ID: <pvmein2bj1p.fsf@chavey.mtv.corp.google.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	chavey@google.com, eric.dumazet@gmail.com, akpm@google.com
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix compiler warning "discards qualifiers from pointer target type",
by allowing explicit discard of const qualifier thru type casting.
The const_cast() macro is taken from a patch from Kaveh R. Ghazi
[PATCH]: Fix problematic -Wcast-qual cases using new CONST_CAST macro
posted on 
http://old.nabble.com/-PATCH-:-Fix-problematic--Wcast-qual-cases-using-new-CONST_CAST--macro-td11824676.html
The proposed __nowarn__ keyword has not yet been implemented, 
(see http://gcc.gnu.org/ml/gcc-patches/2009-11/msg01261.html).


Signed-off-by: Laurent Chavey <chavey@google.com>
---
 include/linux/kernel.h        |   12 ++++++++++++
 net/ipv4/netfilter/ipt_ULOG.c |    2 +-
 net/netfilter/xt_time.c       |    2 +-
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 3fa4c59..0246771 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -710,4 +710,16 @@ struct sysinfo {
 # define REBUILD_DUE_TO_FTRACE_MCOUNT_RECORD
 #endif
 
+/* Cast away const-ness to pass -Wcast-qual */
+#ifdef __GNUC__
+union gcc_constcast
+{
+	const void *cv;
+	void *v;
+};
+#define const_cast(X) ((__extension__(union gcc_constcast)(const void *)(X)).v)
+#else
+#define const_cast(X) ((void *)(X))
+#endif
+
 #endif
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index d32cc4b..c8f8b8b 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -210,7 +210,7 @@ static void ipt_ulog_packet(unsigned int hooknum,
 
 	/* We might not have a timestamp, get one */
 	if (skb->tstamp.tv64 == 0)
-		__net_timestamp((struct sk_buff *)skb);
+		__net_timestamp((struct sk_buff *)const_cast(skb));
 
 	/* copy hook, prefix, timestamp, payload, etc. */
 	pm->data_len = copy_len;
diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index 93acaa5..8f34a4a 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -170,7 +170,7 @@ time_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	 * it arrived at the right moment before 13:00.
 	 */
 	if (skb->tstamp.tv64 == 0)
-		__net_timestamp((struct sk_buff *)skb);
+		__net_timestamp((struct sk_buff *)const_cast(skb));
 
 	stamp = ktime_to_ns(skb->tstamp);
 	stamp = div_s64(stamp, NSEC_PER_SEC);
