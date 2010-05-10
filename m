From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] virtif: initial interface extensions
Date: Mon, 10 May 2010 23:46:37 +0200
Message-ID: <201005102346.38229.arnd@arndb.de>
References: <C80DA4F7.2FBCF%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stefan Berger <stefanb@us.ibm.com>, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:52539 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756902Ab0EJVrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 17:47:05 -0400
In-Reply-To: <C80DA4F7.2FBCF%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 10 May 2010 20:56:39 Scott Feldman wrote:
> On 5/10/10 8:37 AM, "Stefan Berger" <stefanb@us.ibm.com> wrote:
> > In what case would the IFLA_VIRTIF_PORT_PROFILE be provided? Would libvirt for
> > example need to be aware of whether the Ethernet device can handle the setup
> > protocol via its firmware and in this case provide the port profile parameter
> > and in other cases provide other parameters? Certainly the user or upper layer
> > management software would have to know it when creating the domain XML and in
> > fact different types of parameters were needed.
> 
> > Obviously we should have one
> > common set of (XML) parameters that go into the netlink message and that can
> > be handled by the kernel driver if the firmware knows how to handle it or by
> > LLDPAD. 
> 
> With Arnd's latest additions, we have a single netlink msg, but the
> parameter sets are disjoint between VDP/CDCP and what we need for the kernel
> driver.  So that means the sender (libvirt in this case) needs to know about
> both setups to send a single netlink msg.  An alternative is a have two
> netlink msgs, one for each setup.  That still requires the sender to know
> about two setups.

There are two separate issues here. The first one is whether we're doing
the association in the device driver or in user space. The assumption here
is that if it's in the device driver, there will be a VF number to identify
the channel, while in user space that is not needed.

The other question is which protocol we're using. There are as far as I
can tell five options:

1. enic device driver
2. VDP
3. CDCP
4. CDCP + VDP
5. enic + VDP

The first two ones are the most interesting for now, since Linux cannot do
S-VLANs yet, and they are required for CDCP. However, each of these options
could theoreticall be done in the kernel (plus firmware) or in user space.

If it's done in user space, the VF number is meaningless, because the setup
of the software device is also done from software, but instead you need to
take care of creating the software device with the correct parameters, e.g.
a macvtap device connected to a VLAN interface using the numbers you pass
in the VDP protocol.

Right now, we're not planning to do the protocol that enic uses in LLDPAD,
because it's not publically released. Similarly, there are no adapters that
do VDP in firmware, but both these cases should be covered by the protocol
and it would be good if libvirt could handle them.

Stefan, can you just define the XML in a way that matches the netlink
definition? What you need is something like

1. VF number (optional, signifies that 2/3 are done in firmware)
2. Lower-level protocol
  2.1. CDCP
     2.1.1 SVID
     2.1.2 SCID
  2.2. enic
     2.2.1 port profile name
     2.2.2 ...
3. VDP
  3.1 VSI type/version/provider
  3.2 UUID
  3.3 MAC/VLAN

You need to have 2. or 3. or both, and 2.1/2.2 are mutually exclusive.

	Arnd
