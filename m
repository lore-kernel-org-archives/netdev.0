From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: 3c59x: shared interrupt problem
Date: Wed, 11 Mar 2009 12:31:30 +0100
Message-ID: <20090311113130.GA26526@newton.mathematik.tu-chemnitz.de>
References: <20090309224253.135220@gmx.net> <20090309164927.6eb12aff@nehalam> <20090310081628.GA3217@newton.mathematik.tu-chemnitz.de> <20090310090053.322240@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Gerhard Pircher <gerhard_pircher@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lana.hrz.tu-chemnitz.de ([134.109.132.3]:35489 "EHLO
	lana.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbZCKLbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 07:31:34 -0400
Content-Disposition: inline
In-Reply-To: <20090310090053.322240@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2009 at 10:00:53AM +0100, Gerhard Pircher wrote:
> > 
> > This basically reverts a patch from akpm (bitkeeper cset 1.1046.95.8)
> > This patch was to workaround lots of "nobody cared" warnings generated
> > by boomerang_interrupt().
> > I added Andrew to the Cc, perhaps he can remember some details on this.
> I'm afraid this patch didn't fix the problem. I'm using scp to copy a big
> ISO file from my PC to the AmigaOne and the network transfer still stalls.
> I made a photo from the kernel oops printed out during shutdown.

Your photo shows exactly such a "nobody cared" warning that Andrew wanted 
to get rid of with his patch.

> BTW: shouldn't the driver use vortex_interrupt() to handle interrupts for
> a 3c920?
> 

It depends on the content of your NIC's eeprom which ISR the driver will use.
If your NIC is full bus master capable boomerang_interrupt() will be used,
if not vortex_interrupt() will be used. As far as I know the 3c920 is
of "tornado" type, so it should be full bus master capable.

Your first report showed dnComplete as a pending interrupt source.
Since the driver uses tx_interrupt_mitigation, this happens just if the 
tx ring is full. Could you please test the patch below? This disables
tx_interrupt_mitigation, so the dnComplete interrupt will be triggered 
with every packet.

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index b2563d3..c45c400 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -60,7 +60,7 @@ static int watchdog = 5000;
  * of possible Tx stalls if the system is blocking interrupts
  * somewhere else.  Undefine this to disable.
  */
-#define tx_interrupt_mitigation 1
+#define tx_interrupt_mitigation 0
 
 /* Put out somewhat more debugging messages. (0: no msg, 1 minimal .. 6). */
 #define vortex_debug debug
