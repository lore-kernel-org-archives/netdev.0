From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH net] Panic when tc_lookup_action_n finds a partially
 initialized action.
Date: Tue, 4 Oct 2016 23:52:44 -0700
Message-ID: <20161005065244.GA2245@templeofstupid.com>
References: <20161002031349.GB2635@templeofstupid.com>
 <CAM_iQpX1a1=3PmMAwMRDXpL3qjAskQ990FdxgyCg4T5p4=8G7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krister Johansen <kjlx@templeofstupid.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:57239 "EHLO
        homiemail-a44.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753296AbcJEGwr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 02:52:47 -0400
Received: from homiemail-a44.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a44.g.dreamhost.com (Postfix) with ESMTP id 4A0F2600260F
        for <netdev@vger.kernel.org>; Tue,  4 Oct 2016 23:52:46 -0700 (PDT)
Received: from kmjvbox (c-73-202-117-160.hsd1.ca.comcast.net [73.202.117.160])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a44.g.dreamhost.com (Postfix) with ESMTPSA id DB870600260B
        for <netdev@vger.kernel.org>; Tue,  4 Oct 2016 23:52:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpX1a1=3PmMAwMRDXpL3qjAskQ990FdxgyCg4T5p4=8G7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 03, 2016 at 11:22:33AM -0700, Cong Wang wrote:
> Please try the attached patch. I also convert the read path to RCU
> to avoid a possible deadlock. A quick test shows no lockdep splat.

I tried this patch, but it doesn't solve the problem.  I got a panic on
my very first try:

  SYSTEM MAP: /boot/System.map-4.7.5-1.el7.x86_64
DEBUG KERNEL: /usr/lib/debug/lib/modules/4.7.5-1.el7.x86_64/vmlinux (4.7.5-1.el7.x86_64)
    DUMPFILE: ./vmcore  [PARTIAL DUMP]
        CPUS: 4
        DATE: Tue Oct  4 22:43:45 2016
      UPTIME: 00:02:32
LOAD AVERAGE: 0.20, 0.14, 0.06
       TASKS: 1637
     RELEASE: 4.7.5-1.el7.x86_64
     VERSION: #1 SMP Tue Oct 4 21:58:08 PDT 2016
     MACHINE: x86_64  (3392 Mhz)
      MEMORY: 4 GB
       PANIC: "BUG: unable to handle kernel NULL pointer dereference at           (null)"
         PID: 20151
     COMMAND: "test"
        TASK: ffff880138f89480  [THREAD_INFO: ffff88009f450000]
         CPU: 2
       STATE: TASK_RUNNING (PANIC)

PID: 20151  TASK: ffff880138f89480  CPU: 2   COMMAND: "test"
 #0 [ffff88009f453368] machine_kexec at ffffffff8105c2db
 #1 [ffff88009f4533c8] __crash_kexec at ffffffff81111ca2
 #2 [ffff88009f453498] crash_kexec at ffffffff81111d9c
 #3 [ffff88009f4534b8] oops_end at ffffffff810309d1
 #4 [ffff88009f4534e0] no_context at ffffffff8106a5de
 #5 [ffff88009f453540] __bad_area_nosemaphore at ffffffff8106a92e
 #6 [ffff88009f453590] bad_area at ffffffff81081b45
 #7 [ffff88009f4535b8] __do_page_fault at ffffffff8106b42d
 #8 [ffff88009f453620] trace_do_page_fault at ffffffff8106b5a3
 #9 [ffff88009f453658] do_async_page_fault at ffffffff81063dda
#10 [ffff88009f453670] async_page_fault at ffffffff81735af8
    [exception RIP: tcf_hash_check+18]
    RIP: ffffffff81649772  RSP: ffff88009f453720  RFLAGS: 00010246
    RAX: 0000000000000000  RBX: 0000000000000001  RCX: 0000000000000001
    RDX: ffff8801297ee440  RSI: 0000000000000000  RDI: 0000000000000000
    RBP: ffff88009f453738   R8: ffffffffa04020f0   R9: ffff88009f453770
    R10: ffffffff8164a6a1  R11: ffff880129621f00  R12: ffff8801297ee440
    R13: ffff8800ba0f9940  R14: ffff880093cd3e6c  R15: 0000000000000000
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
#11 [ffff88009f453740] tcf_mirred_init at ffffffffa04011cc [act_mirred]
#12 [ffff88009f4537c8] tcf_action_init_1 at ffffffff8164a7c9
#13 [ffff88009f453868] tcf_action_init at ffffffff8164a881
#14 [ffff88009f4539c0] tcf_exts_validate at ffffffff8164868a
#15 [ffff88009f4539e8] u32_set_parms at ffffffffa04153f2 [cls_u32]
#16 [ffff88009f453a60] u32_change at ffffffffa0416bc4 [cls_u32]
#17 [ffff88009f453b50] tc_ctl_tfilter at ffffffff8164900d
#18 [ffff88009f453c48] rtnetlink_rcv_msg at ffffffff8162b8f4
#19 [ffff88009f453cc0] netlink_rcv_skb at ffffffff81650b77
#20 [ffff88009f453ce8] rtnetlink_rcv at ffffffff8162b848
#21 [ffff88009f453d00] netlink_unicast at ffffffff81650531
#22 [ffff88009f453d48] netlink_sendmsg at ffffffff8165091e
#23 [ffff88009f453dc8] sock_sendmsg at ffffffff815fcae8
#24 [ffff88009f453de8] SYSC_sendto at ffffffff815fcfa2
#25 [ffff88009f453f18] sys_sendto at ffffffff815fdb4e
#26 [ffff88009f453f28] do_syscall_64 at ffffffff81003b12
    RIP: 00000000004cbfba  RSP: 000000c8200a4eb8  RFLAGS: 00000212
    RAX: ffffffffffffffda  RBX: 000000c820000180  RCX: 00000000004cbfba
    RDX: 000000000000008c  RSI: 000000c82007a900  RDI: 0000000000000007
    RBP: 0000000000000000   R8: 000000c8200fd844   R9: 000000000000000c
    R10: 0000000000000000  R11: 0000000000000212  R12: 000000c82007a900
    R13: 0000000000000003  R14: 0012492492492492  R15: 0000000000000039
    ORIG_RAX: 000000000000002c  CS: 0033  SS: 002b

The problem here is the same as before: by using RCU the race isn't
fixed because the module is still discoverable from act_base before the
pernet initialization is completed.

You can see from the trap frame that the first two arguments to
tcf_hash_check were 0.  It couldn't look up the correct per-subsystem
pointer because the id hadn't yet been registered.

> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index d09d068..4aac846 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
>  int tcf_register_action(struct tc_action_ops *act,
>  			struct pernet_operations *ops)
> @@ -341,22 +356,23 @@ int tcf_register_action(struct tc_action_ops *act,
>  	if (!act->act || !act->dump || !act->init || !act->walk || !act->lookup)
>  		return -EINVAL;
>  
> -	write_lock(&act_mod_lock);
> +	mutex_lock(&act_mod_lock);
>  	list_for_each_entry(a, &act_base, head) {
>  		if (act->type == a->type || (strcmp(act->kind, a->kind) == 0)) {
> -			write_unlock(&act_mod_lock);
> +			mutex_unlock(&act_mod_lock);
>  			return -EEXIST;
>  		}
>  	}
> -	list_add_tail(&act->head, &act_base);
> -	write_unlock(&act_mod_lock);
> +	list_add_tail_rcu(&act->head, &act_base);
>  
>  	ret = register_pernet_subsys(ops);
>  	if (ret) {
> -		tcf_unregister_action(act, ops);
> +		__tcf_unregister_action(act);
> +		mutex_unlock(&act_mod_lock);
>  		return ret;
>  	}
>  
> +	mutex_unlock(&act_mod_lock);
>  	return 0;
>  }

If lookups use rcu, then the list_add_tail_rcu() has to come after
register_pernet_subsys() returns success.

>  EXPORT_SYMBOL(tcf_register_action);
> @@ -364,20 +380,13 @@ EXPORT_SYMBOL(tcf_register_action);
>  int tcf_unregister_action(struct tc_action_ops *act,
>  			  struct pernet_operations *ops)
>  {
> -	struct tc_action_ops *a;
>  	int err = -ENOENT;
>  
> +	mutex_lock(&act_mod_lock);
>  	unregister_pernet_subsys(ops);
> +	err = __tcf_unregister_action(act);
> +	mutex_unlock(&act_mod_lock);
>  
> -	write_lock(&act_mod_lock);
> -	list_for_each_entry(a, &act_base, head) {
> -		if (a == act) {
> -			list_del(&act->head);
> -			err = 0;
> -			break;
> -		}
> -	}
> -	write_unlock(&act_mod_lock);
>  	return err;
>  }

Similarly, unregistering the pernet_subsystem before ensuring that the
action has been removed from act_base leads to another version of this
race on module unload.  Presumably you need to wait for the rcu grace
period to elapse upon removal before it's actually safe to unregister
the subsystem, since any callers with references to the action will have
the potential for a similar NULL deference if their per-net id suddenly
expires.

>  EXPORT_SYMBOL(tcf_unregister_action);
> @@ -388,15 +397,15 @@ static struct tc_action_ops *tc_lookup_action_n(char *kind)
>  	struct tc_action_ops *a, *res = NULL;
>  
>  	if (kind) {
> -		read_lock(&act_mod_lock);
> -		list_for_each_entry(a, &act_base, head) {
> +		rcu_read_lock();
> +		list_for_each_entry_rcu(a, &act_base, head) {
>  			if (strcmp(kind, a->kind) == 0) {
>  				if (try_module_get(a->owner))
>  					res = a;
>  				break;
>  			}
>  		}
> -		read_unlock(&act_mod_lock);
> +		rcu_read_unlock();
>  	}
>  	return res;
>  }
> @@ -407,15 +416,15 @@ static struct tc_action_ops *tc_lookup_action(struct nlattr *kind)
>  	struct tc_action_ops *a, *res = NULL;
>  
>  	if (kind) {
> -		read_lock(&act_mod_lock);
> -		list_for_each_entry(a, &act_base, head) {
> +		rcu_read_lock();
> +		list_for_each_entry_rcu(a, &act_base, head) {
>  			if (nla_strcmp(kind, a->kind) == 0) {
>  				if (try_module_get(a->owner))
>  					res = a;
>  				break;
>  			}
>  		}
> -		read_unlock(&act_mod_lock);
> +		rcu_read_unlock();
>  	}
>  	return res;
>  }

Given the fact that RCU tolerates inherent races, but another trip
around the modprobe loop blocks the caller, and forks an unnecessary
process, it's not clear to me that converting this to RCU makes it
simpler, or is the right tool for this particular job.

After testing it, I'm not convinced that this is any less complicated
than the approach that I proposed.

Thanks,

-K
