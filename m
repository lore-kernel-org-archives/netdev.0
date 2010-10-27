From: Dan Carpenter <error27@gmail.com>
Subject: [patch] fix stack overflow in pktgen_if_write()
Date: Thu, 28 Oct 2010 00:12:35 +0200
Message-ID: <20101027221234.GN6062@bicker>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	netdev@vger.kernel.org
To: nelhage@ksplice.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64210 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab0J0WMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 18:12:48 -0400
Received: by wwe15 with SMTP id 15so1330790wwe.1
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 15:12:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nelson Elhage says he was able to oops both amd64 and i386 test 
machines with 8k writes to the pktgen file.  Let's just allocate the
buffer on the heap instead of on the stack.

This can only be triggered by root so there are no security issues here.

Reported-by: Nelson Elhage <nelhage@ksplice.com>
Signed-off-by: Dan Carpenter <error27@gmail.com>
---
I saw this on twitter.  Hi Nelson, could you test this?

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2c0df0f..b5d3c70 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -887,12 +887,14 @@ static ssize_t pktgen_if_write(struct file *file,
 	i += len;
 
 	if (debug) {
-		char tb[count + 1];
-		if (copy_from_user(tb, user_buffer, count))
-			return -EFAULT;
-		tb[count] = 0;
+		char *tb;
+
+		tb = strndup_user(user_buffer, count + 1);
+		if (IS_ERR(tb))
+			return PTR_ERR(tb);
 		printk(KERN_DEBUG "pktgen: %s,%lu  buffer -:%s:-\n", name,
 		       (unsigned long)count, tb);
+		kfree(tb);
 	}
 
 	if (!strcmp(name, "min_pkt_size")) {
