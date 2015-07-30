From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH] printk: Warn about dropped messages also on extended consoles
Date: Thu, 30 Jul 2015 13:28:52 +0200
Message-ID: <1438255732-31326-1-git-send-email-pmladek@suse.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Petr Mladek <pmladek@suse.com>
To: akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The commit #6fe29354befe4c ("printk: implement support for extended console
drivers") added an extra buffer to format messages for extended consoles.
We need to put there also the warning about dropped messages, so it appears
on these consoles.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/printk/printk.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index cf8c24203368..77d3d3698283 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -2254,8 +2254,15 @@ again:
 		}
 
 		if (console_seq < log_first_seq) {
-			len = sprintf(text, "** %u printk messages dropped ** ",
-				      (unsigned)(log_first_seq - console_seq));
+			static const char dropped_msg[] =
+				"** %u printk messages dropped ** ";
+			unsigned int dropped_count =
+				(unsigned int)(log_first_seq - console_seq);
+
+			len = sprintf(text, dropped_msg, dropped_count);
+			if (nr_ext_console_drivers)
+				ext_len = sprintf(ext_text, dropped_msg,
+						  dropped_count);
 
 			/* messages are gone, move to first one */
 			console_seq = log_first_seq;
@@ -2290,8 +2297,8 @@ skip:
 		len += msg_print_text(msg, console_prev, false,
 				      text + len, sizeof(text) - len);
 		if (nr_ext_console_drivers) {
-			ext_len = msg_print_ext_header(ext_text,
-						sizeof(ext_text),
+			ext_len += msg_print_ext_header(ext_text + ext_len,
+						sizeof(ext_text) - ext_len,
 						msg, console_seq, console_prev);
 			ext_len += msg_print_ext_body(ext_text + ext_len,
 						sizeof(ext_text) - ext_len,
-- 
1.8.5.6
