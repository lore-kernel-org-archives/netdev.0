From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: Protect packet sk list with mutex (v2)
Date: Wed, 22 Aug 2012 22:59:45 -0700 (PDT)
Message-ID: <20120822.225945.1565825916747725428.davem@davemloft.net>
References: <50336BC7.7030209@parallels.com>
	<1345618757.5158.612.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33471 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507Ab2HWF7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 01:59:46 -0400
In-Reply-To: <1345618757.5158.612.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 Aug 2012 08:59:17 +0200

> On Tue, 2012-08-21 at 15:06 +0400, Pavel Emelyanov wrote:
>> Change since v1:
>> 
>> * Fixed inuse counters access spotted by Eric
>> 
>> In patch eea68e2f (packet: Report socket mclist info via diag module) I've
>> introduced a "scheduling in atomic" problem in packet diag module -- the
>> socket list is traversed under rcu_read_lock() while performed under it sk
>> mclist access requires rtnl lock (i.e. -- mutex) to be taken.
>> 
>> [152363.820563] BUG: scheduling while atomic: crtools/12517/0x10000002
>> [152363.820573] 4 locks held by crtools/12517:
>> [152363.820581]  #0:  (sock_diag_mutex){+.+.+.}, at: [<ffffffff81a2dcb5>] sock_diag_rcv+0x1f/0x3e
>> [152363.820613]  #1:  (sock_diag_table_mutex){+.+.+.}, at: [<ffffffff81a2de70>] sock_diag_rcv_msg+0xdb/0x11a
>> [152363.820644]  #2:  (nlk->cb_mutex){+.+.+.}, at: [<ffffffff81a67d01>] netlink_dump+0x23/0x1ab
>> [152363.820693]  #3:  (rcu_read_lock){.+.+..}, at: [<ffffffff81b6a049>] packet_diag_dump+0x0/0x1af
>> 
>> Similar thing was then re-introduced by further packet diag patches (fanount 
>> mutex and pgvec mutex for rings) :(
>> 
>> Apart from being terribly sorry for the above, I propose to change the packet
>> sk list protection from spinlock to mutex. This lock currently protects two
>> modifications:
>> 
>> * sklist
>> * prot inuse counters
>> 
>> The sklist modifications can be just reprotected with mutex since they already
>> occur in a sleeping context. The inuse counters modifications are trickier -- the
>> __this_cpu_-s are used inside, thus requiring the caller to handle the potential
>> issues with contexts himself. Since packet sockets' counters are modified in two 
>> places only (packet_create and packet_release) we only need to protect the context 
>> from being preempted. BH disabling is not required in this case.
>> 
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
