From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix the rcu race between free_fib_info and
 ip_route_output_slow
Date: Wed, 23 May 2012 09:39:34 +0200
Message-ID: <1337758775.3361.2056.camel@edumazet-glaptop>
References: <4FBB6105.2060808@intel.com>
	 <20120522.151554.106838106733194160.davem@davemloft.net>
	 <1337742123.14538.175.camel@ymzhang.sh.intel.com>
	 <20120522.232310.911242148705021745.davem@davemloft.net>
	 <1337747829.3361.1599.camel@edumazet-glaptop>
	 <1337748897.14538.184.camel@ymzhang.sh.intel.com>
	 <1337749339.3361.1655.camel@edumazet-glaptop>
	 <1337753757.14538.190.camel@ymzhang.sh.intel.com>
	 <1337754459.3361.1850.camel@edumazet-glaptop>
	 <1337755623.14538.194.camel@ymzhang.sh.intel.com>
	 <1337756138.3361.1922.camel@edumazet-glaptop>
	 <1337757238.3361.1965.camel@edumazet-glaptop>
	 <1337757862.14538.199.camel@ymzhang.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kunx.jiang@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337757862.14538.199.camel@ymzhang.sh.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-23 at 15:24 +0800, Yanmin Zhang wrote:
> On Wed, 2012-05-23 at 09:13 +0200, Eric Dumazet wrote:
> > On Wed, 2012-05-23 at 08:55 +0200, Eric Dumazet wrote:
> > 
> > > Please hold on, I'll send a v2
> > 
> > I believe your patch should be fine, if you move back the
> > fib_info_cnt--;
> > 
> > So only do the dev_put() in free_fib_info_rcu().
> We would do so in a new patch.
> 
> > 
> > No need to clear nh_dev to NULL since we are freeing fi at the end of
> > function.
> David suggests to reset it to NULL to detect other potential
> race conditions.
> 

Yes but no.

Users are in a RCU read lock and we should not change nh_dev to NULL
while they are running.

Thats what I tried to do (David message gave me this wrong hint) but it
came to a dead issue.

Only after a grace period we can :
	dev_put() all involved net_devices
	kfree(fi)

> Besides above suggestions, how do you think about:
> 
> fib_create_info=>fib_find_info, but fib_find_info is not protected by
> fib_info_lock. See the codes:
> 
> fib_create_info()
> {
> 	...
> link_it:
>         ofi = fib_find_info(fi);
>         if (ofi) {
>                 fi->fib_dead = 1;
>                 free_fib_info(fi);
>                 ofi->fib_treeref++;
>                 return ofi;
>         }
>         fi->fib_treeref++;
>         atomic_inc(&fi->fib_clntref);
>         spin_lock_bh(&fib_info_lock);
> 
> 	...
> }
> 
> I plan to change it to hold fib_info_lock before calling fib_find_info. Is
> it ok for you?

Its not needed we hold RTNL mutex.

spinlock is needed mainly because of ip_fib_check_default(), but this
could be changed to use RCU as well. 

(readers use RCU, writers already hold RTNL -> no more fib_info_lock )
