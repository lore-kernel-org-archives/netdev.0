From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Re: [PATCH net-next 2/2] mac802154: don't deliver packets to
 devices that are down
Date: Tue, 10 Jun 2014 17:32:26 +0200
Message-ID: <20140610173226.4ddf9e80@zoidberg>
References: <1402412922-14180-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<1402412922-14180-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<1402413961.3645.432.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:45803 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbaFJPct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 11:32:49 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.4/8.14.4/Debian-7) with ESMTP id s5AFWfAK003367
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 17:32:42 +0200
In-Reply-To: <1402413961.3645.432.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jun 2014 08:26:01 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2014-06-10 at 17:08 +0200, Phoebe Buckheister wrote:
> > Only one WPAN devices can be active at any given time, so only
> > deliver packets to that one interface that is actually up.
> > 
> > Signed-off-by: Phoebe Buckheister
> > <phoebe.buckheister@itwm.fraunhofer.de> ---
> >  net/mac802154/wpan.c |   12 +++++++-----
> >  1 file changed, 7 insertions(+), 5 deletions(-)
> > 
> > diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
> > index c8cfd54..1ba648e 100644
> > --- a/net/mac802154/wpan.c
> > +++ b/net/mac802154/wpan.c
> > @@ -567,7 +567,6 @@ static int mac802154_parse_frame_start(struct
> > sk_buff *skb, void mac802154_wpans_rx(struct mac802154_priv *priv,
> > struct sk_buff *skb) {
> >  	int ret;
> > -	struct sk_buff *sskb;
> >  	struct mac802154_sub_if_data *sdata;
> >  	struct ieee802154_hdr hdr;
> >  
> > @@ -579,12 +578,15 @@ void mac802154_wpans_rx(struct mac802154_priv
> > *priv, struct sk_buff *skb) 
> >  	rcu_read_lock();
> >  	list_for_each_entry_rcu(sdata, &priv->slaves, list) {
> > -		if (sdata->type != IEEE802154_DEV_WPAN)
> > +		if (sdata->type != IEEE802154_DEV_WPAN ||
> > +		    !netif_running(sdata->dev))
> >  			continue;
> >  
> > -		sskb = skb_clone(skb, GFP_ATOMIC);
> > -		if (sskb)
> > -			mac802154_subif_frame(sdata, sskb, &hdr);
> > +		skb = skb_clone(skb, GFP_ATOMIC);
> > +		if (skb)
> > +			mac802154_subif_frame(sdata, skb, &hdr);
> > +
> > +		break;
> >  	}
> >  	rcu_read_unlock();
> >  }
> 
> If this is really the case, do not clone the skb, and fix
> mac802154_subif_rx().
> 
> (mac802154_wpans_rx() would always consume the skb)

That's also possible, I guess. mac802154_wpans_rx is the last call,
after all, and I didn't want to muck with that part of the stack too
much (it's already convoluted and not entirely clear). Monitor devices
will still have to clone their skb though - and they as well could
benefit from not queueing packets to inactive devices.

I'll change and resend.
