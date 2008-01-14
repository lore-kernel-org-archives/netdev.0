From: Joonwoo Park <joonwpark81@gmail.com>
Subject: Re: [ipw3945-devel] [PATCH 2/5] iwlwifi: iwl3945 synchronize interruptand
 tasklet for down iwlwifi
Date: Mon, 14 Jan 2008 18:42:42 +0900
Message-ID: <478B2E92.5090901@gmail.com>
References: <11998765481610-git-send-email-joonwpark81@gmail.com>	 <D936D925018D154694D8A362EEB08920035CCD70@orsmsx416.amr.corp.intel.com>	 <b25c3fa70801101724he91d934y9db6636c68a32486@mail.gmail.com>	 <D936D925018D154694D8A362EEB0892003602E2D@orsmsx416.amr.corp.intel.com> <b25c3fa70801101838o7a71cc60h1c8b8a71624aeff9@mail.gmail.com> <478B1EBF.8030701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Chatre, Reinette" <reinette.chatre@intel.com>,
	linux-wireless@vger.kernel.org,
	ipw3945-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: "Zhu, Yi" <yi.zhu@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.184]:21313 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755172AbYANJmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 04:42:47 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1716847rvb.1
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 01:42:46 -0800 (PST)
In-Reply-To: <478B1EBF.8030701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm so sorry for mangled patch.
resending patch with preformat html from thunderbird.


After disabling interrupts, it's possible irq & tasklet is pending or running
This patch eleminates races for down iwlwifi.

Since synchronize_irq can introduce iwl_irq_tasklet, tasklet_kill should be 
called after doing synchronize_irq.
To avoid races between iwl_synchronize_irq and iwl_irq_tasklet
STATUS_INT_ENABLED flag is needed.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   33 ++++++++++++++++++++++-----
 1 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 6e20725..f98cd4f 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -4405,6 +4405,14 @@ static void iwl_print_rx_config_cmd(struct iwl_rxon_cmd *rxon)
 }
 #endif
 
+static void iwl_synchronize_interrupts(struct iwl_priv *priv)
+{
+	synchronize_irq(priv->pci_dev->irq);
+	/* synchornize_irq introduces irq_tasklet,
+	 * tasklet_kill should be called after doing synchronize_irq */
+	tasklet_kill(&priv->irq_tasklet);
+}
+
 static void iwl_enable_interrupts(struct iwl_priv *priv)
 {
 	IWL_DEBUG_ISR("Enabling interrupts\n");
@@ -4413,7 +4421,7 @@ static void iwl_enable_interrupts(struct iwl_priv *priv)
 	iwl_flush32(priv, CSR_INT_MASK);
 }
 
-static inline void iwl_disable_interrupts(struct iwl_priv *priv)
+static inline void __iwl_disable_interrupts(struct iwl_priv *priv)
 {
 	clear_bit(STATUS_INT_ENABLED, &priv->status);
 
@@ -4427,6 +4435,13 @@ static inline void iwl_disable_interrupts(struct iwl_priv *priv)
 	iwl_flush32(priv, CSR_INT);
 	iwl_write32(priv, CSR_FH_INT_STATUS, 0xffffffff);
 	iwl_flush32(priv, CSR_FH_INT_STATUS);
+}
+
+static inline void iwl_disable_interrupts(struct iwl_priv *priv)
+{
+	__iwl_disable_interrupts(priv);
+
+	iwl_synchronize_interrupts(priv);
 
 	IWL_DEBUG_ISR("Disabled interrupts\n");
 }
@@ -4708,7 +4723,8 @@ static void iwl_irq_tasklet(struct iwl_priv *priv)
 		IWL_ERROR("Microcode HW error detected.  Restarting.\n");
 
 		/* Tell the device to stop sending interrupts */
-		iwl_disable_interrupts(priv);
+		__iwl_disable_interrupts(priv);
+		IWL_DEBUG_ISR("Disabled interrupts\n");
 
 		iwl_irq_handle_error(priv);
 
@@ -4814,8 +4830,11 @@ static void iwl_irq_tasklet(struct iwl_priv *priv)
 		IWL_WARNING("   with FH_INT = 0x%08x\n", inta_fh);
 	}
 
-	/* Re-enable all interrupts */
-	iwl_enable_interrupts(priv);
+	/* To avoid race when device goes down,
+	 * it should be discarded to enable interrupts */
+	if (test_bit(STATUS_INT_ENABLED, &priv->status))
+		/* Re-enable all interrupts */
+		iwl_enable_interrupts(priv);
 
 #ifdef CONFIG_IWLWIFI_DEBUG
 	if (iwl_debug_level & (IWL_DL_ISR)) {
@@ -4876,8 +4895,10 @@ unplugged:
 	return IRQ_HANDLED;
 
  none:
-	/* re-enable interrupts here since we don't have anything to service. */
-	iwl_enable_interrupts(priv);
+	if (test_bit(STATUS_INT_ENABLED, &priv->status))
+		/* re-enable interrupts here since we don't have anything
+		 * to service. */
+		iwl_enable_interrupts(priv);
 	spin_unlock(&priv->lock);
 	return IRQ_NONE;
 }
---

Thanks,
Joonwoo

