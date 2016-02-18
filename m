From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/4] geneve: implement geneve_get_sk_family
 helper
Date: Thu, 18 Feb 2016 16:24:35 +0100
Message-ID: <20160218162435.29efcf36@griffin>
References: <cover.1455790645.git.jbenc@redhat.com>
	<4d1533364167a04892cb7ec573b3b19dc01c682b.1455790645.git.jbenc@redhat.com>
	<20160218144409.GA12622@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56878 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946374AbcBRPYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 10:24:39 -0500
In-Reply-To: <20160218144409.GA12622@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Feb 2016 09:44:10 -0500, John W. Linville wrote:
> On Thu, Feb 18, 2016 at 11:22:49AM +0100, Jiri Benc wrote:
> > +static sa_family_t geneve_get_sk_family(struct geneve_sock *gs)
> > +{
> > +	return gs->sock->sk->sk_family;
> > +}
> > +
> 
> Should this be inline?

AFAIK the kernel policy is to not add inlines in .c files, instead let
the compiler do its job.

> Can we count on GCC to inline geneve_get_sk_family on its own?

Yes.

> Otherwise, we are calling the same function as many as three times
> on receive.
[...]
> Then on these three you are caching the results of the function
> call instead...

The reason I removed the sa_family local variable from geneve_rx is the
next patch in the set where I need to put part of the family references
into a separate function.

I kept the rest of the file as it was - I thought about removing the
local variables in geneve_notify_add/del_rx_port, too, but it would
lead to ugly long lines here:

        for_each_netdev_rcu(net, dev) {
                if (dev->netdev_ops->ndo_add_geneve_port)
                        dev->netdev_ops->ndo_add_geneve_port(dev, sa_family,
                                                             port);
        }

Thus, the local variable makes sense in the these two functions, makes
the code more comprehensible.

> > @@ -596,7 +598,7 @@ static struct geneve_sock *geneve_find_sock(struct geneve_net *gn,
> >  
> >  	list_for_each_entry(gs, &gn->sock_list, list) {
> >  		if (inet_sk(gs->sock->sk)->inet_sport == dst_port &&
> > -		    inet_sk(gs->sock->sk)->sk.sk_family == family) {
> > +		    geneve_get_sk_family(gs) == family) {
> >  			return gs;
> >  		}
> >  	}
> 
> And back to calling it each time (as necessary inside the
> list_for_each_entry).

Just replacing the direct sk_family dereference with the helper, no
real change here. No need to introduce a local variable here, this is
still short enough.

> So, it seems like geneve_get_sk_family needs to be inline -- maybe GCC
> is doing that on its own?  FWIW, I probably would cache the results
> inside of geneve_rx like you have done in geneve_notify_add_rx_port
> and geneve_notify_del_rx_port.

Then I would just have to remove or duplicate the local variable in the
next patch. Not worth it, I think.

Thanks for review,

 Jiri
