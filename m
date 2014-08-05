From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 2/3] netlink: Convert
 netlink_lookup() to use RCU protected hash table
Date: Mon, 04 Aug 2014 19:58:41 -0700 (PDT)
Message-ID: <20140804.195841.536725238366145203.davem@davemloft.net>
References: <cover.1406971567.git.tgraf@suug.ch>
 <a0370889bd1b1bdf097f74df7017d39ae845c12e.1406971567.git.tgraf@suug.ch>
 <53E03D0B.3000208@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, nikolay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <53E03D0B.3000208-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
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

From: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date: Mon, 04 Aug 2014 22:10:19 -0400

> On 08/02/2014 05:47 AM, Thomas Graf wrote:
>>  static void *netlink_seq_start(struct seq_file *seq, loff_t *pos)
>> -	__acquires(nl_table_lock)
>>  {
>> -	read_lock(&nl_table_lock);
>> +	rcu_read_lock();
>>  	return *pos ? netlink_seq_socket_idx(seq, *pos - 1) : SEQ_START_TOKEN;
>>  }
> 
> I'm not sure how you expect this code to work. You're replacing a local lock
> with a RCU critical section. Imagine you're doing spin_lock() and just going
> back to userspace.
> 
> It's quite easy to trigger this issue:

I think he expected the end of the seq sequence to drop the RCU lock,
via netlink_seq_stop().
