From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net] xen-netback: respect user provided max_queues
Date: Wed, 9 Sep 2015 11:09:55 +0100
Message-ID: <1441793395-25537-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Johnny Strom <johnny.strom@linuxsolutions.fi>,
	David Vrabel <david.vrabel@citrix.com>
To: Xen-devel <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:46132 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbbIIKJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 06:09:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Originally that parameter was always reset to num_online_cpus during
module initialisation, which renders it useless.

The fix is to only set max_queues to num_online_cpus when user has not
provided a value.

Reported-by: Johnny Strom <johnny.strom@linuxsolutions.fi>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
---
Cc: Johnny Strom <johnny.strom@linuxsolutions.fi>
Cc: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/netback.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 42569b9..b219a80 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -67,7 +67,7 @@ module_param(rx_drain_timeout_msecs, uint, 0444);
 unsigned int rx_stall_timeout_msecs = 60000;
 module_param(rx_stall_timeout_msecs, uint, 0444);
 
-unsigned int xenvif_max_queues;
+unsigned int xenvif_max_queues = 0;
 module_param_named(max_queues, xenvif_max_queues, uint, 0644);
 MODULE_PARM_DESC(max_queues,
 		 "Maximum number of queues per virtual interface");
@@ -2105,8 +2105,11 @@ static int __init netback_init(void)
 	if (!xen_domain())
 		return -ENODEV;
 
-	/* Allow as many queues as there are CPUs, by default */
-	xenvif_max_queues = num_online_cpus();
+	/* Allow as many queues as there are CPUs if user has not
+	 * specified a value.
+	 */
+	if (xenvif_max_queues == 0)
+		xenvif_max_queues = num_online_cpus();
 
 	if (fatal_skb_slots < XEN_NETBK_LEGACY_SLOTS_MAX) {
 		pr_info("fatal_skb_slots too small (%d), bump it to XEN_NETBK_LEGACY_SLOTS_MAX (%d)\n",
-- 
2.1.4
