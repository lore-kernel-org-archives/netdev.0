From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH 0/2] ixgbe, fix numa issues
Date: Mon, 24 Feb 2014 14:34:33 -0500
Message-ID: <530B9EC9.4080007@redhat.com>
References: <1393267913-28212-1-git-send-email-prarit@redhat.com> <530B9C3E.1000308@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>, nhorman@redhat.com,
	agospoda@redhat.com, e1000-devel@lists.sourceforge.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752539AbaBXTeq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 14:34:46 -0500
In-Reply-To: <530B9C3E.1000308@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/24/2014 02:23 PM, Alexander Duyck wrote:
> On 02/24/2014 10:51 AM, Prarit Bhargava wrote:
>> The ixgbe driver makes some assumptions about the layout of cpus in the
>> system which are not always correct given a particular system layout.  The
>> ixgbe driver allocates one MSI/cpu for queue usage but the code does not take
>> into account that devices are located on NUMA nodes and that the cpus in a node
>> are not contiguous.
>>
>> These issues were found while doing cpu hotplug testing, however, both of these
>> issues can lead to obvious system performance issues as they defeat the
>> purpose of having one MSI processing a queue per cpu.
>>
>> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Cc: Bruce Allan <bruce.w.allan@intel.com>
>> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
>> Cc: Don Skidmore <donald.c.skidmore@intel.com>
>> Cc: Greg Rose <gregory.v.rose@intel.com>
>> Cc: Alex Duyck <alexander.h.duyck@intel.com>
>> Cc: John Ronciak <john.ronciak@intel.com>
>> Cc: Mitch Williams <mitch.a.williams@intel.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: nhorman@redhat.com
>> Cc: agospoda@redhat.com
>> Cc: e1000-devel@lists.sourceforge.net
>>
>> Prarit Bhargava (2):
>>   ixgbe, make interrupt allocations NUMA aware
>>   ixgbe, don't assume mapping of numa node cpus
>>
>>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    2 ++
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c   |   44 ++++++++++++++++++------
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |    6 ++--
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    5 +--
>>  4 files changed, 42 insertions(+), 15 deletions(-)
>>
> 
> This is a step in the right direction but totally defeats the purpose of
> ATR.  With this change we might as well defeature ATR all together since

ATR?  First hit on google is Americans for Tax Reform ;)

> things are now back to RSS w/ NUMA specific allocations which is what we
> had a couple of years ago.  The code as it is written now would be a
> better for for igb which doesn't have ATR than ixgbe.

The big(ger) problem here is that the ixgbe (and other drivers IIUC) do not do a
good job of handling MSIs, making sure they are launched on the right cpus, and
cleaning up during cpu hotplug operations.  This code looks like it needs a bit
of work so your advice is appreciated.

> 
> ATR is supposed to map 1:1 queues to CPUs.  The problem is RSS is also a
> factor and not especially smart or NUMA aware.  The ideal solution would
> be to allocate the first N CPUs, where N is the number in the local node
> for ATR/RSS.  

Okay ... I'll look into that.

Then map all other queues as ATR with a 1:1 mapping to CPUs.
> 

Hmmm ... but what if off-node CPUs cannot reach the device?  Part of the puzzle
here is that ACPI may be not only telling us that the device is on a specific
node, but that the device is physically separated on a root bus.

P.
