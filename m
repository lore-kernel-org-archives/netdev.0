From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next-2.6 PATCH 02/10] ethtool: add ntuple flow specifier
 to network flow classifier
Date: Wed, 02 Mar 2011 19:27:26 +0000
Message-ID: <1299094046.2664.31.camel@bwh-desktop>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
	 <20110225233249.7920.70334.stgit@gitlad.jf.intel.com>
	 <1298682048.3555.18.camel@localhost>
	 <AANLkTi=P0v1+h=TjC2j5k0zM-2BF22tbaoGpKBAjNd7-@mail.gmail.com>
	 <1299091805.2664.16.camel@bwh-desktop>
	 <8A71B368A89016469F72CD08050AD334091C1FAB@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: Dimitrios Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:50528 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756909Ab1CBT1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 14:27:30 -0500
In-Reply-To: <8A71B368A89016469F72CD08050AD334091C1FAB@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-02 at 11:11 -0800, Dimitrios Michailidis wrote:
> Ben Hutchings wrote:
> > /**
> >  * struct ethtool_flow_ext - flow spec common extension fields
> >  * @vlan_etype: EtherType for vlan tagged packet to match
> >  * @vlan_tci: VLAN tag to match
> >  * @data: Driver-dependent data to match
> >  *
> >  * Note: Additional fields may be inserted before @vlan_etype in future,
> >  * but the offset of the existing fields within the containing structure
> >  * (&struct ethtool_rx_flow_spec) will be stable.
> >  */
> > struct ethtool_flow_ext {
> > 	__be16	vlan_etype;
> > 	__be16	vlan_tci;
> > 	__be32	data[2];
> > };
> 
> I am wondering about the semantics of these vlan_* fields.  Is vlan_etype the
> Ethertype in the VLAN header or the type after it?

It would be the the type in the VLAN tag.  The nested ethertype is
normally implied by flow_type to be ETH_P_IP.

This does leave the question of what this would mean:

struct ethtool_rx_flow_spec fs = {
	.flow_type = ... | FLOW_EXT,
	...
	.h_ext.vlan_tci = htons(0x1234),
	.m_ext.vlan_etype = 0xffff,
};

This says the TCI must be == 0x1234 but the type can be anything.  But
the type surely has to be be one assigned for use in VLAN tags.  Should
we leave it to the driver/hardware to determine what those valid types
are, or should we reject this as valid?

> Specifically, I am wondering
> whether these fields are limited to VLANs or can work with general Ethertypes and the
> 2 bytes after them.

If you set flow_type = ETHER_FLOW you can then specify any combination
of Ethernet header fields to match in {h_u,m_u}.ether_spec.  However, so
far only sfc implements it and it only allows matching on the
destination MAC address.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

