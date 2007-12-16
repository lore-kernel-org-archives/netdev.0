From: "Ron Rindjunsky" <rindjon@googlemail.com>
Subject: Re: [RFC] mac80211: clean up frame receive handling
Date: Sun, 16 Dec 2007 11:28:37 +0200
Message-ID: <c85cb4470712160128t7ef525f3md56d05f5990eb81@mail.gmail.com>
References: <1197483844.6558.158.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Michael Wu" <flamingice@sourmilk.net>,
	"Tomas Winkler" <tomasw@gmail.com>, "Jouni Malinen" <j@w1.fi>
To: "Johannes Berg" <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:18137 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755519AbXLPJ2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 04:28:38 -0500
Received: by fk-out-0910.google.com with SMTP id z23so791672fkz.5
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2007 01:28:37 -0800 (PST)
In-Reply-To: <1197483844.6558.158.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -1150,14 +1148,27 @@ ieee80211_deliver_skb(struct ieee80211_t

> -       if (local->bridge_packets && (sdata->type == IEEE80211_IF_TYPE_AP
> -           || sdata->type == IEEE80211_IF_TYPE_VLAN) &&
> +       dst = skb->data;
> +
> +       if (compare_ether_addr(dev->dev_addr, dst) == 0)
> +               skb->pkt_type = PACKET_HOST;
> +       else if (is_multicast_ether_addr(dst)) {
> +               if (is_broadcast_ether_addr(dst))
> +                       skb->pkt_type = PACKET_BROADCAST;
> +               else
> +                       skb->pkt_type = PACKET_MULTICAST;
> +       } else
> +               skb->pkt_type = PACKET_OTHERHOST;
> +
> +       if (local->bridge_packets && (sdata->type == IEEE80211_IF_TYPE_AP ||
> +                                     sdata->type == IEEE80211_IF_TYPE_VLAN) &&

i may miss something, but wouldn't you prefer to use eth_type_trans
here and just add compare_ether_addr check after it?

> @@ -1186,16 +1197,18 @@ ieee80211_deliver_skb(struct ieee80211_t
>
>        if (skb) {
>                /* deliver to local stack */
> -               skb->protocol = eth_type_trans(skb, dev);
>                memset(skb->cb, 0, sizeof(skb->cb));
> +               skb->dev = dev;
> +               skb_reset_mac_header(skb);
> +               skb_pull(skb, ETH_HLEN);
>                netif_rx(skb);
>        }
>
