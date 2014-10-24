From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Fri, 24 Oct 2014 15:41:31 -0700
Message-ID: <8988.1414190491@famine>
References: <20141024154006.GP4977@linux.vnet.ibm.com> <20141024162943.GA16621@declera.com> <20141024165454.GS4977@linux.vnet.ibm.com> <20141024170931.GA21849@declera.com> <20141024172009.GV4977@linux.vnet.ibm.com> <20141024173526.GA26058@declera.com> <20141024183226.GW4977@linux.vnet.ibm.com> <20141024212557.GA15537@declera.com> <20141024214927.GA4977@linux.vnet.ibm.com> <8451.1414188124@famine> <20141024221602.GB4977@linux.vnet.ibm.com>
Cc: Yanko Kaneti <yaneti@declera.com>,
	Josh Boyer <jwboyer@fedoraproject.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Kevin Fenzi <kevin@scrye.com>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	mroos@linux.ee, tj@kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:36006 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754757AbaJXWln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 18:41:43 -0400
In-reply-to: <20141024221602.GB4977@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

>On Fri, Oct 24, 2014 at 03:02:04PM -0700, Jay Vosburgh wrote:
>> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
>> 
[...]
>> 	I've got an ftrace capture from unmodified -net, it looks like
>> this:
>> 
>>     ovs-vswitchd-902   [000] ....   471.778441: rcu_barrier: rcu_sched Begin cpu -1 remaining 0 # 0
>>     ovs-vswitchd-902   [000] ....   471.778452: rcu_barrier: rcu_sched Check cpu -1 remaining 0 # 0
>>     ovs-vswitchd-902   [000] ....   471.778452: rcu_barrier: rcu_sched Inc1 cpu -1 remaining 0 # 1
>>     ovs-vswitchd-902   [000] ....   471.778453: rcu_barrier: rcu_sched OnlineNoCB cpu 0 remaining 1 # 1
>>     ovs-vswitchd-902   [000] ....   471.778453: rcu_barrier: rcu_sched OnlineNoCB cpu 1 remaining 2 # 1
>>     ovs-vswitchd-902   [000] ....   471.778453: rcu_barrier: rcu_sched OnlineNoCB cpu 2 remaining 3 # 1
>>     ovs-vswitchd-902   [000] ....   471.778454: rcu_barrier: rcu_sched OnlineNoCB cpu 3 remaining 4 # 1
>
>OK, so it looks like your system has four CPUs, and rcu_barrier() placed
>callbacks on them all.

	No, the system has only two CPUs.  It's an Intel Core 2 Duo
E8400, and /proc/cpuinfo agrees that there are only 2.  There is a
potentially relevant-sounding message early in dmesg that says:

[    0.000000] smpboot: Allowing 4 CPUs, 2 hotplug CPUs

>>     ovs-vswitchd-902   [000] ....   471.778454: rcu_barrier: rcu_sched Inc2 cpu -1 remaining 4 # 2
>
>The above removes the extra count used to avoid races between posting new
>callbacks and completion of previously posted callbacks.
>
>>          rcuos/0-9     [000] ..s.   471.793150: rcu_barrier: rcu_sched CB cpu -1 remaining 3 # 2
>>          rcuos/1-18    [001] ..s.   471.793308: rcu_barrier: rcu_sched CB cpu -1 remaining 2 # 2
>
>Two of the four callbacks fired, but the other two appear to be AWOL.
>And rcu_barrier() won't return until they all fire.
>
>> 	I let it sit through several "hung task" cycles but that was all
>> there was for rcu:rcu_barrier.
>> 
>> 	I should have ftrace with the patch as soon as the kernel is
>> done building, then I can try the below patch (I'll start it building
>> now).
>
>Sounds very good, looking forward to hearing of the results.

	Going to bounce it for ftrace now, but the cpu count mismatch
seemed important enough to mention separately.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
