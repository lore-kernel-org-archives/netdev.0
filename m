From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH] net: fec: Detect and recover receive queue hangs
Date: Sun, 20 Nov 2016 06:18:13 +0000
Message-ID: <AM4PR0401MB226045E9C87FADD2717853AAFFB20@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <1479417282-15540-1-git-send-email-chris.lesiak@licor.com>
 <AM4PR0401MB2260764510A33C534AB0136FFFB00@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <b420fcd7-4171-f5c7-9d0c-cd8809e31bbc@licor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Jaccon Bastiaansen" <jaccon.bastiaansen@gmail.com>
To: Chris Lesiak <chris.lesiak@licor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b420fcd7-4171-f5c7-9d0c-cd8809e31bbc@licor.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Lesiak <chris.lesiak@licor.com> Sent: Friday, November 18, 2016=
 10:37 PM
 >To: Andy Duan <fugang.duan@nxp.com>
 >Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Jaccon
 >Bastiaansen <jaccon.bastiaansen@gmail.com>
 >Subject: Re: [PATCH] net: fec: Detect and recover receive queue hangs
 >
 >On 11/18/2016 12:44 AM, Andy Duan wrote:
 >> From: Chris Lesiak <chris.lesiak@licor.com> Sent: Friday, November 18,
 >> 2016 5:15 AM
 >>  >To: Andy Duan <fugang.duan@nxp.com>
 >>  >Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Jaccon
 >> >Bastiaansen <jaccon.bastiaansen@gmail.com>; chris.lesiak@licor.com
 >>  >Subject: [PATCH] net: fec: Detect and recover receive queue hangs  >
 >> >This corrects a problem that appears to be similar to ERR006358.  But
 >> while
 >>  >ERR006358 is a race when the tx queue transitions from empty to not
 >> empty,  >this problem is a race when the rx queue transitions from full=
 to
 >not full.
 >>  >
 >>  >The symptom is a receive queue that is stuck.  The ENET_RDAR
 >> register will  >read 0, indicating that there are no empty receive
 >> descriptors in the receive  >ring.  Since no additional frames can be q=
ueued,
 >no RXF interrupts occur.
 >>  >
 >>  >This problem can be triggered with a 1 Gb link and about 400 Mbps of
 >traffic.
 >
 >I can cause the error by running the following on an imx6q: iperf -s -u A=
nd
 >sending packets from the other end of a 1 Gbps link:
 >iperf -c $IPADDR -u -b40000pps
 >
 >A few others have seen this problem.
 >See: https://community.nxp.com/thread/322882
 >
 >>  >
 >>  >This patch detects this condition, sets the work_rx bit, and
 >> reschedules the  >poll method.
 >>  >
 >>  >Signed-off-by: Chris Lesiak <chris.lesiak@licor.com>
 >>  >---
 >>  > drivers/net/ethernet/freescale/fec_main.c | 31
 >> >+++++++++++++++++++++++++++++++  > 1 file changed, 31 insertions(+)
 >> > Firstly, how to reproduce the issue, pls list the reproduce steps.
 >> Thanks.
 >> Secondly, pls check below comments.
 >>
 >>  >diff --git a/drivers/net/ethernet/freescale/fec_main.c
 >>  >b/drivers/net/ethernet/freescale/fec_main.c
 >>  >index fea0f33..8a87037 100644
 >>  >--- a/drivers/net/ethernet/freescale/fec_main.c
 >>  >+++ b/drivers/net/ethernet/freescale/fec_main.c
 >>  >@@ -1588,6 +1588,34 @@ fec_enet_interrupt(int irq, void *dev_id)
 >>  > 	return ret;
 >>  > }
 >>  >
 >>  >+static inline bool
 >>  >+fec_enet_recover_rxq(struct fec_enet_private *fep, u16 queue_id) {
 >>  >+	int work_bit =3D (queue_id =3D=3D 0) ? 2 : ((queue_id =3D=3D 1) ? 0=
 : 1);
 >>  >+
 >>  >+	if (readl(fep->rx_queue[queue_id]->bd.reg_desc_active))
 >> If rx ring is really empty in slight throughput cases,  rdar is always =
cleared,
 >then there always do napi reschedule.
 >
 >I think that you are concerned that if rdar is zero due to this hardware
 >problem, but the rx ring is actually empty, then fec_enet_rx_queue will
 >never do a write to rdar so that it can be non-zero.  That will cause nap=
i to
 >always be resceduled.
 >
 >I suppose that might be the case with zero rx traffic, and I was concerne=
d
 >that it might be true even when there was rx traffic.  I suspected that t=
he
 >hardware, seeing that rdar is zero, would never queue another packet, eve=
n
 >if there were in fact empty descriptors.  But it doesn't seem to be the c=
ase.  It
 >does reschedule multiple times, but eventually sees some packets in the r=
x
 >ring and recovers.
 >
 >I admit that I do not completely understand how that can happen.  I did
 >confirm that fec_enet_active_rxring is not being called.
 >
 >Maybe someone with a deeper understanding of the fec than I can provide
 >an explanation.
 >
The patch needs to hold on for some time (days), I will reserve time to inv=
estigate the issue.
Thanks.

 >>
 >>  >+		return false;
 >>  >+
 >>  >+	dev_notice_once(&fep->pdev->dev, "Recovered rx queue\n");
 >>  >+
 >>  >+	fep->work_rx |=3D 1 << work_bit;
 >>  >+
 >>  >+	return true;
 >>  >+}
 >>  >+
 >>  >+static inline bool fec_enet_recover_rxqs(struct fec_enet_private
 >> *fep)  >+{
 >>  >+	unsigned int q;
 >>  >+	bool ret =3D false;
 >>  >+
 >>  >+	for (q =3D 0; q < fep->num_rx_queues; q++) {
 >>  >+		if (fec_enet_recover_rxq(fep, q))
 >>  >+			ret =3D true;
 >>  >+	}
 >>  >+
 >>  >+	return ret;
 >>  >+}
 >>  >+
 >>  > static int fec_enet_rx_napi(struct napi_struct *napi, int budget)  {
 >>  > 	struct net_device *ndev =3D napi->dev;
 >>  >@@ -1601,6 +1629,9 @@ static int fec_enet_rx_napi(struct napi_struct
 >> *napi,  >int budget)
 >>  > 	if (pkts < budget) {
 >>  > 		napi_complete(napi);
 >>  > 		writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
 >>  >+
 >>  >+		if (fec_enet_recover_rxqs(fep) && napi_reschedule(napi))
 >>  >+			writel(FEC_NAPI_IMASK, fep->hwp + FEC_IMASK);
 >>  > 	}
 >>  > 	return pkts;
 >>  > }
 >>  >--
 >>  >2.5.5
 >>
 >
 >
 >--
 >Chris Lesiak
 >Principal Design Engineer, Software
 >LI-COR Biosciences
 >chris.lesiak@licor.com
 >
 >Any opinions expressed are those of the author and do not necessarily
 >represent those of his employer.
 >
