From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH 0/2] ixgbe, fix numa issues
Date: Mon, 24 Feb 2014 20:06:24 -0500
Message-ID: <530BEC90.2010705@redhat.com>
References: <1393267913-28212-1-git-send-email-prarit@redhat.com> <530B9C3E.1000308@intel.com> <530B9EC9.4080007@redhat.com> <530BA40E.3060008@intel.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:23179 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752541AbaBYBGm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 20:06:42 -0500
In-Reply-To: <530BA40E.3060008@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/24/2014 02:57 PM, Alexander Duyck wrote:

>>
>> The big(ger) problem here is that the ixgbe (and other drivers IIUC) do not do a
>> good job of handling MSIs, making sure they are launched on the right cpus, and
>> cleaning up during cpu hotplug operations.  This code looks like it needs a bit
>> of work so your advice is appreciated.
>>
> 
> I'm not seeing how this helps with hotplug since the driver doesn't get
> notifications of any such event anyway, at least not currently.  Are
> there some changes coming in that regard?

There have been some issues with CPU hotplug.  The problem started a while ago
with several different vendors systems being unable to perform cpu hotplug down
without running into strange storage issues.  I chased this down and came up
with linux.git commit da6139e49c7cb0f4251265cb5243b8d220adb48d, x86: Add check
for number of available vectors before CPU down [1].

What has caused that check to be necessary is that the ixgbe driver is now
allocating so many interrupts that on large systems which full sockets are taken
in and out of service, it is possible that there are not enough empty vectors
for all the irqs on a down'd cpu.  IMO what the ixgbe driver is effectively
doing is starving the system of resources.  If I rmmod the ixgbe driver (and
free it's irqs of course) I have no problem in taking all cpus except 1 out of
service.

I've started coding a cpu notifier which would take a queue out of service when
a cpu goes down but I hit these smaller issues which have to be fixed first
before I come up with the notifier.

P.

[1] Please note that even this is incorrect.  I don't properly take into account
node-specific interrupts which can only be moved to specific cpus because of the
affinity settings of MSI.  I'm working on a patch right now to fix that issue.


> 
>>>
>>> ATR is supposed to map 1:1 queues to CPUs.  The problem is RSS is also a
>>> factor and not especially smart or NUMA aware.  The ideal solution would
>>> be to allocate the first N CPUs, where N is the number in the local node
>>> for ATR/RSS.  
>>
>> Okay ... I'll look into that.
>>
>> Then map all other queues as ATR with a 1:1 mapping to CPUs.
>>>
>>
>> Hmmm ... but what if off-node CPUs cannot reach the device?  Part of the puzzle
>> here is that ACPI may be not only telling us that the device is on a specific
>> node, but that the device is physically separated on a root bus.
>>
>> P.
>>
> 
> As far as I know there shouldn't be anything that explicitly prevents us
> from reading/writing to any memory in the system.  In the case of the
> Intel NUMA configurations anyway we just can use the QPI bus if the CPU
> isn't connected to the same root complex.


> 
> Thanks,
> 
> Alex
