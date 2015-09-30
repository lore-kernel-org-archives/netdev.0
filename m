From: Casey Leedom <leedom@chelsio.com>
Subject: RE: [PATCHv2 net-next 2/4] cxgb4: For T4, don't read the Firmware
 Mailbox Control register
Date: Wed, 30 Sep 2015 17:53:50 +0000
Message-ID: <4985EFDD773FCB459EF7915D2A3621AD93BB822C@nice.asicdesigners.com>
References: <1443625411-12096-1-git-send-email-hariprasad@chelsio.com>,<1443625411-12096-3-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>
To: Hariprasad S <hariprasad@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14488 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272AbbI3Rxx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 13:53:53 -0400
In-Reply-To: <1443625411-12096-3-git-send-email-hariprasad@chelsio.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hari,

  I think you missed the corresponding change that's needed for the const char *owner[] array.  You need to add an "<unread>" entry so the index of "4" makes sense.

Casey

________________________________________
From: Hariprasad Shenai [hariprasad@chelsio.com]
Sent: Wednesday, September 30, 2015 8:03 AM
To: netdev@vger.kernel.org
Cc: davem@davemloft.net; Casey Leedom; Nirranjan Kirubaharan; Hariprasad S
Subject: [PATCHv2 net-next 2/4] cxgb4: For T4, don't read the Firmware Mailbox Control register

T4 doesn't have the Shadow copy of the register which we can read without
side effect. So don't read mbox control register for T4 adapter

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 0a87a32..8001619 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1134,12 +1134,20 @@ static int mbox_show(struct seq_file *seq, void *v)
        unsigned int mbox = (uintptr_t)seq->private & 7;
        struct adapter *adap = seq->private - mbox;
        void __iomem *addr = adap->regs + PF_REG(mbox, CIM_PF_MAILBOX_DATA_A);
-       unsigned int ctrl_reg = (is_t4(adap->params.chip)
-                                ? CIM_PF_MAILBOX_CTRL_A
-                                : CIM_PF_MAILBOX_CTRL_SHADOW_COPY_A);
-       void __iomem *ctrl = adap->regs + PF_REG(mbox, ctrl_reg);

-       i = MBOWNER_G(readl(ctrl));
+       /* For T4 we don't have a shadow copy of the Mailbox Control register.
+        * And since reading that real register causes a side effect of
+        * granting ownership, we're best of simply not reading it at all.
+        */
+       if (is_t4(adap->params.chip)) {
+               i = 4; /* index of "<unread>" */
+       } else {
+               unsigned int ctrl_reg = CIM_PF_MAILBOX_CTRL_SHADOW_COPY_A;
+               void __iomem *ctrl = adap->regs + PF_REG(mbox, ctrl_reg);
+
+               i = MBOWNER_G(readl(ctrl));
+       }
+
        seq_printf(seq, "mailbox owned by %s\n\n", owner[i]);

        for (i = 0; i < MBOX_LEN; i += 8)
--
2.3.4
