From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] net: Allow ethtool to set interface in loopback
 mode.
Date: Fri, 07 Jan 2011 01:30:29 +0000
Message-ID: <1294363829.11825.81.camel@bwh-desktop>
References: <AANLkTikW24AcLEAioYtCwuQOoVnTrqVoAaZw3sksZ_jU@mail.gmail.com>
	 <1294187401-4662-1-git-send-email-maheshb@google.com>
	 <20110104163645.0b3a3687@nehalam> <1294190504.2992.3.camel@localhost>
	 <4D249ABD.4080209@garzik.org> <1294352011.11825.50.camel@bwh-desktop>
	 <AANLkTi=3ewzgz=z-WmqT=vBvci3-H6HE3CCVk4ZGuFED@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Laurent Chavey <chavey@google.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:29639 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755276Ab1AGBac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 20:30:32 -0500
In-Reply-To: <AANLkTi=3ewzgz=z-WmqT=vBvci3-H6HE3CCVk4ZGuFED@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-01-06 at 16:47 -0800, Mahesh Bandewar wrote:
> On Thu, Jan 6, 2011 at 2:13 PM, Ben Hutchings <bhutchings@solarflare.com> wrote:
> > On Wed, 2011-01-05 at 11:22 -0500, Jeff Garzik wrote:
> >> On 01/04/2011 08:21 PM, Ben Hutchings wrote:
> >> > On Tue, 2011-01-04 at 16:36 -0800, Stephen Hemminger wrote:
> >> >> On Tue,  4 Jan 2011 16:30:01 -0800
> >> >> Mahesh Bandewar<maheshb@google.com>  wrote:
> >> >>
> >> >>> This patch enables ethtool to set the loopback mode on a given interface.
> >> >>> By configuring the interface in loopback mode in conjunction with a policy
> >> >>> route / rule, a userland application can stress the egress / ingress path
> >> >>> exposing the flows of the change in progress and potentially help developer(s)
> >> >>> understand the impact of those changes without even sending a packet out
> >> >>> on the network.
> >> >>>
> >> >>> Following set of commands illustrates one such example -
> >> >>>   a) ip -4 addr add 192.168.1.1/24 dev eth1
> >> >>>   b) ip -4 rule add from all iif eth1 lookup 250
> >> >>>   c) ip -4 route add local 0/0 dev lo proto kernel scope host table 250
> >> >>>   d) arp -Ds 192.168.1.100 eth1
> >> >>>   e) arp -Ds 192.168.1.200 eth1
> >> >>>   f) sysctl -w net.ipv4.ip_nonlocal_bind=1
> >> >>>   g) sysctl -w net.ipv4.conf.all.accept_local=1
> >> >>>   # Assuming that the machine has 8 cores
> >> >>>   h) taskset 000f netserver -L 192.168.1.200
> >> >>>   i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168.1.200 -l 30
> >> >>>
> >> >>> Signed-off-by: Mahesh Bandewar<maheshb@google.com>
> >> >>> Reviewed-by: Ben Hutchings<bhutchings@solarflare.com>
> >> >>
> >> >> Since this is a boolean it SHOULD go into ethtool_flags rather than
> >> >> being a high level operation.
> >> >
> >> > It could do, but I though ETHTOOL_{G,S}FLAGS were intended for
> >> > controlling offload features.
> >>
> >> It doesn't have to be.  As Stephen guessed, [GS]FLAGS are basically
> >> common flags -- as differentiated from private,
> >> driver-specific/hardware-specific flags.
> >
> > Well, that would allow the patch to be simplified quite a bit. :-)
> 
> Ben, Are you suggesting to use ETH_FLAG_LOOPBACK instead of
> ETHTOOL_{G|S}LOOPBACK flags?
[...]

Exactly.

An example implementation (untested):

--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -548,11 +548,24 @@ static u32 efx_ethtool_get_rx_csum(struct net_device *net_dev)
 	return efx->rx_checksum_enabled;
 }
 
+static u32 efx_ethtool_get_flags(struct net_device *net_dev)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	u32 flags;
+
+	flags = ethtool_op_get_flags(net_dev);
+	if (efx->loopback_mode != LOOPBACK_NONE)
+		flags |= ETH_FLAG_LOOPBACK;
+	return flags;
+}
+
 static int efx_ethtool_set_flags(struct net_device *net_dev, u32 data)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	u32 supported = (efx->type->offload_features &
-			 (ETH_FLAG_RXHASH | ETH_FLAG_NTUPLE));
+	u32 supported = (ETH_FLAG_LOOPBACK |
+			 (efx->type->offload_features &
+			  (ETH_FLAG_RXHASH | ETH_FLAG_NTUPLE)));
+	enum efx_loopback_mode loopback;
 	int rc;
 
 	rc = ethtool_op_set_flags(net_dev, data, supported);
@@ -562,7 +575,15 @@ static int efx_ethtool_set_flags(struct net_device *net_dev, u32 data)
 	if (!(data & ETH_FLAG_NTUPLE))
 		efx_filter_clear_rx(efx, EFX_FILTER_PRI_MANUAL);
 
-	return 0;
+	loopback = (data & ETH_FLAG_LOOPBACK) ? LOOPBACK_DATA : LOOPBACK_NONE;
+	mutex_lock(&efx->mac_lock);
+	if (efx->loopback_mode != loopback) {
+		efx->loopback_mode = loopback;
+		rc = __efx_reconfigure_port(efx);
+	}
+	mutex_unlock(&efx->mac_lock);
+
+	return rc;
 }
 
 static void efx_ethtool_self_test(struct net_device *net_dev,
@@ -1057,7 +1078,7 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.get_tso		= ethtool_op_get_tso,
 	/* Need to enable/disable TSO-IPv6 too */
 	.set_tso		= efx_ethtool_set_tso,
-	.get_flags		= ethtool_op_get_flags,
+	.get_flags		= efx_ethtool_get_flags,
 	.set_flags		= efx_ethtool_set_flags,
 	.get_sset_count		= efx_ethtool_get_sset_count,
 	.self_test		= efx_ethtool_self_test,
---

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

