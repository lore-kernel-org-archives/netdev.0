From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Subject: Re: [PATCH] ipv4: fix the rcu race between free_fib_info and
 ip_route_output_slow
Date: Wed, 23 May 2012 14:15:57 +0800
Message-ID: <1337753757.14538.190.camel@ymzhang.sh.intel.com>
References: <4FBB6105.2060808@intel.com>
	 <20120522.151554.106838106733194160.davem@davemloft.net>
	 <1337742123.14538.175.camel@ymzhang.sh.intel.com>
	 <20120522.232310.911242148705021745.davem@davemloft.net>
	 <1337747829.3361.1599.camel@edumazet-glaptop>
	 <1337748897.14538.184.camel@ymzhang.sh.intel.com>
	 <1337749339.3361.1655.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kunx.jiang@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337749339.3361.1655.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-23 at 07:02 +0200, Eric Dumazet wrote:
> On Wed, 2012-05-23 at 12:54 +0800, Yanmin Zhang wrote:
> 
> > > fi->fib_dev (aka fib_nh[0].nh_dev) need full RCU protection.
> > The new patch posted at https://lkml.org/lkml/2012/5/22/558 does move the
> > resetting to RCU protection.
> 
> Its not enough.
> 
> We must take care that all users are in a RCU protected region.
> 
> They might be already, but a full check is needed.
> 
> For example 
> 
> net/ipv4/fib_trie.c:2563:    fi->fib_dev ? fi->fib_dev->name : "*"
> 
> looks to be safe (because already in a rcu_read_lock())
> 
> But its not.
> 
> Right thing would be to do :
> 
> struct net_device *ndev = rcu_dereference(fi->fib_dev)
> 
> 	...
> 	ndev ? ndev->name : "*"
Thanks for the pointer.

Besides fi->fib_dev here, we need check fi->fib_hash, fi->fib_lhash,
and nexthop_nh->nh_hash.

Yanmin
