From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next] vxlan: distribute vxlan tunneled traffic
 across multiple TXQs
Date: Tue, 24 Dec 2013 12:27:19 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C26B3203B@CMEXMB1.ad.emulex.com>
References: <1387803413-22152-1-git-send-email-sathya.perla@emulex.com>
 <20131223112854.572b11aa@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"edumazet@google.com" <edumazet@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:1679 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab3LXM1U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 07:27:20 -0500
In-Reply-To: <20131223112854.572b11aa@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> 
> On Mon, 23 Dec 2013 18:26:53 +0530
> Sathya Perla <sathya.perla@emulex.com> wrote:
> 
> > The vxlan driver sets itself as the socket owner for all the TX flows
> > it encapsulates (using vxlan_set_owner()) and assigns it's own skb
> > destructor. This causes all tunneled traffic to land up on only one TXQ
> > as all encapsulated skbs refer to the vxlan socket and not the original
> > socket.  Also, the vxlan skb destructor breaks some functionality for
> > tunneled traffic like wmem accounting and as Eric D. mentioned, TCP
> > small queues and FQ/pacing packet scheduler too.
> >
> > This patch removes vxlan ownership on tunneled skbs. This causes
> > tunneled traffic to be hashed into multiple TXQs based on the original
> > socket hash.
> >
...
> > -
> >  /* Compute source port for outgoing packet
> >   *   first choice to use L4 flow hash since it will spread
> >   *     better and maybe available from hardware
> > @@ -1514,8 +1500,6 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
> >  	ip6h->daddr	  = *daddr;
> >  	ip6h->saddr	  = *saddr;
> >
> > -	vxlan_set_owner(vs->sock->sk, skb);
> > -
> >  	err = handle_offloads(skb);
> >  	if (err)
> >  		return err;
> > @@ -1572,8 +1556,6 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
> >  	uh->len = htons(skb->len);
> >  	uh->check = 0;
> >
> > -	vxlan_set_owner(vs->sock->sk, skb);
> > -
> >  	err = handle_offloads(skb);
> >  	if (err)
> >  		return err;
> > @@ -1836,8 +1818,10 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct
> net_device *dev)
> >  		struct sk_buff *skb1;
> >
> >  		skb1 = skb_clone(skb, GFP_ATOMIC);
> > -		if (skb1)
> > +		if (skb1) {
> > +			skb1->sk = skb->sk;
> >  			vxlan_xmit_one(skb1, dev, rdst, did_rsc);
> > +		}
> >  	}
> >
> >  	dev_kfree_skb(skb);
> 
> The idea is good, but without the destructor there is nothing to keep
> the UDP socket from being destroyed while packet is being sent on another
> CPU.

Stephen, what is the consequence of freeing the UDP socket while a tunneled
skb is still in flight on another CPU? Wouldn't it be safe if the skb did not refer to the
vxlan socket at all?
