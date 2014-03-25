From: Richard Guy Briggs <rgb@redhat.com>
Subject: unbind [was: Re: [PATCH] netlink: have netlink per-protocol bind
 function return] an error code.
Date: Tue, 25 Mar 2014 09:11:59 -0400
Message-ID: <20140325131159.GH28666@madcap2.tricolour.ca>
References: <1239812af16a5c746772913ef68d3570383f2e50.1395419169.git.rgb@redhat.com>
 <20140323.005010.1898428719601246326.davem@davemloft.net>
 <20140324143843.GC28666@madcap2.tricolour.ca>
 <20140324183406.GE28666@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	eparis@redhat.com, sgrubb@redhat.com, hadi@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140324183406.GE28666@madcap2.tricolour.ca>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/03/24, Richard Guy Briggs wrote:
> On 14/03/24, Richard Guy Briggs wrote:
> > On 14/03/23, David Miller wrote:
> > > From: Richard Guy Briggs <rgb@redhat.com>
> > > Date: Fri, 21 Mar 2014 12:39:11 -0400

Ok, sorry for all the noise.  I had a problem between chair and keyboard
which can explain the number of useless revs of this patch...  v6 is
current with potentially v7 with the inline hunk below...

> > > > @@ -1441,6 +1441,17 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
> > > >  	if (!nladdr->nl_groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
> > > >  		return 0;
> > > >  
> > > > +	if (nlk->netlink_bind && nladdr->nl_groups) {
> > > > +		int i;
> > > > +
> > > > +		for (i = 0; i < nlk->ngroups; i++)
> > > > +			if (test_bit(i, (long unsigned int *)&nladdr->nl_groups)) {
> > > > +				err = nlk->netlink_bind(i);
> > > > +				if (err)
> > > > +					return err;
> > > > +			}
> > > > +	}
> > > > +
> > > 
> > > You can't just leave a partially set of completed bindings in place.
> > 
> > In the general case, I agree.
> > 
> > > It's not valid to leave half-baked state like this.
> > 
> > In the one existing case (netfilter), it adds a module that is never
> > unloaded.  (refcounts are bumped up and down, but I don't see an
> > auto-reap based on cleared multicast group subscriptions.)  For that
> > matter, netlink_realloc_groups() isn't reversed on error either.
> 
> Ok, in netlink_bind(), netlink_insert()/netlink_autobind() also need
> to be undone with netlink_remove() if nlk->portid was not set.

This is also true with netlink_setsockopt() in the
NETLINK_{ADD,DROP}_MEMBERSHIP case, where on ADD we should call
netlink_bind() but on DROP we should *not* call it and instead call
netlink_unbind() afterwards, perhaps such as:

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 45dccff..3354d54 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2108,7 +2108,7 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 			return err;
 		if (!val || val - 1 >= nlk->ngroups)
 			return -EINVAL;
-		if (nlk->netlink_bind) {
+		if (optname == NETLINK_ADD_MEMBERSHIP && nlk->netlink_bind) {
 			err = nlk->netlink_bind(val);
 			if (err)
 				return err;
@@ -2117,6 +2117,8 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 		netlink_update_socket_mc(nlk, val,
 					 optname == NETLINK_ADD_MEMBERSHIP);
 		netlink_table_ungrab();
+		if (optname == NETLINK_DROP_MEMBERSHIP && nlk->netlink_unbind)
+			nlk->netlink_unbind(val);
 
 		err = 0;
 		break;

> > In the proposed case (audit) it is only a permissions check, so there is
> > nothing to undo.
> > 
> > So, I was being lazy looking at the existing situation.
> > 
> > > If you return an error, all of the binding state changes must be
> > > completely undone.
> > 
> > Is it time to add a ".unbind = netlink_unbind" to struct proto_ops
> > netlink_ops?  (I am only half serious here...)
> 
> At this stage, that function would be a no-op for netfilter and audit.
> Are there any out-of-tree users of this per-protocol bind function?
> 
> > > If you can't find a way to do this cleanly, you'll need to find
> > > a way for the audit code to not return an error.
> > 
> > Fair enough.  I'll go back and look at updating subscriptions and
> > listeners first and undoing those actions if the bind fails.  In the
> > case of netlink_setsockopt() it is just one to undo, which is easy.
> > netlink_bind() is a bit more complex, but doable.

So netlink_setsockopt() was right, but ADD/DROP need slightly different
treatment.

netlink_bind() just needs to undo netlink_bind() on error.

> > The whole purpose here was to add a way for each protocol to be able to
> > add its own permissions check and signal a way for netlink to refuse the
> > subscription if the userspace process doesn't have the required
> > permissions, so not returning an error defeats that whole purpose.

We could do all we wanted in audit, but that would still not signal
netlink to block that subscription.

> > - RGB
> 
> - RGB

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
