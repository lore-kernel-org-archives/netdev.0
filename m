From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 0/2] ixgbe, fix numa issues
Date: Mon, 24 Feb 2014 11:23:42 -0800
Message-ID: <530B9C3E.1000308@intel.com>
References: <1393267913-28212-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>, nhorman@redhat.com,
	agospoda@redhat.com, e1000-devel@lists.sourceforge.net
To: Prarit Bhargava <prarit@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27954 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752907AbaBXTXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 14:23:44 -0500
In-Reply-To: <1393267913-28212-1-git-send-email-prarit@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2014 10:51 AM, Prarit Bhargava wrote:
> The ixgbe driver makes some assumptions about the layout of cpus in the
> system which are not always correct given a particular system layout.  The
> ixgbe driver allocates one MSI/cpu for queue usage but the code does not take
> into account that devices are located on NUMA nodes and that the cpus in a node
> are not contiguous.
>
> These issues were found while doing cpu hotplug testing, however, both of these
> issues can lead to obvious system performance issues as they defeat the
> purpose of having one MSI processing a queue per cpu.
>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Cc: Alex Duyck <alexander.h.duyck@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> Cc: Mitch Williams <mitch.a.williams@intel.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: nhorman@redhat.com
> Cc: agospoda@redhat.com
> Cc: e1000-devel@lists.sourceforge.net
>
> Prarit Bhargava (2):
>   ixgbe, make interrupt allocations NUMA aware
>   ixgbe, don't assume mapping of numa node cpus
>
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    2 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c   |   44 ++++++++++++++++++------
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |    6 ++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    5 +--
>  4 files changed, 42 insertions(+), 15 deletions(-)
>

This is a step in the right direction but totally defeats the purpose of
ATR.  With this change we might as well defeature ATR all together since
things are now back to RSS w/ NUMA specific allocations which is what we
had a couple of years ago.  The code as it is written now would be a
better for for igb which doesn't have ATR than ixgbe.

ATR is supposed to map 1:1 queues to CPUs.  The problem is RSS is also a
factor and not especially smart or NUMA aware.  The ideal solution would
be to allocate the first N CPUs, where N is the number in the local node
for ATR/RSS.  Then map all other queues as ATR with a 1:1 mapping to CPUs.

Thanks,

Alex
