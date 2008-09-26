From: "Xiaoming.Zhang" <Xiaoming.Zhang@resilience.com>
Subject: Re: [patch 10/21] driver/net/skge.c: restart the interface when it's options or pauseparam is set
Date: Fri, 26 Sep 2008 14:28:05 +0800
Message-ID: <200809261428.06275.Xiaoming.Zhang@resilience.com>
References: <200809222152.m8MLqHXf031966@imap1.linux-foundation.org> <20080923164718.787237e2@extreme>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_2DI3I3eltUKg/pK"
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex2.resilience.com ([207.47.19.10]:18235 "EHLO
	ex2.resilience.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbYIZGop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 02:44:45 -0400
In-Reply-To: <20080923164718.787237e2@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_2DI3I3eltUKg/pK
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 24 September 2008 07:47, Stephen Hemminger wrote:
> On Mon, 22 Sep 2008 14:52:17 -0700
>
> akpm@linux-foundation.org wrote:
> > From: "Xiaoming.Zhang" <Xiaoming.Zhang@resilience.com>
> >
> > We have an issue of the skge driver: The card won't work when it's
> > options are changed.  Here's the hardware info:
> >
> > # lspci -v
> > 05:04.0 Ethernet controller: Marvell Technology Group Ltd. 88E8001
> > Gigabit Ethernet Controller (rev 13) Subsystem: Marvell Technology Group
> > Ltd. Marvell RDK-8001 Flags: bus master, 66MHz, medium devsel, latency
> > 32, IRQ 16 Memory at d042c000 (32-bit, non-prefetchable) [size=16K] I/O
> > ports at d000 [size=256]
> >         [virtual] Expansion ROM at 20400000 [disabled] [size=128K]
> >         Capabilities: [48] Power Management version 2
> >         Capabilities: [50] Vital Product Data
> >
> > The happens in both Linux-2.6.26(skge version 1.23) and RHEL5.2(skge
> > version 1.6).
> >
> > For example, at first it is set to "speed 1000 duplex full auto-neg on"
> > and it works, then run
> >
> >        ethtool -s <ethx> autoneg off
> > or     ethtool -s <ethx> speed 100 duplex full autoneg off
> >
> > Then it will stop working. After that if we restart the interface:
> >
> > 	ifconifg <ethx> down
> > 	ifconfig <ethx> up
> >
> > It will work again. And `ethtool -A' has the same issue.
> >
> > So we think after setting the options, the interface should be restarted.
> >
> > Signed-off-by: Zhang Xiaoming <xiaoming.zhang@resilience.com>
> > Cc: Stephen Hemminger <shemminger@vyatta.com>
> > Cc: Jeff Garzik <jeff@garzik.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >
> >  drivers/net/skge.c |   12 ++++++++----
> >  1 file changed, 8 insertions(+), 4 deletions(-)
> >
> > diff -puN
> > drivers/net/skge.c~driver-net-skgec-restart-the-interface-when-its-option
> >s-or-pauseparam-is-set drivers/net/skge.c ---
> > a/drivers/net/skge.c~driver-net-skgec-restart-the-interface-when-its-opti
> >ons-or-pauseparam-is-set +++ a/drivers/net/skge.c
> > @@ -353,8 +353,10 @@ static int skge_set_settings(struct net_
> >  	skge->autoneg = ecmd->autoneg;
> >  	skge->advertising = ecmd->advertising;
> >
> > -	if (netif_running(dev))
> > -		skge_phy_reset(skge);
> > +	if (netif_running(dev)) {
> > +		skge_down(dev);
> > +		skge_up(dev);
> > +	}
> >
> >  	return (0);
> >  }
> > @@ -595,8 +597,10 @@ static int skge_set_pauseparam(struct ne
> >  			skge->flow_control = FLOW_MODE_NONE;
> >  	}
> >
> > -	if (netif_running(dev))
> > -		skge_phy_reset(skge);
> > +	if (netif_running(dev)) {
> > +		skge_down(dev);
> > +		skge_up(dev);
> > +	}
> >
> >  	return 0;
> >  }
>
> Since skge_up can fail because of out of memory, this code needs to
> check the return value. And then if it fails the "limbo state" needs
> to be handled in skge_down.

How about like this? It is tested.

Thank you.


Signed-off-by: Zhang Xiaoming <xiaoming.zhang@resilience.com>

--- drivers/net/skge.c.orig	2008-09-26 05:36:07.000000000 +0800
+++ drivers/net/skge.c	2008-09-26 05:35:50.000000000 +0800
@@ -319,6 +319,7 @@ static int skge_set_settings(struct net_
 	struct skge_port *skge = netdev_priv(dev);
 	const struct skge_hw *hw = skge->hw;
 	u32 supported = skge_supported_modes(hw);
+	int err = 0;
 
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
 		ecmd->advertising = supported;
@@ -367,8 +368,14 @@ static int skge_set_settings(struct net_
 	skge->autoneg = ecmd->autoneg;
 	skge->advertising = ecmd->advertising;
 
-	if (netif_running(dev))
-		skge_phy_reset(skge);
+	if (netif_running(dev)) {
+		skge_down(dev);
+		err = skge_up(dev);
+		if (err) {
+			dev_close(dev);
+			return err;
+		}
+	}
 
 	return (0);
 }
@@ -593,6 +600,7 @@ static int skge_set_pauseparam(struct ne
 {
 	struct skge_port *skge = netdev_priv(dev);
 	struct ethtool_pauseparam old;
+	int err = 0;
 
 	skge_get_pauseparam(dev, &old);
 
@@ -609,8 +617,14 @@ static int skge_set_pauseparam(struct ne
 			skge->flow_control = FLOW_MODE_NONE;
 	}
 
-	if (netif_running(dev))
-		skge_phy_reset(skge);
+	if (netif_running(dev)) {
+		skge_down(dev);
+		err = skge_up(dev);
+		if (err) {
+			dev_close(dev);
+			return err;
+		}
+	}
 
 	return 0;
 }
-- 
Have fun,
Xiaoming (Mark) Zhang


--Boundary-00=_2DI3I3eltUKg/pK
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="skge.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="skge.patch"

--- drivers/net/skge.c.orig	2008-09-26 05:36:07.000000000 +0800
+++ drivers/net/skge.c	2008-09-26 05:35:50.000000000 +0800
@@ -319,6 +319,7 @@ static int skge_set_settings(struct net_
 	struct skge_port *skge = netdev_priv(dev);
 	const struct skge_hw *hw = skge->hw;
 	u32 supported = skge_supported_modes(hw);
+	int err = 0;
 
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
 		ecmd->advertising = supported;
@@ -367,8 +368,14 @@ static int skge_set_settings(struct net_
 	skge->autoneg = ecmd->autoneg;
 	skge->advertising = ecmd->advertising;
 
-	if (netif_running(dev))
-		skge_phy_reset(skge);
+	if (netif_running(dev)) {
+		skge_down(dev);
+		err = skge_up(dev);
+		if (err) {
+			dev_close(dev);
+			return err;
+		}
+	}
 
 	return (0);
 }
@@ -593,6 +600,7 @@ static int skge_set_pauseparam(struct ne
 {
 	struct skge_port *skge = netdev_priv(dev);
 	struct ethtool_pauseparam old;
+	int err = 0;
 
 	skge_get_pauseparam(dev, &old);
 
@@ -609,8 +617,14 @@ static int skge_set_pauseparam(struct ne
 			skge->flow_control = FLOW_MODE_NONE;
 	}
 
-	if (netif_running(dev))
-		skge_phy_reset(skge);
+	if (netif_running(dev)) {
+		skge_down(dev);
+		err = skge_up(dev);
+		if (err) {
+			dev_close(dev);
+			return err;
+		}
+	}
 
 	return 0;
 }

--Boundary-00=_2DI3I3eltUKg/pK--
