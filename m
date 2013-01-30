From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: i.Mx6Quad - eth0: tx queue full!
Date: Wed, 30 Jan 2013 08:37:14 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE011B0826@039-SN2MPN1-022.039d.mgd.msft.net>
References: <5106B7EE.3040603@gmail.com>
 <5106D5D4.2090200@boundarydevices.com> <5107FA00.2010809@gmail.com>
 <51081910.4030707@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Ungerer <gregungerer@westnet.com.au>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	LAK <linux-arm-kernel@lists.infradead.org>,
	=?iso-8859-1?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
	Fabio Estevam <festevam@gmail.com>
To: Troy Kisky <troy.kisky@boundarydevices.com>,
	Vikram Narayanan <vikram186@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:29950
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751082Ab3A3IhS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 03:37:18 -0500
In-Reply-To: <51081910.4030707@boundarydevices.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all

The issue cannot be found kernel 3.0.35 branch: (even run stress test w=
ith IPU and VPU)
ssh://sw-git01-tx30/git/sw_git/repos/linux-2.6-imx.git =20
branch name: imx_3.0.35


The patch as below:


=46rom 91a0c892263e57ecde9e9ff38be3acdb7f66a17f Mon Sep 17 00:00:00 200=
1
=46rom: Fugang Duan <B38611@freescale.com>
Date: Thu, 9 Aug 2012 17:59:44 +0800
Subject: [PATCH] ENGR00180288 - FEC : Fix kernel dump about eth0

Kernel dump when do wifi stress test with suspend and resume as below:
        eth0: tx queue full!.
        remove wake up source irq 103=20
        PM: resume of devices complete after 348.934 msecs
        Restarting tasks ... done.
        ------------[ cut here ]------------
        WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x284/0x2a=
8()
        NETDEV WATCHDOG: eth0 (fec): transmit queue 0 timed out=20
        Modules linked in: ar6000
        [<8004482c>] (unwind_backtrace+0x0/0xf8) from
        [<80068cd0>] (warn_slowpath_common+0x4c/0x64)
        [<80068cd0>] (warn_slowpath_common+0x4c/0x64)from
        [<80068d7c>] (warn_slowpath_fmt+0x30/0x40)
        [<80068d7c>] (warn_slowpath_fmt+0x30/0x40) from
        [<803f0c50>] (dev_watchdog+0x284/0x2a8)
        [<803f0c50>] (dev_watchdog+0x284/0x2a8) from
        [<80074430>] (run_timer_softirq+0xec/0x214)
        [<80074430>] (run_timer_softirq+0xec/0x214) from
        [<8006e524>] (__do_softirq+0xac/0x140)
        [<8006e524>] (__do_softirq+0xac/0x140) from
        [<8006ea60>] (irq_exit+0x94/0x9c)
        [<8006ea60>] (irq_exit+0x94/0x9c) from
        [<80039240>] (do_local_timer+0x54/0x70)
        [<80039240>] (do_local_timer+0x54/0x70) from
        [<8003ea0c>] (__irq_svc+0x4c/0xe8)
        Exception stack(0x80a2bf68 to 0x80a2bfb0)
        bf60:                   0000001f 80a3babc 80a2bfb0 00000000 80a=
2a000 80a7b8e4
        bf80: 804befcc 80a3ee7c 1000406a 412fc09a 00000000 00000000 80a=
81440 80a2bfb0
        bfa0: 8003fa64 8003fa68 60000013 ffffffff
        [<8003ea0c>] (__irq_svc+0x4c/0xe8) from [<8003fa68>] (default_i=
dle+0x24/0x28)
        [<8003fa68>] (default_idle+0x24/0x28) from [<8003fc60>] (cpu_id=
le+0xbc/0xfc)
        [<8003fc60>] (cpu_idle+0xbc/0xfc) from [<80008878>] (start_kern=
el+0x258/0x29c)
        [<80008878>] (start_kernel+0x258/0x29c) from [<10008040>] (0x10=
008040)
        ---[ end trace 30671ac42e272c2d ]---

But ethernet and system still be alive. In sometime,the issue
will cause system hang like "nfs: server 10.192.242.179 not=20
responding, still trying".

The root cause is tx buffer descriptors are not cleaned when
ethernet resume back.

Signed-off-by: Fugang Duan <B38611@freescale.com>

drivers/net/fec.c |   39 ++++++++++++++++++++++++++-------------
 1 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index f007bf0..b1fa464 100755
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1456,6 +1456,28 @@ static const struct net_device_ops fec_netdev_op=
s =3D {
 #endif
 };
=20
+/* Init TX buffer descriptors
+ */
+static void fec_enet_txbd_init(struct net_device *dev)
+{
+       struct fec_enet_private *fep =3D netdev_priv(dev);
+       struct bufdesc *bdp;
+       int i;
+
+       /* ...and the same for transmit */
+       bdp =3D fep->tx_bd_base;
+       for (i =3D 0; i < TX_RING_SIZE; i++) {
+
+               /* Initialize the BD for every fragment in the page. */
+               bdp->cbd_sc =3D 0;
+               bdp++;
+       }
+
+       /* Set the last buffer to wrap */
+       bdp--;
+       bdp->cbd_sc |=3D BD_SC_WRAP;
+}
+
  /*
   * XXX:  We need to clean up on failure exits here.
   *
@@ -1512,19 +1534,8 @@ static int fec_enet_init(struct net_device *ndev=
)
        bdp--;
        bdp->cbd_sc |=3D BD_SC_WRAP;
=20
-       /* ...and the same for transmit */
-       bdp =3D fep->tx_bd_base;
-       for (i =3D 0; i < TX_RING_SIZE; i++) {
-
-               /* Initialize the BD for every fragment in the page. */
-               bdp->cbd_sc =3D 0;
-               bdp->cbd_bufaddr =3D 0;
-               bdp++;
-       }
-
-       /* Set the last buffer to wrap */
-       bdp--;
-       bdp->cbd_sc |=3D BD_SC_WRAP;
+       /* Init transmit descriptors */
+       fec_enet_txbd_init(ndev);
=20
        fec_restart(ndev, 0);
=20
@@ -1575,6 +1586,8 @@ fec_restart(struct net_device *dev, int duplex)
        writel(fep->bd_dma, fep->hwp + FEC_R_DES_START);
        writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc) * RX=
_RING_SIZE,
                        fep->hwp + FEC_X_DES_START);
+       /* Reinit transmit descriptors */
+       fec_enet_txbd_init(dev);
=20
        fep->dirty_tx =3D fep->cur_tx =3D fep->tx_bd_base;
        fep->cur_rx =3D fep->rx_bd_base;
--=20
1.7.0.4

Thanks,
Andy




-----Original Message-----
=46rom: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.o=
rg] On Behalf Of Troy Kisky
Sent: Wednesday, January 30, 2013 2:47 AM
To: Vikram Narayanan
Cc: netdev@vger.kernel.org; Greg Ungerer; shawn.guo@linaro.org; LAK; Uw=
e Kleine-K=F6nig; Fabio Estevam
Subject: Re: i.Mx6Quad - eth0: tx queue full!

On 1/29/2013 9:34 AM, Vikram Narayanan wrote:
> On 1/29/2013 1:17 AM, Troy Kisky wrote:
>> On 1/28/2013 10:39 AM, Vikram Narayanan wrote:
>>> Running the latest head <linux-2.6.git> on an i.Mx6Quad based=20
>>> platform gives me the below error when flooded with ping requests.
>>>
>>> =3D=3D Start log =3D=3D
>>> [ 2555.004031] ------------[ cut here ]------------ [ 2555.009740]=20
>>> WARNING: at net/sched/sch_generic.c:254
>>> dev_watchdog+0x298/0x2b8()
>>> [ 2555.018721] NETDEV WATCHDOG: eth0 (fec): transmit queue 0 timed=20
>>> out
>>
>> I think the tx interrupt status bit was lost. The packets were=20
>> transmitted, but the interrupt never happened. The controller should=
=20
>> have been reset here, but perhaps a bug with the reset code.
>> Are you using the mainline kernel, or a version Freescale's kernel.
>
> I tried with both the kernels. Freescale's and mainline results in th=
e=20
> same error.
>
>> mainline fec_restart does not reset tx_full
>>
>> You can try adding
>> fep->tx_full =3D 0;
>
> With this there was no improvement.

I have fixed this bug (and more) on Freescale's kernel (imx-3.0.35_1.1.=
0). I created a branch you can try.
=46eel free to port to mainline.

This is the patch that should fix your problem
fec: clear TX_FULL in fec_restart

git://github.com/boundarydevices/linux-imx6.git ethernet_test



Please let me know results.
Thanks
Troy


--
To unsubscribe from this list: send the line "unsubscribe netdev" in th=
e body of a message to majordomo@vger.kernel.org More majordomo info at=
  http://vger.kernel.org/majordomo-info.html
