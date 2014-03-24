From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH] netlink: have netlink per-protocol bind function return
 an error code.
Date: Mon, 24 Mar 2014 10:38:43 -0400
Message-ID: <20140324143843.GC28666@madcap2.tricolour.ca>
References: <1239812af16a5c746772913ef68d3570383f2e50.1395419169.git.rgb@redhat.com>
 <20140323.005010.1898428719601246326.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	eparis@redhat.com, sgrubb@redhat.com, hadi@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140323.005010.1898428719601246326.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/03/23, David Miller wrote:
> From: Richard Guy Briggs <rgb@redhat.com>
> Date: Fri, 21 Mar 2014 12:39:11 -0400
> 
> > @@ -1441,6 +1441,17 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
> >  	if (!nladdr->nl_groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
> >  		return 0;
> >  
> > +	if (nlk->netlink_bind && nladdr->nl_groups) {
> > +		int i;
> > +
> > +		for (i = 0; i < nlk->ngroups; i++)
> > +			if (test_bit(i, (long unsigned int *)&nladdr->nl_groups)) {
> > +				err = nlk->netlink_bind(i);
> > +				if (err)
> > +					return err;
> > +			}
> > +	}
> > +
> 
> You can't just leave a partially set of completed bindings in place.

In the general case, I agree.

> It's not valid to leave half-baked state like this.

In the one existing case (netfilter), it adds a module that is never
unloaded.  (refcounts are bumped up and down, but I don't see an
auto-reap based on cleared multicast group subscriptions.)  For that
matter, netlink_realloc_groups() isn't reversed on error either.

In the proposed case (audit) it is only a permissions check, so there is
nothing to undo.

So, I was being lazy looking at the existing situation.

> If you return an error, all of the binding state changes must be
> completely undone.

Is it time to add a ".unbind = netlink_unbind" to struct proto_ops
netlink_ops?  (I am only half serious here...)

> If you can't find a way to do this cleanly, you'll need to find
> a way for the audit code to not return an error.

Fair enough.  I'll go back and look at updating subscriptions and
listeners first and undoing those actions if the bind fails.  In the
case of netlink_setsockopt() it is just one to undo, which is easy.
netlink_bind() is a bit more complex, but doable.

The whole purpose here was to add a way for each protocol to be able to
add its own permissions check and signal a way for netlink to refuse the
subscription if the userspace process doesn't have the required
permissions, so not returning an error defeats that whole purpose.

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
