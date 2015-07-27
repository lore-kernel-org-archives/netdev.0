From: Bandan Das <bsd@redhat.com>
Subject: Re: [RFC PATCH 0/4] Shared vhost design
Date: Mon, 27 Jul 2015 15:48:19 -0400
Message-ID: <jpgmvyh9ybg.fsf@linux.bootlegged.copy>
References: <1436760455-5686-1-git-send-email-bsd@redhat.com>
	<OF451FED84.3040AFD2-ONC2257E8C.0043F908-C2257E8C.00446592@il.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: cgroups@vger.kernel.org, jasowang@redhat.com, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, Razya Ladelsky <RAZYA@il.ibm.com>
To: Eyal Moscovici <EYALMO@il.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <OF451FED84.3040AFD2-ONC2257E8C.0043F908-C2257E8C.00446592@il.ibm.com>
	(Eyal Moscovici's message of "Fri, 24 Jul 2015 15:27:02 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eyal Moscovici <EYALMO@il.ibm.com> writes:

> Hi, 
>
> The test showed the same relative numbers as we got in our internal 
> testing. I was wondering about the configuration in regards to NUMA. From
Thanks for confirming.

> our testing we saw that if the VMs are spread across 2 NUMA nodes then 
> having a shared vhost thread per node performs better then having the two 
> threads in the same core.

IIUC, this is similar to my test setup and observations i.e 
> 14*                                               1173.8  1216.9

In this case, there's a shared vhost thread on CPU 14 for numa node 0
and another on CPU 15 for numa node 1. Guests running on CPUs 0,2,4,6,8,10,12
are serviced by vhost-0 that runs on CPU 14 and guests running on CPUs 1,3,5,7,9,11,13
get serviced by vhost-1 (Numa node 1). I tried some other configurations but
this configuration gave me the best results.


Eyal, I think it makes sense to add polling on top of these patches and
get numbers for them too. Thoughts ?

Bandan

> Eyal Moscovici
> HL-Cloud Infrastructure Solutions
> IBM Haifa Research Lab
>
>
>
> From:   Bandan Das <bsd@redhat.com>
> To:     kvm@vger.kernel.org
> Cc:     netdev@vger.kernel.org, linux-kernel@vger.kernel.org, 
> mst@redhat.com, Eyal Moscovici/Haifa/IBM@IBMIL, Razya 
> Ladelsky/Haifa/IBM@IBMIL, cgroups@vger.kernel.org, jasowang@redhat.com
> Date:   07/13/2015 07:08 AM
> Subject:        [RFC PATCH 0/4] Shared vhost design
>
>
>
> Hello,
>
> There have been discussions on improving the current vhost design. The 
> first
> attempt, to my knowledge was Shirley Ma's patch to create a dedicated 
> vhost
> worker per cgroup.
>
> http://comments.gmane.org/gmane.linux.network/224730
>
> Later, I posted a cmwq based approach for performance comparisions
> http://comments.gmane.org/gmane.linux.network/286858
>
> More recently was the Elvis work that was presented in KVM Forum 2013
> http://www.linux-kvm.org/images/a/a3/Kvm-forum-2013-elvis.pdf
>
> The Elvis patches rely on common vhost thread design for scalability
> along with polling for performance. Since there are two major changes
> being proposed, we decided to split up the work. The first (this RFC),
> proposing a re-design of the vhost threading model and the second part
> (not posted yet) to focus more on improving performance. 
>
> I am posting this with the hope that we can have a meaningful discussion
> on the proposed new architecture. We have run some tests to show that the 
> new
> design is scalable and in terms of performance, is comparable to the 
> current
> stable design. 
>
> Test Setup:
> The testing is based on the setup described in the Elvis proposal.
> The initial tests are just an aggregate of Netperf STREAM and MAERTS but
> as we progress, I am happy to run more tests. The hosts are two identical
> 16 core Haswell systems with point to point network links. For the first 
> 10 runs,
> with n=1 upto n=10 guests running in parallel, I booted the target system 
> with nr_cpus=8
> and mem=12G. The purpose was to do a comparision of resource utilization
> and how it affects performance. Finally, with the number of guests set at 
> 14,
> I didn't limit the number of CPUs booted on the host or limit memory seen 
> by
> the kernel but boot the kernel with isolcpus=14,15 that will be used to 
> run
> the vhost threads. The guests are pinned to cpus 0-13 and based on which
> cpu the guest is running on, the corresponding I/O thread is either pinned
> to cpu 14 or 15.
>
> Results
> # X axis is number of guests
> # Y axis is netperf number
> # nr_cpus=8 and mem=12G
> #Number of Guests        #Baseline            #ELVIS
> 1                        1119.3                                1111.0
> 2                                                 1135.6  1130.2
> 3                                                 1135.5  1131.6
> 4                                                 1136.0  1127.1
> 5                                                 1118.6  1129.3
> 6                                                 1123.4  1129.8
> 7                                                 1128.7  1135.4
> 8                                                 1129.9  1137.5
> 9                                                 1130.6  1135.1
> 10                                                1129.3  1138.9
> 14*                                               1173.8  1216.9
>
> #* Last run with the vCPU and I/O thread(s) pinned, no CPU/memory limit 
> imposed.
> #  I/O thread runs on CPU 14 or 15 depending on which guest it's serving
>
> There's a simple graph at
> http://people.redhat.com/~bdas/elvis/data/results.png
> that shows how task affinity results in a jump and even without it,
> as the number of guests increase, the shared vhost design performs
> slightly better.
>
> Observations:
> 1. In terms of "stock" performance, the results are comparable.
> 2. However, with a tuned setup, even without polling, we see an 
> improvement
> with the new design.
> 3. Making the new design simulate old behavior would be a matter of 
> setting
> the number of guests per vhost threads to 1.
> 4. Maybe, setting a per guest limit on the work being done by a specific 
> vhost
> thread is needed for it to be fair.
> 5. cgroup associations needs to be figured out. I just slightly hacked the
> current cgroup association mechanism to work with the new model. Ccing 
> cgroups
> for input/comments.
>
> Many thanks to Razya Ladelsky and Eyal Moscovici, IBM for the initial
> patches, the helpful testing suggestions and discussions.
>
> Bandan Das (4):
>   vhost: Introduce a universal thread to serve all users
>   vhost: Limit the number of devices served by a single worker thread
>   cgroup: Introduce a function to compare cgroups
>   vhost: Add cgroup-aware creation of worker threads
>
>  drivers/vhost/net.c    |   6 +-
>  drivers/vhost/scsi.c   |  18 ++--
>  drivers/vhost/vhost.c  | 272 
> +++++++++++++++++++++++++++++++++++--------------
>  drivers/vhost/vhost.h  |  32 +++++-
>  include/linux/cgroup.h |   1 +
>  kernel/cgroup.c        |  40 ++++++++
>  6 files changed, 275 insertions(+), 94 deletions(-)
