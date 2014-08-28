From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: net_ns cleanup / RCU overhead
Date: Thu, 28 Aug 2014 12:24:31 -0700
Message-ID: <20140828192431.GF5001@linux.vnet.ibm.com>
References: <20140820055855.GB5579@hostway.ca>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Simon Kirby <sim@hostway.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140820055855.GB5579@hostway.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 19, 2014 at 10:58:55PM -0700, Simon Kirby wrote:
> Hello!
> 
> In trying to figure out what happened to a box running lots of vsftpd
> since we deployed a CONFIG_NET_NS=y kernel to it, we found that the
> (wall) time needed for cleanup_net() to complete, even on an idle box,
> can be quite long:
> 
> #!/bin/bash
> 
> ip netns delete test >&/dev/null
> while ip netns add test; do
>         echo hi
>         ip netns delete test
> done
> 
> On my desktop and typical hosts, this prints at only around 4 or 6 per
> second. While this is happening, "vmstat 1" reports 100% idle, and there
> there are D-state processes with stacks similar to:
> 
> 30566 [kworker/u16:1] D wait_rcu_gp+0x48, synchronize_sched+0x2f, cleanup_net+0xdb, process_one_work+0x175, worker_thread+0x119, kthread+0xbb, ret_from_fork+0x7c, 0xffffffffffffffff
> 
> 32220 ip              D copy_net_ns+0x68, create_new_namespaces+0xfc, unshare_nsproxy_namespaces+0x66, SyS_unshare+0x159, system_call_fastpath+0x16, 0xffffffffffffffff
> 
> copy_net_ns() is waiting on net_mutex which is held by cleanup_net().
> 
> vsftpd uses CLONE_NEWNET to set up privsep processes. There is a comment
> about it being really slow before 2.6.35 (it avoids CLONE_NEWNET in that
> case). I didn't find anything that makes 2.6.35 any faster, but on Debian
> 2.6.36-5-amd64, I notice it does seem to be a bit faster than 3.2, 3.10,
> 3.16, though still not anything I'd ever want to rely on per connection.
> 
> C implementation of the above: http://0x.ca/sim/ref/tools/netnsloop.c
> 
> Kernel stack "top": http://0x.ca/sim/ref/tools/pstack
> 
> What's going on here?

That is a bit slow for many configurations, but there are some exceptions.

So, what is your kernel's .config?

							Thanx, Paul
