From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: Re: [PATCH] ServerEngines, benet: Avoid potential null deref in
 be_cmd_get_seeprom_data()
Date: Fri, 4 Feb 2011 21:18:28 -0600
Message-ID: <20110205031828.GA12772@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>, <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Jesper Juhl [jj@chaosbits.net]
> ent: Thursday, February 03, 2011 3:27 PM
> To: netdev@vger.kernel.org
> Cc: linux-drivers; linux-kernel@vger.kernel.org; Khaparde, Ajit; Bandi, Sarveshwar; Seetharaman, Subramanian; Perla, Sathya
> Subject: [PATCH] ServerEngines, benet: Avoid potential null deref in be_cmd_get_seeprom_data()

> wrb_from_mccq() may return null, so we may crash on a null deref in
> be_cmd_get_seeprom_data().
> This avoids that potential crash.

> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Thanks Jesper.
But because we have acquired a lock, we need to release it.
I would suggest considering the following patch.
 
---

[PATCH] ServerEngines, benet: Avoid potential null deref in be_cmd_get_seeprom_data()

Found by: Jesper Juhl <jj@chaosbits.net>

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_cmds.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 0c7811f..a179cc6 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1786,6 +1786,10 @@ int be_cmd_get_seeprom_data(struct be_adapter *adapter,
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = nonemb_cmd->va;
 	sge = nonembedded_sgl(wrb);
 
@@ -1801,6 +1805,7 @@ int be_cmd_get_seeprom_data(struct be_adapter *adapter,
 
 	status = be_mcc_notify_wait(adapter);
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
-- 
1.7.1
