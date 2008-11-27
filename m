From: Hollis Blanchard <hollisb@us.ibm.com>
Subject: [PATCH 1 of 2] netconsole: don't require struct console to send data
Date: Thu, 27 Nov 2008 15:11:01 -0600
Message-ID: <5b87df37a941e38bfd93.1227820261@localhost.localdomain>
References: <patchbomb.1227820260@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fall-pradero.atl.sa.earthlink.net ([207.69.195.104]:33057 "EHLO
	fall-pradero.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752932AbYK0VWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 16:22:55 -0500
In-Reply-To: <patchbomb.1227820260@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will allow callers not on the console path to use write_msg().

Signed-off-by: Hollis Blanchard <hollisb@us.ibm.com>

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -67,7 +67,7 @@ __setup("netconsole=", option_setup);
 /* Linked list of all configured targets */
 static LIST_HEAD(target_list);
 
-/* This needs to be a spinlock because write_msg() cannot sleep */
+/* This needs to be a spinlock because netconsole_write_msg() cannot sleep */
 static DEFINE_SPINLOCK(target_list_lock);
 
 /**
@@ -694,7 +694,7 @@ static struct notifier_block netconsole_
 	.notifier_call  = netconsole_netdev_event,
 };
 
-static void write_msg(struct console *con, const char *msg, unsigned int len)
+static void netconsole_write_msg(const char *msg, unsigned int len)
 {
 	int frag, left;
 	unsigned long flags;
@@ -728,10 +728,15 @@ static void write_msg(struct console *co
 	spin_unlock_irqrestore(&target_list_lock, flags);
 }
 
+static void netconsole_console_write(struct console *con, const char *msg, unsigned int len)
+{
+	netconsole_write_msg(msg, len);
+}
+
 static struct console netconsole = {
 	.name	= "netcon",
 	.flags	= CON_ENABLED,
-	.write	= write_msg,
+	.write	= netconsole_console_write,
 };
 
 static int __init init_netconsole(void)
