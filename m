From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [RFC PATCH iproute2] ip: Add support for setting MAC and VLAN
 on hardware queues
Date: Wed, 18 Nov 2009 15:07:23 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FA69A3201@rrsmsx501.amr.corp.intel.com>
References: <20091117215432.15195.94504.stgit@localhost.localdomain>
	<20091117140641.7f8c8ac0@nehalam>
	<20091118.100728.91511216.davem@davemloft.net>
 <20091118111555.0e4caa8f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:36318 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756962AbZKRWHU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 17:07:20 -0500
In-Reply-To: <20091118111555.0e4caa8f@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Stephen Hemminger [mailto:shemminger@vyatta.com]
>Sent: Wednesday, November 18, 2009 11:16 AM
>> >
>> > Is there anything to avoid prevent this from being misused by users who
>> > are doing multiqueue. Maybe we need equivalent of "mounted" flag that
>block
>> > devices have?
>>
>> It's a privileged config operation as far as I can tell.
>>
>> Given that, what could we possibly need to protect?
>>
>> This stuff looks basically fine to me.
>>
>
>I was thinking that maybe the general question of SR-IOV overlap with other
>multiqueue usage. How is it possible to be sure queue is not being used
>for other traffic?  The MAC stuff itself is fine, just an example where
>changing a queue being used for SR-IOV makes sense, but if being used
>for regular multiqueue receive doesn't.
>
>The filesystem example is that for years it was possible to do something
>dumb like do fsck on a mounted filesystem and cause trouble (on unix and
>early
>linux); but current systems don't allow it because it is stupid idea.
>

Right now, this is only intended for SR-IOV usage, and the ixgbe driver enforces that by returning error if you try to set filters on queue 0, which corresponds to the PF device. We could conceivably extend this for use with non-IOV device queues and filters, but we'd need to look long and hard at the use cases and semantics of "what is a queue?" before we do that.

In this case (SR-IOV), we really can't realistically do any policy enforcement aside from root privilege.  Yeah, it's a bad idea to change these filters on an active queue - the VM would just mysteriously stop receiving traffic.  OTOH, the driver can't tell for sure what's going on with the VF device. Is it running, unloaded, crashed, booting...? There's no way to tell.

So we have to allow the filters to be changed at any time, even if there's a possibility that the VM is using the queue. We have to trust that the VM manager/hypervisor/whatever knows what it's doing, because we have no choice.

-Mitch
