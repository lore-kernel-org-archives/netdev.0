From: Neil Horman <nhorman@redhat.com>
Subject: Re: netpoll rtnl_dereference() usage
Date: Fri, 25 Mar 2016 14:16:06 -0400
Message-ID: <20160325181606.GA18985@hmsreliant.think-freely.org>
References: <20160325173032.GC29822@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org, Alexander Duyck <aduyck@mirantis.com>,
	linux-kernel@vger.kernel.org
To: Bjorn Helgaas <helgaas@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160325173032.GC29822@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 25, 2016 at 12:30:32PM -0500, Bjorn Helgaas wrote:
> Hi Neil,
> 
> Since we're looking at netpoll, here's another question (or two).
> 0790bbb68f9d ("netpoll: cleanup sparse warnings") adds this:
> 
> @@ -1236,7 +1236,11 @@ void __netpoll_cleanup(struct netpoll *np)
>         struct netpoll_info *npinfo;
>         unsigned long flags;
>  
> -       npinfo = np->dev->npinfo;
> +       /* rtnl_dereference would be preferable here but
> +        * rcu_cleanup_netpoll path can put us in here safely without
> +        * holding the rtnl, so plain rcu_dereference it is
> +        */
> +       npinfo = rtnl_dereference(np->dev->npinfo);
>         if (!npinfo)
>                 return;
> 
> The comment seems to contradict the code: the comment says "we would
> like to use rtnl_dereference(), but we have to use rcu_dereference()."
> But the code in fact *does* use rtnl_dereference().
> 
its the comment that went awry.  I remember writing that patch, and I initially
thought we had to use rcu_derefence there, but I would up finding a way to keep
the rntl lock held, so rtnl_deref should be ok.  I must have just forgotten to
fixup the comment.

> Also, "rcu_cleanup_netpoll" doesn't exist; maybe it's a typo for
> rcu_cleanup_netpoll_info()?  I don't see the path that leads from
> rcu_cleanup_netpoll_info() to __netpoll_cleanup(), but I don't claim
> to understand the netpoll async subtleties.
> 
Correct again, its the rcu callback rcu_cleanup_netpoll_info that I'm referring
to there, and the comment was written initially when rcu_cleanup_netpoll info
was called cleanup_netpoll_info and called forward into __netpoll_cleanup (in my
development patch versions).  That comment should really just be re-written.
I'm happy to do so if you like

Best
Neil

> Bjorn
