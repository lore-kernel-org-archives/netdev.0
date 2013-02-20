From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs
 copies out
Date: Wed, 20 Feb 2013 08:55:31 -0800
Message-ID: <1361379331.19353.189.camel@edumazet-glaptop>
References: <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
	 <1334030180.13293.98.camel@edumazet-glaptop>
	 <20120410051127.GA32048@merlins.org>
	 <1334038263.2907.1.camel@edumazet-glaptop>
	 <20120411052733.GA17352@merlins.org> <20120715215935.GF24420@merlins.org>
	 <1342419529.3265.12217.camel@edumazet-glaptop>
	 <20120716151826.GA10586@merlins.org>
	 <1342455717.2830.14.camel@edumazet-glaptop>
	 <20130219040557.GB4778@merlins.org>
	 <1361251033.19353.120.camel@edumazet-glaptop>
	 (sfid-20130219_061917_530878_1ED7A14C) <1361268221.8553.1.camel@jlt4.sipsolutions.net>
	 <1361290909.19353.140.camel@edumazet-glaptop>
	 (sfid-20130219_172155_748777_C3ED0F5E) <1361351538.8629.3.camel@jlt4.sipsolutions.net>
	 (sfid-20130220_101252_930264_DBD3955C) <1361351703.8629.5.camel@jlt4.sipsolutions.net>
	 <1361373064.19353.180.camel@edumazet-glaptop>
	 (sfid-20130220_161110_395796_DBAC0744) <1361377243.8629.34.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1361377243.8629.34.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-02-20 at 17:20 +0100, Johannes Berg wrote:
> On Wed, 2013-02-20 at 07:11 -0800, Eric Dumazet wrote:
> > On Wed, 2013-02-20 at 10:15 +0100, Johannes Berg wrote:
> > 
> > > OTOH, this affects the protocol, and when you really can't allocate any
> > > order-1 pages you pointed out yourself that many other things also won't
> > > work, so I'm not really sure it makes a big difference if we change the
> > > driver?
> > 
> > It will make a huge difference, even on non pressure mode, as TCP
> > receive window will grow twice faster.
> 
> Hmm, why does that depend on the allocation size?

I guess you missed all the patches about skb->truesize on netdev

> 
> > Unless wifi speed reaches 10Gbps, following patch should do the trick
> > 
> > 
> > diff --git a/drivers/net/wireless/iwlwifi/dvm/rx.c b/drivers/net/wireless/iwlwifi/dvm/rx.c
> > index a4eed20..77a3ee3 100644
> > --- a/drivers/net/wireless/iwlwifi/dvm/rx.c
> > +++ b/drivers/net/wireless/iwlwifi/dvm/rx.c
> > @@ -750,7 +750,12 @@ static void iwlagn_pass_packet_to_mac80211(struct iwl_priv *priv,
> >  	/* Dont use dev_alloc_skb(), we'll have enough headroom once
> >  	 * ieee80211_hdr pulled.
> >  	 */
> > -	skb = alloc_skb(128, GFP_ATOMIC);
> > +	fraglen = 128;
> > +	/* if we use order-1 pages, copy to get better TCP performance */
> > +	if (rxb->truesize > PAGE_SIZE)
> > +		fraglen = max_t(unsigned, fraglen, len);
> > +
> > +	skb = alloc_skb(fraglen, GFP_ATOMIC);
> 
> Hmm, I don't quite understand -- that's not doing any copy?
> 
> FWIW if you do the copy you should not "steal" the pages, then they'd be
> recycled in the RX ring right away.

Code should just works, please read the following lines in the same
function....

        /* If frame is small enough to fit in skb->head, pull it completely.
         * If not, only pull ieee80211_hdr so that splice() or TCP coalesce
         * are more efficient.
         */
        hdrlen = (len <= skb_tailroom(skb)) ? len : sizeof(*hdr);

        memcpy(skb_put(skb, hdrlen), hdr, hdrlen);
        fraglen = len - hdrlen;

        if (fraglen) {
                int offset = (void *)hdr + hdrlen -
                             rxb_addr(rxb) + rxb_offset(rxb);

                skb_add_rx_frag(skb, 0, rxb_steal_page(rxb), offset,
                                fraglen, rxb->truesize);
        }



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
