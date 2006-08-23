From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [patch 5/5] d80211: add ioctl to stop data frame tx
Date: Wed, 23 Aug 2006 12:20:16 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F0165B5C1@dhost002-46.dex002.intermedia.net>
References: <1156317906.3629.18.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jiri Benc" <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:36227 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932293AbWHWTUF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:20:05 -0400
Content-class: urn:content-classes:message
in-reply-to: <1156317906.3629.18.camel@ux156>
To: "Johannes Berg" <johannes@sipsolutions.net>,
	"David Kimdon" <dwhedon@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David - how long does the data flow need to be stopped when radar is
detected? If it's a short time it would be better to buffer the data
frames, if the connection can be disabled for a long time then dropping
them might be better.

There is one other application where data frames should be buffered - in
a client while roaming between 2 APs. The best way to implement this
will be to extend the 802.11 qdisc. Currently there are 4 queues,
representing the 4 EDCA access categories. Only the top AC (AC_VO) is
used for sending management frames. I would recommend we split the
qdisc, so that there are 2 software queues attached to this AC - one for
management frames and 802.1x, and another for data frames. This way if
we want to stop data (either for radar, or because we are mid BSS
transition) we can simply stop all the queues except the AC_VO
management queue.

Simon


-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Johannes Berg
Sent: Wednesday, August 23, 2006 12:25 AM
To: David Kimdon
Cc: netdev@vger.kernel.org; John W. Linville; Jiri Benc
Subject: Re: [patch 5/5] d80211: add ioctl to stop data frame tx

On Tue, 2006-08-22 at 10:34 -0700, David Kimdon wrote:

> This ioctl is used when radar is delected on a channel.  Data frames 
> must stop but management frames must be allowed to continue for some 
> time to communicate the channel switch to stations.

Which does lead to the question: How are you detecting radar in
userspace in the first place??

> +       if (unlikely(local->stop_data_frame_tx)) {
> +               struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)
skb->data;
> +               u16 fc = le16_to_cpu(hdr->frame_control);
> +               if ((fc & IEEE80211_FCTL_FTYPE) ==
IEEE80211_FTYPE_DATA) {
> +                       dev_kfree_skb(skb);
> +                       return 0;
> +               }
> +       }

Should that really drop dataframes dead on the floor? And wouldn't it
make sense stop the networking layer from injecting more data into the
stack when stop_data_frame_tx is enabled?

> +static int ieee80211_ioctl_set_stop_data_frame_tx(struct net_device
*dev,
> +                                                 int val) {
> +	struct ieee80211_local *local = dev->ieee80211_ptr;
> +        local->stop_data_frame_tx = val;
> +        return 0;
> +}

Again, whitespace damaged. Yes, I know it's hard to code in there with
any smart editor that thinks it knows what to do based on the
surroundings because those may also contain whitespace...


> +                ret = ieee80211_ioctl_set_stop_data_frame_tx(dev, 
> + value);

Ditto.

johannes
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
