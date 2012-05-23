From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Subject: Re: [PATCH] ipv4: fix the rcu race between free_fib_info and
 ip_route_output_slow
Date: Wed, 23 May 2012 15:24:22 +0800
Message-ID: <1337757862.14538.199.camel@ymzhang.sh.intel.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kunx.jiang@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17599 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753723Ab2EWHXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2012 03:23:31 -0400
In-Reply-To: <1337757238.3361.1965.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-23 at 09:13 +0200, Eric Dumazet wrote:
> On Wed, 2012-05-23 at 08:55 +0200, Eric Dumazet wrote:
> 
> > Please hold on, I'll send a v2
> 
> I believe your patch should be fine, if you move back the
> fib_info_cnt--;
> 
> So only do the dev_put() in free_fib_info_rcu().
We would do so in a new patch.

> 
> No need to clear nh_dev to NULL since we are freeing fi at the end of
> function.
David suggests to reset it to NULL to detect other potential
race conditions.

Besides above suggestions, how do you think about:

fib_create_info=>fib_find_info, but fib_find_info is not protected by
fib_info_lock. See the codes:

fib_create_info()
{
	...
link_it:
        ofi = fib_find_info(fi);
        if (ofi) {
                fi->fib_dead = 1;
                free_fib_info(fi);
                ofi->fib_treeref++;
                return ofi;
        }
        fi->fib_treeref++;
        atomic_inc(&fi->fib_clntref);
        spin_lock_bh(&fib_info_lock);

	...
}

I plan to change it to hold fib_info_lock before calling fib_find_info. Is
it ok for you?

Thanks for the direct speaking.

Yanmin
