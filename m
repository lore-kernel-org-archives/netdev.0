From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-2.6] 3c59x: Fix deadlock in vortex_error()
Date: Tue, 07 Sep 2010 02:27:10 +0100
Message-ID: <1283822830.5323.562.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Jens =?ISO-8859-1?Q?Sch=FC=DFler?= <jgs@trash.net>,
	595554@bugs.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60945 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755761Ab0IGB1Q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Sep 2010 21:27:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a bug introduced in commit
de847272149365363a6043a963a6f42fb91566e2
"3c59x: Use fine-grained locks for MII and windowed register access".

vortex_interrupt() holds vp->window_lock over multiple register
accesses to reduce locking overhead.  However it also needs to call
vortex_error() sometimes, and that uses the regular functions for
access to windowed registers, which will try to acquire window_lock
again.

Therefore, drop window_lock around the call to vortex_error() and set
the window afterward reacquiring the lock.  Since vortex_error() may
call vortex_rx(), which *does* require its caller to hold window_lock,
lift that call up into vortex_interrupt().  This also removes the
potential for calling vortex_rx() on a later-generation NIC.

Reported-and-tested-by: Jens Sch=C3=BC=C3=9Fler <jgs@trash.net> [in Deb=
ian's 2.6.32]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Dave,

This is the regression I mentioned before.  3c59x should be good after
this.

Ben.

 drivers/net/3c59x.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index a045559..85671ad 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1994,10 +1994,9 @@ vortex_error(struct net_device *dev, int status)
 		}
 	}
=20
-	if (status & RxEarly) {				/* Rx early is unused. */
-		vortex_rx(dev);
+	if (status & RxEarly)				/* Rx early is unused. */
 		iowrite16(AckIntr | RxEarly, ioaddr + EL3_CMD);
-	}
+
 	if (status & StatsFull) {			/* Empty statistics. */
 		static int DoneDidThat;
 		if (vortex_debug > 4)
@@ -2298,7 +2297,12 @@ vortex_interrupt(int irq, void *dev_id)
 		if (status & (HostError | RxEarly | StatsFull | TxComplete | IntReq)=
) {
 			if (status =3D=3D 0xffff)
 				break;
+			if (status & RxEarly)
+				vortex_rx(dev);
+			spin_unlock(&vp->window_lock);
 			vortex_error(dev, status);
+			spin_lock(&vp->window_lock);
+			window_set(vp, 7);
 		}
=20
 		if (--work_done < 0) {
--=20
1.7.1


