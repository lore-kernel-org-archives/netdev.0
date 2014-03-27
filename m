From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/core: Use RCU_INIT_POINTER(x, NULL) in netpoll.c
Date: Thu, 27 Mar 2014 14:28:31 -0700
Message-ID: <20140327212831.GA4284@linux.vnet.ibm.com>
References: <1395601966-12490-1-git-send-email-monamagarwal123@gmail.com>
 <20140324111144.GA19368@hmsreliant.think-freely.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Monam Agarwal <monamagarwal123@gmail.com>, davem@davemloft.net,
	ebiederm@xmission.com, cwang@twopensource.com, kaber@trash.net,
	antonio@meshcoding.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140324111144.GA19368@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 24, 2014 at 07:11:44AM -0400, Neil Horman wrote:
> On Mon, Mar 24, 2014 at 12:42:46AM +0530, Monam Agarwal wrote:
> > This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)
> > 
> > The rcu_assign_pointer() ensures that the initialization of a structure       
> > is carried out before storing a pointer to that structure. 
> > And in the case of the NULL pointer, there is no structure to initialize. 
> > So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)
> > 
> > Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
> No, I don't think this is right. __netpoll_cleanup can be called in parallel
> with bottom half access to dev->npinfo.  rcu_assign pointer is safe against
> those accesses, but RCU_INIT_POINTER is not.

Hello, Neil,

But in this case, NULL is being assigned, so there should be no problem.
If this was a non-NULL pointer to a structure that had not already been
exposed to readers, then yes, this would be a problem.  But NULL pointers
are OK to assign using RCU_INIT_POINTER().

							Thanx, Paul

> Neil
> 
> > ---
> >  net/core/netpoll.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> > index 7291dde..41c4e9c 100644
> > --- a/net/core/netpoll.c
> > +++ b/net/core/netpoll.c
> > @@ -809,7 +809,7 @@ void __netpoll_cleanup(struct netpoll *np)
> >  		if (ops->ndo_netpoll_cleanup)
> >  			ops->ndo_netpoll_cleanup(np->dev);
> >  
> > -		rcu_assign_pointer(np->dev->npinfo, NULL);
> > +		RCU_INIT_POINTER(np->dev->npinfo, NULL);
> >  		call_rcu_bh(&npinfo->rcu, rcu_cleanup_netpoll_info);
> >  	}
> >  }
> > -- 
> > 1.7.9.5
> > 
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
