From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Zynq macb
Date: Thu, 13 Mar 2014 15:16:51 -0700
Message-ID: <c6344e9b-fa32-4313-8950-59030c4bffb8@AM1EHSMHS003.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>,
	Michal Simek <michal.simek@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	Punnaiah Choudary Kalluri
	<punnaiah.choudary.kalluri@xilinx.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Nicolas,

I did some testing on the current linux-next tree and ran iperf on Zynq=
=2E
It seems that network and even the whole system can collapse when doing
that.
I don't really know what's going on, but once I saw the message:
	"inconsistent Rx descriptor chain"
printed twice (system frozen afterwards).

I don't know what exactly is going wrong, but suspect something around
memory/DMA. I have no clue whether it makes any sense or not, but I
tried using the macb_* functions instead of the gem_* ones (see diff be=
low).
That seems to result in a stable system and working Ethernet.

So, I guess my questions are:
Does any of this make sense?
Is it reasonable for the Zynq GEM to use the macb_* routines (are there
any implementation options to check whether one or the other are
appropriate for an macb implementation?)?
Any other hints?

	Thanks,
	S=C3=B6ren

-----------8<-------------8<---------------8<--------------8<----------=
------8<--------
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet=
/cadence/macb.c
index d0c38e01e99f..8c73cd43457e 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1905,17 +1905,10 @@ static int __init macb_probe(struct platform_de=
vice *pdev)
        dev->base_addr =3D regs->start;
=20
        /* setup appropriated routines according to adapter type */
-       if (macb_is_gem(bp)) {
-               bp->macbgem_ops.mog_alloc_rx_buffers =3D gem_alloc_rx_b=
uffers;
-               bp->macbgem_ops.mog_free_rx_buffers =3D gem_free_rx_buf=
fers;
-               bp->macbgem_ops.mog_init_rings =3D gem_init_rings;
-               bp->macbgem_ops.mog_rx =3D gem_rx;
-       } else {
-               bp->macbgem_ops.mog_alloc_rx_buffers =3D macb_alloc_rx_=
buffers;
-               bp->macbgem_ops.mog_free_rx_buffers =3D macb_free_rx_bu=
ffers;
-               bp->macbgem_ops.mog_init_rings =3D macb_init_rings;
-               bp->macbgem_ops.mog_rx =3D macb_rx;
-       }
+       bp->macbgem_ops.mog_alloc_rx_buffers =3D macb_alloc_rx_buffers;
+       bp->macbgem_ops.mog_free_rx_buffers =3D macb_free_rx_buffers;
+       bp->macbgem_ops.mog_init_rings =3D macb_init_rings;
+       bp->macbgem_ops.mog_rx =3D macb_rx;
=20
        /* Set MII management clock divider */
        config =3D macb_mdc_clk_div(bp);
