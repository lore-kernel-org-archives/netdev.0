From: Patrick McHardy <kaber@trash.net>
Subject: Re: ip -6 route shows incorrect route expiry times
Date: Sun, 30 Jan 2005 18:09:56 +0100
Message-ID: <41FD14E4.8010305@trash.net>
References: <20050130160840.C25000@flint.arm.linux.org.uk> <20050131.012910.117562374.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070503020703030504000401"
Cc: rmk@arm.linux.org.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050131.012910.117562374.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070503020703030504000401
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

YOSHIFUJI Hideaki / $B5HF#1QL@ wrote:

>In article <20050130160840.C25000@flint.arm.linux.org.uk> (at Sun, 30 Jan 2005 16:08:40 +0000), Russell King <rmk@arm.linux.org.uk> says:
>
>
>>rmk@dyn-67:[bk]:<1030> /sbin/ip -6 route; sleep 10; /sbin/ip -6 route
>>default via fe80::a00:2bff:fe95:1d7b dev eth0  proto kernel  metric 1024
>>  expires 169sec mtu 1500 advmss 1440
>>default via fe80::a00:2bff:fe95:1d7b dev eth0  proto kernel  metric 1024
>>  expires 168sec mtu 1500 advmss 1440
>>
>>It appears that the expiry seconds here are actually in units of
>>10 seconds.  Maybe someone's double-converting kernel Hz to user Hz?
>>
>
>Kernel exports in USER_HZ.
>iproute2 seem to convert it again; workaround is to do "export HZ=100".
>
I've sent this fix to Stephen yesterday.

Regards
Patrick


--------------070503020703030504000401
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/29 10:59:53+01:00 kaber@coreworks.de 
#   Use USER_HZ where necessary
# 
# BitKeeper/etc/logging_ok
#   2005/01/29 10:59:51+01:00 kaber@coreworks.de +1 -0
#   Logging to logging@openlogging.org accepted
# 
# tc/tc_util.c
#   2005/01/29 10:59:48+01:00 kaber@coreworks.de +1 -1
#   Use USER_HZ where necessary
# 
# lib/utils.c
#   2005/01/29 10:59:48+01:00 kaber@coreworks.de +7 -0
#   Use USER_HZ where necessary
# 
# ip/iproute.c
#   2005/01/29 10:59:48+01:00 kaber@coreworks.de +3 -3
#   Use USER_HZ where necessary
# 
# include/utils.h
#   2005/01/29 10:59:48+01:00 kaber@coreworks.de +10 -0
#   Use USER_HZ where necessary
# 
diff -Nru a/include/utils.h b/include/utils.h
--- a/include/utils.h	2005-01-30 18:08:57 +01:00
+++ b/include/utils.h	2005-01-30 18:08:57 +01:00
@@ -113,4 +113,14 @@
 	return __iproute2_hz_internal;
 }
 
+extern int __iproute2_user_hz_internal;
+extern int __get_user_hz(void);
+
+static __inline__ int get_user_hz(void)
+{
+	if (__iproute2_user_hz_internal == 0)
+		__iproute2_user_hz_internal = __get_user_hz();
+	return __iproute2_user_hz_internal;
+}
+
 #endif /* __UTILS_H__ */
diff -Nru a/ip/iproute.c b/ip/iproute.c
--- a/ip/iproute.c	2005-01-30 18:08:57 +01:00
+++ b/ip/iproute.c	2005-01-30 18:08:57 +01:00
@@ -412,7 +412,7 @@
 			struct rta_cacheinfo *ci = RTA_DATA(tb[RTA_CACHEINFO]);
 			static int hz;
 			if (!hz)
-				hz = get_hz();
+				hz = get_user_hz();
 			if (ci->rta_expires != 0)
 				fprintf(fp, " expires %dsec", ci->rta_expires/hz);
 			if (ci->rta_error != 0)
@@ -439,7 +439,7 @@
 		if ((r->rtm_flags & RTM_F_CLONED) || (ci && ci->rta_expires)) {
 			static int hz;
 			if (!hz)
-				hz = get_hz();
+				hz = get_user_hz();
 			if (r->rtm_flags & RTM_F_CLONED)
 				fprintf(fp, "%s    cache ", _SL_);
 			if (ci->rta_expires)
@@ -491,7 +491,7 @@
 			if (i-2 < sizeof(mx_names)/sizeof(char*))
 				fprintf(fp, " %s", mx_names[i-2]);
 			else
-				fprintf(fp, " metric%d", i);
+				fprintf(fp, " metric %d", i);
 			if (mxlock & (1<<i))
 				fprintf(fp, " lock");
 
diff -Nru a/lib/utils.c b/lib/utils.c
--- a/lib/utils.c	2005-01-30 18:08:57 +01:00
+++ b/lib/utils.c	2005-01-30 18:08:57 +01:00
@@ -383,6 +383,13 @@
 	return HZ;
 }
 
+int __iproute2_user_hz_internal;
+
+int __get_user_hz(void)
+{
+	return sysconf(_SC_CLK_TCK);
+}
+
 const char *rt_addr_n2a(int af, int len, const void *addr, char *buf, int buflen)
 {
 	switch (af) {
diff -Nru a/tc/tc_util.c b/tc/tc_util.c
--- a/tc/tc_util.c	2005-01-30 18:08:57 +01:00
+++ b/tc/tc_util.c	2005-01-30 18:08:57 +01:00
@@ -417,7 +417,7 @@
 
 void print_tm(FILE * f, const struct tcf_t *tm)
 {
-	int hz = get_hz();
+	int hz = get_user_hz();
 	if (tm->install != 0)
 		fprintf(f, " installed %d sec", tm->install/hz);
 	if (tm->lastuse != 0)

--------------070503020703030504000401--
