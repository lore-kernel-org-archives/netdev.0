From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch] bonding: fix potential deadlock in bond_uninit()
Date: Wed, 31 Mar 2010 04:28:33 -0700
Message-ID: <m1d3ykzq5a.fsf@fess.ebiederm.org>
References: <20100331105559.5607.38643.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100331105559.5607.38643.sendpatchset@localhost.localdomain> (Amerigo Wang's message of "Wed\, 31 Mar 2010 06\:52\:13 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amerigo Wang <amwang@redhat.com> writes:

> bond_uninit() is invoked with rtnl_lock held, when it does destroy_workqueue()
> which will potentially flush all works in this workqueue, if we hold rtnl_lock
> again in the work function, it will deadlock.
>
> So unlock rtnl_lock before calling destroy_workqueue().

Ouch.  That seems rather rude to our caller, and likely very
dangerous.

Is this a deadlock you actually hit, or is this something lockdep
warned about?

My gut feel says we need to move the destroy_workqueue into
the network device destructor.

Eric



> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: Jiri Pirko <jpirko@redhat.com>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
>
> ---
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 5b92fbf..b781728 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4542,8 +4542,11 @@ static void bond_uninit(struct net_device *bond_dev)
>  
>  	bond_remove_proc_entry(bond);
>  
> -	if (bond->wq)
> +	if (bond->wq) {
> +		rtnl_unlock();
>  		destroy_workqueue(bond->wq);
> +		rtnl_lock();
> +	}
>  
>  	netif_addr_lock_bh(bond_dev);
>  	bond_mc_list_destroy(bond);
