From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] pkt_sched: namespace aware ifb
Date: Sat, 12 Jan 2013 21:49:59 -0800
Message-ID: <1358056199.20249.2121.camel@edumazet-glaptop>
References: <50F1699E.1000200@hartkopp.net>
	 <20130112.132316.2121287993605534669.davem@davemloft.net>
	 <20130112.133630.257139657732337147.davem@davemloft.net>
	 <1358046374.20249.1789.camel@edumazet-glaptop>
	 <20130113035013.GJ5259@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:46378 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151Ab3AMFuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 00:50:03 -0500
Received: by mail-da0-f41.google.com with SMTP id e20so1354824dak.0
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2013 21:50:02 -0800 (PST)
In-Reply-To: <20130113035013.GJ5259@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-01-12 at 22:50 -0500, Benjamin LaHaise wrote:
> On Sat, Jan 12, 2013 at 07:06:14PM -0800, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > act_mirred needs to find the current net_ns, and struct net
> > pointer is not provided in the call chain. We run in process
> > context and current->nsproxy->net_ns is the needed pointer.
> ...
> 
> I don't think this is correct.  Going by the call chain, tcf_action_add can 
> be called because of a netlink message, and that netlink message may not be 
> in the same "struct net" as the current process.  It looks like the ->init 
> operation is going to need to have the namespace passed in for this to work 
> correctly.

But it is working in my tests.

I added a WARN and the call stack is :

[  701.522282]  [<ffffffff8108634f>] warn_slowpath_common+0x7f/0xc0
[  701.522284]  [<ffffffff810863aa>] warn_slowpath_null+0x1a/0x20
[  701.522286]  [<ffffffffa00e00e3>] tcf_mirred_init+0x43/0x340 [act_mirred]
[  701.522289]  [<ffffffff81506385>] ? __rtnl_unlock+0x15/0x20
[  701.522293]  [<ffffffff815195e8>] tcf_action_init_1+0x198/0x1e0
[  701.522295]  [<ffffffff815196c8>] tcf_action_init+0x98/0x100
[  701.522298]  [<ffffffff81517f30>] tcf_exts_validate+0x90/0xb0
[  701.522300]  [<ffffffff8151e55b>] u32_set_parms.isra.11+0x3b/0x270
[  701.522303]  [<ffffffff812ffdf0>] ? nla_parse+0x90/0xe0
[  701.522304]  [<ffffffff8151ed16>] u32_change+0x2e6/0x4c0
[  701.522306]  [<ffffffff81518432>] tc_ctl_tfilter+0x4e2/0x720
[  701.522308]  [<ffffffff815064ad>] rtnetlink_rcv_msg+0x11d/0x310
[  701.522310]  [<ffffffff81506390>] ? __rtnl_unlock+0x20/0x20
[  701.522312]  [<ffffffff81522d39>] netlink_rcv_skb+0xa9/0xd0
[  701.522314]  [<ffffffff81503875>] rtnetlink_rcv+0x25/0x40
[  701.522316]  [<ffffffff81522681>] netlink_unicast+0x1b1/0x230
[  701.522317]  [<ffffffff815229fe>] netlink_sendmsg+0x2fe/0x3b0
[  701.522321]  [<ffffffff814dbdf2>] sock_sendmsg+0xd2/0xf0
[  701.522323]  [<ffffffff814dbca0>] ? sock_recvmsg+0xe0/0x100
[  701.522326]  [<ffffffff814dd0f0>] __sys_sendmsg+0x380/0x390
[  701.522329]  [<ffffffff815b20b4>] ? __do_page_fault+0x214/0x460
[  701.522331]  [<ffffffff814df4e9>] sys_sendmsg+0x49/0x90
[  701.522334]  [<ffffffff815b68c2>] system_call_fastpath+0x16/0x1b

Could you elaborate on what could be the problem ?

We hold the RTNL, so I dont think another process could possibly call
tcf_mirred_init()
