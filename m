From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [Patch net-next] net_sched: avoid calling tcf_unbind_filter()
 in call_rcu callback
Date: Wed, 01 Oct 2014 13:50:24 -0700
Message-ID: <542C6910.4070904@intel.com>
References: <1412118444-29179-1-git-send-email-xiyou.wangcong@gmail.com> <1412118444-29179-2-git-send-email-xiyou.wangcong@gmail.com> <542B5096.2040106@gmail.com> <542B5679.3060601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11621 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751295AbaJAUus (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2014 16:50:48 -0400
In-Reply-To: <542B5679.3060601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/2014 06:18 PM, John Fastabend wrote:
> On 09/30/2014 05:53 PM, John Fastabend wrote:
>> On 09/30/2014 04:07 PM, Cong Wang wrote:
>>> This fixes the following crash:
>>>
>>> [   63.976822] general protection fault: 0000 [#1] PREEMPT SMP
>>> DEBUG_PAGEALLOC
>>> [   63.980094] CPU: 1 PID: 15 Comm: ksoftirqd/1 Not tainted
>>> 3.17.0-rc6+ #648
>>> [   63.980094] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>>> [   63.980094] task: ffff880117dea690 ti: ffff880117dfc000 task.ti:
>>> ffff880117dfc000
>>> [   63.980094] RIP: 0010:[<ffffffff817e6d07>]  [<ffffffff817e6d07>]
>>> u32_destroy_key+0x27/0x6d
>>> [   63.980094] RSP: 0018:ffff880117dffcc0  EFLAGS: 00010202
>>> [   63.980094] RAX: ffff880117dea690 RBX: ffff8800d02e0820 RCX:
>>> 0000000000000000
>>> [   63.980094] RDX: 0000000000000001 RSI: 0000000000000002 RDI:
>>> 6b6b6b6b6b6b6b6b
>>> [   63.980094] RBP: ffff880117dffcd0 R08: 0000000000000000 R09:
>>> 0000000000000000
>>> [   63.980094] R10: 00006c0900006ba8 R11: 00006ba100006b9d R12:
>>> 0000000000000001
>>> [   63.980094] R13: ffff8800d02e0898 R14: ffffffff817e6d4d R15:
>>> ffff880117387a30
>>> [   63.980094] FS:  0000000000000000(0000) GS:ffff88011a800000(0000)
>>> knlGS:0000000000000000
>>> [   63.980094] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>> [   63.980094] CR2: 00007f07e6732fed CR3: 000000011665b000 CR4:
>>> 00000000000006e0
>>> [   63.980094] Stack:
>>> [   63.980094]  ffff88011a9cd300 ffffffff82051ac0 ffff880117dffce0
>>> ffffffff817e6d68
>>> [   63.980094]  ffff880117dffd70 ffffffff810cb4c7 ffffffff810cb3cd
>>> ffff880117dfffd8
>>> [   63.980094]  ffff880117dea690 ffff880117dea690 ffff880117dfffd8
>>> 000000000000000a
>>> [   63.980094] Call Trace:
>>> [   63.980094]  [<ffffffff817e6d68>] u32_delete_key_freepf_rcu+0x1b/0x1d
>>> [   63.980094]  [<ffffffff810cb4c7>] rcu_process_callbacks+0x3bb/0x691
>>> [   63.980094]  [<ffffffff810cb3cd>] ? rcu_process_callbacks+0x2c1/0x691
>>> [   63.980094]  [<ffffffff817e6d4d>] ? u32_destroy_key+0x6d/0x6d
>>> [   63.980094]  [<ffffffff810780a4>] __do_softirq+0x142/0x323
>>> [   63.980094]  [<ffffffff810782a8>] run_ksoftirqd+0x23/0x53
>>> [   63.980094]  [<ffffffff81092126>] smpboot_thread_fn+0x203/0x221
>>> [   63.980094]  [<ffffffff81091f23>] ? smpboot_unpark_thread+0x33/0x33
>>> [   63.980094]  [<ffffffff8108e44d>] kthread+0xc9/0xd1
>>> [   63.980094]  [<ffffffff819e00ea>] ? do_wait_for_common+0xf8/0x125
>>> [   63.980094]  [<ffffffff8108e384>] ? __kthread_parkme+0x61/0x61
>>> [   63.980094]  [<ffffffff819e43ec>] ret_from_fork+0x7c/0xb0
>>> [   63.980094]  [<ffffffff8108e384>] ? __kthread_parkme+0x61/0x61
>>>
>>> tp could be freed in call_rcu callback too, the order is not guaranteed.
>>>
>>> Cc: John Fastabend <john.r.fastabend@intel.com>
>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>> ---
>>
>> Thanks for catching this. What if we just drop tcf_exts_result
>> I can't see how its being used anymore. It appears to just be passed
>> around the ./net/sched files for some historic reason that is lost on
>> me. Would you mind testing a patch if I sent it out?
>>
>> Maybe Jamal can shed some light?
>>
> 
> Sorry I should say its not needed to pass to the actions,
> tcf_exts_exec(). It _is_ needed here to get the class setup
> correct. And the tcf_exts_exec() stuff is a separate patch.
> 
> Thanks again.
> 
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
> 
> 
>>

Its worth noting why this is safe. Any running schedulers will either
read the valid class field or it will be zeroed.

All schedulers today when the class is 0 do a lookup using the
same call used by the tcf_exts_bind(). So even if we have a running
classifier hit the null class pointer it will do a lookup and get
to the same result. This is particularly fragile at the moment because
the only way to verify this is to audit the schedulers call sites.

I think we need a helper to ensure the code doesn't get broken in
a subtle way in the future. At very least it should be documented.
I'll try to draft a follow up patch to use a helper routine for
this and document it.

Similar patches are needed for basic, fw, route, rsvp, and tcindex.

.John
