From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 08/14] fm10k: use netdev_rss_key_fill() helper
Date: Sun, 16 Nov 2014 06:23:12 -0800
Message-ID: <1416147798-16561-9-git-send-email-edumazet@google.com>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Thomas Lendacky <Thomas.Lendacky@amd.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shradha Shah <sshah@solarflare.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:48805 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932154AbaKPOYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:24:06 -0500
Received: by mail-ob0-f202.google.com with SMTP id uz6so2642976obc.5
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:24:05 -0800 (PST)
In-Reply-To: <1416147798-16561-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of well known RSS key increases attack surface.
Switch to a random one, using generic helper so that all
ports share a common key.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index a0cb74ab3dc6..4f5892cc32d7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1551,15 +1551,11 @@ void fm10k_down(struct fm10k_intfc *interface)
 static int fm10k_sw_init(struct fm10k_intfc *interface,
 			 const struct pci_device_id *ent)
 {
-	static const u32 seed[FM10K_RSSRK_SIZE] = { 0xda565a6d, 0xc20e5b25,
-						    0x3d256741, 0xb08fa343,
-						    0xcb2bcad0, 0xb4307bae,
-						    0xa32dcb77, 0x0cf23080,
-						    0x3bb7426a, 0xfa01acbe };
 	const struct fm10k_info *fi = fm10k_info_tbl[ent->driver_data];
 	struct fm10k_hw *hw = &interface->hw;
 	struct pci_dev *pdev = interface->pdev;
 	struct net_device *netdev = interface->netdev;
+	u32 rss_key[FM10K_RSSRK_SIZE];
 	unsigned int rss;
 	int err;
 
@@ -1673,8 +1669,8 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 	/* initialize vxlan_port list */
 	INIT_LIST_HEAD(&interface->vxlan_port);
 
-	/* initialize RSS key */
-	memcpy(interface->rssrk, seed, sizeof(seed));
+	netdev_rss_key_fill(rss_key, sizeof(rss_key));
+	memcpy(interface->rssrk, rss_key, sizeof(rss_key));
 
 	/* Start off interface as being down */
 	set_bit(__FM10K_DOWN, &interface->state);
-- 
2.1.0.rc2.206.gedb03e5
