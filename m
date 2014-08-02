From: Nikolay Aleksandrov <nikolay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 2/3] netlink: Convert
 netlink_lookup() to use RCU protected hash table
Date: Sat, 02 Aug 2014 12:44:14 +0200
Message-ID: <53DCC0FE.5010502@redhat.com>
References: <cover.1406971567.git.tgraf@suug.ch>
 <a0370889bd1b1bdf097f74df7017d39ae845c12e.1406971567.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
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

On 08/02/2014 11:47 AM, Thomas Graf wrote:
> Heavy Netlink users such as Open vSwitch spend a considerable amount of
> time in netlink_lookup() due to the read-lock on nl_table_lock. Use of
> RCU relieves the lock contention.
> 
> Makes use of the new resizable hash table to avoid locking on the
> lookup.
> 
> The hash table will grow if entries exceeds 75% of table size up to a
> total table size of 64K. It will automatically shrink if usage falls
> below 30%.
> 
> Also splits nl_table_lock into a separate mutex to protect hash table
> mutations and allow synchronize_rcu() to sleep while waiting for readers
> during expansion and shrinking.
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
>  net/netlink/af_netlink.c | 285 ++++++++++++++++++-----------------------------
>  net/netlink/af_netlink.h |  18 +--
>  net/netlink/diag.c       |  11 +-
>  3 files changed, 119 insertions(+), 195 deletions(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
