From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH] pktgen: clean up handling of local/transient counter vars
Date: Mon, 18 Oct 2010 18:14:44 -0400
Message-ID: <1287440084-4848-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37843 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756136Ab0JRWOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 18:14:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The temporary variable "i" is needlessly initialized to zero
in two distinct cases in this file:

1) where it is set to zero and then used as an argument in an addition
before being assigned a non-zero value.

2) where it is only used in a standard/typical loop counter

For (1), simply delete assignment to zero and usages while still
zero; for (2) simply make the loop start at zero as per standard
practice as seen everywhere else in the same file.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/core/pktgen.c |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2c0df0f..679b797 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -771,10 +771,10 @@ done:
 static unsigned long num_arg(const char __user * user_buffer,
 			     unsigned long maxlen, unsigned long *num)
 {
-	int i = 0;
+	int i;
 	*num = 0;
 
-	for (; i < maxlen; i++) {
+	for (i = 0; i < maxlen; i++) {
 		char c;
 		if (get_user(c, &user_buffer[i]))
 			return -EFAULT;
@@ -789,9 +789,9 @@ static unsigned long num_arg(const char __user * user_buffer,
 
 static int strn_len(const char __user * user_buffer, unsigned int maxlen)
 {
-	int i = 0;
+	int i;
 
-	for (; i < maxlen; i++) {
+	for (i = 0; i < maxlen; i++) {
 		char c;
 		if (get_user(c, &user_buffer[i]))
 			return -EFAULT;
@@ -846,7 +846,7 @@ static ssize_t pktgen_if_write(struct file *file,
 {
 	struct seq_file *seq = file->private_data;
 	struct pktgen_dev *pkt_dev = seq->private;
-	int i = 0, max, len;
+	int i, max, len;
 	char name[16], valstr[32];
 	unsigned long value = 0;
 	char *pg_result = NULL;
@@ -860,13 +860,13 @@ static ssize_t pktgen_if_write(struct file *file,
 		return -EINVAL;
 	}
 
-	max = count - i;
-	tmp = count_trail_chars(&user_buffer[i], max);
+	max = count;
+	tmp = count_trail_chars(user_buffer, max);
 	if (tmp < 0) {
 		pr_warning("illegal format\n");
 		return tmp;
 	}
-	i += tmp;
+	i = tmp;
 
 	/* Read variable name */
 
@@ -1764,7 +1764,7 @@ static ssize_t pktgen_thread_write(struct file *file,
 {
 	struct seq_file *seq = file->private_data;
 	struct pktgen_thread *t = seq->private;
-	int i = 0, max, len, ret;
+	int i, max, len, ret;
 	char name[40];
 	char *pg_result;
 
@@ -1773,12 +1773,12 @@ static ssize_t pktgen_thread_write(struct file *file,
 		return -EINVAL;
 	}
 
-	max = count - i;
-	len = count_trail_chars(&user_buffer[i], max);
+	max = count;
+	len = count_trail_chars(user_buffer, max);
 	if (len < 0)
 		return len;
 
-	i += len;
+	i = len;
 
 	/* Read variable name */
 
@@ -1975,7 +1975,7 @@ static struct net_device *pktgen_dev_get_by_name(struct pktgen_dev *pkt_dev,
 						 const char *ifname)
 {
 	char b[IFNAMSIZ+5];
-	int i = 0;
+	int i;
 
 	for (i = 0; ifname[i] != '@'; i++) {
 		if (i == IFNAMSIZ)
@@ -2519,8 +2519,8 @@ static void free_SAs(struct pktgen_dev *pkt_dev)
 {
 	if (pkt_dev->cflows) {
 		/* let go of the SAs if we have them */
-		int i = 0;
-		for (;  i < pkt_dev->cflows; i++) {
+		int i;
+		for (i = 0; i < pkt_dev->cflows; i++) {
 			struct xfrm_state *x = pkt_dev->flows[i].x;
 			if (x) {
 				xfrm_state_put(x);
-- 
1.7.2.1

