From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] [DCCP]: Convert do_gettimeofday() to getnstimeofday().
Date: Mon, 21 Apr 2008 16:22:27 +0900 (JST)
Message-ID: <20080421.162227.63020853.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34220 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbYDUHUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 03:20:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What do_gettimeofday() does is to call getnstimeofday() and
to convert the result from timespec{} to timeval{}.
We do not always need timeval{} and we can convert timespec{}
when we really need (to print).

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index 7053bb8..6e1df62 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -46,29 +46,24 @@ struct {
 	struct kfifo	  *fifo;
 	spinlock_t	  lock;
 	wait_queue_head_t wait;
-	struct timeval	  tstart;
+	struct timespec	  tstart;
 } dccpw;
 
 static void printl(const char *fmt, ...)
 {
 	va_list args;
 	int len;
-	struct timeval now;
+	struct timespec now;
 	char tbuf[256];
 
 	va_start(args, fmt);
-	do_gettimeofday(&now);
+	getnstimeofday(&now);
 
-	now.tv_sec -= dccpw.tstart.tv_sec;
-	now.tv_usec -= dccpw.tstart.tv_usec;
-	if (now.tv_usec < 0) {
-		--now.tv_sec;
-		now.tv_usec += 1000000;
-	}
+	now = timespec_sub(now, dccpw.tstart);
 
 	len = sprintf(tbuf, "%lu.%06lu ",
 		      (unsigned long) now.tv_sec,
-		      (unsigned long) now.tv_usec);
+		      (unsigned long) now.tv_nsec / NSEC_PER_USEC);
 	len += vscnprintf(tbuf+len, sizeof(tbuf)-len, fmt, args);
 	va_end(args);
 
@@ -119,7 +114,7 @@ static struct jprobe dccp_send_probe = {
 static int dccpprobe_open(struct inode *inode, struct file *file)
 {
 	kfifo_reset(dccpw.fifo);
-	do_gettimeofday(&dccpw.tstart);
+	getnstimeofday(&dccpw.tstart);
 	return 0;
 }
 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
