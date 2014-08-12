From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net 1/2] xen-netback: fix debugfs write length check
Date: Tue, 12 Aug 2014 11:59:29 +0100
Message-ID: <1407841170-20916-2-git-send-email-wei.liu2@citrix.com>
References: <1407841170-20916-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:31541 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752157AbaHLK7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 06:59:33 -0400
In-Reply-To: <1407841170-20916-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enlarge buffer size and check input length properly, so that we don't
misuse -ENOSPC.

Note that command like "kickXXXX" is still allowed, that's one patch for
another day if we really want to be very strict on this.

Reported-by: SeeChen Ng <seechen81@gmail.com>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/xenbus.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 580517d..4c9041e 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -116,6 +116,7 @@ static int xenvif_read_io_ring(struct seq_file *m, void *v)
 }
 
 #define XENVIF_KICK_STR "kick"
+#define BUFFER_SIZE     32
 
 static ssize_t
 xenvif_write_io_ring(struct file *filp, const char __user *buf, size_t count,
@@ -124,22 +125,24 @@ xenvif_write_io_ring(struct file *filp, const char __user *buf, size_t count,
 	struct xenvif_queue *queue =
 		((struct seq_file *)filp->private_data)->private;
 	int len;
-	char write[sizeof(XENVIF_KICK_STR)];
+	char write[BUFFER_SIZE];
 
 	/* don't allow partial writes and check the length */
 	if (*ppos != 0)
 		return 0;
-	if (count < sizeof(XENVIF_KICK_STR) - 1)
+	if (count >= sizeof(write))
 		return -ENOSPC;
 
 	len = simple_write_to_buffer(write,
-				     sizeof(write),
+				     sizeof(write) - 1,
 				     ppos,
 				     buf,
 				     count);
 	if (len < 0)
 		return len;
 
+	write[len] = '\0';
+
 	if (!strncmp(write, XENVIF_KICK_STR, sizeof(XENVIF_KICK_STR) - 1))
 		xenvif_interrupt(0, (void *)queue);
 	else {
-- 
1.7.10.4
