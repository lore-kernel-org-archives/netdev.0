From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Tue, 25 Mar 2014 20:11:55 +0100
Message-ID: <20140325191155.GB22086@order.stressinduktion.org>
References: <20140310.010313.703650662340510015.davem@davemloft.net> <20140310081533.GA27052@unicorn.suse.cz> <20140310120016.GH5493@order.stressinduktion.org> <20140310.223841.953940361609160158.davem@davemloft.net> <20140311095309.GA3287@unicorn.suse.cz> <20140311150814.GB3287@unicorn.suse.cz> <20140311153931.GC3287@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59118 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471AbaCYTL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 15:11:57 -0400
Content-Disposition: inline
In-Reply-To: <20140311153931.GC3287@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michal,

On Tue, Mar 11, 2014 at 04:39:31PM +0100, Michal Kubecek wrote:
> On Tue, Mar 11, 2014 at 04:08:14PM +0100, Michal Kubecek wrote:
> > > 
> > > I also believe the function should return immediately if mx is null so
> > > that we don't call dst_metrics_write_ptr() if no metrics are to be set
> > > for the new route.
> > 
> > Not so easy... :-( This would cause a problem if a host route is changed
> > twice in this way:
> > 
> >   ip route add fec0::1 dev eth0 rto_min 1000
> >   ip route change fec0::1 dev eth0
> >   ip route change fec0::1 dev eth0 hoplimit 10
> > 
> > First route has metrics in its inetpeer. This inetpeer is then inherited
> > by the second route but the metrics in it are not used as its dst_entry
> > points to the read-only default. But when it is replaced by the third
> > version, it inherits the inetpeer and it is not cleaned up by
> > ip6_cow_metrics() because it is not new.
> > 
> > What I ended up with is below. It uses the metrics in inetpeer if there
> > is one even if the new host metric doesn't have any metrics to set (in
> > which case it clears them first). I tested various scenarios and the
> > results were correct.
> 
> This doesn't cover all cases either:
> 
>   ip route add fec0::1 dev eth0 rto_min 1000
>   ip route delete fec0::1
>   ip route add fec0::1 dev eth0
>   ip route change fec0::1 dev eth0 hoplimit 10
> 
> This way the inetpeer with rto_min 1000 persists until the fourth
> command but neither third nor fourth see old dst_entry with writeable
> metrics.
> 
> I think changing the condition for copying in ip6_cow_metrics() would
> do the trick but I better stop now and look at it again later with
> a fresh mind.

Do you need some help regarding this patch so that it may be included in
net-next before it gets closed?

Thanks,

  Hannes
