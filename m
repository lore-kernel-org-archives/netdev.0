From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 PATCH 1/2] Add netdev port-profile support (take III, was iovnl)
Date: Wed, 28 Apr 2010 15:13:58 +0200
Message-ID: <201004281513.58879.arnd@arndb.de>
References: <20100428044235.8646.61943.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:56769 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab0D1NOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 09:14:19 -0400
In-Reply-To: <20100428044235.8646.61943.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 28 April 2010, Scott Feldman wrote:
> From: Scott Feldman <scofeldm@cisco.com>
> 
> Add new netdev ops ndo_{set|get}_port_profile to allow setting of port-profile
> on a netdev interface.  Extends RTM_SETLINK/RTM_GETLINK with new sub cmd called
> IFLA_PORT_PROFILE (added to end of IFLA_cmd list).  The port-profile cmd
> arguments are (as seen from modified iproute2 cmdline):
>
>        ip link set DEVICE [ { up | down } ]
>                           [ arp { on | off } ]
>                           [ dynamic { on | off } ]
>                           [ multicast { on | off } ]
>                           ...
>                           [ vf NUM [ mac LLADDR ]
>                                    [ vlan VLANID [ qos VLAN-QOS ] ]
>                                    [ rate TXRATE ] ] 
>                           [ port_profile [ PORT-PROFILE
>                                    [ mac LLADDR ]
>                                    [ host_uuid HOST_UUID ]
>                                    [ client_uuid CLIENT_UUID ]
>                                    [ client_name CLIENT_NAME ] ] ]
>        ip link show [ DEVICE ]

We will need a few more options to cover draft VDP in addition to the protocol
your NIC is using. I still think it's possible to use the same interface
for both, but the differences are obviously showing.

The missing bits that I can see so far are:

- You only have 'get' and 'set'. We will also need a 'unset' or 'delete'
  option in order to get rid of a port profile association.
- VDP has three different ways to 'set' a port profile: 'associate',
  'pre-associate with resource reservation' and 'pre-associate without
  resource reservation'. This could become an extra option flag.
- Instead of a port profile name, VDP specifies a tuple like
   struct vsi_associate {
	unsigned char VSI_Mgr_ID;       /* VSI manager ID */
	unsigned char VSI_Type_ID[3];   /* 24 bit VSI Type ID */
	unsigned char VSI_Type_Version; /* VSI Type version */
   };
   I'm not sure how to deal with that best, but there needs to be
   some parsing of these numbers.
- VDP requires a vlan ID to be part of the association, in addition to
  the MAC address. In theory, we could have multiple tuples of MAC+VLAN
  addresses, but we can probably just associate each tuple separately
  and ignore that part of the standard.
- we have a set of possible error conditions that can be returned by
  the switch (invalid format, insufficient resources, unknown VTID,
  VTID violation, VTID verison violation, out of sync). It should be
  possible to return each of these to the user with 'get'.

> Since we're using netlink sockets, the receiver of the RTM_SETLINK msg can
> be in kernel- or user-space.  For kernel-space recipient, rtnetlink.c, the
> new ndo_set_port_profile netdev op is called to set the port-profile.
> User-space recipients can decide how they propagate the msg to the switch.
> There is also a RTM_GETLINK cmd to to return port-profile setting of an
> interface and to also return the status of the last port-profile.

More on a stylistic note, I'm not convinced that using RTM_SETLINK/GETLINK
is the right interface for this, unlike the 'ip link set DEV vf ...' stuff,
because it seems to suggest that this is an option of the adapter itself.
I actually liked the iovnl family better in this regard, because it kept
the protocols separate.

What I could imagine to unify this is something like

   ip port_profile set DEVICE [ { pre_associate | pre_associate_rr } ]
                              { name PORT-PROFILE | vsi MGR:VTID:VER }
                                    mac LLADDR
				    [ vlan VID ]
                                    [ host_uuid HOST_UUID ]
                                    [ client_uuid CLIENT_UUID ]
                                    [ client_name CLIENT_NAME ]
   ip port_profile del DEVICE [ mac LLADDR [ vlan VID ] ]
   ip port_profile show DEVICE

	Arnd
