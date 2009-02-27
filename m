From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 07/11] libfc: use lso_max for sequence offload
Date: Fri, 27 Feb 2009 14:07:10 -0800
Message-ID: <20090227220710.4987.65927.stgit.yi.zou@intel.com>
References: <20090227220034.4987.50755.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090227220034.4987.50755.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure for large send is supported by LLD in outgoing FCP data, we are only
sending the lso_max a time in one single large send, since that is what
supported by LLD.

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 drivers/scsi/libfc/fc_fcp.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/scsi/libfc/fc_fcp.c b/drivers/scsi/libfc/fc_fcp.c
index 2a631d7..80e8491 100644
--- a/drivers/scsi/libfc/fc_fcp.c
+++ b/drivers/scsi/libfc/fc_fcp.c
@@ -435,7 +435,13 @@ static int fc_fcp_send_data(struct fc_fcp_pkt *fsp, struct fc_seq *seq,
 	 * burst length (t_blen) to seq_blen, otherwise set t_blen
 	 * to max FC frame payload previously set in fsp->max_payload.
 	 */
-	t_blen = lp->seq_offload ? seq_blen : fsp->max_payload;
+	t_blen = fsp->max_payload;
+	if (lp->seq_offload) {
+		t_blen = min(seq_blen, (size_t)lp->lso_max);
+		FC_DEBUG_FCP("fsp=%p:lso:blen=%zx lso_max=0x%x t_blen=%zx\n",
+			   fsp, seq_blen, lp->lso_max, t_blen);
+	}
+
 	WARN_ON(t_blen < FC_MIN_MAX_PAYLOAD);
 	if (t_blen > 512)
 		t_blen &= ~(512 - 1);	/* round down to block size */

