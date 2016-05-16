From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] ixgbe: take online CPU number as MQ max limit when alloc_etherdev_mq()
Date: Mon, 16 May 2016 09:09:02 -0700
Message-ID: <CAKgT0UfJqu5sa7U4HKLFk0h3NjqavaAY0xfsahZ32MvnePFHdg@mail.gmail.com>
References: <1463118995-31763-1-git-send-email-ethan.zhao@oracle.com>
	<CAKgT0UeiEW21E7A9fnt_BUCppopns-E2w1WbwF-8A6sCZkJ8rQ@mail.gmail.com>
	<573937A7.9010405@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	shannon nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Bruce W Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ethan Zhao <ethan.kernel@gmail.com>
To: ethan zhao <ethan.zhao@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <573937A7.9010405@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 15, 2016 at 7:59 PM, ethan zhao <ethan.zhao@oracle.com> wrote:
> Alexander,
>
> On 2016/5/14 0:46, Alexander Duyck wrote:
>>
>> On Thu, May 12, 2016 at 10:56 PM, Ethan Zhao <ethan.zhao@oracle.com>
>> wrote:
>>>
>>> Allocating 64 Tx/Rx as default doesn't benefit perfomrnace when less
>>> CPUs were assigned. especially when DCB is enabled, so we should take
>>> num_online_cpus() as top limit, and aslo to make sure every TC has
>>> at least one queue, take the MAX_TRAFFIC_CLASS as bottom limit of queues
>>> number.
>>>
>>> Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
>>
>> What is the harm in allowing the user to specify up to 64 queues if
>> they want to?  Also what is your opinion based on?  In the case of RSS
>
>
>  There is no module parameter to specify queue number in this upstream ixgbe
>   driver.  for what to specify more queues than num_online_cpus() via
> ethtool ?
>  I couldn't figure out the benefit to do that.

There are a number of benefits to being able to set the number of
queues based on the user desire.  Just because you can't figure out
how to use a feature is no reason to break it so that nobody else can.

>  But if DCB is turned on after loading, the queues would be 64/64, that
> doesn't
>  make sense if only 16 CPUs assigned.

It makes perfect sense.  What is happening is that it is allocating an
RSS set per TC.  So what you should have is either 4 queues per CPU
with each one belonging to a different TC, or 4 queues per CPU with
the first 8 CPUs covering TCs 0-3, and the last 8 CPUs covering TCs
4-7.

I can see how the last setup might actually be a bit confusing.  To
that end you might consider modifying ixgbe_acquire_msix_vectors uses
the number of RSS queues instead of the number of Rx queues in the
case of DCB.  Then you would get more consistent behavior with each
q_vector or CPU (if num_q_vecotrs == num_online_cpus()) having one
queue belonging to each TC.  You would end up with either 8 or 16
q_vectors hosting 8 or 4 queues so that they can process DCB requests
without having to worry about head of line blocking.

>> traffic the upper limit is only 16 on older NICs, but last I knew the
>> latest X550 can support more queues for RSS.  Have you only been
>> testing on older NICs or did you test on the latest hardware as well?
>
>   More queues for RSS than num_online_cpus() could bring better performance
> ?
>   Test result shows false result.  even memory cost is not an issue for most
> of
>   the expensive servers, but not for all.

The feature is called DCB.  What it allows for is the avoidance of
head-of-line blocking.  So when you have DCB enabled you should have a
set of queues for each possible RSS result so that if you get a higher
priority request on one of the queues it can use the higher priority
queue instead of having to rely on the the lower priority queue to
receive traffic.  You cannot do that without allocating a queue for
each TC, and reducing the number of RSS queues supported on the system
will hurt performance.  Therefore on a 16 CPU system it is very useful
to be able to allocate 4 queues per RSS flow as that way you get
optimal CPU distribution and can still avoid head-of-line blocking via
DCB.

>>
>> If you want to control the number of queues allocated in a given
>> configuration you should look at the code over in the ixgbe_lib.c, not
>
>   Yes,  RSS,  RSS with SRIOV, FCoE, DCB etc uses different queues
> calculation algorithm.
>   But they all take the dev queues allocated in alloc_etherdev_mq() as upper
> limit.
>
>  If we set 64 as default here, DCB would says "oh, there is 64 there, I
> could use it"

Right.  But the deciding factor for DCB is RSS which is already
limited by the number of CPUs.  If it is allocating 64 queues it is
because there are either at least 8 CPUs present and 8 TCs being
allocated per CPU, or there are at least 16 queues present and it is
allocating 4 TCs per CPU.

>>
>> ixgbe_main.c.  All you are doing with this patch is denying the user
>> choice with this change as they then are not allowed to set more
>
>   Yes, it is purposed to deny configuration that doesn't benefit.

Doesn't benefit who?  It is obvious you don't understand how DCB is
meant to work since you are assuming the queues are throw-away.
Anyone who makes use of the ability to prioritize their traffic would
likely have a different opinion.

>> queues.  Even if they find your decision was wrong for their
>> configuration.
>>
>> - Alex
>>
>  Thanks,
>  Ethan

Your response clearly points out you don't understand DCB.  I suggest
you take another look at how things are actually being configured.  I
believe what you will find is that the current implementation is
basing things on the number of online CPUs already based on the
ring_feature[RING_F_RSS].limit value.  All that is happening is that
you are getting that value multiplied by the number of TCs and the RSS
value is reduced if the result is greater than 64 based on the maximum
number of queues.

With your code on an 8 core system you go from being able to perform
RSS over 8 queues to only being able to perform RSS over 1 queue when
you enable DCB.  There was a bug a long time ago where this actually
didn't provide any gain because the interrupt allocation was binding
all 8 RSS queues to a single q_vector, but that has long since been
fixed and what you should be seeing is that RSS will spread traffic
across either 8 or 16 queues when DCB is enabled in either 8 or 4 TC
mode.

My advice would be to use a netperf TCP_CRR test and watch what queues
and what interrupts traffic is being delivered to.  Then if you have
DCB enabled on both ends you might try changing the priority of your
netperf session and watch what happens when you switch between TCs.
What you should find is that you will shift between groups of queues
and as you do so you should not have any active queues overlapping
unless you have less interrupts than CPUs.

- Alex
