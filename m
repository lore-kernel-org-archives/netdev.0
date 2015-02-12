From: Junichi Nomura <j-nomura@ce.jp.nec.com>
Subject: [PATCH net] tg3: Hold tp->lock before calling tg3_halt() from
 tg3_init_one()
Date: Thu, 12 Feb 2015 01:26:24 +0000
Message-ID: <54DC0140.6000406@ce.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "prashant@broadcom.com" <prashant@broadcom.com>,
	"mchan@broadcom.com" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO200.gate.nec.co.jp ([210.143.35.50]:36979 "EHLO
	tyo200.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbbBLDAY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 22:00:24 -0500
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t1C1RiEc019524
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 10:27:44 +0900 (JST)
Content-Language: ja-JP
Content-ID: <9FEB00FAAA8C034EA478A888D998E87C@gisp.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tg3_init_one() calls tg3_halt() without tp->lock despite its assumption
and causes deadlock.
If lockdep is enabled, a warning like this shows up before the stall:

  [ BUG: bad unlock balance detected! ]
  3.19.0test #3 Tainted: G            E
  -------------------------------------
  insmod/369 is trying to release lock (&(&tp->lock)->rlock) at:
  [<ffffffffa02d5a1d>] tg3_chip_reset+0x14d/0x780 [tg3]
  but there are no more locks to release!

tg3_init_one() doesn't call tg3_halt() under normal situation but
during kexec kdump I hit this problem.

Fixes: 932f19de ("tg3: Release tp->lock before invoking synchronize_irq()")
Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 615a6db..23a019c 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17855,8 +17855,10 @@ static int tg3_init_one(struct pci_dev *pdev,
 	 */
 	if ((tr32(HOSTCC_MODE) & HOSTCC_MODE_ENABLE) ||
 	    (tr32(WDMAC_MODE) & WDMAC_MODE_ENABLE)) {
+		tg3_full_lock(tp, 0);
 		tw32(MEMARB_MODE, MEMARB_MODE_ENABLE);
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
+		tg3_full_unlock(tp);
 	}
 
 	err = tg3_test_dma(tp);
-- 
1.9.3

-- 
Jun'ichi Nomura, NEC Corporation