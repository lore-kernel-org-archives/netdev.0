From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch] ipvs: close race conditions on ip_vs_conn_tab list
 modification
Date: Fri, 24 Jun 2005 11:46:21 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0506241046280.1690@u.domain.uli>
References: <20050623183926.GI16783@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
        Wensong Zhang <wensong@linux-vs.org>, akpm@osdl.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Neil Horman <nhorman@redhat.com>
In-Reply-To: <20050623183926.GI16783@hmsendeavour.rdu.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	adding netdev to CC

On Thu, 23 Jun 2005, Neil Horman wrote:

> Hello there-
> 	Patch to close a race condition in ip_vs_conn_flush.  In an smp system,
> it is possible for an connection timer to expire, calling ip_vs_conn_expire
> while the connection table is being flushed, before ct_write_lock_bh is
> acquired.  Since the list iterator loop in ip_vs_con_flush releases and
> re-acquires the spinlock (even though it doesn't re-enable softirqs), it is
> possible for the expiration function to modify the connection list, while it is
> being traversed in ip_vs_conn_flush.  The result is that the next pointer gets
> set to NULL, and subsequently dereferenced, resulting in an oops.  This patch
> removes the lock release and re-aquisition from the loop, closing the race
> window.  Tested by myself, and those who origionally experienced the crash and
> reported it to me, with successful results.
>
> Signed-off-by: Neil Horman <nhorman@redhat.com>
>
>  ip_vs_conn.c |    2 --
>  1 files changed, 2 deletions(-)
>
>
> --- linux-2.6.git/net/ipv4/ipvs/ip_vs_conn.c.orig	2005-06-23 13:11:00.910372471 -0400
> +++ linux-2.6.git/net/ipv4/ipvs/ip_vs_conn.c	2005-06-23 13:15:54.459852393 -0400
> @@ -840,7 +838,6 @@
>
>  		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
>  			atomic_inc(&cp->refcnt);
> -			ct_write_unlock(idx);
>
>  			if ((ct = cp->control))
>  				atomic_inc(&ct->refcnt);
> @@ -850,7 +847,6 @@
>  				IP_VS_DBG(4, "del conn template\n");
>  				ip_vs_conn_expire_now(ct);
>  			}
> -			ct_write_lock(idx);
>  		}
>  		ct_write_unlock_bh(idx);
>  	}

	Looks ok but can you test an extended version:

- remove these atomic_inc for cp and ct and the corresponding
__ip_vs_conn_put from ip_vs_conn_expire_now

- do the same for ip_vs_random_dropentry, it looks wrong in the same
way because it is not running anymore together with the connection 
expiration in same sltimer_handler

	Also, 2.4 needs the same changes, I hope you can continue?

Regards

--
Julian Anastasov <ja@ssi.bg>
