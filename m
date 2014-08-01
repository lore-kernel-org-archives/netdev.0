From: Nikolay Aleksandrov <nikolay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 2/3] netlink: Convert
 netlink_lookup() to use RCU protected hash table
Date: Fri, 01 Aug 2014 16:51:34 +0200
Message-ID: <53DBA976.8030103@redhat.com>
References: <cover.1406891028.git.tgraf@suug.ch>
 <72a64dfee4f20f2ca596df26f3e4ae543cf4c068.1406891028.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org,
 paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <72a64dfee4f20f2ca596df26f3e4ae543cf4c068.1406891028.git.tgraf-G/eBtMaohhA@public.gmane.org>
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

On 08/01/2014 01:58 PM, Thomas Graf wrote:
> Heavy Netlink users such as Open vSwitch spend a considerable amount of
> time in netlink_lookup() due to the read-lock on nl_table_lock. Use of
> RCU relieves the lock contention.
> 
> Makes use of the new resizable hash table to avoid locking on the
> lookup.
> 
> The hash table will grow if entries exceeds 75% of table size up to a
> total table size of 64K. It will automatically shrink if usage falls
> below 50%.
> 
> Also splits nl_table_lock into a separate spinlock to protect hash table
> mutations. This avoids a possible deadlock when the hash table growing
> waits on RCU readers to complete via synchronize_rcu() while readers
> holding RCU read lock are waiting on the nl_table_lock() to be released
> to lock the table for broadcasting.
> 
> Before:
>    9.16%  kpktgend_0  [openvswitch]      [k] masked_flow_lookup
>    6.42%  kpktgend_0  [pktgen]           [k] mod_cur_headers
>    6.26%  kpktgend_0  [pktgen]           [k] pktgen_thread_worker
>    6.23%  kpktgend_0  [kernel.kallsyms]  [k] memset
>    4.79%  kpktgend_0  [kernel.kallsyms]  [k] netlink_lookup
>    4.37%  kpktgend_0  [kernel.kallsyms]  [k] memcpy
>    3.60%  kpktgend_0  [openvswitch]      [k] ovs_flow_extract
>    2.69%  kpktgend_0  [kernel.kallsyms]  [k] jhash2
> 
> After:
>   15.26%  kpktgend_0  [openvswitch]      [k] masked_flow_lookup
>    8.12%  kpktgend_0  [pktgen]           [k] pktgen_thread_worker
>    7.92%  kpktgend_0  [pktgen]           [k] mod_cur_headers
>    5.11%  kpktgend_0  [kernel.kallsyms]  [k] memset
>    4.11%  kpktgend_0  [openvswitch]      [k] ovs_flow_extract
>    4.06%  kpktgend_0  [kernel.kallsyms]  [k] _raw_spin_lock
>    3.90%  kpktgend_0  [kernel.kallsyms]  [k] jhash2
>    [...]
>    0.67%  kpktgend_0  [kernel.kallsyms]  [k] netlink_lookup
> 
> Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> ---

Hmm, in both the rhashtable_insert() and rhashtable_remove() calls in the
netlink code you're using GFP_ATOMIC flags but if rhashtable_expand/shring gets
called even though the allocation will be with GFP_ATOMIC, they still call
synchronize_rcu() which may block. Now I'm not familiar with the netlink code,
but I think that in general the flags are useless for GFP_ATOMIC because of the
calls to synchronize_rcu() in expand/shrink which can block anyway.
Just a thought, I may be missing something of course.

Nik
