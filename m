From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] netconsole: Disable softirqs in write_msg()
Date: Wed, 19 Nov 2008 08:41:06 +0000
Message-ID: <20081119084106.GA6699@ff.dom.local>
References: <87y6zwwy5c.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>,
	Johannes Berg <johannes@sipsolutions.net>,
	Ferenc Wagner <wferi@niif.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:37544 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbYKSIlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 03:41:14 -0500
Received: by ug-out-1314.google.com with SMTP id 39so449492ugf.37
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 00:41:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <87y6zwwy5c.fsf@tac.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This report: http://marc.info/?l=linux-netdev&m=122599341430090&w=2
shows local_bh_enable() is used in the wrong context (irqs disabled).
It happens when a usual network path is called by netconsole, which
simply turns off hardirqs around this all.

This patch additionally disables softirqs to avoid possibility of
enabling bh and calling do_softirq() with hardirqs disabled.

Reported-by: Ferenc Wagner <wferi@niif.hu>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 drivers/net/netconsole.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index d304d38..f6ecad8 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -702,6 +702,8 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 	if (list_empty(&target_list))
 		return;
 
+	/* Avoid enabling softirqs with hardirqs disabled */
+	local_bh_disable();
 	spin_lock_irqsave(&target_list_lock, flags);
 	list_for_each_entry(nt, &target_list, list) {
 		netconsole_target_get(nt);
@@ -723,6 +725,7 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 		netconsole_target_put(nt);
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
+	local_bh_enable();
 }
 
 static struct console netconsole = {
