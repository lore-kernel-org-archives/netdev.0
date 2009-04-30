From: Don Fry <pcnet32@verizon.net>
Subject: Re: [PATCH net-next-2.6] pcnet32: Remove pointless memory barriers
Date: Wed, 29 Apr 2009 17:09:48 -0700
Message-ID: <1241050188.18295.13.camel@localhost.localdomain>
References: <1240945659.8819.9.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, romieu@fr.zoreil.com,
	David Miller <davem@davemloft.net>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173007pub.verizon.net ([206.46.173.7]:21083 "EHLO
	vms173007pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760086AbZD3AKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 20:10:08 -0400
Received: from [192.168.1.3] ([173.50.252.109]) by vms173007.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008; 32bit))
 with ESMTPA id <0KIW006IK0GCGA0K@vms173007.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 29 Apr 2009 19:09:49 -0500 (CDT)
In-reply-to: <1240945659.8819.9.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After going back to my original NAPI changes, email exchanges today with
Francois and John, and looking through all the architecture
implementation of mmiowb and locking; I agree that this mmiowb is
unnecessary since a lock is always released which has all the memory
barriers needed.  I no longer have access to all the equipment I had
available at IBM, but it was tested a extensively on Intel and Power
platforms without the mmiowb.

Acked-by:  Don Fry <pcnet32@verizon.net>

-----Original Message-----
From: John Dykstra <john.dykstra1@gmail.com>
To: netdev <netdev@vger.kernel.org>, Don Fry <pcnet32@verizon.net>
Subject: [PATCH net-next-2.6] pcnet32: Remove pointless memory barriers
Date: Tue, 28 Apr 2009 19:07:39 +0000

These two memory barriers in performance-critical paths are not needed
on x86.  Even if some other architecture does buffer PCI I/O space
writes, the existing memory-mapped I/O barriers are unlikely to be what
is needed.

Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
---
 drivers/net/pcnet32.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index e5e8c59..1c35e1d 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1405,7 +1405,7 @@ static int pcnet32_poll(struct napi_struct *napi, int budget)
 
 		/* Set interrupt enable. */
 		lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);
-		mmiowb();
+
 		spin_unlock_irqrestore(&lp->lock, flags);
 	}
 	return work_done;
@@ -2597,7 +2597,7 @@ pcnet32_interrupt(int irq, void *dev_id)
 			val = lp->a.read_csr(ioaddr, CSR3);
 			val |= 0x5f00;
 			lp->a.write_csr(ioaddr, CSR3, val);
-			mmiowb();
+
 			__napi_schedule(&lp->napi);
 			break;
 		}

