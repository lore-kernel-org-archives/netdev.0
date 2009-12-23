From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: ucc_geth broken in 2.6.32 by
	864fdf884e82bacbe8ca5e93bd43393a61d2e2b4
Date: Wed, 23 Dec 2009 23:22:26 +0300
Message-ID: <20091223202226.GA8185@oksana.dev.rtsoft.ru>
References: <20091223174019.GB762@caffeine.csclub.uwaterloo.ca>
	<20091223180415.GA12987@oksana.dev.rtsoft.ru>
	<20091223200948.GF760@caffeine.csclub.uwaterloo.ca>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20091223200948.GF760@caffeine.csclub.uwaterloo.ca>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 23, 2009 at 03:09:48PM -0500, Lennart Sorensen wrote:
[...]
> So there result is:
> 
> Unable to handle kernel paging request for data at address 0x00000058
> Faulting instruction address: 0xc024f2fc
> Oops: Kernel access of bad area, sig: 11 [#1]
> RC8360 CM
> Modules linked in: rclibapi xeno_native max6369_wdt ucc_geth_driver spi_mpc8xxx ltc4215 lm75
> NIP: c024f2fc LR: e30aa0a4 CTR: c024f2e8
> REGS: df857ca0 TRAP: 0300   Not tainted  (2.6.32-trunk-8360e)
> MSR: 00009032 <EE,ME,IR,DR>  CR: 44042088  XER: 00000000
> DAR: 00000058, DSISR: 20000000
> TASK = df848c90[4] 'events/0' THREAD: df856000
> GPR00: e30aa0a4 df857d50 df848c90 00000000 00000640 00000001 c0428df4 dfa40b80
> GPR08: 000000c8 e30ad2b8 df084360 c024f2e8 44042082 1001af90 e30ad2b8 00000000
> GPR16: 00000048 00000001 00000000 00000000 df08436c df08440c 00000190 df08455c
> GPR24: df0844ec df0842c0 df084000 180005ea dfa40b80 00000000 df0842c0 00000000
> NIP [c024f2fc] skb_recycle_check+0x14/0x100
> LR [e30aa0a4] ucc_geth_poll+0xd8/0x4e0 [ucc_geth_driver]
> Call Trace:
> [df857d50] [c000b03c] __ipipe_grab_irq+0x3c/0xa4 (unreliable)
> [df857d60] [e30aa0a4] ucc_geth_poll+0xd8/0x4e0 [ucc_geth_driver]

This I can reproduce. It seems it's a long standing bug that
becomes easily reproducible with quiesce/activate sequence.
The driver doesn't handle empty queue correctly, i.e. it ignores
the empty queue check if netdev queue is stopped, which makes no
sense.

Can you try this patch in addition to previous (i.e. both should
be applied)?

Thanks!

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 2f73e3f..b22de51 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3275,7 +3275,7 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 		/* Handle the transmitted buffer and release */
 		/* the BD to be used with the current frame  */
 
-		if ((bd == ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
+		if (bd == ugeth->txBd[txQ]) /* queue empty? */
 			break;
 
 		dev->stats.tx_packets++;
