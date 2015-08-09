From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 0/4] Shared vhost design
Date: Sun, 9 Aug 2015 15:45:47 +0300
Message-ID: <20150809154357-mutt-send-email-mst@redhat.com>
References: <1436760455-5686-1-git-send-email-bsd@redhat.com>
 <20150727235818-mutt-send-email-mst@redhat.com>
 <jpgoaihs7lt.fsf@linux.bootlegged.copy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eyal Moscovici <EYALMO-7z/5BgaJwgfQT0dZR+AlfA@public.gmane.org>,
	Razya Ladelsky <RAZYA-7z/5BgaJwgfQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Bandan Das <bsd-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <jpgoaihs7lt.fsf-oDDOE2N8RG3XLSnhx7PemevR1TjyzBtM@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 08, 2015 at 07:06:38PM -0400, Bandan Das wrote:
> Hi Michael,
> 
> "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> 
> > On Mon, Jul 13, 2015 at 12:07:31AM -0400, Bandan Das wrote:
> >> Hello,
> >> 
> >> There have been discussions on improving the current vhost design. The first
> >> attempt, to my knowledge was Shirley Ma's patch to create a dedicated vhost
> >> worker per cgroup.
> >> 
> >> http://comments.gmane.org/gmane.linux.network/224730
> >> 
> >> Later, I posted a cmwq based approach for performance comparisions
> >> http://comments.gmane.org/gmane.linux.network/286858
> >> 
> >> More recently was the Elvis work that was presented in KVM Forum 2013
> >> http://www.linux-kvm.org/images/a/a3/Kvm-forum-2013-elvis.pdf
> >> 
> >> The Elvis patches rely on common vhost thread design for scalability
> >> along with polling for performance. Since there are two major changes
> >> being proposed, we decided to split up the work. The first (this RFC),
> >> proposing a re-design of the vhost threading model and the second part
> >> (not posted yet) to focus more on improving performance. 
> >> 
> >> I am posting this with the hope that we can have a meaningful discussion
> >> on the proposed new architecture. We have run some tests to show that the new
> >> design is scalable and in terms of performance, is comparable to the current
> >> stable design. 
> >> 
> >> Test Setup:
> >> The testing is based on the setup described in the Elvis proposal.
> >> The initial tests are just an aggregate of Netperf STREAM and MAERTS but
> >> as we progress, I am happy to run more tests. The hosts are two identical
> >> 16 core Haswell systems with point to point network links. For the first 10 runs,
> >> with n=1 upto n=10 guests running in parallel, I booted the target system with nr_cpus=8
> >> and mem=12G. The purpose was to do a comparision of resource utilization
> >> and how it affects performance. Finally, with the number of guests set at 14,
> >> I didn't limit the number of CPUs booted on the host or limit memory seen by
> >> the kernel but boot the kernel with isolcpus=14,15 that will be used to run
> >> the vhost threads. The guests are pinned to cpus 0-13 and based on which
> >> cpu the guest is running on, the corresponding I/O thread is either pinned
> >> to cpu 14 or 15.
> >> Results
> >> # X axis is number of guests
> >> # Y axis is netperf number
> >> # nr_cpus=8 and mem=12G
> >> #Number of Guests        #Baseline            #ELVIS
> >> 1                        1119.3		      1111.0
> >> 2			 1135.6		      1130.2
> >> 3			 1135.5		      1131.6
> >> 4			 1136.0		      1127.1
> >> 5			 1118.6		      1129.3
> >> 6			 1123.4		      1129.8
> >> 7			 1128.7		      1135.4
> >> 8			 1129.9		      1137.5
> >> 9			 1130.6		      1135.1
> >> 10			 1129.3		      1138.9
> >> 14*			 1173.8		      1216.9
> >
> > I'm a bit too busy now, with 2.4 and related stuff, will review once we
> > finish 2.4.  But I'd like to ask two things:
> > - did you actually test a config where cgroups were used?
> 
> Here are some numbers with a simple cgroup setup.
> 
> Three cgroups with cpusets cpu=0,2,4 for cgroup1, cpu=1,3,5 for cgroup2 and cpu=6,7
> for cgroup3 (even though 6,7 have different numa nodes)
> 
> I run netperf for 1 to 9 guests starting with assigning the first guest
> to cgroup1, second to cgroup2, third to cgroup3 and repeat this sequence
> upto 9 guests.
> 
> The numbers  - (TCP_STREAM + TCP_MAERTS)/2
> 
>  #Number of Guests             #ELVIS (Mbps)
>  1                    	      1056.9
>  2		      	      1122.5
>  3		      	      1122.8
>  4		      	      1123.2
>  5		      	      1122.6
>  6		      	      1110.3
>  7		      	      1116.3
>  8		      	      1121.8
>  9		      	      1118.5
> 
> Maybe, my cgroup setup was too simple but these numbers are comparable
> to the no cgroups results above. I wrote some tracing code to trace
> cgroup_match_groups() and find cgroup search overhead but it seemed
> unnecessary for this particular test.
> 
> 
> > - does the design address the issue of VM 1 being blocked
> >   (e.g. because it hits swap) and blocking VM 2?
> Good question. I haven't thought of this yet. But IIUC,
> the worker thread will complete VM1's job and then move on to
> executing VM2's scheduled work.
> It doesn't matter if VM1 is
> blocked currently. I think it would be a problem though if/when
> polling is introduced.

Sorry, I wasn't clear. If VM1's memory is in swap, attempts to
access it might block the service thread, so it won't
complete VM2's job.



> 
> >> 
> >> #* Last run with the vCPU and I/O thread(s) pinned, no CPU/memory limit imposed.
> >> #  I/O thread runs on CPU 14 or 15 depending on which guest it's serving
> >> 
> >> There's a simple graph at
> >> http://people.redhat.com/~bdas/elvis/data/results.png
> >> that shows how task affinity results in a jump and even without it,
> >> as the number of guests increase, the shared vhost design performs
> >> slightly better.
> >> 
> >> Observations:
> >> 1. In terms of "stock" performance, the results are comparable.
> >> 2. However, with a tuned setup, even without polling, we see an improvement
> >> with the new design.
> >> 3. Making the new design simulate old behavior would be a matter of setting
> >> the number of guests per vhost threads to 1.
> >> 4. Maybe, setting a per guest limit on the work being done by a specific vhost
> >> thread is needed for it to be fair.
> >> 5. cgroup associations needs to be figured out. I just slightly hacked the
> >> current cgroup association mechanism to work with the new model. Ccing cgroups
> >> for input/comments.
> >> 
> >> Many thanks to Razya Ladelsky and Eyal Moscovici, IBM for the initial
> >> patches, the helpful testing suggestions and discussions.
> >> 
> >> Bandan Das (4):
> >>   vhost: Introduce a universal thread to serve all users
> >>   vhost: Limit the number of devices served by a single worker thread
> >>   cgroup: Introduce a function to compare cgroups
> >>   vhost: Add cgroup-aware creation of worker threads
> >> 
> >>  drivers/vhost/net.c    |   6 +-
> >>  drivers/vhost/scsi.c   |  18 ++--
> >>  drivers/vhost/vhost.c  | 272 +++++++++++++++++++++++++++++++++++--------------
> >>  drivers/vhost/vhost.h  |  32 +++++-
> >>  include/linux/cgroup.h |   1 +
> >>  kernel/cgroup.c        |  40 ++++++++
> >>  6 files changed, 275 insertions(+), 94 deletions(-)
> >> 
> >> -- 
> >> 2.4.3
