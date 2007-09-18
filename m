From: Rick Jones <rick.jones2@hp.com>
Subject: [PATCH] iproute2: enable setting rto_min, rtt and rttvar in tc-esque units
Date: Tue, 18 Sep 2007 13:15:26 -0700 (PDT)
Message-ID: <200709182015.NAA25590@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=X-roman8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:38504 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752758AbXIRUPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 16:15:52 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel12.hp.com (Postfix) with ESMTP id EF9E736442
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 13:15:31 -0700 (PDT)
Received: (from raj@localhost)
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) id NAA25590
	for netdev@vger.kernel.org; Tue, 18 Sep 2007 13:15:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable users of ip to specify the times for rtt, rttvar and rto_min
in human-friendly terms a la "tc" while maintaining backwards 
compatability with the previous "raw" mechanism.  Builds upon
David Miller's uncommited patch to set rto_min.

Signed-off-by: Rick Jones <rick.jones2@hp.com>
---

 include/linux/rtnetlink.h |    2 +
 include/utils.h           |    1 +
 ip/iproute.c              |   30 ++++++++++++++++-----
 lib/utils.c               |   64 +++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip.8             |   36 ++++++++++++++++++++-----
 5 files changed, 119 insertions(+), 14 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 477270c..2494d2c 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -352,6 +352,8 @@ enum
 #define RTAX_INITCWND RTAX_INITCWND
 	RTAX_FEATURES,
 #define RTAX_FEATURES RTAX_FEATURES
+	RTAX_RTO_MIN,
+#define RTAX_RTO_MIN RTAX_RTO_MIN
 	__RTAX_MAX
 };
 
diff --git a/include/utils.h b/include/utils.h
index a3fd335..7da2b29 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -77,6 +77,7 @@ extern int get_prefix(inet_prefix *dst, char *arg, int family);
 
 extern int get_integer(int *val, const char *arg, int base);
 extern int get_unsigned(unsigned *val, const char *arg, int base);
+extern int get_jiffies(unsigned *val, const char *arg, int base, int *raw);
 #define get_byte get_u8
 #define get_ushort get_u16
 #define get_short get_s16
diff --git a/ip/iproute.c b/ip/iproute.c
index 6fe4a70..ebb0b2f 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -51,6 +51,7 @@ static const char *mx_names[RTAX_MAX+1] = {
 	[RTAX_HOPLIMIT] = "hoplimit",
 	[RTAX_INITCWND] = "initcwnd",
 	[RTAX_FEATURES] = "features",
+	[RTAX_RTO_MIN]	= "rto_min",
 };
 static void usage(void) __attribute__((noreturn));
 
@@ -71,9 +72,10 @@ static void usage(void)
 	fprintf(stderr, "INFO_SPEC := NH OPTIONS FLAGS [ nexthop NH ]...\n");
 	fprintf(stderr, "NH := [ via ADDRESS ] [ dev STRING ] [ weight NUMBER ] NHFLAGS\n");
 	fprintf(stderr, "OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ]\n");
-	fprintf(stderr, "           [ rtt NUMBER ] [ rttvar NUMBER ]\n");
+	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ]\n");
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ]\n");
+	fprintf(stderr, "           [ rto_min TIME ]\n");
 	fprintf(stderr, "TYPE := [ unicast | local | broadcast | multicast | throw |\n");
 	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");
@@ -82,6 +84,7 @@ static void usage(void)
 	fprintf(stderr, "MP_ALGO := { rr | drr | random | wrandom }\n");
 	fprintf(stderr, "NHFLAGS := [ onlink | pervasive ]\n");
 	fprintf(stderr, "RTPROTO := [ kernel | boot | static | NUMBER ]\n");
+	fprintf(stderr, "TIME := NUMBER[s|ms|us|ns|j]\n");
 	exit(-1);
 }
 
@@ -516,7 +519,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			if (mxlock & (1<<i))
 				fprintf(fp, " lock");
 
-			if (i != RTAX_RTT && i != RTAX_RTTVAR)
+			if (i != RTAX_RTT && i != RTAX_RTTVAR &&
+			    i != RTAX_RTO_MIN)
 				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
 			else {
 				unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
@@ -524,7 +528,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				val *= 1000;
 				if (i == RTAX_RTT)
 					val /= 8;
-				else
+				else if (i == RTAX_RTTVAR)
 					val /= 4;
 				if (val >= hz)
 					fprintf(fp, " %ums", val/hz);
@@ -689,6 +693,7 @@ int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 	int table_ok = 0;
 	int proto_ok = 0;
 	int type_ok = 0;
+	int raw = 0;
 
 	memset(&req, 0, sizeof(req));
 
@@ -796,9 +801,19 @@ int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 				mxlock |= (1<<RTAX_RTT);
 				NEXT_ARG();
 			}
-			if (get_unsigned(&rtt, *argv, 0))
+			if (get_jiffies(&rtt, *argv, 0, &raw))
 				invarg("\"rtt\" value is invalid\n", *argv);
-			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_RTT, rtt);
+			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_RTT, 
+				(raw) ? rtt : rtt * 8);
+		} else if (strcmp(*argv, "rto_min") == 0) {
+			unsigned rto_min;
+			NEXT_ARG();
+			mxlock |= (1<<RTAX_RTO_MIN);
+			if (get_jiffies(&rto_min, *argv, 0, &raw))
+				invarg("\"rto_min\" value is invalid\n",
+				       *argv);
+			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_RTO_MIN,
+				      rto_min);
 		} else if (matches(*argv, "window") == 0) {
 			unsigned win;
 			NEXT_ARG();
@@ -836,9 +851,10 @@ int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 				mxlock |= (1<<RTAX_RTTVAR);
 				NEXT_ARG();
 			}
-			if (get_unsigned(&win, *argv, 0))
+			if (get_jiffies(&win, *argv, 0, &raw))
 				invarg("\"rttvar\" value is invalid\n", *argv);
-			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_RTTVAR, win);
+			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_RTTVAR,
+				(raw) ? win : win * 4);
 		} else if (matches(*argv, "ssthresh") == 0) {
 			unsigned win;
 			NEXT_ARG();
diff --git a/lib/utils.c b/lib/utils.c
index 4f35a60..4c42dfd 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -61,6 +61,70 @@ int get_unsigned(unsigned *val, const char *arg, int base)
 	return 0;
 }
 
+/*
+ * get_jiffies is "translated" from a similar routine "get_time" in
+ * tc_util.c.  we don't use the exact same routine because tc passes
+ * microseconds to the kernel and the callers of get_jiffies want 
+ * to pass jiffies, and have a different assumption for the units of
+ * a "raw" number.
+ */
+
+int get_jiffies(unsigned *jiffies, const char *arg, int base, int *raw)
+{
+	double t;
+	unsigned long res;
+	char *p;
+
+	if (strchr(arg,'.') != NULL) {
+		t = strtod(arg,&p);
+		if (t < 0.0)
+			return -1;
+	}
+	else {
+		res = strtoul(arg,&p,base);
+		if (res > UINT_MAX)
+			return -1;
+		t = (double)res;
+	}
+	if (p == arg)
+		return -1;
+
+	if (__iproute2_hz_internal == 0)
+                __iproute2_hz_internal = __get_hz();
+	
+	*raw = 1;
+
+	if (*p) {
+		*raw = 0;
+                if (strcasecmp(p, "s") == 0 || strcasecmp(p, "sec")==0 ||
+                    strcasecmp(p, "secs")==0)
+                        t *= __iproute2_hz_internal;
+                else if (strcasecmp(p, "ms") == 0 || strcasecmp(p, "msec")==0 ||
+                         strcasecmp(p, "msecs") == 0)
+                        t *= __iproute2_hz_internal/1000.0;
+                else if (strcasecmp(p, "us") == 0 || strcasecmp(p, "usec")==0 ||
+                         strcasecmp(p, "usecs") == 0)
+                        t *= __iproute2_hz_internal/1000000.0;
+                else if (strcasecmp(p, "ns") == 0 || strcasecmp(p, "nsec")==0 ||
+                         strcasecmp(p, "nsecs") == 0)
+                        t *= __iproute2_hz_internal/1000000000.0;
+		else if (strcasecmp(p, "j") == 0 || strcasecmp(p, "hz") == 0 ||
+			 strcasecmp(p,"jiffies") == 0)
+			t *= 1.0; /* allow suffix, do nothing */
+                else
+                        return -1;
+        }
+
+	/* emulate ceil() without having to bring-in -lm and always be >= 1 */
+
+	*jiffies = t;
+	if (*jiffies < t)
+		*jiffies += 1;
+	
+        return 0;
+
+}
+
 int get_u64(__u64 *val, const char *arg, int base)
 {
 	unsigned long long res;
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index a9132da..7181054 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -169,9 +169,9 @@ replace " | " monitor " } "
 .B  advmss
 .IR NUMBER " ] [ "
 .B  rtt
-.IR NUMBER " ] [ "
+.IR TIME " ] [ "
 .B  rttvar
-.IR NUMBER " ] [ "
+.IR TIME " ] [ "
 .B  window
 .IR NUMBER " ] [ "
 .B  cwnd
@@ -179,7 +179,9 @@ replace " | " monitor " } "
 .B  ssthresh
 .IR REALM " ] [ "
 .B  realms
-.IR REALM " ]"
+.IR REALM " ] [ "
+.B  rto_min
+.IR TIME " ]"
 
 .ti -8
 .IR TYPE " := [ "
@@ -301,6 +303,9 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .IR KEY " := { " DOTTED_QUAD " | " NUMBER " }"
 
 .ti -8
+.IR TIME " := " NUMBER "[s|ms|us|ns|j]"
+
+.ti -8
 .BR "ip maddr" " [ " add " | " del " ]"
 .IB MULTIADDR " dev " STRING
 
@@ -1062,12 +1067,29 @@ measured in bytes.  It limits maximal data bursts that our TCP
 peers are allowed to send to us.
 
 .TP
-.BI rtt " NUMBER"
-the initial RTT ('Round Trip Time') estimate.
+.BI rtt " TIME"
+the initial RTT ('Round Trip Time') estimate. If no suffix is
+specified the units are raw values passed directly to the
+routing code to maintain compatability with previous releases.
+Otherwise if a suffix of s, sec or secs is used to specify
+seconds; ms, msec or msecs to specify milliseconds; us, usec 
+or usecs to specify microseconds; ns, nsec or nsecs to specify 
+nanoseconds; j, hz or jiffies to specify jiffies, the value is 
+converted to what the routing code expects.
+
+
+.TP
+.BI rttvar " TIME " "(2.3.15+ only)"
+the initial RTT variance estimate. Values are specified as with 
+.BI rtt
+above.
 
 .TP
-.BI rttvar " NUMBER " "(2.3.15+ only)"
-the initial RTT variance estimate.
+.BI rto_min " TIME " "(2.6.23+ only)"
+the minimum TCP Retransmission TimeOut to use when communicating with this
+destination.  Values are specified as with
+.BI rtt
+above.
 
 .TP
 .BI ssthresh " NUMBER " "(2.3.15+ only)"
