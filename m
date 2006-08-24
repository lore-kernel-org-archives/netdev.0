From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFC] make d80211 use nl80211
Date: Thu, 24 Aug 2006 19:09:34 +0200
Message-ID: <200608241909.35065.mb@bu3sch.de>
References: <1156254813.3825.2.camel@ux156> <1156435657.10283.10.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49066
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030394AbWHXRKx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 13:10:53 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1156435657.10283.10.camel@ux156>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 24 August 2006 18:07, Johannes Berg wrote:
> new version of this one too...
> --
> Subject: d80211: use nl80211
> 
> This patch makes d80211 partially configurable using the
> infrastructure that nl80211 provides. So far, it allows
> packet injection and adding/removing virtual interfaces.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> 


> +static int ieee80211_inject(void *priv, void *frame, int framelen, u32 flags,
> +			    int queue)
> +{
> +	struct ieee80211_local *local = priv;
> +	struct ieee80211_tx_packet_data *pkt_data;
> +	struct sk_buff *pkt;
> +	void *pktdata;
> +
> +	pkt = alloc_skb(framelen, GFP_KERNEL);

if (!pkt)
	return -ENOMEM;

> +	pktdata = skb_put(pkt, framelen);
> +	memcpy(pktdata, frame, framelen);

having two variables with almost the same name seems
confusing to me. What about removing void *pktdata; and
doing the following instead of the two lines above?

memcpy(skb_put(pkt, framelen), frame, framelen);

That is also how it's done in lots of other networking code.

> +	pkt_data = (struct ieee80211_tx_packet_data *) pkt->cb;
> +	pkt_data->ifindex = local->mdev->ifindex;
> +	pkt_data->internal_flags = TX_FLAG_INJECTED;
> +	pkt_data->flags = flags;
> +	/* FIXME: never used, I think? Or could be invalid? */
> +	pkt_data->queue = queue;
> +
> +	/* FIXME */
> +	pkt->priority = 20; /* use hardcoded priority for mgmt TX queue */
> +
> +	pkt->dev = local->mdev;
> +	dev_queue_xmit(pkt);
> +
> +	return 0;
> +}

The other code looks fine to me (the add nl80211 patch, too).

-- 
Greetings Michael.
