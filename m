From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] inet: fix enforcing of fragment queue hash list
 depth
Date: Mon, 15 Apr 2013 09:23:50 -0700
Message-ID: <1366043030.4459.109.camel@edumazet-glaptop>
References: <20130415142454.14020.18322.stgit@dragon>
	 <20130415152637.GA29378@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36146 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753463Ab3DOQXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 12:23:53 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz11so2655546pad.30
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 09:23:53 -0700 (PDT)
In-Reply-To: <20130415152637.GA29378@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-15 at 17:26 +0200, Hannes Frederic Sowa wrote:
> Hi Jesper!
> 
> On Mon, Apr 15, 2013 at 04:25:10PM +0200, Jesper Dangaard Brouer wrote:
> > I have found an issues with commit:
> > 
> >  commit 5a3da1fe9561828d0ca7eca664b16ec2b9bf0055
> >  Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >  Date:   Fri Mar 15 11:32:30 2013 +0000
> > 
> >     inet: limit length of fragment queue hash table bucket lists
> > 
> > There is a connection between the fixed 128 hash depth limit and the
> > frag mem limit/thresh settings, which limits how high the thresh can
> > be set.
> > 
> > The 128 elems hash depth limit, results in bad behaviour if mem limit
> > thresh holds are increased, via /proc/sys/net ::
> > 
> >  /proc/sys/net/ipv4/ipfrag_high_thresh
> >  /proc/sys/net/ipv4/ipfrag_low_thresh
> > 
> > If we increase the thresh, to something allowing 128 elements in each
> > bucket, which is not that high given the hash array size of 64
> > (64*128=8192), e.g.
> >   big MTU frags (2944(truesize)+208(ipq))*8192(max elems)=25755648
> >   small frags   ( 896(truesize)+208(ipq))*8192(max elems)=9043968
> 
> I thought it was pretty high already. While creating this patch I also
> had a patch which did calculate the chain limit while updating the sysctl
> high_thresh knob (perhaps this could be of use):
> 
> http://patchwork.ozlabs.org/patch/227136/
> 
> Perhaps we should reconsider the formula I choose to calculate this limit.
> But because we would actually have 128 iterations in the hash bucket I
> am more in favor of resizing (or even come up with a way to dynamically
> resize) the hash table. On a smaller sized machine I can actually create
> severe latency because of the list iteration even with the 128 list length
> limit in place.

Allowing thousand of fragments and keeping a 64 slot hash table is not
going to work.

depths of 128 are just insane.

Really Jesper, you'll need to make the hash table dynamic, if you really
care.
