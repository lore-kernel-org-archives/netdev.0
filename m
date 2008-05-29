From: James Cammarata <jimi@sngx.net>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool - e1000/pcnet32
Date: Wed, 28 May 2008 21:08:05 -0500
Message-ID: <483E1005.3080804@sngx.net>
References: <482DA5B6.1020606@sngx.net> <482DB46A.8020103@cosmosbay.com> <482EF192.4070707@sngx.net> <482F5113.5090703@cosmosbay.com> <482F610D.2080108@sngx.net> <20080518003104.GK28241@solarflare.com> <482FBA09.80201@sngx.net> <483E0AAE.2020107@sngx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754658AbYE2CHE@vger.kernel.org>
In-Reply-To: <483E0AAE.2020107@sngx.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Missed an errant define in some copied code (from the get_stats function in e1000_main.c).

Signed-off-by: James Cammarata <jimi@sngx.net>
---

--- linux-2.6.25.4/drivers/net/e1000/e1000_main.c	2008-05-15 10:00:12.000000000 -0500
+++ linux-2.6.25.4-jcammara/drivers/net/e1000/e1000_main.c	2008-05-28 21:06:19.000000000 -0500
@@ -141,6 +141,7 @@ static void e1000_free_tx_resources(stru
 static void e1000_free_rx_resources(struct e1000_adapter *adapter,
                              struct e1000_rx_ring *rx_ring);
 void e1000_update_stats(struct e1000_adapter *adapter);
+void e1000_clear_stats(struct e1000_adapter *adapter);
 
 static int e1000_init_module(void);
 static void e1000_exit_module(void);
@@ -3819,6 +3820,29 @@ e1000_update_stats(struct e1000_adapter 
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 }
 
+void
+e1000_clear_stats(struct e1000_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	unsigned long flags;
+
+	/*
+	 * Prevent stats update while adapter is being reset, or if the pci
+	 * connection is down.
+	 */
+	if (adapter->link_speed == 0)
+		return;
+	if (pci_channel_offline(pdev))
+		return;
+
+	spin_lock_irqsave(&adapter->stats_lock, flags);
+
+	memset(&adapter->stats, 0, sizeof(struct e1000_hw_stats));
+	memset(&adapter->net_stats, 0, sizeof(struct net_device_stats));
+
+	spin_unlock_irqrestore(&adapter->stats_lock, flags);
+}
+
 /**
  * e1000_intr_msi - Interrupt Handler
  * @irq: interrupt number
