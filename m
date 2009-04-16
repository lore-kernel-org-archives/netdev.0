From: Ed Swierk <eswierk@aristanetworks.com>
Subject: e1000 watchdog timer fails to start after ethool settings change
Date: Wed, 15 Apr 2009 21:57:49 -0700
Message-ID: <1239857869.31663.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: jesse.brandeburg@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:57934 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbZDPE5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 00:57:55 -0400
Received: by rv-out-0506.google.com with SMTP id f9so238649rvb.1
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 21:57:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent patch to e1000, intended to avoid a race in the interrupt code,
seems to prevent the watchdog timer from resuming properly.  It neuters
the effect of

  /* fire a link change interrupt to start the watchdog */ 
  ew32(ICS, E1000_ICS_LSC); 
 
in e1000_up() when the __E1000_RESETTING flag is set, for example when
invoked by e1000_set_settings().

The result is that running

  ethtool -s eth0 autoneg on

in Qemu with an emulated e1000 NIC causes the kernel to stop noticing
link status changes, leaving the link down until I prod the driver with
ifconfig eth0 down; ifconfig eth0 up.

Here is the patch causing the bug:

> From: Jesse Brandeburg <jesse.brandeburg@xxxxxxxxx>
> 
> A nasty bug was found where an MTU change (or anything else that caused a
> reset) could race with the interrupt code.  The interrupt code was entered
> by a shared interrupt during the MTU change.
> 
> This change prevents the interrupt code from running while the driver is in
> the middle of its reset path.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@xxxxxxxxx>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 26474c9..c986978 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -31,7 +31,7 @@
>  
>  char e1000_driver_name[] = "e1000";
>  static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
> -#define DRV_VERSION "7.3.20-k3-NAPI"
> +#define DRV_VERSION "7.3.21-k3-NAPI"
>  const char e1000_driver_version[] = DRV_VERSION;
>  static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
>  
> @@ -3712,7 +3712,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
>  	struct e1000_hw *hw = &adapter->hw;
>  	u32 rctl, icr = er32(ICR);
>  
> -	if (unlikely(!icr))
> +	if (unlikely((!icr) || test_bit(__E1000_RESETTING, &adapter->flags)))
>  		return IRQ_NONE;  /* Not our interrupt */
>  
>  	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is
> 

Undoing the patch fixes the problem on a Qemu emulated e1000 NIC:

Index: linux-2.6.29.1/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.29.1.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6.29.1/drivers/net/e1000/e1000_main.c
@@ -3712,7 +3712,7 @@ static irqreturn_t e1000_intr(int irq, v
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl, icr = er32(ICR);
 
-	if (unlikely((!icr) || test_bit(__E1000_RESETTING, &adapter->flags)))
+	if (unlikely(!icr))
 		return IRQ_NONE;  /* Not our interrupt */
 
 	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is

---

Of course this leaves the original problem unfixed; hopefully someone
can suggest a better solution.

--Ed


