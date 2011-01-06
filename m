From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] net: Allow ethtool to set interface in loopback
 mode.
Date: Thu, 06 Jan 2011 22:13:31 +0000
Message-ID: <1294352011.11825.50.camel@bwh-desktop>
References: <AANLkTikW24AcLEAioYtCwuQOoVnTrqVoAaZw3sksZ_jU@mail.gmail.com>
	 <1294187401-4662-1-git-send-email-maheshb@google.com>
	 <20110104163645.0b3a3687@nehalam> <1294190504.2992.3.camel@localhost>
	 <4D249ABD.4080209@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Mahesh Bandewar <maheshb@google.com>,
	David Miller <davem@davemloft.net>,
	Laurent Chavey <chavey@google.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:15982 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355Ab1AFWNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 17:13:35 -0500
In-Reply-To: <4D249ABD.4080209@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-05 at 11:22 -0500, Jeff Garzik wrote:
> On 01/04/2011 08:21 PM, Ben Hutchings wrote:
> > On Tue, 2011-01-04 at 16:36 -0800, Stephen Hemminger wrote:
> >> On Tue,  4 Jan 2011 16:30:01 -0800
> >> Mahesh Bandewar<maheshb@google.com>  wrote:
> >>
> >>> This patch enables ethtool to set the loopback mode on a given interface.
> >>> By configuring the interface in loopback mode in conjunction with a policy
> >>> route / rule, a userland application can stress the egress / ingress path
> >>> exposing the flows of the change in progress and potentially help developer(s)
> >>> understand the impact of those changes without even sending a packet out
> >>> on the network.
> >>>
> >>> Following set of commands illustrates one such example -
> >>> 	a) ip -4 addr add 192.168.1.1/24 dev eth1
> >>> 	b) ip -4 rule add from all iif eth1 lookup 250
> >>> 	c) ip -4 route add local 0/0 dev lo proto kernel scope host table 250
> >>> 	d) arp -Ds 192.168.1.100 eth1
> >>> 	e) arp -Ds 192.168.1.200 eth1
> >>> 	f) sysctl -w net.ipv4.ip_nonlocal_bind=1
> >>> 	g) sysctl -w net.ipv4.conf.all.accept_local=1
> >>> 	# Assuming that the machine has 8 cores
> >>> 	h) taskset 000f netserver -L 192.168.1.200
> >>> 	i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168.1.200 -l 30
> >>>
> >>> Signed-off-by: Mahesh Bandewar<maheshb@google.com>
> >>> Reviewed-by: Ben Hutchings<bhutchings@solarflare.com>
> >>
> >> Since this is a boolean it SHOULD go into ethtool_flags rather than
> >> being a high level operation.
> >
> > It could do, but I though ETHTOOL_{G,S}FLAGS were intended for
> > controlling offload features.
> 
> It doesn't have to be.  As Stephen guessed, [GS]FLAGS are basically 
> common flags -- as differentiated from private, 
> driver-specific/hardware-specific flags.

Well, that would allow the patch to be simplified quite a bit. :-)

Ben.

From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] ethtool: Define ETH_FLAG_LOOPBACK
Date: Thu, 6 Jan 2011 22:10:55 +0000

Mahesh Bandewar <maheshb@google.com> requested this, writing:

By configuring the interface in loopback mode in conjunction with a policy
route / rule, a userland application can stress the egress / ingress path
exposing the flows of the change in progress and potentially help developer(s)
understand the impact of those changes without even sending a packet out
on the network.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -309,6 +309,7 @@ struct ethtool_perm_addr {
  * flag differs from the read-only value.
  */
 enum ethtool_flags {
+	ETH_FLAG_LOOPBACK	= (1 << 2),	/* Host-side loopback enabled */
 	ETH_FLAG_TXVLAN		= (1 << 7),	/* TX VLAN offload enabled */
 	ETH_FLAG_RXVLAN		= (1 << 8),	/* RX VLAN offload enabled */
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
---

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

