From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH net-next] packet: Protect packet sk list with mutex
Date: Mon, 20 Aug 2012 22:10:18 +0400
Message-ID: <50327D8A.5010400@parallels.com>
References: <50324EBC.9060804@parallels.com> <1345475500.5158.321.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:16542 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751296Ab2HTSK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 14:10:29 -0400
In-Reply-To: <1345475500.5158.321.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/20/2012 07:11 PM, Eric Dumazet wrote:
> On Mon, 2012-08-20 at 18:50 +0400, Pavel Emelyanov wrote:
>> In patch eea68e2f (packet: Report socket mclist info via diag module) I've
>> introduced a "scheduling in atomic" problem in packet diag module -- the
>> socket list is traversed under rcu_read_lock() while performed under it sk
>> mclist access requires rtnl lock (i.e. -- mutex) to be taken. Similar thing
>> was then re-introduced by further packet diag patches (fanount mutex and 
>> pgvec mutex for rings) :(
>>
>> Apart from being terribly sorry for the above, I propose to change the
>> packet sk list protection from spinlock to mutex. This lock currently 
>> protects only the sklist modifications (that already happen in sleeping 
>> context) and nothing more.
>>
>> Am I wrong again and a fine-grained atomic locking is required for
>> everything that is reported by packet diag instead?
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>>
>> ---
>>
>> diff --git a/include/net/netns/packet.h b/include/net/netns/packet.h
>> index cb4e894..4780b08 100644
>> --- a/include/net/netns/packet.h
>> +++ b/include/net/netns/packet.h
>> @@ -8,7 +8,7 @@
>>  #include <linux/spinlock.h>
>>  
>>  struct netns_packet {
>> -	spinlock_t		sklist_lock;
>> +	struct mutex		sklist_lock;
>>  	struct hlist_head	sklist;
>>  };
>>  
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index 226b2cd..5048672 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -2308,10 +2308,10 @@ static int packet_release(struct socket *sock)
>>  	net = sock_net(sk);
>>  	po = pkt_sk(sk);
>>  
>> -	spin_lock_bh(&net->packet.sklist_lock);
>> +	mutex_lock(&net->packet.sklist_lock);
>>  	sk_del_node_init_rcu(sk);
>>  	sock_prot_inuse_add(net, sk->sk_prot, -1);
> 
> Last time I checked, sock_prot_inuse_add() needed BH protection.

AFAIU now this is the case for e.g. TCP sockets since they can be created in 
rx code. For packet I've found no places where these stats can be modified other
than those two in af_packet.c

> ( This could be relaxed somehow on x86 thanks to this_cpu_add() ... but
> thats another point)
> 
> Could you please report the full stack trace ?

Sure:

[152363.820563] BUG: scheduling while atomic: crtools/12517/0x10000002
[152363.820573] 4 locks held by crtools/12517:
[152363.820581]  #0:  (sock_diag_mutex){+.+.+.}, at: [<ffffffff81a2dcb5>] sock_diag_rcv+0x1f/0x3e
[152363.820613]  #1:  (sock_diag_table_mutex){+.+.+.}, at: [<ffffffff81a2de70>] sock_diag_rcv_msg+0xdb/0x11a
[152363.820644]  #2:  (nlk->cb_mutex){+.+.+.}, at: [<ffffffff81a67d01>] netlink_dump+0x23/0x1ab
[152363.820693]  #3:  (rcu_read_lock){.+.+..}, at: [<ffffffff81b6a049>] packet_diag_dump+0x0/0x1af
[152363.820724] Modules linked in:
[152363.820737] Pid: 12517, comm: crtools Tainted: G        W 3.6.0-rc1-46175-g07cbd24-dirty #236
[152363.820750] Call Trace:
[152363.820761]  [<ffffffff810959c2>] __schedule_bug+0x6a/0x78
[152363.820772]  [<ffffffff81c26cb9>] __schedule+0xb1/0x5b1
[152363.820784]  [<ffffffff81098af0>] __cond_resched+0x2a/0x35
[152363.820795]  [<ffffffff81c27234>] _cond_resched+0x2c/0x37
[152363.820806]  [<ffffffff81c26210>] mutex_lock_nested+0x2a/0x45
[152363.820818]  [<ffffffff81a2b81c>] rtnl_lock+0x17/0x19
[152363.820829]  [<ffffffff81b69de0>] pdiag_put_mclist+0x4e/0xeb
[152363.820840]  [<ffffffff81b6a001>] sk_diag_fill.clone.0+0x14c/0x194
[152363.820851]  [<ffffffff81c28545>] ? _raw_read_unlock_bh+0x43/0x47
[152363.820863]  [<ffffffff81b6a147>] packet_diag_dump+0xfe/0x1af
[152363.820874]  [<ffffffff81b6a049>] ? sk_diag_fill.clone.0+0x194/0x194
[152363.820885]  [<ffffffff81a67d4b>] netlink_dump+0x6d/0x1ab
[152363.820896]  [<ffffffff81a6847f>] netlink_dump_start+0xed/0x114
[152363.820907]  [<ffffffff81b69d89>] packet_diag_handler_dump+0x61/0x6a
[152363.820918]  [<ffffffff81b6a049>] ? sk_diag_fill.clone.0+0x194/0x194
[152363.820930]  [<ffffffff81a2de8b>] sock_diag_rcv_msg+0xf6/0x11a
[152363.820941]  [<ffffffff81a2dd95>] ? sock_diag_register_inet_compat+0x36/0x36
[152363.820953]  [<ffffffff81a690a0>] netlink_rcv_skb+0x43/0x94
[152363.820979]  [<ffffffff81a2dcc4>] sock_diag_rcv+0x2e/0x3e
[152363.820990]  [<ffffffff81a68e4f>] netlink_unicast+0xe9/0x16f
[152363.821002]  [<ffffffff81a69601>] netlink_sendmsg+0x1e6/0x204
[152363.821129]  [<ffffffff81a0ba29>] ? rcu_read_unlock+0x56/0x67
[152363.821143]  [<ffffffff81a06877>] __sock_sendmsg_nosec+0x58/0x61
[152363.821155]  [<ffffffff81a072b6>] sock_sendmsg+0x6e/0x87
[152363.821168]  [<ffffffff8113a172>] ? might_fault+0xa5/0xac
[152363.821180]  [<ffffffff81a138ae>] ? copy_from_user+0x2a/0x2c
[152363.821192]  [<ffffffff81a13c9e>] ? verify_iovec+0x54/0xaa
[152363.821204]  [<ffffffff81a08092>] __sys_sendmsg+0x211/0x2a7
[152363.821216]  [<ffffffff810b7515>] ? lock_release_holdtime+0x2c/0xf5
[152363.821228]  [<ffffffff810bba71>] ? __lock_release+0x113/0x12c
[152363.821243]  [<ffffffff81c28937>] ? _raw_spin_unlock_irq+0x30/0x4a
[152363.821257]  [<ffffffff810bafa6>] ? trace_hardirqs_on_caller+0x123/0x15a
[152363.821272]  [<ffffffff810bafea>] ? trace_hardirqs_on+0xd/0xf
[152363.821286]  [<ffffffff8116dc31>] ? fcheck_files+0xac/0xea
[152363.821297]  [<ffffffff8116ddaa>] ? fget_light+0x3a/0xb9
[152363.821309]  [<ffffffff81c27183>] ? __schedule+0x57b/0x5b1
[152363.821320]  [<ffffffff81a082ed>] sys_sendmsg+0x42/0x60
[152363.821332]  [<ffffffff81c295e9>] system_call_fastpath+0x16/0x1b


> 
> 

Thank,
Pavel
