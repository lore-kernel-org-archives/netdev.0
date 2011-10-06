From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH] SELinux: Fix RCU deref check warning in sel_netport_insert() [ver #3]
Date: Thu, 06 Oct 2011 18:52:01 -0400
Message-ID: <1882445.sqVsvZfAlf@sifl>
References: <20111005111919.30551.77529.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41027 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755411Ab1JFWwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 18:52:08 -0400
Received: by wwf22 with SMTP id 22so4995297wwf.1
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2011 15:52:07 -0700 (PDT)
In-Reply-To: <20111005111919.30551.77529.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, October 05, 2011 12:19:19 PM David Howells wrote:
> Fix the following bug in sel_netport_insert() where rcu_dereference() should
> be rcu_dereference_protected() as sel_netport_lock is held.
> 
> ===================================================
> [ INFO: suspicious rcu_dereference_check() usage. ]
> ---------------------------------------------------
> security/selinux/netport.c:127 invoked rcu_dereference_check() without
> protection!
> 
> other info that might help us debug this:
> 
> 
> rcu_scheduler_active = 1, debug_locks = 0
> 1 lock held by ossec-rootcheck/3323:
>  #0:  (sel_netport_lock){+.....}, at: [<ffffffff8117d775>]
> sel_netport_sid+0xbb/0x226
> 
> stack backtrace:
> Pid: 3323, comm: ossec-rootcheck Not tainted 3.1.0-rc8-fsdevel+ #1095
> Call Trace:
>  [<ffffffff8105cfb7>] lockdep_rcu_dereference+0xa7/0xb0
>  [<ffffffff8117d871>] sel_netport_sid+0x1b7/0x226
>  [<ffffffff8117d6ba>] ? sel_netport_avc_callback+0xbc/0xbc
>  [<ffffffff8117556c>] selinux_socket_bind+0x115/0x230
>  [<ffffffff810a5388>] ? might_fault+0x4e/0x9e
>  [<ffffffff810a53d1>] ? might_fault+0x97/0x9e
>  [<ffffffff81171cf4>] security_socket_bind+0x11/0x13
>  [<ffffffff812ba967>] sys_bind+0x56/0x95
>  [<ffffffff81380dac>] ? sysret_check+0x27/0x62
>  [<ffffffff8105b767>] ? trace_hardirqs_on_caller+0x11e/0x155
>  [<ffffffff81076fcd>] ? audit_syscall_entry+0x17b/0x1ae
>  [<ffffffff811b5eae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>  [<ffffffff81380d7b>] system_call_fastpath+0x16/0x1b
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  security/selinux/netport.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)

Acked-by: Paul Moore <paul@paul-moore.com>

> diff --git a/security/selinux/netport.c b/security/selinux/netport.c
> index 0b62bd1..7b9eb1f 100644
> --- a/security/selinux/netport.c
> +++ b/security/selinux/netport.c
> @@ -123,7 +123,9 @@ static void sel_netport_insert(struct sel_netport *port)
> if (sel_netport_hash[idx].size == SEL_NETPORT_HASH_BKT_LIMIT) {
>  		struct sel_netport *tail;
>  		tail = list_entry(
> -			rcu_dereference(sel_netport_hash[idx].list.prev),
> +			rcu_dereference_protected(
> +				sel_netport_hash[idx].list.prev,
> +				lockdep_is_held(&sel_netport_lock)),
>  			struct sel_netport, list);
>  		list_del_rcu(&tail->list);
>  		kfree_rcu(tail, rcu);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
paul moore
www.paul-moore.com
