From: Dave Dillow <dave@thedillows.org>
Subject: Re: [PATCH] deinline a few large functions in vlan code v2
Date: Tue, 11 Apr 2006 09:59:44 -0400
Message-ID: <1144763984.16193.9.camel@dillow.idleaire.com>
References: <200604071628.30486.vda@ilport.com.ua>
	 <200604101716.58463.vda@ilport.com.ua>
	 <1144682807.12177.22.camel@dillow.idleaire.com>
	 <200604111028.54813.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751005AbWDKN7w@vger.kernel.org>
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <200604111028.54813.vda@ilport.com.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-04-11 at 10:28 +0300, Denis Vlasenko wrote:
> > > > > block? For example, typhoon.c:
> > > > > 
> > > > >                 spin_lock(&tp->state_lock);
> > > > > +#if defined(CONFIG_VLAN_8021Q) || defined (CONFIG_VLAN_8021Q_MODULE)
> > > > >                 if(tp->vlgrp != NULL && rx->rxStatus & TYPHOON_RX_VLAN)
> > > > >                         vlan_hwaccel_receive_skb(new_skb, tp->vlgrp,
> > > > >                                                  ntohl(rx->vlanTag) & 0xffff);
> > > > >                 else
> > > > > +#endif
> > > > >                         netif_receive_skb(new_skb);
> > > > >                 spin_unlock(&tp->state_lock);
> > > > > 
> > > > > Same for s2io.c, chelsio/sge.c, etc...
> > > > 
> > > > Very likely yes.  tp->vlgrp will never be non-NULL in such situations
> > > > so it's not a correctness issue, but rather an optimization :-)
> > 
> > I see this as a minor optimization, at the cost uglifying the body of a
> > function.
> 
> But it saves some text (~5k total in all network drivers)
> and removes a branch on rx path on non-VLAN enabled kernels...

DaveM beat me to it, but as he said, it saves 5K only if you have all
the drivers built in or loaded. And even if it saves 200 bytes in one
module, unless that module text was already less than 200 bytes into a
page, you've saved no memory -- a 4300 byte module takes 2 pages on x86,
as does a 4100 byte module.

The only savings is in instruction cache, and it would be better to
perhaps uninline vlan_hwaccel_receive_skb() or __vlan_hwaccel_rx() and
make vlan_tx_tag_present be

#if defined(CONFIG_VLAN_8021Q) || defined (CONFIG_VLAN_8021Q_MODULE)
#define vlan_tx_tag_present(__skb) \
        (VLAN_TX_SKB_CB(__skb)->magic == VLAN_TX_COOKIE_MAGIC)
#else
#define vlan_tx_tag_present(x) 	0
#endif

to get the cache savings on the hot paths without the ugliness.

> > Besides, if you're going to do this, you can get rid of the 
> > spin_lock functions around it to, since they only protect tp->vlgrp in
> > this instance.
> 
> Done.
> 
> > Please don't apply this to typhoon.c
> 
> Please comment on the below patch fragment, is it ok with you?

NAK. The #ifdefs are ugly, for no significant gain.

And you introduced a race condition when you moved the spin_locks. The
test for tp->vlgrp is no longer protected.
-- 
Dave Dillow <dave@thedillows.org>
