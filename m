From: Bandan Das <bsd@redhat.com>
Subject: Re: [RFC PATCH 0/4] Shared vhost design
Date: Mon, 10 Aug 2015 16:00:21 -0400
Message-ID: <jpgtws6rk16.fsf@linux.bootlegged.copy>
References: <1436760455-5686-1-git-send-email-bsd@redhat.com>
	<20150727235818-mutt-send-email-mst@redhat.com>
	<jpgoaihs7lt.fsf@linux.bootlegged.copy>
	<20150809154357-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eyal Moscovici <EYALMO@il.ibm.com>,
	Razya Ladelsky <RAZYA@il.ibm.com>, cgroups@vger.kernel.org,
	jasowang@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43597 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752498AbbHJUAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 16:00:23 -0400
In-Reply-To: <20150809154357-mutt-send-email-mst@redhat.com> (Michael
	S. Tsirkin's message of "Sun, 9 Aug 2015 15:45:47 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> writes:

> On Sat, Aug 08, 2015 at 07:06:38PM -0400, Bandan Das wrote:
>> Hi Michael,
...
>>
>> > - does the design address the issue of VM 1 being blocked
>> >   (e.g. because it hits swap) and blocking VM 2?
>> Good question. I haven't thought of this yet. But IIUC,
>> the worker thread will complete VM1's job and then move on to
>> executing VM2's scheduled work.
>> It doesn't matter if VM1 is
>> blocked currently. I think it would be a problem though if/when
>> polling is introduced.
>
> Sorry, I wasn't clear. If VM1's memory is in swap, attempts to
> access it might block the service thread, so it won't
> complete VM2's job.

Ah ok, I understand now. I am pretty sure the current RFC doesn't
take care of this :) I will add this to my todo list for v2.

Bandan

>
>
>> 
>> >> 
>> >> #* Last run with the vCPU and I/O thread(s) pinned, no CPU/memory limit imposed.
>> >> #  I/O thread runs on CPU 14 or 15 depending on which guest it's serving
>> >> 
>> >> There's a simple graph at
>> >> http://people.redhat.com/~bdas/elvis/data/results.png
>> >> that shows how task affinity results in a jump and even without it,
>> >> as the number of guests increase, the shared vhost design performs
>> >> slightly better.
>> >> 
>> >> Observations:
>> >> 1. In terms of "stock" performance, the results are comparable.
>> >> 2. However, with a tuned setup, even without polling, we see an improvement
>> >> with the new design.
>> >> 3. Making the new design simulate old behavior would be a matter of setting
>> >> the number of guests per vhost threads to 1.
>> >> 4. Maybe, setting a per guest limit on the work being done by a specific vhost
>> >> thread is needed for it to be fair.
>> >> 5. cgroup associations needs to be figured out. I just slightly hacked the
>> >> current cgroup association mechanism to work with the new model. Ccing cgroups
>> >> for input/comments.
>> >> 
>> >> Many thanks to Razya Ladelsky and Eyal Moscovici, IBM for the initial
>> >> patches, the helpful testing suggestions and discussions.
>> >> 
>> >> Bandan Das (4):
>> >>   vhost: Introduce a universal thread to serve all users
>> >>   vhost: Limit the number of devices served by a single worker thread
>> >>   cgroup: Introduce a function to compare cgroups
>> >>   vhost: Add cgroup-aware creation of worker threads
>> >> 
>> >>  drivers/vhost/net.c    |   6 +-
>> >>  drivers/vhost/scsi.c   |  18 ++--
>> >>  drivers/vhost/vhost.c  | 272 +++++++++++++++++++++++++++++++++++--------------
>> >>  drivers/vhost/vhost.h  |  32 +++++-
>> >>  include/linux/cgroup.h |   1 +
>> >>  kernel/cgroup.c        |  40 ++++++++
>> >>  6 files changed, 275 insertions(+), 94 deletions(-)
>> >> 
>> >> -- 
>> >> 2.4.3
