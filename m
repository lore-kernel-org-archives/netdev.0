From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.7-rc3-mm2 2/5] via-velocity: uniformize use of OWNED_BY_NIC
Date: Fri, 18 Jun 2004 22:11:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618221142.A20210@electric-eye.fr.zoreil.com>
References: <20040618221014.A15640@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@redhat.com, akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040618221014.A15640@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Fri, Jun 18, 2004 at 10:10:14PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Introduce velocity_give_rx_desc() to uniformize the use of OWNED_BY_NIC
through the driver.

diff -puN drivers/net/via-velocity.c~via-velocity-30 drivers/net/via-velocity.c
--- linux-2.6.7-rc3/drivers/net/via-velocity.c~via-velocity-30	2004-06-18 21:34:14.000000000 +0200
+++ linux-2.6.7-rc3-fr/drivers/net/via-velocity.c	2004-06-18 21:34:14.000000000 +0200
@@ -465,6 +465,12 @@ static void velocity_init_cam_filter(str
 	}
 }
 
+static inline void velocity_give_rx_desc(struct rx_desc *rd)
+{
+	*(u32 *)&rd->rdesc0 = 0;
+	rd->rdesc0.owner = cpu_to_le32(OWNED_BY_NIC);
+}
+
 /**
  *	velocity_rx_reset	-	handle a receive reset
  *	@vptr: velocity we are resetting
@@ -485,7 +491,7 @@ static void velocity_rx_reset(struct vel
 	 *	Init state, all RD entries belong to the NIC
 	 */
 	for (i = 0; i < vptr->options.numrx; ++i)
-		vptr->rd_ring[i].rdesc0.owner = cpu_to_le32(OWNED_BY_NIC);
+		velocity_give_rx_desc(vptr->rd_ring + i);
 
 	writew(vptr->options.numrx, &regs->RBRDU);
 	writel(vptr->rd_pool_dma, &regs->RDBaseLo);
@@ -1008,7 +1014,7 @@ static int velocity_init_rd_ring(struct 
 			velocity_free_rd_ring(vptr);
 			goto out;
 		}
-		rd->rdesc0.owner = OWNED_BY_NIC;
+		velocity_give_rx_desc(rd);
 	}
 	vptr->rd_used = vptr->rd_curr = 0;
 out:
@@ -1205,8 +1211,7 @@ static int velocity_rx_srv(struct veloci
 				if (--rd_prev < 0)
 					rd_prev = vptr->options.numrx - 1;
 
-				rd = &(vptr->rd_ring[rd_prev]);
-				rd->rdesc0.owner = OWNED_BY_NIC;
+				velocity_give_rx_desc(vptr->rd_ring + rd_prev);
 			}
 			writew(4, &(regs->RBRDU));
 			vptr->rd_used -= 4;

_
