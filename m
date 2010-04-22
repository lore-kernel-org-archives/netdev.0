From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Thu, 22 Apr 2010 12:02:30 -0700
Message-ID: <20100422190230.GL28829@x200.localdomain>
References: <C7F4AD4F.2A34D%scofeldm@cisco.com>
 <201004220851.05756.arnd@arndb.de>
 <20100422174729.GK28829@x200.localdomain>
 <201004222048.53950.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@redhat.com>,
	Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Mitch Williams <mitch.a.williams@intel.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753466Ab0DVTDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 15:03:07 -0400
Content-Disposition: inline
In-Reply-To: <201004222048.53950.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Arnd Bergmann (arnd@arndb.de) wrote:
> On Thursday 22 April 2010 19:47:29 Chris Wright wrote:
> > OK, wasn't clear if you meant that or simply 100% dedicating the interface
> > via something like virtio.  The add_vf() idea, while neat, doesn't really
> > match how VF's are allocated.
> 
> But we still need something like that for allocating queues in VMDq
> and similar cases where we do not have pass-through, right?

Iff we care about VMDq w/out SR-IOV (since SR-IOV hardware is VMDq
capable and already has a queue-pair + interrupt + net_dev), yes.

And it's not just VMDq, it's any multi-queue card that can do mac/vlan
filter in hw + header/data split (for direct data DMA to guest buffers).

> As far as I can tell we don't have an interface for that yet, but
> we have drivers for a number of cards that could do this.
> 
> > > I don't have an SR-IOV card available for testing yet. How is this
> > > configured now?
> > 
> > The device shows up in the host as a normal network device, so mgmt tools
> > currently treat it as if it's no different from a PF.  So that's just
> > plain old:
> > 
> > SIOCSIFHWADDR or RTM_SETLINK (i.e. normal ->ndo_set_mac_addr)
> 
> Ok, but that only works for a fixed number of VFs and you can only
> configure the VF before it's assigned to the guest, right?

Depends on assign.

Assign meaning it's still visible in host, but only one guest is using
it via virtio (e.g. vhost-net)....then no, can change anytime (although
it's not typically changed during VM lifecycle).

Assign meaning direct PCI device assignment of the VF to the guest,
then yes, only while the device has driver in host.

> Both are not serious limitations, but it would be nice to
> have an easy way around them. In particular, for assigning
> the mac address and vlan id (VF in access mode), there needs
> to be some interface that allows the host but not the guest
> to change the settings after assigning the card to the guest.
> 
> This is a fundamental requirement for VEPA, because the switch
> applied its forwarding rules based on the mac address and trusts
> the hypervisor to make sure it cannot be faked by the guest.

Sure, but the VF (when directly assigned to the guest) is going to (at
least it should, for security reasons) always trap to a privileged code if
the guest tries to do something like set mac or vlan id.  All the SR-IOV
cards I've seen do this.  The "set VF mac addr" is really a message to
the PF.

thanks,
-chris
