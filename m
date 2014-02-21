From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net-next 1/3] pktgen: fix out-of-bounds access in pgctrl_write()
Date: Fri, 21 Feb 2014 21:38:34 +0100
Message-ID: <1393015116-7488-2-git-send-email-minipli@googlemail.com>
References: <1393015116-7488-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:36413 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496AbaBUUiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 15:38:50 -0500
Received: by mail-bk0-f43.google.com with SMTP id mx12so1200874bkb.30
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 12:38:49 -0800 (PST)
In-Reply-To: <1393015116-7488-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a privileged user writes an empty string to /proc/net/pktgen/pgctrl
the code for stripping the (then non-existent) '\n' actually writes the
zero byte at index -1 of data[]. The then still uninitialized array will
very likely fail the command matching tests and the pr_warning() at the
end will therefore leak stack bytes to the kernel log.

Fix those issues by simply ensuring we're passed a non-empty string as
the user API apparently expects a trailing '\n' for all commands.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/core/pktgen.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index fdac61cac1..cc07c43494 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -485,6 +485,9 @@ static ssize_t pgctrl_write(struct file *file, const char __user *buf,
 		goto out;
 	}
 
+	if (count == 0)
+		return -EINVAL;
+
 	if (count > sizeof(data))
 		count = sizeof(data);
 
@@ -492,7 +495,7 @@ static ssize_t pgctrl_write(struct file *file, const char __user *buf,
 		err = -EFAULT;
 		goto out;
 	}
-	data[count - 1] = 0;	/* Make string */
+	data[count - 1] = 0;	/* Strip trailing '\n' and terminate string */
 
 	if (!strcmp(data, "stop"))
 		pktgen_stop_all_threads_ifs(pn);
-- 
1.7.10.4
