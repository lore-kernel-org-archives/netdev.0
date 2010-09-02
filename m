From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 2 Sep 2010 21:39:12 +0900
Message-ID: <000a01cb4a9b$e8d6ab00$66f8800a@maildom.okisemi.com>
References: <4C763A67.5040107@dsn.okisemi.com> <4C7D0E7A.5060309@dsn.okisemi.com> <1283266263.2550.106.camel@edumazet-laptop>
Cc: "Stephen Hemminger" <shemminger@vyatta.com>,
	"Sam Ravnborg" <sam@ravnborg.org>, "Joe Perches" <joe@perches.com>,
	"LKML" <linux-kernel@vger.kernel.org>,
	"ML netdev" <netdev@vger.kernel.org>,
	"Greg Rose" <gregory.v.rose@intel.com>,
	"Maxime Bizon" <mbizon@freebox.fr>,
	"Kristoffer Glembo" <kristoffer@gaisler.com>,
	"Ralf Baechle" <ralf@linux-mips.org>,
	"John Linn" <john.linn@xilinx.com>,
	"Randy Dunlap" <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	"MeeGo" <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>,
	"Intel OTC" <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	"Toshiharu Okada" <okada533@dsn.okisemi.com>,
	"Tomoya Morinaga" <morinaga526@dsn.okisemi.com>,
	"Takahiro Shimizu" <shimizu394@dsn.okisemi.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:8274 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750799Ab0IBMjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 08:39:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric

Thank you for your comments.

> I find hard to believe this driver needs to copy all outgoing frames on
> pre-allocated skbs.
>
> +       /* [Header:14][payload] ---> [Header:14][paddong:2][payload]    */
> +       memcpy(tmp_skb->data, skb->data, ETH_HLEN);
> +       tmp_skb->data[ETH_HLEN] = 0x00;
> +       tmp_skb->data[ETH_HLEN + 1] = 0x00;
> +       tmp_skb->len = skb->len;
> +       memcpy(&tmp_skb->data[ETH_HLEN + 2], &skb->data[ETH_HLEN],
> +              (skb->len - ETH_HLEN));
> +       buffer_info->kernel_skb = skb;
> +       skb = tmp_skb;
>
> Whats the deal here please ?

This processing depends on hardware specification.

At the time of transmission.
Hardware accepts a packet in the following format.
  [Header: 14octet] + [padding: 2octet] + [payload]
  Also, it is necessary to align the head of a [Header: 14octet] at 64byte.

In my knowledge, SKB received by kernel are the following format.
  [padding: 2octet] + [Header:14octet] + [payload]
  Also, The head of [payload] has aligned at 16 byte.

So, it has adjusted with the format of hardware by a copy.

Thanks, Ohtake(OKISemi)
----- Original Message ----- 
From: "Eric Dumazet" <eric.dumazet@gmail.com>
To: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Cc: "Stephen Hemminger" <shemminger@vyatta.com>; "Sam Ravnborg" <sam@ravnborg.org>; "Joe Perches" <joe@perches.com>;
"LKML" <linux-kernel@vger.kernel.org>; "ML netdev" <netdev@vger.kernel.org>; "Greg Rose" <gregory.v.rose@intel.com>;
"Maxime Bizon" <mbizon@freebox.fr>; "Kristoffer Glembo" <kristoffer@gaisler.com>; "Ralf Baechle" <ralf@linux-mips.org>;
"John Linn" <john.linn@xilinx.com>; "Randy Dunlap" <randy.dunlap@oracle.com>; "David S. Miller" <davem@davemloft.net>;
"MeeGo" <meego-dev@meego.com>; "Wang, Qi" <qi.wang@intel.com>; "Wang, Yong Y" <yong.y.wang@intel.com>; "Andrew"
<andrew.chih.howe.khor@intel.com>; "Intel OTC" <joel.clark@intel.com>; "Foster, Margie" <margie.foster@intel.com>;
"Toshiharu Okada" <okada533@dsn.okisemi.com>; "Tomoya Morinaga" <morinaga526@dsn.okisemi.com>; "Takahiro Shimizu"
<shimizu394@dsn.okisemi.com>
Sent: Tuesday, August 31, 2010 11:51 PM
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH


> Le mardi 31 aout 2010 a 23:15 +0900, Masayuki Ohtake a ecrit :
> > Hi Sam, Joe and Stephen
> >
> > Thank you for your comments.
> > We have modified this driver for your comment.
> >
> > ---
> > Gigabit Ethernet driver of Topcliff PCH
>
> > + skb->protocol = eth_type_trans(skb, netdev);
> > + if ((tcp_ip_status & PCH_GBE_RXD_ACC_STAT_TCPIPOK) ==
> > +     PCH_GBE_RXD_ACC_STAT_TCPIPOK) {
> > + skb->ip_summed = CHECKSUM_UNNECESSARY;
> > + } else {
> > + skb->ip_summed = CHECKSUM_NONE;
> > + }
> > +
> > + if (netif_receive_skb(skb) == NET_RX_DROP) {
> > + adapter->stats.rx_dropped++;
>
> dont use pr_err() here, dropping a frame is a normal condition.
>
> > + pr_err("Receive Netif Receive Dropped Error\n");
> > + }
> > + (*work_done)++;
> > + netdev->last_rx = jiffies;
>
> really ? last_rx is a thing of the past.
>
> > + pr_debug
> > +     ("Receive skb->ip_summed: %d length: %d\n",
> > +      skb->ip_summed, length);
> > + }
> > +dorrop:
> > + /* return some buffers to hardware, one at a time is too slow */
> > + if (unlikely(cleaned_count >= PCH_GBE_RX_BUFFER_WRITE)) {
> > + pch_gbe_alloc_rx_buffers(adapter, rx_ring,
> > + cleaned_count);
> > + cleaned_count = 0;
> > + }
> > + if (++i == rx_ring->count)
> > + i = 0;
> > + }
> > + rx_ring->next_to_clean = i;
> > + if (cleaned_count)
> > + pch_gbe_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
> > + return cleaned;
> > +}
> > +
>
>
>
> I find hard to believe this driver needs to copy all outgoing frames on
> pre-allocated skbs.
>
> +       /* [Header:14][payload] ---> [Header:14][paddong:2][payload]    */
> +       memcpy(tmp_skb->data, skb->data, ETH_HLEN);
> +       tmp_skb->data[ETH_HLEN] = 0x00;
> +       tmp_skb->data[ETH_HLEN + 1] = 0x00;
> +       tmp_skb->len = skb->len;
> +       memcpy(&tmp_skb->data[ETH_HLEN + 2], &skb->data[ETH_HLEN],
> +              (skb->len - ETH_HLEN));
> +       buffer_info->kernel_skb = skb;
> +       skb = tmp_skb;
>
> Whats the deal here please ?
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


