From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [PATCH] tg3: Work around HW/FW limitations with vlan
 encapsulated frames
Date: Fri, 19 Sep 2014 13:54:53 -0700
Message-ID: <1411160093.6401.30.camel@prashant>
References: <1411050677-28147-1-git-send-email-vyasevic@redhat.com>
	 <1411081221.18724.84.camel@prashant>  <541C36CC.60405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevich@gmail.com>, <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:9876 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757837AbaISVPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:15:37 -0400
In-Reply-To: <541C36CC.60405@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 09:59 -0400, Vlad Yasevich wrote:
> On 09/18/2014 07:00 PM, Prashant Sreedharan wrote:
> > On Thu, 2014-09-18 at 10:31 -0400, Vladislav Yasevich wrote:
> >> TG3 appears to have an issue performing TSO and checksum offloading
> >> correclty when the frame has been vlan encapsulated (non-accelrated).
> >> In these cases, tcp checksum is not correctly updated.
> > 
> > Yes that is true for inline vlan headers, to clarify was TSO and
> > checksum offload working for accelerated 802.1ad packets ? 
> 
> We don't accelerate 802.1ad if the driver doesn't claim offload support.
> If I had to guess, the TSO would probably work, but the packet would
> be encapsulated as 802.1Q by the FW/HW and connection would fail.
> 
In your initial mail you mentioned when you strip the vlan header and
set vlan_tci it worked for you. But as you guessed it will not, as the
chip does not support 802.1AD. Thanks for clarifying.

> > 
> >> This patch attempts to work around this issue.  After the patch,
> >> 802.1ad vlans start working correctly over tg3 devices.
> >>
> >> CC: Prashant Sreedharan <prashant@broadcom.com>
> >> CC: Michael Chan <mchan@broadcom.com>
> >> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> >> ---
> >>  drivers/net/ethernet/broadcom/tg3.c | 20 ++++++++++++++++++--
> >>  1 file changed, 18 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> >> index cb77ae9..e7d3a62 100644
> >> --- a/drivers/net/ethernet/broadcom/tg3.c
> >> +++ b/drivers/net/ethernet/broadcom/tg3.c
> >> @@ -7914,8 +7914,6 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >>  
> >>  	entry = tnapi->tx_prod;
> >>  	base_flags = 0;
> >> -	if (skb->ip_summed == CHECKSUM_PARTIAL)
> >> -		base_flags |= TXD_FLAG_TCPUDP_CSUM;

Check comment below
> >>  
> >>  	mss = skb_shinfo(skb)->gso_size;
> >>  	if (mss) {
> >> @@ -7929,6 +7927,13 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >>  
> >>  		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb) - ETH_HLEN;
> >>  
> >> +		/* HW/FW can not correctly segment packets that have been
> >> +		 * vlan encapsulated.
> >> +		 */
> >> +		if (skb->protocol == htons(ETH_P_8021Q) ||
> >> +		    skb->protocol == htons(ETH_P_8021AD))
> >> +			return tg3_tso_bug(tp, tnapi, txq, skb);
> > 
> > I think skb_gso_segment() would return skbs that would still have
> > checksum offloaded to the chip.
> 
> Doesn't appear to.  If I don't do this, then netperf throughput drops
> to 45.75 Mbps.  If I put the above back in, the throughput goes to to 940Mbps.
> 

Two things either the skb is having the "encap_hdr_csum" set forcing
skb_segment() to do the checksum calculation OR the second workaround
"skb_checksum_help" below will do the checksum for the list of skbs
returned by skb_gso_segment(). 

Also you can move the above workaround further up after skb_cow_head()
succeeds.

> >  
> >> +
> >>  		if (!skb_is_gso_v6(skb)) {
> >>  			if (unlikely((ETH_HLEN + hdr_len) > 80) &&
> >>  			    tg3_flag(tp, TSO_BUG))
> >> @@ -7979,6 +7984,17 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >>  				base_flags |= tsflags << 12;
> >>  			}
> >>  		}
> >> +	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
> >> +		/* HW/FW can not correctly checksum packets that have been
> >> +		 * vlan encapsulated.
> >> +		 */
> >> +		if (skb->protocol == htons(ETH_P_8021Q) ||
> >> +		    skb->protocol == htons(ETH_P_8021AD)) {
> >> +			if (skb_checksum_help(skb))
> >> +				goto drop;
> >> +		} else  {
> >> +			base_flags |= TXD_FLAG_TCPUDP_CSUM;
> >> +		}

tg3 supports various family of chips (around 20+ )I need to check if LSO
offload is ok without setting TXD_FLAG_TCPUDP_CSUM for all of them and
some of these chips are pretty old too, so instead you can clear the
TXD_FLAG_TCPUDP_CSUM flag if skb_checksum_help() succeeds and leave the
initial setting of base_flags as it is thus avoiding any regressions.

> >>  	}
> >>  
> >>  	if (tg3_flag(tp, USE_JUMBO_BDFLAG) &&
> > 
> > Instead of the above workarounds since the chips supported by tg3 does
> > not support checksum offload and TSO for inline vlan headers, these
> > features can be disabled/cleared in dev->vlan_features. Side effect is
> > accelerated vlan headers will also have TSO and checksum offload
> > disabled.
> 
> I didn't want to impact normal accelerated usage.  The non-accelerated
> case is rather rare especially since tg3 driver doesn't allow you to
> turn off vlan acceleration.  One has to put a software device between
> tg3 and vlan that allow you to turn off vlan acceleration (ex: bridge)
> and turn off acceleration on the bridge to get this to happen for 802.1Q
> vlans.  People don't normally turn off vlan acceleration though as evidenced
> by this bug (and issues in other drivers) being around for a _very_ long time.
> 

Ok, since this is rare we can go with the workaround
> > 
> > Also as part of this review, found a problem with the receive section of
> > the driver it was not checking for 802.1ad vlan protocol and dropping
> > 802.1ad vlan packets of size > mtu + ETH_HLEN
> 
> Good catch.  I should have run the TCP_MAERTS test.  :)
> 
> I'll update the patch with the below hunk and resubmit if we can agree
> on using the tg3_tso_bug workaround.

yes please include. thanks.
> 
> -vlad
> 
> > 
> > diff --git a/drivers/net/ethernet/broadcom/tg3.c
> > b/drivers/net/ethernet/broadcom/tg3.c
> > index cb77ae9..620887a 100644
> > --- a/drivers/net/ethernet/broadcom/tg3.c
> > +++ b/drivers/net/ethernet/broadcom/tg3.c
> > @@ -6918,7 +6918,8 @@ static int tg3_rx(struct tg3_napi *tnapi, int
> > budget)
> >                 skb->protocol = eth_type_trans(skb, tp->dev);
> >  
> >                 if (len > (tp->dev->mtu + ETH_HLEN) &&
> > -                   skb->protocol != htons(ETH_P_8021Q)) {
> > +                   skb->protocol != htons(ETH_P_8021Q) &&
> > +                   skb->protocol != htons(ETH_P_8021AD)) {
> >                         dev_kfree_skb_any(skb);
> >                         goto drop_it_no_recycle;
> >                 }
> > 
> > 
> 
