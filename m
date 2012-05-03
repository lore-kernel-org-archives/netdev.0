From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 7/9] net: add skb_orphan_frags to copy aside frags with
 destructors
Date: Fri, 4 May 2012 00:10:24 +0300
Message-ID: <20120503210826.GA30504@redhat.com>
References: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
 <1336056971-7839-7-git-send-email-ian.campbell@citrix.com>
 <20120503154142.GB27671@redhat.com>
 <20120503.135532.1038384417514973419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20253 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754928Ab2ECVKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 17:10:21 -0400
Content-Disposition: inline
In-Reply-To: <20120503.135532.1038384417514973419.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 03, 2012 at 01:55:32PM -0400, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Thu, 3 May 2012 18:41:43 +0300
> 
> > On Thu, May 03, 2012 at 03:56:09PM +0100, Ian Campbell wrote:
> >> This should be used by drivers which need to hold on to an skb for an extended
> >> (perhaps unbounded) period of time. e.g. the tun driver which relies on
> >> userspace consuming the skb.
> >> 
> >> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> >> Cc: mst@redhat.com
> > 
> > 
> > Right. But local sockets queue at socket forever as well.
> > I think this should be called in skb_set_owner_r?
> > 
> > This might somewhat penalize speed for local clients in the name
> > of correctness but these are rare so being correct is
> > more important I think.
> 
> But, on the other hand, putting the check into skb_set_owner_r() is a
> not so nice test to have in the fast path of every socket receive.

True.  Hmm we orphan skbs when we loop them back
so how about reusing the skb->destructor for this?

We could teach pskb_copy pskb_expand_head etc that
when skb with this flag is cloned (expand head etc)
destructor would be set to a function that copies frags.
(clone is less of a fast path so I think adding
 a branch there is less of an issue).

Of course destructor is also called from kfree_skb
but we could clear this flag before the call
in kfree_skb so that destructor can distinguish.

-- 
MST
