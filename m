From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [TG3] Always load TSO firmware
Date: Thu, 20 Nov 2003 20:56:05 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031120095605.GA6572@gondor.apana.org.au>
References: <20031117093225.GA12420@gondor.apana.org.au> <20031117123836.2f8e70af.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="k+w/mQv8wyuph6w0"
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031117123836.2f8e70af.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Nov 17, 2003 at 12:38:36PM -0800, David S. Miller wrote:
> 
> Whether we load the TSO firmware or not on 5705 determines how big
> an onboard buffer area we give to the chip for packet data.  It may
> be the case that we are miscalculating these values or not programming
> them into the chip correctly.

OK, I've cross-checked with the Broadcom drivers and the problem seems
to be specific to 5705 A1 which is the chipset in question.

The Broadcom drivers limit the number of rx descriptors to 63 while
tg3.c only limits it to 64.  It has been confirmed that lowering
the limit makes the problem go away.

Here is the patch.

Thanks,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=q

--- tg3.c.orig	2003-11-18 21:18:04.000000000 +1100
+++ tg3.c	2003-11-18 21:34:22.000000000 +1100
@@ -6067,8 +6067,8 @@
 	tp->rx_pending = ering->rx_pending;
 
 	if ((tp->tg3_flags2 & TG3_FLG2_MAX_RXPEND_64) &&
-	    tp->rx_pending > 64)
-		tp->rx_pending = 64;
+	    tp->rx_pending > 63)
+		tp->rx_pending = 63;
 	tp->rx_jumbo_pending = ering->rx_jumbo_pending;
 	tp->tx_pending = ering->tx_pending;
 
@@ -7672,7 +7672,7 @@
 	    !(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) &&
 	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH)) {
 		tp->tg3_flags2 |= TG3_FLG2_MAX_RXPEND_64;
-		tp->rx_pending = 64;
+		tp->rx_pending = 63;
 	}
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704)

--k+w/mQv8wyuph6w0--
