From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 02/11] igb: Use node specific allocations for the q_vectors
 and rings
Date: Mon, 10 Oct 2011 09:15:02 -0700
Message-ID: <4E931A06.7090805@intel.com>
References: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com>	<1318056461-19562-3-git-send-email-jeffrey.t.kirsher@intel.com> <20111008.155158.566839176815794249.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:5872 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750897Ab1JJQOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 12:14:53 -0400
In-Reply-To: <20111008.155158.566839176815794249.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/2011 12:51 PM, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri,  7 Oct 2011 23:47:32 -0700
> 
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> This change is meant to update the ring and vector allocations so that they
>> are per node instead of allocating everything on the node that
>> ifconfig/modprobe is called on.  By doing this we can cut down
>> significantly on cross node traffic.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> adapter->node seems superfluous.
> 
> It's always "-1" when we enter the allocation functions, and we
> always restore it to it's original value upon exit from such
> functions.
> 
> Just get rid of it and use a local variable in these functions
> to keep track of the current allocation node.
> 
> Also, what ensures that MSI-X interrupts are targetted to a cpu
> on the the node where you've made these allocations?  I was
> pretty sure Ben Hutchings added infrastructure that's usable
> to ensure this, but I can't see where you're using it.

Actually the main reason for having adapter->node is because in our
out-of-tree driver we end up using it as a module parameter in the event
that someone is running in single queue mode and wants to split up the
ports between nodes.  As such I would prefer to keep the parameter
around and just default it to -1 as I am currently doing.  However if it
must go I guess I can work around that sync-up issue.

In this case we don't have any guarantee other than the fact that most
people when trying to get performance will arrange their IRQs in a round
robin fashion.  However this approach is still preferred over just
allocating all of the rings on one node and incurring the possible
overhead for all of the access being primarily on a single node.  The
igb implementation doesn't have the code in place yet for the irq
affinity hints.  It is one of the few things remaining for me to sync up
between igb and ixgbe, however it is on my list of things to do.

Thanks,

Alex
