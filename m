From: Willy Tarreau <w@1wt.eu>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Wed, 20 Nov 2013 20:11:45 +0100
Message-ID: <20131120191145.GP8581@1wt.eu>
References: <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu>
 <20131117141940.GA18569@1wt.eu>
 <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <87li0kkhzx.fsf@natisbad.org>
 <1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131119174323.GH913@1wt.eu>
 <1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131119184121.GN913@1wt.eu> <874n780wzc.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Florian Fainelli <f.fainelli@gmail.com>, simon.guinot@sequanux.org,
 Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
 edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
 linux-arm-kernel@lists.infradead.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <874n780wzc.fsf@natisbad.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Arnaud,

first, thanks for all these tests.

On Wed, Nov 20, 2013 at 12:53:43AM +0100, Arnaud Ebalard wrote:
(...)
> In the end, here are the conclusions *I* draw from this test session,
> do not hesitate to correct me:
> 
>  - Eric, it seems something changed in linus tree betwen the beginning
>    of the thread and now, which somehow reduces the effect of the
>    regression we were seen: I never got back the 256KB/s.
>  - You revert patch still improves the perf a lot
>  - It seems reducing MVNETA_TX_DONE_TIMER_PERIOD does not help
>  - w/ your revert patch, I can confirm that mvneta driver is capable of
>    doing line rate w/ proper tweak of TCP send window (256KB instead of
>    4M)
>  - It seems I will I have to spend some time on the SATA issues I
>    previously thought were an artefact of not cleaning my tree during a
>    debug session [1], i.e. there is IMHO an issue.

Could you please try Eric's patch that was just merged into Linus' tree
if it was not yet in the kernel you tried :

  98e09386c0e  tcp: tsq: restore minimal amount of queueing

For me it restored the original performance (I saturate the Gbps with
about 7 concurrent streams).

Further, I wrote the small patch below for mvneta. I'm not sure it's
smp-safe but it's a PoC. In mvneta_poll() which currently is only called
upon Rx interrupt, it tries to flush all possible remaining Tx descriptors
if any. That significantly improved my transfer rate, now I easily achieve
1 Gbps using a single TCP stream on the mirabox. Not tried on the AX3 yet.

It also increased the overall connection rate by 10% on empty HTTP responses
(small packets), very likely by reducing the dead time between some segments!

You'll probably want to give it a try, so here it comes.

Cheers,
Willy

>From d1a00e593841223c7d871007b1e1fc528afe8e4d Mon Sep 17 00:00:00 2001
From: Willy Tarreau <w@1wt.eu>
Date: Wed, 20 Nov 2013 19:47:11 +0100
Subject: EXP: net: mvneta: try to flush Tx descriptor queue upon Rx
 interrupts

Right now the mvneta driver doesn't handle Tx IRQ, and solely relies on a
timer to flush Tx descriptors. This causes jerky output traffic with bursts
and pauses, making it difficult to reach line rate with very few streams.
This patch tries to improve the situation which is complicated by the lack
of public datasheet from Marvell. The workaround consists in trying to flush
pending buffers during the Rx polling. The idea is that for symmetric TCP
traffic, ACKs received in response to the packets sent will trigger the Rx
interrupt and will anticipate the flushing of the descriptors.

The results are quite good, a single TCP stream is now capable of saturating
a gigabit.

This is only a workaround, it doesn't address asymmetric traffic nor datagram
based traffic.

Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 drivers/net/ethernet/marvell/mvneta.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 5aed8ed..59e1c86 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2013,6 +2013,26 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 	}
 
 	pp->cause_rx_tx = cause_rx_tx;
+
+	/* Try to flush pending Tx buffers if any */
+	if (test_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags)) {
+		int tx_todo = 0;
+
+		mvneta_tx_done_gbe(pp,
+	                           (((1 << txq_number) - 1) &
+	                           MVNETA_CAUSE_TXQ_SENT_DESC_ALL_MASK),
+	                           &tx_todo);
+
+		if (tx_todo > 0) {
+			mod_timer(&pp->tx_done_timer,
+			          jiffies + msecs_to_jiffies(MVNETA_TX_DONE_TIMER_PERIOD));
+		}
+		else {
+			clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
+			del_timer(&pp->tx_done_timer);
+		}
+	}
+
 	return rx_done;
 }
 
-- 
1.7.12.1
