From: Basil Gor <basil.gor@gmail.com>
Subject: Re: [PATCH] macvlan/macvtap: Fix vlan tagging on user read
Date: Wed, 18 Apr 2012 23:33:12 +0400
Message-ID: <20120418193312.GA24516@nanobar>
References: <1334774098-22886-1-git-send-email-basilgor@gmail.com>
 <m1hawglvk3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:56089 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab2DRTdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 15:33:39 -0400
Received: by lbom4 with SMTP id m4so2506282lbo.19
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 12:33:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <m1hawglvk3.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 18, 2012 at 11:54:52AM -0700, Eric W. Biederman wrote:
> Basil Gor <basil.gor@gmail.com> writes:
> 
> > Vlan tag is restored during buffer transmit to a network device (bridge
> > port) in bridging code in case of tun/tap driver. In case of macvtap it
> > has to be done explicitly. Otherwise vlan_tci is ignored and user always
> > gets untagged packets.
> >
> > Scenario tested:
> > kvm guests (that use vlans) migration from bridged network to macvtap
> > revealed that packets delivered to guests are always untagged. Dumping
> > and comparing sk_buff in case of tap and macvtap driver showed that
> > macvtap does not restore vlan_tci.
> >
> > With current patch applied I was able to get working network, kvm guests
> > get correctly tagged packets and can reach each other when macvtap in
> > bridge mode (both with no vlans and through vlan interfaces).
> 
> My first impression is that this is the wrong place to add a vlan
> header back.
> 
> You need to keep the vlan information in vlan_tci until just
> before the packet is delivered to userspace. Which would suggest
> the best place for these games is macvtap_put_user.
> 
> Elsewhere vlan headers should not be explicitly stored in the packet.
> 
> At least that was the rule last I looked.
> 
> Eric
> 
> 
This sounds right, and macvtap_put_user was the first place where I
put vlan header adding. But qemu-kvm does smth like get pending data
size and then read, and when I put code in macvtap_put_user qemu
supplied buffer 4 bytes smaller then needed and packets were
truncated. On the other hand tun/tap driver never keeps vlan info in
vlan_tci because you can't do any vlan operations on it I think. So I
decided to restore vlan header just before adding it to macvtap queue.

But I'll try to look deeper in it.
Thanks
> > Signed-off-by: Basil Gor <basilgor@gmail.com>
> > ---
> >  drivers/net/macvtap.c |    9 +++++++++
> >  1 files changed, 9 insertions(+), 0 deletions(-)
> >
> > diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> > index 0427c65..a6802b9 100644
> > --- a/drivers/net/macvtap.c
> > +++ b/drivers/net/macvtap.c
> > @@ -1,6 +1,7 @@
> >  #include <linux/etherdevice.h>
> >  #include <linux/if_macvlan.h>
> >  #include <linux/interrupt.h>
> > +#include <linux/if_vlan.h>
> >  #include <linux/nsproxy.h>
> >  #include <linux/compat.h>
> >  #include <linux/if_tun.h>
> > @@ -254,6 +255,14 @@ static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
> >  	if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
> >  		goto drop;
> >  
> > +	if (vlan_tx_tag_present(skb)) {
> > +		skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
> > +		if (unlikely(!skb))
> > +			return NET_RX_DROP;
> > +
> > +		skb->vlan_tci = 0;
> > +	}
> > +
> >  	skb_queue_tail(&q->sk.sk_receive_queue, skb);
> >  	wake_up_interruptible_poll(sk_sleep(&q->sk), POLLIN | POLLRDNORM | POLLRDBAND);
> >  	return NET_RX_SUCCESS;
