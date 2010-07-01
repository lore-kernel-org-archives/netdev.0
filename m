From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Thu, 01 Jul 2010 16:27:17 +0200
Message-ID: <4C2CA5C5.4040402@kernel.org>
References: <20100625101022.GA16321@redhat.com> <20100701110708.GA27368@redhat.com> <1277983179.1917.10.camel@laptop> <1277984603.1917.15.camel@laptop> <20100701115507.GA31333@redhat.com> <20100701122340.GB31333@redhat.com> <1277987657.1917.32.camel@laptop> <1277988395.1917.47.camel@laptop> <20100701130816.GB32223@redhat.com> <1277991024.1917.108.camel@laptop> <20100701133956.GD32223@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Oleg Nesterov <oleg@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100701133956.GD32223@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 07/01/2010 03:39 PM, Michael S. Tsirkin wrote:
>> I think that's called kernel_thread() see
>> kernel/kthread.c:create_kthread().
>>
>> Doing the whole kthreadd dance and then copying bits and pieces back
>> sounds very fragile, so yeah, something like that should work.
> 
> Thanks!
> Sridhar, Tejun, have the time to look into this approach?

All that's necessary is shortcutting indirection through kthreadd.
ie. An exported function which looks like the following,

 struct kthread_clone_or_whatever(int (*threadfn).....)
 {
	struct kthread_create_info create;
	int pid;

	INIT create;

	pid = kernel_thread(kthread, &create, CLONE_FS...);
	if (pid < 0)
		return ERROR;
	wait_for_completion(&create.done);

	if (!IS_ERR(create.result))
		SET NAME;
	return create.result;
 }

It might be a good idea to make the function take extra clone flags
but anyways once created cloned task can be treated the same way as
other kthreads, so nothing else needs to be changed.

Thanks.

-- 
tejun
