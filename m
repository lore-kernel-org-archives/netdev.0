From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 03/12] ipvs: prefer NETDEV_DOWN event to free
 cached dsts
Date: Wed, 6 Mar 2013 23:21:17 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1303062310520.1899@ja.ssi.bg>
References: <1362559342-18784-1-git-send-email-ja@ssi.bg>  <1362559342-18784-4-git-send-email-ja@ssi.bg> <1362563789.17102.69.camel@hawk.mlab.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:33200 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755527Ab3CFVUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 16:20:21 -0500
In-Reply-To: <1362563789.17102.69.camel@hawk.mlab.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 6 Mar 2013, Hans Schillstrom wrote:

> Hi Julian
> 
> On Wed, 2013-03-06 at 10:42 +0200, Julian Anastasov wrote:
> > 	The real server becomes unreachable on down event,
> > no need to wait device unregistration. Should help in
> > releasing dsts early before dst->dev is replaced with lo.
> 
> Have you test this in a network namespace ?
> i.e. kill the namespace with heave traffic through it

	This should not be a problem. Even without ns exit
situation, we can have a case where device goes down,
the output routes will start to fail and we will
not cache route anymore. It can happen while the
input device floods us with requests.

> From what I remember this was a tricky area...
> 
> I have some test cases for this, should I run them ?

	If it is easy...

> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> >  net/netfilter/ipvs/ip_vs_ctl.c |    8 +++-----
> >  1 files changed, 3 insertions(+), 5 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> > index c68198b..76fc8f2 100644
> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> > @@ -1512,10 +1512,8 @@ __ip_vs_dev_reset(struct ip_vs_dest *dest, struct net_device *dev)
> >  	spin_unlock_bh(&dest->dst_lock);
> >  
> >  }
> > -/*
> > - * Netdev event receiver
> > - * Currently only NETDEV_UNREGISTER is handled, i.e. if we hold a reference to
> > - * a device that is "unregister" it must be released.
> > +/* Netdev event receiver
> > + * Currently only NETDEV_DOWN is handled to release refs to cached dsts
> >   */
> >  static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
> >  			    void *ptr)
> > @@ -1527,7 +1525,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
> >  	struct ip_vs_dest *dest;
> >  	unsigned int idx;
> >  
> > -	if (event != NETDEV_UNREGISTER || !ipvs)
> > +	if (event != NETDEV_DOWN || !ipvs)
> >  		return NOTIFY_DONE;
> >  	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
> >  	EnterFunction(2);
> 
> 
> Regards
> Hans

Regards

--
Julian Anastasov <ja@ssi.bg>
