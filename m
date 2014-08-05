From: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 2/3] netlink: Convert
 netlink_lookup() to use RCU protected hash table
Date: Mon, 04 Aug 2014 22:10:19 -0400
Message-ID: <53E03D0B.3000208@oracle.com>
References: <cover.1406971567.git.tgraf@suug.ch>
 <a0370889bd1b1bdf097f74df7017d39ae845c12e.1406971567.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
 nikolay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
 walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <a0370889bd1b1bdf097f74df7017d39ae845c12e.1406971567.git.tgraf-G/eBtMaohhA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 08/02/2014 05:47 AM, Thomas Graf wrote:
>  static void *netlink_seq_start(struct seq_file *seq, loff_t *pos)
> -	__acquires(nl_table_lock)
>  {
> -	read_lock(&nl_table_lock);
> +	rcu_read_lock();
>  	return *pos ? netlink_seq_socket_idx(seq, *pos - 1) : SEQ_START_TOKEN;
>  }

I'm not sure how you expect this code to work. You're replacing a local lock
with a RCU critical section. Imagine you're doing spin_lock() and just going
back to userspace.

It's quite easy to trigger this issue:

[  531.479773] ===============================
[  531.482951] [ INFO: suspicious RCU usage. ]
[  531.485512] 3.16.0-next-20140804-sasha-00029-gcb12d07 #995 Not tainted
[  531.489198] -------------------------------
[  531.491518] net/netlink/af_netlink.c:2953 suspicious rcu_dereference_protected() usage!
[  531.495781]
[  531.495781] other info that might help us debug this:
[  531.495781]
[  531.499094]
[  531.499094] rcu_scheduler_active = 1, debug_locks = 1
[  531.502685] 3 locks held by trinity-c490/9673:
[  531.505179] #0: (&f->f_pos_lock){+.+.+.}, at: __fdget_pos (fs/file.c:714)
[  531.510057] #1: (&p->lock){+.+.+.}, at: seq_lseek (fs/seq_file.c:322)
[  531.514819] #2: (rcu_read_lock){......}, at: netlink_seq_start (net/netlink/af_netlink.c:2923)
[  531.517956]
[  531.517956] stack backtrace:
[  531.519054] CPU: 7 PID: 9673 Comm: cat Not tainted 3.16.0-next-20140804-sasha-00029-gcb12d07 #995
[  531.521526]  0000000000000000 00000000917b9e45 ffff881efe493e20 ffffffffa55825a1
[  531.523616]  ffff881efebeb000 ffff881efe493e50 ffffffffa21d3a75 ffffffffa81ce2c0
[  531.527426]  0000000000000002 ffff8807cb581d90 ffff880fa3da8000 ffff881efe493ea0
[  531.532068] Call Trace:
[  531.533595] dump_stack (lib/dump_stack.c:52)
[  531.536398] lockdep_rcu_suspicious (kernel/locking/lockdep.c:4259)
[  531.537934] netlink_seq_next (net/netlink/af_netlink.c:2953 (discriminator 5))
[  531.539355] traverse (fs/seq_file.c:142)
[  531.541241] ? mutex_lock_nested (./arch/x86/include/asm/preempt.h:98 kernel/locking/mutex.c:567 kernel/locking/mutex.c:584)
[  531.544797] seq_lseek (fs/seq_file.c:331 (discriminator 1))
[  531.547485] proc_reg_llseek (fs/proc/inode.c:197)
[  531.549904] SyS_lseek (fs/read_write.c:264 fs/read_write.c:289 fs/read_write.c:280)
[  531.552190] tracesys (arch/x86/kernel/entry_64.S:541)

I'd suggest testing any RCU related patches with CONFIG_PROVE_RCU in the future.


Thanks,
Sasha
