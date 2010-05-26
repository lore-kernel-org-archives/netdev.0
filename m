From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 4/17] drivers/isdn/hardware/mISDN: Add missing spin_unlock
Date: Wed, 26 May 2010 17:55:10 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005261754560.23743@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Add a spin_unlock missing on the error path.  The return value of write_reg
seems to be completely ignored, so it seems that the lock should be
released in every case.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression E1;
@@

* spin_lock(E1,...);
  <+... when != E1
  if (...) {
    ... when != E1
*   return ...;
  }
  ...+>
* spin_unlock(E1,...);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/isdn/hardware/mISDN/hfcsusb.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index b3b7e28..8700474 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -97,8 +97,10 @@ static int write_reg(struct hfcsusb *hw, __u8 reg, __u8 val)
 			hw->name, __func__, reg, val);
 
 	spin_lock(&hw->ctrl_lock);
-	if (hw->ctrl_cnt >= HFC_CTRL_BUFSIZE)
+	if (hw->ctrl_cnt >= HFC_CTRL_BUFSIZE) {
+		spin_unlock(&hw->ctrl_lock);
 		return 1;
+	}
 	buf = &hw->ctrl_buff[hw->ctrl_in_idx];
 	buf->hfcs_reg = reg;
 	buf->reg_val = val;
