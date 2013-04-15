From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH] inet: fix enforcing of fragment queue hash list depth
Date: Mon, 15 Apr 2013 19:09:51 +0200
Message-ID: <20130415170951.GB29378@order.stressinduktion.org>
References: <20130415142454.14020.18322.stgit@dragon> <20130415152637.GA29378@order.stressinduktion.org> <1366043030.4459.109.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44665 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932263Ab3DORJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 13:09:52 -0400
Content-Disposition: inline
In-Reply-To: <1366043030.4459.109.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 15, 2013 at 09:23:50AM -0700, Eric Dumazet wrote:
> On Mon, 2013-04-15 at 17:26 +0200, Hannes Frederic Sowa wrote:
> > Hi Jesper!
> > 
> > On Mon, Apr 15, 2013 at 04:25:10PM +0200, Jesper Dangaard Brouer wrote:
> > > I have found an issues with commit:
> > > 
> > >  commit 5a3da1fe9561828d0ca7eca664b16ec2b9bf0055
> > >  Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > >  Date:   Fri Mar 15 11:32:30 2013 +0000
> > > 
> > >     inet: limit length of fragment queue hash table bucket lists
> > > 
> > > There is a connection between the fixed 128 hash depth limit and the
> > > frag mem limit/thresh settings, which limits how high the thresh can
> > > be set.
> > > 
> > > The 128 elems hash depth limit, results in bad behaviour if mem limit
> > > thresh holds are increased, via /proc/sys/net ::
> > > 
> > >  /proc/sys/net/ipv4/ipfrag_high_thresh
> > >  /proc/sys/net/ipv4/ipfrag_low_thresh
> > > 
> > > If we increase the thresh, to something allowing 128 elements in each
> > > bucket, which is not that high given the hash array size of 64
> > > (64*128=8192), e.g.
> > >   big MTU frags (2944(truesize)+208(ipq))*8192(max elems)=25755648
> > >   small frags   ( 896(truesize)+208(ipq))*8192(max elems)=9043968
> > 
> > I thought it was pretty high already. While creating this patch I also
> > had a patch which did calculate the chain limit while updating the sysctl
> > high_thresh knob (perhaps this could be of use):
> > 
> > http://patchwork.ozlabs.org/patch/227136/
> > 
> > Perhaps we should reconsider the formula I choose to calculate this limit.
> > But because we would actually have 128 iterations in the hash bucket I
> > am more in favor of resizing (or even come up with a way to dynamically
> > resize) the hash table. On a smaller sized machine I can actually create
> > severe latency because of the list iteration even with the 128 list length
> > limit in place.
> 
> Allowing thousand of fragments and keeping a 64 slot hash table is not
> going to work.
> 
> depths of 128 are just insane.
> 
> Really Jesper, you'll need to make the hash table dynamic, if you really
> care.

Where there already plans how this could be achieved? I am currently
looking at nested hash table lookups, the dcache and Relativistic
Hash Table[1] paper. Last time I played with the idea to move the
fragmentation cache to RCU I abandoned it because of the high update
rate it could experience.

[1] http://static.usenix.org/event/atc11/tech/final_files/Triplett.pdf
