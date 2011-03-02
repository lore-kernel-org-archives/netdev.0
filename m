From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 02/10] ethtool: add ntuple flow specifier
 to network flow classifier
Date: Wed, 02 Mar 2011 18:50:05 +0000
Message-ID: <1299091805.2664.16.camel@bwh-desktop>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
	 <20110225233249.7920.70334.stgit@gitlad.jf.intel.com>
	 <1298682048.3555.18.camel@localhost>
	 <AANLkTi=P0v1+h=TjC2j5k0zM-2BF22tbaoGpKBAjNd7-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46709 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754696Ab1CBSuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 13:50:08 -0500
In-Reply-To: <AANLkTi=P0v1+h=TjC2j5k0zM-2BF22tbaoGpKBAjNd7-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-02-25 at 21:30 -0800, Alexander Duyck wrote:
> On Fri, Feb 25, 2011 at 5:00 PM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > On Fri, 2011-02-25 at 15:32 -0800, Alexander Duyck wrote:
[...]
> >> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> >> index aac3e2e..3d1f8e0 100644
> >> --- a/include/linux/ethtool.h
> >> +++ b/include/linux/ethtool.h
> >> @@ -378,10 +378,25 @@ struct ethtool_usrip4_spec {
> >>  };
> >>
> >>  /**
> >> + * struct ethtool_ntuple_spec_ext - flow spec extension for ntuple in nfc
> >> + * @unused: space unused by extension
> >> + * @vlan_etype: EtherType for vlan tagged packet to match
> >> + * @vlan_tci: VLAN tag to match
> >> + * @data: Driver-dependent data to match
> >> + */
> >> +struct ethtool_ntuple_spec_ext {
> >> +     __be32  unused[15];
> >> +     __be16  vlan_etype;
> >> +     __be16  vlan_tci;
> >> +     __be32  data[2];
> >> +};
> > [...]
> >
> > This is a really nasty way to reclaim space in the union.
> >
> > Let's name the union, shrink it and insert the extra fields that way:
> >
> > --- a/include/linux/ethtool.h
> > +++ b/include/linux/ethtool.h
> > @@ -377,27 +377,43 @@ struct ethtool_usrip4_spec {
> >        __u8    proto;
> >  };
> >
> > +union ethtool_flow_union {
> > +       struct ethtool_tcpip4_spec              tcp_ip4_spec;
> > +       struct ethtool_tcpip4_spec              udp_ip4_spec;
> > +       struct ethtool_tcpip4_spec              sctp_ip4_spec;
> > +       struct ethtool_ah_espip4_spec           ah_ip4_spec;
> > +       struct ethtool_ah_espip4_spec           esp_ip4_spec;
> > +       struct ethtool_usrip4_spec              usr_ip4_spec;
> > +       struct ethhdr                           ether_spec;
> > +       __u8                                    hdata[52];
> > +};
> > +
> > +struct ethtool_flow_ext {
> > +       __be16  vlan_etype;
> > +       __be16  vlan_tci;
> > +       __be32  data[2];
> > +       __u32   reserved[2];
> > +};
> > +
> 
> Any chance of getting the reserved fields moved to the top of the
> structure?  My only concern is that we might end up with a flow spec
> larger than 52 bytes at some point and moving the reserved fields to
> the front might give us a little more wiggle room future
> compatibility.
[...]

OK, so how about this:

/**
 * union ethtool_flow_union - flow spec type-specific fields
 * @tcp_ip4_spec: TCP/IPv4 fields to match
 * @udp_ip4_spec: UDP/IPv4 fields to match
 * @sctp_ip4_spec: SCTP/IPv4 fields to match 
 * @ah_ip4_spec: AH/IPv4 fields to match
 * @esp_ip4_spec: ESP/IPv4 fields to match
 * @usr_ip4_spec: User-defined IPv4 fields to match
 * @ether_spec: Ethernet fields to match
 *
 * Note: The size of this union may shrink in future to allow for
 * expansion in &struct ethtool_flow_ext.
 */
union ethtool_flow_union {
	struct ethtool_tcpip4_spec		tcp_ip4_spec;
	struct ethtool_tcpip4_spec		udp_ip4_spec;
	struct ethtool_tcpip4_spec		sctp_ip4_spec;
	struct ethtool_ah_espip4_spec		ah_ip4_spec;
	struct ethtool_ah_espip4_spec		esp_ip4_spec;
	struct ethtool_usrip4_spec		usr_ip4_spec;
	struct ethhdr				ether_spec;
	__u8					hdata[60];
};

/**
 * struct ethtool_flow_ext - flow spec common extension fields
 * @vlan_etype: EtherType for vlan tagged packet to match
 * @vlan_tci: VLAN tag to match
 * @data: Driver-dependent data to match
 *
 * Note: Additional fields may be inserted before @vlan_etype in future,
 * but the offset of the existing fields within the containing structure
 * (&struct ethtool_rx_flow_spec) will be stable.
 */
struct ethtool_flow_ext {
	__be16	vlan_etype;
	__be16	vlan_tci;
	__be32	data[2];
};

Please can you check that these definitions won't affect the size of
struct ethtool_rx_flow_spec on i386 or x86-64?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

