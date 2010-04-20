From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Tue, 20 Apr 2010 15:48:26 +0200
Message-ID: <201004201548.26609.arnd@arndb.de>
References: <20100419191807.10423.84600.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:60717 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084Ab0DTNsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 09:48:31 -0400
In-Reply-To: <20100419191807.10423.84600.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 19 April 2010, Scott Feldman wrote:

> IOV netlink (IOVNL) adds I/O Virtualization control support to a master
> device (MD) netdev interface.  The MD (e.g. SR-IOV PF) will set/get
> control settings on behalf of a slave netdevice (e.g. SR-IOV VF).  The
> design allows for the case where master and slave are the
> same netdev interface.

What is the reason for controlling the slave device through the master,
rather than talking to the slave directly? The kernel always knows
the master for each slave, so it seems to me that this information
is redundant.

Is this new interface only for the case that you have a switch integrated
in the NIC, or also for the case where you do an LLDP and EDP exchange
with an adjacent bridge and put the device into VEPA mode?

> One control setting example is MAC/VLAN settings for a VF.  Another
> example control setting is a port-profile for a VF.  A port-profile is an
> identifier that defines policy-based settings on the network port
> backing the VF.  The network port settings examples are VLAN membership,
> QoS settings, and L2 security settings, typical of a data center network.
> 
> This patch adds the iovnl interface definitions and an iovnl module.

How does this relate to the existing DCB netlink interface? My feeling
is that there is some overlap in how it would get used, and some parts
that are very distinct. In particular, I'd guess that you'd want to
be able to set DCB parameters for each VF, but not all DCB adapters
would support SR-IOV.

Did you consider making this code an extension to the DCB interface
instead of a separate one? What was the reason for your decision
to keep it separate?

Also, do you expect your interface to be supported by dcbd/lldpad,
or is there a good reason to create a new tool for iovnl?

> + * @IOV_ATTR_IFNAME: interface name of master (PF) net device (NLA_NUL_STRING)
> + * @IOV_ATTR_VF_IFNAME: interface name of target VF device (NLA_NUL_STRING)

As mentioned above, why not drop one of these, and just pass the VF's IFNAME?

> + * @IOV_ATTR_PORT_PROFILE: port-profile name to assign to device
> + *   (NLA_NUL_STRING)

How does the definition of the port profile get into the NIC's switch?
Is there any way to list the available port profiles?

> + * @IOV_ATTR_CLIENT_NAME: client name (NLA_NUL_STRING)
> + * @IOV_ATTR_HOST_UUID: host UUID (NLA_NUL_STRING)

Can you elaborate more on what these do? Who is the 'client' and the 'host'
in this case, and why do you need to identify them?

> + * @IOV_ATTR_MAC_ADDR: device station MAC address (NLA_U8[6])

Just one mac address? What happens if we want to assign multiple mac
addresses to the VF later? Also, how is this defined specifically?
Will a SIOCSIFHWADDR with a different MAC address on the VF fail
later, or is this just the default value?

> + * @IOV_ATTR_VLAN: device 8021q VLAN ID (NLA_U16)

Same here: Should you be able to set multiple MAC addresses, or
trunk mode? Can the VF override it?
Also, for the new multi-channel VEPA, I'd guess that you also need
to supply an 802.1ad S-VLAN ID.

	Arnd
