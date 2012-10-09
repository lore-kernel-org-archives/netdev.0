From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: setting flow spec rules under vswitch configuration
Date: Tue, 9 Oct 2012 17:48:31 +0100
Message-ID: <1349801311.2800.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <5073F073.3060403@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rony Efraim <ronye@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30757 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754705Ab2JIQsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 12:48:39 -0400
In-Reply-To: <5073F073.3060403@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-09 at 11:37 +0200, Or Gerlitz wrote:
> Hi Ben,
> 
> Looking on kernel ethtool flow steering APIs in the context of a device
> which is used as the uplink of a virtual switch, the admin should be able
> to provide flow specification and action (e.g drop) that relates to traffic
> coming from a specific port of the switch e.g that relates to a certain 
> VM,etc.
> 
> For that end, we need to be able to specify both the L3/L4 attributes of
> the flow and an L2 spec, that is the L2 spec containing the destination MAC
> can't be assumed as the one of that device.
> 
> Specifically, in struct ethtool_rx_ntuple_flow_spec, I think we should 
> let the
> to provide an ethhdr even when L3/L4 spec is given, make sense?

Yes, but the ethertype looks redundant - the inner type is implied by
the L3 flow type and the outer type for a VLAN-encapsulated packet
should be matched against ethtool_flow_ext::vlan_etype.  Might be better
to avoid confusion by just specifying the L2 addresses.

> if yes, how
> would you like to see this change, add a union entry that contains both, 
> or in
> another way?

struct ethtool_rx_ntuple_flow_spec is obsolete; struct
ethtool_rx_flow_spec is what we have to consider.  That effectively has:

	union ethtool_flow_union {
		struct ethtool_tcpip4_spec		tcp_ip4_spec;
		struct ethtool_tcpip4_spec		udp_ip4_spec;
		struct ethtool_tcpip4_spec		sctp_ip4_spec;
		struct ethtool_ah_espip4_spec		ah_ip4_spec;
		struct ethtool_ah_espip4_spec		esp_ip4_spec;
		struct ethtool_usrip4_spec		usr_ip4_spec;
		struct ethhdr				ether_spec;
		/* above are up to 16 bytes long */
		__u8					hdata[60];
	} h_u;
	struct ethtool_flow_ext {
		__be16	vlan_etype;
		__be16	vlan_tci;
		__be32	data[2];
	} h_ext;
	union ethtool_flow_union m_u;
	struct ethtool_flow_ext m_ext;

So ethtool_flow_union::hdata currently provides 44 bytes of padding
between the per-protocol flow specs and ethtool_flow_ext, which can be
reallocated to the *beginning* of ethtool_flow_ext.  At some point we'll
presumably want to add IPv6 flow specs, which will use up 24 bytes of
that padding at the front.  So we can potentially extend
ethtool_flow_ext by up to 20 bytes.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
