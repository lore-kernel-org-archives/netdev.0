From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] net: add a synchronize_net() in
 netdev_rx_handler_unregister()
Date: Fri, 29 Mar 2013 09:17:19 -0400
Message-ID: <1364563039.10629.19.camel@gandalf.local.home>
References: <1364490997.6345.237.camel@gandalf.local.home>
	 <1364491792.15753.47.camel@edumazet-glaptop>
	 <20130329094856.GB1677@minipsycho.orion>
	 <1364562082.5113.16.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Guy Streeter <streeter@redhat.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:20747 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755933Ab3C2NRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 09:17:22 -0400
In-Reply-To: <1364562082.5113.16.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-29 at 06:01 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> On Fri, 2013-03-29 at 10:48 +0100, Jiri Pirko wrote:
> 
> > Hmm. I think that this might be issue introduced by:
> > commit a9b3cd7f323b2e57593e7215362a7b02fc933e3a
> > Author: Stephen Hemminger <shemminger@vyatta.com>
> > Date:   Mon Aug 1 16:19:00 2011 +0000
> > 
> >     rcu: convert uses of rcu_assign_pointer(x, NULL) to RCU_INIT_POINTER
> > 
> > 
> > Because, if rcu_dereference(dev->rx_handler) is null,
> > rcu_dereference(dev->rx_handler_data) is never done. Therefore I believe
> > we are hitting following scenario:
> > 
> > 
> >    CPU0				CPU1
> >    ----				----
> >   			    dev->rx_handler_data = NULL
> >  rcu_read_lock()
> >  			    dev->rx_handler = NULL
> > 
> > 
> > CPU0 will see rx_handler set and yet, rx_handler_data nulled. Write
> > barrier in rcu_assign_pointer() might prevent this reorder from happening.
> > Therefore I suggest:
> > 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 0caa38e..c16b829 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -3332,8 +3332,8 @@ void netdev_rx_handler_unregister(struct net_device *dev)
> >  {
> >  
> >  	ASSERT_RTNL();
> > -	RCU_INIT_POINTER(dev->rx_handler, NULL);
> > -	RCU_INIT_POINTER(dev->rx_handler_data, NULL);
> > +	rcu_assign_pointer(dev->rx_handler, NULL);
> > +	rcu_assign_pointer(dev->rx_handler_data, NULL);
> >  }
> >  EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
> >  
> > 
> 
> Nope this changes nothing at all.

Exactly! In fact, the bug triggered on an older kernel that had the
original rcu_assign_pointer()

> 
> However, we can fix the bug in a different way, if we want to avoid a
> test in fast path.
> 
> With following patch, we can make sure that a reader seeing a non NULL
> rx_handler has a guarantee to see a non NULL rx_handler_data
> 

[..]

> We can fix bug this in two ways. First is adding a test in
> bond_handle_frame() and others to check if rx_handler_data is NULL.
> 
> A second way is adding a synchronize_net() in
> netdev_rx_handler_unregister() to make sure that a rcu protected reader
> has the guarantee to see a non NULL rx_handler_data.
> 
> The second way is better as it avoids an extra test in fast path.
> 
> Reported-by: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jiri Pirko <jpirko@redhat.com>
> Cc: Paul E. McKenney <paulmck@us.ibm.com>
> ---
>  net/core/dev.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b13e5c7..56932a4 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3314,6 +3314,7 @@ int netdev_rx_handler_register(struct net_device *dev,
>  	if (dev->rx_handler)
>  		return -EBUSY;
>  
> +	/* Note: rx_handler_data must be set before rx_handler */
>  	rcu_assign_pointer(dev->rx_handler_data, rx_handler_data);
>  	rcu_assign_pointer(dev->rx_handler, rx_handler);
>  
> @@ -3334,6 +3335,11 @@ void netdev_rx_handler_unregister(struct net_device *dev)
>  
>  	ASSERT_RTNL();
>  	RCU_INIT_POINTER(dev->rx_handler, NULL);
> +	/* a reader seeing a non NULL rx_handler in a rcu_read_lock()
> +	 * section has a guarantee to see a non NULL rx_handler_data
> +	 * as well.
> +	 */
> +	synchronize_net();

I've thought about this too, but I wasn't sure we wanted two
synchronize_*() functions, as the caller does a synchronize as well.
That said, I think this is the more robust solution and it lets all
rx_handler() functions assume that their rx_handler_data is set. And it
removes the check from the fast path which outweighs an added
synchronization in the slow path.

Acked-by: Steven Rostedt <rostedt@goodmis.org>

Thanks!

-- Steve

>  	RCU_INIT_POINTER(dev->rx_handler_data, NULL);
>  }
>  EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
> 
