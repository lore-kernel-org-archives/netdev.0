From: Peter Chubb <peterc@gelato.unsw.edu.au>
Subject: Re: TG3 fix for slow switches (Was: TG3 driver failure on HP 16-way)
Date: Tue, 21 Dec 2004 12:11:40 +1100
Message-ID: <16839.30796.413939.333935@wombat.chubb.wattle.id.au>
References: <16839.27239.264551.415058@berry.gelato.unsw.EDU.AU>
	<20041220161552.2b88aa3d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041220161552.2b88aa3d.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "David" == David S Miller <davem@davemloft.net> writes:

David> On Tue, 21 Dec 2004 11:12:23 +1100 Peter Chubb
David> <peterc@gelato.unsw.edu.au> wrote:

>> The problem is that the driver gives up before the switch that the
>> NIC is connected to has finished the negotiation phase.
>> 
>> Here's a simple patch.  I changed the way the loop works too,
>> because tg3_readphys() sets *val to 0xffffffff if it fails.

David> This patch shouldn't be needed.  This waiting loop is just an
David> optimization in case we can negotiation quickly.

David> You need to figure out why that isn't working correctly.

It doesn't work because tg3_readphy sets bmsr to 0xffffffff even if it
can't read the value.  This breaks that loop early; and because
BBMSR_LSTATUS is set, all sorts of things happen before the card is ready.


Why is tg3_readphys returning 0xffffffff if it can't read a value anyway?

Here's another possible fix.

===== drivers/net/tg3.c 1.222 vs edited =====
Index: linux-2.6.10-rc3/drivers/net/tg3.c
===================================================================
--- linux-2.6.10-rc3.orig/drivers/net/tg3.c	2004-12-21 00:25:34.000000000 +0000
+++ linux-2.6.10-rc3/drivers/net/tg3.c	2004-12-21 01:00:56.586108274 +0000
@@ -1554,10 +1554,11 @@
 		}
 	}
 
-	bmsr = 0;
+
 	for (i = 0; i < 100; i++) {
 		tg3_readphy(tp, MII_BMSR, &bmsr);
-		tg3_readphy(tp, MII_BMSR, &bmsr);
+		if (tg3_readphy(tp, MII_BMSR, &bmsr))
+			bmsr = 0;
 		if (bmsr & BMSR_LSTATUS)
 			break;
 		udelay(40);
