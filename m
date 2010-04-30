From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.34-rc5-git7 (plus all patches) -- another suspicious
 rcu_dereference_check() usage.
Date: Fri, 30 Apr 2010 15:48:39 -0700
Message-ID: <20100430224839.GA15238@linux.vnet.ibm.com>
References: <h2ya44ae5cd1004261751waa5cb65ei3d139cbcfa2cc5cf@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivek Goyal <vgoyal@redhat.com>, Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <h2ya44ae5cd1004261751waa5cb65ei3d139cbcfa2cc5cf@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 26, 2010 at 08:51:06PM -0400, Miles Lane wrote:
> This one occurred during the wakeup from suspend to RAM.
> 
> [  984.724697] [ INFO: suspicious rcu_dereference_check() usage. ]
> [  984.724700] ---------------------------------------------------
> [  984.724703] include/linux/fdtable.h:88 invoked
> rcu_dereference_check() without protection!
> [  984.724706]
> [  984.724707] other info that might help us debug this:
> [  984.724708]
> [  984.724711]
> [  984.724711] rcu_scheduler_active = 1, debug_locks = 1
> [  984.724714] no locks held by dbus-daemon/4680.
> [  984.724717]
> [  984.724717] stack backtrace:
> [  984.724721] Pid: 4680, comm: dbus-daemon Not tainted 2.6.34-rc5-git7 #33
> [  984.724724] Call Trace:
> [  984.724734]  [<ffffffff81074556>] lockdep_rcu_dereference+0x9d/0xa6
> [  984.724740]  [<ffffffff810fc785>] fcheck_files+0xb1/0xc9
> [  984.724745]  [<ffffffff810fc7f5>] fget_light+0x35/0xab
> [  984.724751]  [<ffffffff81433e1b>] ? sock_poll_wait+0x13/0x18
> [  984.724755]  [<ffffffff81433e39>] ? unix_poll+0x19/0x95
> [  984.724762]  [<ffffffff8110aa95>] do_sys_poll+0x1ff/0x3e5
> [  984.724766]  [<ffffffff8110a19e>] ? __pollwait+0x0/0xc7
> [  984.724771]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> [  984.724776]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> [  984.724780]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> [  984.724784]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> [  984.724788]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> [  984.724793]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> [  984.724797]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> [  984.724802]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> [  984.724806]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> [  984.724812]  [<ffffffff8110ae0f>] sys_poll+0x50/0xbb
> [  984.724818]  [<ffffffff81009d82>] system_call_fastpath+0x16/0x1b

And here, at long last, is the relevant patch.

							Thanx, Paul

------------------------------------------------------------------------

commit dced7789910f0b1b4e9b94fe74d79f2c2f788399
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Fri Apr 30 15:24:24 2010 -0700

    vfs: fix RCU-lockdep false positive due to /proc access
    
    If a single-threaded process does a file-descriptor operation, and
    some other process accesses that same file descriptor via /proc,
    the current rcu_dereference_check_fdtable() can give a false-positive
    RCU-lockdep splat due to the reference count being increased by the
    /proc access after the reference-count check in fget_light() but before
    the check in rcu_dereference_check_fdtable().
    
    This commit prevents this false positive by checking for a single-threaded
    process.
    
    Located-by: Miles Lane <miles.lane@gmail.com>
    Located-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/include/linux/fdtable.h b/include/linux/fdtable.h
index 013dc52..e4a6d31 100644
--- a/include/linux/fdtable.h
+++ b/include/linux/fdtable.h
@@ -61,7 +61,8 @@ struct files_struct {
 	(rcu_dereference_check((fdtfd), \
 			       rcu_read_lock_held() || \
 			       lockdep_is_held(&(files)->file_lock) || \
-			       atomic_read(&(files)->count) == 1))
+			       atomic_read(&(files)->count) == 1 || \
+			       thread_group_empty(current)))
 
 #define files_fdtable(files) \
 		(rcu_dereference_check_fdtable((files), (files)->fdt))
