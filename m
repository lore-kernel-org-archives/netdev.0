From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 09/14] i40e: use netdev_rss_key_fill() helper
Date: Sun, 16 Nov 2014 06:23:13 -0800
Message-ID: <1416147798-16561-10-git-send-email-edumazet@google.com>
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
Received: from mail-ie0-f201.google.com ([209.85.223.201]:57055 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932154AbaKPOYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:24:10 -0500
Received: by mail-ie0-f201.google.com with SMTP id rd18so2941113iec.2
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:24:09 -0800 (PST)
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
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 10 +++-------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 11 +++--------
 2 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index de664631c807..a0bee83ab2de 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7002,20 +7002,16 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
  **/
 static int i40e_config_rss(struct i40e_pf *pf)
 {
-	/* Set of random keys generated using kernel random number generator */
-	static const u32 seed[I40E_PFQF_HKEY_MAX_INDEX + 1] = {0x41b01687,
-				0x183cfd8c, 0xce880440, 0x580cbc3c, 0x35897377,
-				0x328b25e1, 0x4fa98922, 0xb7d90c14, 0xd5bad70d,
-				0xcd15a2c1, 0xe8580225, 0x4a1e9d11, 0xfe5731be};
+	u32 rss_key[I40E_PFQF_HKEY_MAX_INDEX + 1];
 	struct i40e_hw *hw = &pf->hw;
 	u32 lut = 0;
 	int i, j;
 	u64 hena;
 	u32 reg_val;
 
-	/* Fill out hash function seed */
+	netdev_rss_key_fill(rss_key, sizeof(rss_key));
 	for (i = 0; i <= I40E_PFQF_HKEY_MAX_INDEX; i++)
-		wr32(hw, I40E_PFQF_HKEY(i), seed[i]);
+		wr32(hw, I40E_PFQF_HKEY(i), rss_key[i]);
 
 	/* By default we enable TCP/UDP with IPv4/IPv6 ptypes */
 	hena = (u64)rd32(hw, I40E_PFQF_HENA(0)) |
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index f0d07ad54198..489227891ffb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1434,18 +1434,12 @@ static int next_queue(struct i40evf_adapter *adapter, int j)
  **/
 static void i40evf_configure_rss(struct i40evf_adapter *adapter)
 {
+	u32 rss_key[I40E_VFQF_HKEY_MAX_INDEX + 1];
 	struct i40e_hw *hw = &adapter->hw;
 	u32 lut = 0;
 	int i, j;
 	u64 hena;
 
-	/* Set of random keys generated using kernel random number generator */
-	static const u32 seed[I40E_VFQF_HKEY_MAX_INDEX + 1] = {
-			0x794221b4, 0xbca0c5ab, 0x6cd5ebd9, 0x1ada6127,
-			0x983b3aa1, 0x1c4e71eb, 0x7f6328b2, 0xfcdc0da0,
-			0xc135cafa, 0x7a6f7e2d, 0xe7102d28, 0x163cd12e,
-			0x4954b126 };
-
 	/* No RSS for single queue. */
 	if (adapter->num_active_queues == 1) {
 		wr32(hw, I40E_VFQF_HENA(0), 0);
@@ -1454,8 +1448,9 @@ static void i40evf_configure_rss(struct i40evf_adapter *adapter)
 	}
 
 	/* Hash type is configured by the PF - we just supply the key */
+	netdev_rss_key_fill(rss_key, sizeof(rss_key));
 	for (i = 0; i <= I40E_VFQF_HKEY_MAX_INDEX; i++)
-		wr32(hw, I40E_VFQF_HKEY(i), seed[i]);
+		wr32(hw, I40E_VFQF_HKEY(i), rss_key[i]);
 
 	/* Enable PCTYPES for RSS, TCP/UDP with IPv4/IPv6 */
 	hena = I40E_DEFAULT_RSS_HENA;
-- 
2.1.0.rc2.206.gedb03e5
