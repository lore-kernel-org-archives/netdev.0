From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH 1/4] iseries_veth: Don't send packets to LPARs which aren't up
Date: Thu, 12 May 2005 17:47:27 +1000
Message-ID: <200505121747.27752.michael@ellerman.id.au>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261219AbVELHrl@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew, Jeff,

The iseries_veth driver has a logic bug which means it will erroneously
send packets to LPARs for which we don't have a connection.

This usually isn't a big problem because the Hypervisor call fails
gracefully and we return, but if packets are TX'ed during the negotiation
of the connection bad things might happen.

Regardless, the right thing is to bail early if we know there's no
connection.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
--

 iseries_veth.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: veth-fixes/drivers/net/iseries_veth.c
===================================================================
--- veth-fixes.orig/drivers/net/iseries_veth.c
+++ veth-fixes/drivers/net/iseries_veth.c	
@@ -924,7 +924,7 @@ static int veth_transmit_to_one(struct s
 
 	spin_lock_irqsave(&cnx->lock, flags);
 
-	if (! cnx->state & VETH_STATE_READY)
+	if (! (cnx->state & VETH_STATE_READY))
 		goto drop;
 
 	if ((skb->len - 14) > VETH_MAX_MTU)
