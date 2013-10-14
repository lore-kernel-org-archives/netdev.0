From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC net] bridge: clean the nf_bridge status when forwarding
 the skb
Date: Mon, 14 Oct 2013 15:27:56 -0700
Message-ID: <20131014152756.7b83dcc0@nehalam.linuxnetplumber.net>
References: <1380226790-513-1-git-send-email-antonio@meshcoding.com>
	<20130926141021.3cde0f0f@nehalam.linuxnetplumber.net>
	<20130926211648.GB1228@open-mesh.com>
	<20130926143248.2799b4ea@nehalam.linuxnetplumber.net>
	<20130926220143.GC1228@open-mesh.com>
	<20131014222010.GB3873@neomailbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:50907 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757333Ab3JNW17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 18:27:59 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so7934141pbc.29
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 15:27:59 -0700 (PDT)
In-Reply-To: <20131014222010.GB3873@neomailbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Oct 2013 00:20:10 +0200
Antonio Quartulli <antonio@meshcoding.com> wrote:

> On Fri, Sep 27, 2013 at 12:01:43AM +0200, Antonio Quartulli wrote:
> > On Thu, Sep 26, 2013 at 02:32:48PM -0700, Stephen Hemminger wrote:
> > > > > > diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> > > > > > index 4b81b14..65864bc 100644
> > > > > > --- a/net/bridge/br_forward.c
> > > > > > +++ b/net/bridge/br_forward.c
> > > > > > @@ -49,6 +49,11 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
> > > > > >  	} else {
> > > > > >  		skb_push(skb, ETH_HLEN);
> > > > > >  		br_drop_fake_rtable(skb);
> > > > > > +
> > > > > > +		/* clean the NF bridge data */
> > > > > > +		nf_bridge_put(skb->nf_bridge);
> > > > > > +		skb->nf_bridge = NULL;
> > > > > > +
> > > > > >  		dev_queue_xmit(skb);
> > > > > >  	}
> > > > > >  
> > > > 
> > > > Regarding CONFIG_BRIDGE_NETFILTER you are right, thanks.
> > > > 
> > > > > 
> > > > > I think the header will also be garbage if bridge on bridge with netfilter is used.
> > > > > See nf_bridge_save_header.
> > > > 
> > > > What header are you referring to? nf_bridge_save_header() saves the header in
> > > > skb->nf_bridge->data, which is freed during nf_bridge_put() (assuming
> > > > ->use reached 0).
> > > > 
> > > > 
> > > 
> > > If bridge is stacked the original ether header will get overwritten by the second
> > > call to save_header.
> > 
> > Sorry, but I am not getting what you mean (I am new to the code and it is late here..):
> > save_header() will store the Ethernet header in nf_bridge->data for
> > later recover (if needed).
> > 
> > By freeing nf_bridge I also destroy this header copy.
> > 
> > When the skb enters the second bridge, save_header() will save again the header
> > in nf_bridge->data. But I don't see how this can create a problem.
> > 
> > The problem I had before this patch comes from the fact that
> > nf_bridge_copy_header() is invoked in the second bridge with the nf_bridge state
> > of the first. This was overwriting my the packet Ethernet header with what the
> > first invocation of save_header() stored in nf_bridge->data.
> > 
> > But by unsetting nf_bridge I think I am preventing this from happening again.
> > no?
> 
> Hello Stephen,
> 
> do you have other comments about this patch? I know it is rather difficult that
> a generic user hits this issue, but I'd like to see it fixed because other
> people using batman-adv may incur in this problem.
> 
> Cheers,
> 
> 

The patch content is fine, but it needs necessary ifdef's.
I would also prefer to have the clean done as a function that can be stubbed out
like the other bridge netfilter stuff. 
