From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net] r8152: drop the tx packet with invalid length
Date: Fri, 19 Dec 2014 06:42:14 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2ED585A@RTITMBSV03.realtek.com.tw>
References: <1417020748.29427.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141126.120658.498602780456343676.davem@davemloft.net>
	<1417027459.29427.63.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141126.153356.461494573591656082.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141126.153356.461494573591656082.davem@davemloft.net>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Thursday, November 27, 2014 4:34 AM
[...]
> >> > Looks like a candidate for ndo_gso_check(), so that we do not drop, but
> >> > instead segment from netif_needs_gso()/validate_xmit_skb()
> >> 
> >> You mean have the bridge implement the ndo_gso_check() method right?
> > 
> > No, I meant this particular driver.
> > 
> > Note that netif_skb_features() does only this check :
> > 
> > if (gso_segs > dev->gso_max_segs || gso_segs < dev->gso_min_segs)
> >       features &= ~NETIF_F_GSO_MASK;
> > 
> > Ie not testing gso_max_size
> > 
> > It looks like all these particular tests should be moved on
> > ndo_gso_check(), to remove code from netif_skb_features()
> 
> A check against gso_max_size is generic enough that it ought to be put
> right into netif_needs_gso() rather then duplicating it into every
> driver's ndo_gso_check() method don't you think?

Excuse me. I try to implement ndo_gso_check() with kernel 3.18.
However, I still get packets with gso and their skb lengths are more
than the acceptable one. Do I miss something?

+static bool rtl8152_gso_check(struct sk_buff *skb, struct net_device *dev)
+{
+	if ((skb->len + sizeof(struct tx_desc)) > agg_buf_sz)
+		return false;
+
+	return true;
+}
 
@@ -5861,6 +5876,9 @@ static const struct net_device_ops rtl8152_netdev_ops = {
 	.ndo_set_mac_address	= rtl8152_set_mac_address,
 	.ndo_change_mtu		= rtl8152_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_gso_check		= rtl8152_gso_check,
 };

Best Regards,
Hayes
