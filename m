From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (2/3) tcp - diagnostics enhancement for westwood
Date: Mon, 27 Sep 2004 13:24:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927132418.509c689b@zqx3.pdx.osdl.net>
References: <20040927112118.4c376303@zqx3.pdx.osdl.net>
	<20040927121746.7ab592d5.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Joe Perches <joe@Perches.com>
In-Reply-To: <20040927121746.7ab592d5.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Joe's suggestion, put jiffies_to_usecs in time.h and make it smarter
about HZ values math.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/time.h b/include/linux/time.h
--- a/include/linux/time.h	2004-09-27 13:22:41 -07:00
+++ b/include/linux/time.h	2004-09-27 13:22:41 -07:00
@@ -194,6 +194,18 @@
 	return (j * 1000) / HZ;
 #endif
 }
+
+static inline unsigned int jiffies_to_usecs(const unsigned long j)
+{
+#if HZ <= 1000 && !(1000 % HZ)
+	return (1000000 / HZ) * j;
+#elif HZ > 1000 && !(HZ % 1000)
+	return (j*1000 + (HZ - 1000))/(HZ / 1000);
+#else
+	return (j * 1000000) / HZ;
+#endif
+}
+
 static inline unsigned long msecs_to_jiffies(const unsigned int m)
 {
 #if HZ <= 1000 && !(1000 % HZ)
diff -Nru a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
--- a/net/ipv4/tcp_diag.c	2004-09-27 13:22:41 -07:00
+++ b/net/ipv4/tcp_diag.c	2004-09-27 13:22:41 -07:00
@@ -41,12 +41,6 @@
    rta->rta_len = rtalen;                   \
    RTA_DATA(rta); })
 
-static inline unsigned int jiffies_to_usecs(const unsigned long j)
-{
-	return 1000*jiffies_to_msecs(j);
-}
-
-
 /* Return information about state of tcp endpoint in API format. */
 void tcp_get_info(struct sock *sk, struct tcp_info *info)
 {
