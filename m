From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (16/23) sk98: more efficient time OsGetTime
Date: Thu, 11 Nov 2004 16:02:25 -0800
Message-ID: <20041111160225.1185793e@zqx3.pdx.osdl.net>
References: <4192C60A.1050205@designassembly.de>
	<20041111154225.5cf85567@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Heyse <mhk@designassembly.de>,
        Mirko Lindner
 <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041111154225.5cf85567@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Avoid doing a gettimeofday to only get low resolution time.
Can use jiffies_64 and internal 64 bit divide to get what is
needed.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv1st.h b/drivers/net/sk98lin/h/skdrv1st.h
--- a/drivers/net/sk98lin/h/skdrv1st.h	2004-11-03 17:06:12 -08:00
+++ b/drivers/net/sk98lin/h/skdrv1st.h	2004-11-03 17:06:12 -08:00
@@ -96,9 +96,6 @@
 #define SK_BIG_ENDIAN
 #endif
 
-/* we use gethrtime(), return unit: nanoseconds */
-#define SK_TICKS_PER_SEC	100
-
 #define	SK_MEM_MAPPED_IO
 
 // #define SK_RLMT_SLOW_LOOKAHEAD
diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-03 17:06:12 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-03 17:06:12 -08:00
@@ -56,7 +56,6 @@
 
 extern SK_MBUF		*SkDrvAllocRlmtMbuf(SK_AC*, SK_IOC, unsigned);
 extern void		SkDrvFreeRlmtMbuf(SK_AC*, SK_IOC, SK_MBUF*);
-extern SK_U64		SkOsGetTime(SK_AC*);
 extern int		SkPciReadCfgDWord(SK_AC*, int, SK_U32*);
 extern int		SkPciReadCfgWord(SK_AC*, int, SK_U16*);
 extern int		SkPciReadCfgByte(SK_AC*, int, SK_U8*);
@@ -83,25 +82,28 @@
 };
 
 
-/*
- * Time macros
- */
-#if SK_TICKS_PER_SEC == 100
-#define SK_PNMI_HUNDREDS_SEC(t)	(t)
+/* Units used for timing measurements. */
+#define SK_TICKS_PER_SEC	HZ
+
+/* OS time value in HZ (1000 or 100) */
+static inline SK_U64 SkOsGetTime(const SK_AC *pAC)
+{
+	return get_jiffies_64();
+}
+
+/* Convert OS time units to hundredth's of sec */
+static inline SK_U64 jiffies_64_to_hsecs(u64 t)
+{
+#if (HZ % 100) == 0
+	do_div(t, HZ / 100);
 #else
-#define SK_PNMI_HUNDREDS_SEC(t)	((((unsigned long)t) * 100) / \
-										(SK_TICKS_PER_SEC))
+	t *= 100;
+	do_div(x, HZ);
 #endif
-
-/*
- * New SkOsGetTime
- */
-#define SkOsGetTimeCurrent(pAC, pUsec) {\
-	struct timeval t;\
-	do_gettimeofday(&t);\
-	*pUsec = ((((t.tv_sec) * 1000000L)+t.tv_usec)/10000);\
+	return t;
 }
 
+#define SK_PNMI_HUNDREDS_SEC(t)	jiffies_64_to_hsecs(t)
 
 /*
  * ioctl definitions
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-03 17:06:12 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-03 17:06:12 -08:00
@@ -4221,26 +4221,6 @@
 
 /*****************************************************************************
  *
- *	SkOsGetTime - provide a time value
- *
- * Description:
- *	This routine provides a time value. The unit is 1/HZ (defined by Linux).
- *	It is not used for absolute time, but only for time differences.
- *
- *
- * Returns:
- *	Time value
- */
-SK_U64 SkOsGetTime(SK_AC *pAC)
-{
-	SK_U64	PrivateJiffies;
-	SkOsGetTimeCurrent(pAC, &PrivateJiffies);
-	return PrivateJiffies;
-} /* SkOsGetTime */
-
-
-/*****************************************************************************
- *
  *	SkPciReadCfgDWord - read a 32 bit value from pci config space
  *
  * Description:
