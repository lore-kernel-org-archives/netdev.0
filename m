From: "David S. Miller" <davem@redhat.com>
Subject: Update to 2.6.9-pre networking
Date: Wed, 18 Aug 2004 22:47:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040818224727.55e0984e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Two bugs fixed:

1) tcp_init_metrics needs to setup rtt_seq
2) ICMP xfrm changes were dereferencing user pointers directly

Available at:

	bk://kernel.bkbits.net/davem/net-2.6
	ftp.kernel.org:/pub/linux/kernel/people/davem/net-2.6.7-2.diff.gz

Enjoy.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/18 17:56:52-07:00 davem@nuts.davemloft.net 
#   [TCP]: When fetching srtt from metrics, do not forget to set rtt_seq.
#   
#   Otherwise RTT will end up being wrong for a long
#   time, because tcp_rtt_estimator() requires that
#   every time srtt is set, rtt_seq is set too.
#   
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv4/tcp_input.c
#   2004/08/18 17:55:57-07:00 davem@nuts.davemloft.net +3 -1
#   [TCP]: When fetching srtt from metrics, do not forget to set rtt_seq.
# 
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-08-19 05:47:01 -07:00
+++ b/net/ipv4/tcp_input.c	2004-08-19 05:47:01 -07:00
@@ -852,8 +852,10 @@
 	 * to low value, and then abruptly stops to do it and starts to delay
 	 * ACKs, wait for troubles.
 	 */
-	if (dst_metric(dst, RTAX_RTT) > tp->srtt)
+	if (dst_metric(dst, RTAX_RTT) > tp->srtt) {
 		tp->srtt = dst_metric(dst, RTAX_RTT);
+		tp->rtt_seq = tp->snd_nxt;
+	}
 	if (dst_metric(dst, RTAX_RTTVAR) > tp->mdev) {
 		tp->mdev = dst_metric(dst, RTAX_RTTVAR);
 		tp->mdev_max = tp->rttvar = max(tp->mdev, TCP_RTO_MIN);
# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/18 22:17:01-07:00 davem@nuts.davemloft.net 
#   [IPV4/IPV6]: Fix direct user pointer deref in xfrm icmp changes.
#   
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv6/raw.c
#   2004/08/18 22:16:27-07:00 davem@nuts.davemloft.net +4 -4
#   [IPV4/IPV6]: Fix direct user pointer deref in xfrm icmp changes.
# 
# net/ipv4/raw.c
#   2004/08/18 22:16:27-07:00 davem@nuts.davemloft.net +4 -4
#   [IPV4/IPV6]: Fix direct user pointer deref in xfrm icmp changes.
# 
diff -Nru a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c	2004-08-19 05:47:09 -07:00
+++ b/net/ipv4/raw.c	2004-08-19 05:47:09 -07:00
@@ -326,8 +326,8 @@
 static void raw_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 {
 	struct iovec *iov;
-	u8 *type = NULL;
-	u8 *code = NULL;
+	u8 __user *type = NULL;
+	u8 __user *code = NULL;
 	int probed = 0;
 	int i;
 
@@ -354,8 +354,8 @@
 				code = iov->iov_base;
 
 			if (type && code) {
-				fl->fl_icmp_type = *type;
-				fl->fl_icmp_code = *code;
+				get_user(fl->fl_icmp_type, type);
+				__get_user(fl->fl_icmp_code, code);
 				probed = 1;
 			}
 			break;
diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	2004-08-19 05:47:09 -07:00
+++ b/net/ipv6/raw.c	2004-08-19 05:47:09 -07:00
@@ -559,8 +559,8 @@
 static void rawv6_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 {
 	struct iovec *iov;
-	u8 *type = NULL;
-	u8 *code = NULL;
+	u8 __user *type = NULL;
+	u8 __user *code = NULL;
 	int probed = 0;
 	int i;
 
@@ -587,8 +587,8 @@
 				code = iov->iov_base;
 
 			if (type && code) {
-				fl->fl_icmp_type = *type;
-				fl->fl_icmp_code = *code;
+				get_user(fl->fl_icmp_type, type);
+				__get_user(fl->fl_icmp_code, code);
 				probed = 1;
 			}
 			break;
