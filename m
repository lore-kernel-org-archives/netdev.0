From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH] net: fec: Detect and recover receive queue hangs
Date: Fri, 18 Nov 2016 06:44:18 +0000
Message-ID: <AM4PR0401MB2260764510A33C534AB0136FFFB00@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <1479417282-15540-1-git-send-email-chris.lesiak@licor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Jaccon Bastiaansen" <jaccon.bastiaansen@gmail.com>
To: Chris Lesiak <chris.lesiak@licor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479417282-15540-1-git-send-email-chris.lesiak@licor.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Lesiak <chris.lesiak@licor.com> Sent: Friday, November 18, 2016=
 5:15 AM
 >To: Andy Duan <fugang.duan@nxp.com>
 >Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Jaccon
 >Bastiaansen <jaccon.bastiaansen@gmail.com>; chris.lesiak@licor.com
 >Subject: [PATCH] net: fec: Detect and recover receive queue hangs
 >
 >This corrects a problem that appears to be similar to ERR006358.  But whi=
le
 >ERR006358 is a race when the tx queue transitions from empty to not empty=
,
 >this problem is a race when the rx queue transitions from full to not ful=
l.
 >
 >The symptom is a receive queue that is stuck.  The ENET_RDAR register wil=
l
 >read 0, indicating that there are no empty receive descriptors in the rec=
eive
 >ring.  Since no additional frames can be queued, no RXF interrupts occur.
 >
 >This problem can be triggered with a 1 Gb link and about 400 Mbps of traf=
fic.
 >
 >This patch detects this condition, sets the work_rx bit, and reschedules =
the
 >poll method.
 >
 >Signed-off-by: Chris Lesiak <chris.lesiak@licor.com>
 >---
 > drivers/net/ethernet/freescale/fec_main.c | 31
 >+++++++++++++++++++++++++++++++
 > 1 file changed, 31 insertions(+)
 >
Firstly, how to reproduce the issue, pls list the reproduce steps. Thanks.
Secondly, pls check below comments.

 >diff --git a/drivers/net/ethernet/freescale/fec_main.c
 >b/drivers/net/ethernet/freescale/fec_main.c
 >index fea0f33..8a87037 100644
 >--- a/drivers/net/ethernet/freescale/fec_main.c
 >+++ b/drivers/net/ethernet/freescale/fec_main.c
 >@@ -1588,6 +1588,34 @@ fec_enet_interrupt(int irq, void *dev_id)
 > 	return ret;
 > }
 >
 >+static inline bool
 >+fec_enet_recover_rxq(struct fec_enet_private *fep, u16 queue_id) {
 >+	int work_bit =3D (queue_id =3D=3D 0) ? 2 : ((queue_id =3D=3D 1) ? 0 : 1=
);
 >+
 >+	if (readl(fep->rx_queue[queue_id]->bd.reg_desc_active))
If rx ring is really empty in slight throughput cases,  rdar is always clea=
red, then there always do napi reschedule.

 >+		return false;
 >+
 >+	dev_notice_once(&fep->pdev->dev, "Recovered rx queue\n");
 >+
 >+	fep->work_rx |=3D 1 << work_bit;
 >+
 >+	return true;
 >+}
 >+
 >+static inline bool fec_enet_recover_rxqs(struct fec_enet_private *fep)
 >+{
 >+	unsigned int q;
 >+	bool ret =3D false;
 >+
 >+	for (q =3D 0; q < fep->num_rx_queues; q++) {
 >+		if (fec_enet_recover_rxq(fep, q))
 >+			ret =3D true;
 >+	}
 >+
 >+	return ret;
 >+}
 >+
 > static int fec_enet_rx_napi(struct napi_struct *napi, int budget)  {
 > 	struct net_device *ndev =3D napi->dev;
 >@@ -1601,6 +1629,9 @@ static int fec_enet_rx_napi(struct napi_struct *nap=
i,
 >int budget)
 > 	if (pkts < budget) {
 > 		napi_complete(napi);
 > 		writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
 >+
 >+		if (fec_enet_recover_rxqs(fep) && napi_reschedule(napi))
 >+			writel(FEC_NAPI_IMASK, fep->hwp + FEC_IMASK);
 > 	}
 > 	return pkts;
 > }
 >--
 >2.5.5
