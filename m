From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: Fix kernel panic in nfulnl_rcv_nl_event
Date: Wed, 20 May 2015 13:39:09 +0200
Message-ID: <20150520113909.GA10948@salvia>
References: <20150517213031.4ABD2480853@fruggeri-Arora18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, gaofeng@cn.fujitsu.com,
	dvlasenk@redhat.com, netfilter-devel@vger.kernel.org,
	davem@davemloft.net, fruggeri@arista.com
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150517213031.4ABD2480853@fruggeri-Arora18.sjc.aristanetworks.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 17, 2015 at 02:30:31PM -0700, Francesco Ruggeri wrote:
> nfnetlink_log_init registers netlink callback nfulnl_rcv_nl_event before
> registering the pernet_subsys, but the callback relies on data structures
> allocated by pernet init functions.
> When nfnetlink_log is loaded, if a netlink message is received after
> the netlink callback is registered but before the pernet_subsys is
> registered, the kernel will panic in the sequence
> 
> nfulnl_rcv_nl_event
>   nfnl_log_pernet
>     net_generic
>       BUG_ON(id == 0)  where id is nfnl_log_net_id.
> 
> The panic can be easily reproduced in 4.0.3 by:
> 
> while true ;do modprobe nfnetlink_log ; rmmod nfnetlink_log ; done &
> while true ;do ip netns add dummy ; ip netns del dummy ; done &
> 
> This patch moves register_pernet_subsys to earlier in nfnetlink_log_init.
> 
> Notice that the BUG_ON hit in 4.0.3 was recently removed in 2591ffd308
> ["netns: remove BUG_ONs from net_generic()"].

I'm going to send a v2 of this patch with two changes:

* We have the same problem in nfnetlink_queue.
* Remove status = -ENOMEM as it is scratched soon thereafter.

Please, have a look at the patch I'll send after this and confirm this
looks good to you.
