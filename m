From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [PATCH] virtif: initial interface extensions
Date: Mon, 10 May 2010 17:25:00 -0700
Message-ID: <C80DF1EC.2FFE0%scofeldm@cisco.com>
References: <201005102346.38229.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Stefan Berger <stefanb@us.ibm.com>, <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:36782 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560Ab0EKAZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 20:25:08 -0400
In-Reply-To: <201005102346.38229.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/10/10 2:46 PM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> On Monday 10 May 2010 20:56:39 Scott Feldman wrote:
>> With Arnd's latest additions, we have a single netlink msg, but the
>> parameter sets are disjoint between VDP/CDCP and what we need for the kernel
>> driver.  So that means the sender (libvirt in this case) needs to know about
>> both setups to send a single netlink msg.  An alternative is a have two
>> netlink msgs, one for each setup.  That still requires the sender to know
>> about two setups.
> 
> There are two separate issues here. The first one is whether we're doing
> the association in the device driver or in user space. The assumption here
> is that if it's in the device driver, there will be a VF number to identify
> the channel, while in user space that is not needed.
> 
> The other question is which protocol we're using. There are as far as I
> can tell five options:
> 
> 1. enic device driver
> 2. VDP
> 3. CDCP
> 4. CDCP + VDP
> 5. enic + VDP
> 
> The first two ones are the most interesting for now, since Linux cannot do
> S-VLANs yet, and they are required for CDCP. However, each of these options
> could theoreticall be done in the kernel (plus firmware) or in user space.
> 
> If it's done in user space, the VF number is meaningless, because the setup
> of the software device is also done from software, but instead you need to
> take care of creating the software device with the correct parameters, e.g.
> a macvtap device connected to a VLAN interface using the numbers you pass
> in the VDP protocol.
> 
> Right now, we're not planning to do the protocol that enic uses in LLDPAD,
> because it's not publically released. Similarly, there are no adapters that
> do VDP in firmware, but both these cases should be covered by the protocol
> and it would be good if libvirt could handle them.
> 
> Stefan, can you just define the XML in a way that matches the netlink
> definition? What you need is something like
> 
> 1. VF number (optional, signifies that 2/3 are done in firmware)
> 2. Lower-level protocol
>   2.1. CDCP
>      2.1.1 SVID
>      2.1.2 SCID
>   2.2. enic
>      2.2.1 port profile name
>      2.2.2 ...
> 3. VDP
>   3.1 VSI type/version/provider
>   3.2 UUID
>   3.3 MAC/VLAN
> 
> You need to have 2. or 3. or both, and 2.1/2.2 are mutually exclusive.

I'm don't think this is going in the right direction.  We're talking a
pretty simple concept of a port-profile used to configure the virtual port
backing a VM i/f to something that's trying to munge disjoint protocols
based on pre-standard work into a single API.  It's forcing all those
pre-standard protocol details into the API, into the XML, and into the mgmt
software (libvirt), and into the admin's lap.

I want the API to pass a port-profile name plus other information associated
with the VM i/f to some mgmt object which can setup the virtual port backing
the VM i/f.  (And unset it).  Using netlink for API let's that object be in
user- or kernel-space software, hardware or firmware.  How the object sets
up the virtual port based on the passed port-profile is beyond the scope of
the API.

My last port-profile patch is this API.  It gives us this:

    1) single netlink msg for kernel- and user-space
    2) single parameter set from sender's perspective (libvirt)
    3) single XML representation of parameters
    4) single code path in kernel and libvirt
    5) (potential) cross-vendor-switch VM migration
    6) admin-friendly port-profile names
    7) allows pre-standard (802.1Qbg/bh) details to change
       without bogging down the API

What I proposed on the libvirt list is to maintain a mapping database from
port-profile to vendor-specific or protocol-specific parameters.  Using VDP
as an example, a port-profile would resolve the VDP tuple:

     port-profile: "joes-garage"   --->  VSI Manager ID: 15
                                         VSI Type ID: 12345
                                         VSI Type ID Ver: 1
                                         other VSI settings (preassociate)

How the mapping database is maintained is beyond the scope of the API.

The port-profile string is the unifying concept.  This is the common ground
and the only way to be protocol-independent in the API.

-scott

