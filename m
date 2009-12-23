From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: ucc_geth broken in 2.6.32 by
	864fdf884e82bacbe8ca5e93bd43393a61d2e2b4
Date: Wed, 23 Dec 2009 21:04:15 +0300
Message-ID: <20091223180415.GA12987@oksana.dev.rtsoft.ru>
References: <20091223174019.GB762@caffeine.csclub.uwaterloo.ca>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20091223174019.GB762@caffeine.csclub.uwaterloo.ca>
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

On Wed, Dec 23, 2009 at 12:40:19PM -0500, Lennart Sorensen wrote:
> We use the ucc_geth for 6 ports (4 100Mbit and 2 Gbit ports) on an
> mpc8360e.  Up to 2.6.31 this worked fine.  2.6.32 on the other hand
> crashes very quickly after boot.

Hm. Just curious, what CPU revision you use? So that I could try
to reproduce the issue... I have MPC8360E-MDS boards, rev 2.0 and
rev rev 2.1 CPUs, Marvell PHYs. I also have MPC8360E-RDK (rev 2.1).
And I didn't see any issues with this patch.

> I managed to see the same crash when I was selectively trying to add newer
> ucc_geth patches to the 2.6.31 kernel a couple of months ago, and the same
> patch that caused a crash then seems suspect.  If I revert the patch the
> system runs completely stable.  Amusingly, the excact error message the
> patch claims to fix is in fact the error it causes to happen in my case.
> 
> So preferably 864fdf884e82bacbe8ca5e93bd43393a61d2e2b4 could be reverted

I don't see any point in reverting, because it will surely break my boards.
So, we need to fix this, not just hide.

> unless someone can fix it.

Well, I'm ready to help you with debugging.

> Now I must add that I run with the xenomai/adeos-ipipe patches as well,
> which do change interrupt handling a little,

It could be that it takes too long to stop the UCC, and xenomai
makes the timings worse, so the watchdog triggers.

Can you try the following patch?

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index afaf088..2f73e3f 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1563,6 +1563,8 @@ static int ugeth_disable(struct ucc_geth_private *ugeth, enum comm_dir mode)
 
 static void ugeth_quiesce(struct ucc_geth_private *ugeth)
 {
+	netif_device_detach(ugeth->ndev);
+
 	/* Wait for and prevent any further xmits. */
 	netif_tx_disable(ugeth->ndev);
 
@@ -1577,7 +1579,7 @@ static void ugeth_activate(struct ucc_geth_private *ugeth)
 {
 	napi_enable(&ugeth->napi);
 	enable_irq(ugeth->ug_info->uf_info.irq);
-	netif_tx_wake_all_queues(ugeth->ndev);
+	netif_device_attach(ugeth->ndev);
 }
 
 /* Called every time the controller might need to be made
