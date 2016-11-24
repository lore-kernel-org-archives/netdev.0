From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] net/iucv: use explicit clean up labels in iucv_init()
Date: Thu, 24 Nov 2016 17:10:13 +0100
Message-ID: <20161124161013.dukr42y2nwscosk6@linutronix.de>
References: <20161117183541.8588-1-bigeasy@linutronix.de>
 <20161117183541.8588-13-bigeasy@linutronix.de>
 <62f8abea-093c-cac5-ffb1-7b8710aa0a91@linux.vnet.ibm.com>
 <20161124091046.hixy3j4ibt7xzezr@linutronix.de>
 <20161124141415.llqki5vo7nqdusqv@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, rt@linutronix.de,
        "David S. Miller" <davem@davemloft.net>,
        linux-s390@vger.kernel.org, netdev@vger.kernel.org
To: Ursula Braun <ubraun@linux.vnet.ibm.com>, tglx@linutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161124141415.llqki5vo7nqdusqv@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ursula suggested to use explicit labels for clean up in the error path
instead of one `out_free' label which handles multiple exits.
Since the previous patch got already applied, here is a follow up patch.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 net/iucv/iucv.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/iucv/iucv.c b/net/iucv/iucv.c
index f0d6afc5d4a9..8f7ef167c45a 100644
--- a/net/iucv/iucv.c
+++ b/net/iucv/iucv.c
@@ -2038,16 +2038,16 @@ static int __init iucv_init(void)
 	rc = cpuhp_setup_state(CPUHP_NET_IUCV_PREPARE, "net/iucv:prepare",
 			       iucv_cpu_prepare, iucv_cpu_dead);
 	if (rc)
-		goto out_free;
+		goto out_dev;
 	rc = cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "net/iucv:online",
 			       iucv_cpu_online, iucv_cpu_down_prep);
 	if (rc < 0)
-		goto out_free;
+		goto out_prep;
 	iucv_online = rc;
 
 	rc = register_reboot_notifier(&iucv_reboot_notifier);
 	if (rc)
-		goto out_free;
+		goto out_remove_hp;
 	ASCEBC(iucv_error_no_listener, 16);
 	ASCEBC(iucv_error_no_memory, 16);
 	ASCEBC(iucv_error_pathid, 16);
@@ -2061,11 +2061,11 @@ static int __init iucv_init(void)
 
 out_reboot:
 	unregister_reboot_notifier(&iucv_reboot_notifier);
-out_free:
-	if (iucv_online)
-		cpuhp_remove_state(iucv_online);
+out_remove_hp:
+	cpuhp_remove_state(iucv_online);
+out_prep:
 	cpuhp_remove_state(CPUHP_NET_IUCV_PREPARE);
-
+out_dev:
 	root_device_unregister(iucv_root);
 out_int:
 	unregister_external_irq(EXT_IRQ_IUCV, iucv_external_interrupt);
-- 
2.10.2
