From: Nelson Elhage <nelhage@ksplice.com>
Subject: [PATCH] pktgen: Limit how much data we copy onto the stack.
Date: Thu, 28 Oct 2010 11:20:42 -0400
Message-ID: <1288279242-22153-1-git-send-email-nelhage@ksplice.com>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	netdev@vger.kernel.org, Eugene Teo <eugene@redhat.com>,
	Nelson Elhage <nelhage@ksplice.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DMZ-MAILSEC-SCANNER-6.MIT.EDU ([18.7.68.35]:48311 "EHLO
	dmz-mailsec-scanner-6.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753753Ab0J1PVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 11:21:05 -0400
In-Reply-To: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A program that accidentally writes too much data to the pktgen file can overflow
the kernel stack and oops the machine. This is only triggerable by root, so
there's no security issue, but it's still an unfortunate bug.

printk() won't print more than 1024 bytes in a single call, anyways, so let's
just never copy more than that much data. We're on a fairly shallow stack, so
that should be safe even with CONFIG_4KSTACKS.

Signed-off-by: Nelson Elhage <nelhage@ksplice.com>
---
While testing Dan's patch, I realized the printk() limitation, so I don't think
there's any reason to need a kmalloc() at all. I've tested this on a
CONFIG_4KSTACKS kernel, and copying 1k works fine.

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 10a1ea7..d6667cf 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -889,10 +889,11 @@ static ssize_t pktgen_if_write(struct file *file,
 	i += len;
 
 	if (debug) {
-		char tb[count + 1];
-		if (copy_from_user(tb, user_buffer, count))
+		size_t copy = min(count, 1023);
+		char tb[copy + 1];
+		if (copy_from_user(tb, user_buffer, copy))
 			return -EFAULT;
-		tb[count] = 0;
+		tb[copy] = 0;
 		printk(KERN_DEBUG "pktgen: %s,%lu  buffer -:%s:-\n", name,
 		       (unsigned long)count, tb);
 	}
-- 
1.7.1.31.g6297e

