From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network interfaces with random MAC address
Date: Wed, 21 Jul 2010 12:25:49 -0700
Message-ID: <201007211225.50457.leedom@chelsio.com>
References: <20100721102816.4bef5ada@nehalam> <201007211129.48288.leedom@chelsio.com> <20100721.113906.102700682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, andy@greyhouse.net, harald@redhat.com,
	bhutchings@solarflare.com, sassmann@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:20569 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761348Ab0GUTeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 15:34:14 -0400
In-Reply-To: <20100721.113906.102700682.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: David Miller <davem@davemloft.net>
| Date: Wednesday, July 21, 2010 11:39 am
| 
| From: Casey Leedom <leedom@chelsio.com>
| Date: Wed, 21 Jul 2010 11:29:47 -0700
| 
| >   Another option might be to have a new Net Device Operations call to ask
| > the adapter for a Unique Key.  This could be formed for most devices via a
| > tuple of the {PCI Vendor ID, PCI Device ID, Adapter Serial Number, Port
| > Number, [and if applicable] Adapter Function ID}.  Of course this could
| > be a fairly long string ... :-)
| 
| If a unique key were available, it could be used to generate a persistent
| MAC address.

  True but ... the Unique Key name space is probably a lot larger (in bits) than 
the MAC Address name space (~(48-2) bits) ... :-)

| And this sort of means that these drivers could use bits of the
| device's geographic ID the construct persistent MAC addresses, but
| only if done in a MAC namespace that could be guarenteed unique on the
| local system.

  Yep.  That's the problem of trying to construct a Unique Locally Assigned MAC 
Address from a Unique Name in a larger name space.

| From: "Rose, Gregory V" <gregory.v.rose@intel.com>
| Date: Wednesday, July 21, 2010 11:43 am
| 
| I'm curious, what happens when the VM using the VF migrates to a new
| machine and has another VF assigned to with a different MAC address?

  To be honest, I still haven't wrapped my head around how Virtual Machines are 
ever going to be able to migrate when they have arbitrary PCI Devices "assigned" 
(KVM Terminology) to them (AKA "PCI Pass Through").  Allowing VMs to directly 
touch real and arbitrary hardware devices means that some abstraction of "saving 
the device state" and "restoring the device state" can be successfully 
negotiated ... which would be hard even if you quiesce the device and you 
migrate to another Physical Host with identical PCI Hardware which is then 
"assigned" to the migrated VM.  Hard, hard, hard.

  This is why most of the Hypervisor systems have used synthetic Pseudo Devices 
to allow that state of those Virtual Devices to be migrated (including the MAC 
Addresses which we've been talking about).  I actually think that the Microsoft 
HyperV approach of Virtual Ingress Queues may be a better solution.  You still 
need to make the VM-to-Hypervisor transitions but you get to avoid the Free List 
memory copy costs which are actually the dominant cost in the RX path to VMs 
using software vNICs.

  But that's straying far from the topic at hand.  The short answer is pretty 
much what David suggests: the _hardware_ PCI-E SR-IOV Virtual Function provides 
persistent, non-random MAC Addresses for use by the VF Driver -- if it wants to 
use them.  A VF Driver running in a VM is capable of specifying arbitrary MAC 
Addresses for use with the VF and may ignore the hardware MAC Addresses provided 
by the VF.  This is little different from the current situation with software 
vNICs which use manufactured MAC Addresses (which are persistent in all of the 
Hypervisor systems at which I've looked).

| From: David Miller <davem@davemloft.net>
| Date: Wednesday, July 21, 2010 11:48 am
| 
| If the VM itself is the "physical entity" of the system, the logical
| conclusion I come to is that some kind of key should be obtained
| through the VM to uniquely give the device a persistent MAC.

  Which is, as above, what all Hypervisor systems which I've looked at do.

| You could do things like have the PF controller use the root filesystem
| ID label to construct the VF's MAC address, or something like that.

  It's actually stored in the VM's meta-data.  When a VM migrates from one 
Physical Host to another all of the VM's transient and persistent state must be 
available to the new Physical Host.  Xen, for instance, has the concept of a 
Physical Host Pool where all of the Physical Hosts have common access to shared 
resources like Network Attached Storage, LAN/VLANs and the shared VM meta-data.

Casey
