From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [bug report] net: dsa: ksz: fix skb freeing
Date: Thu, 17 Aug 2017 00:27:19 +0300
Message-ID: <20170816212719.uyszb2krtgir3xn2@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34999 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752428AbdHPV17 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 17:27:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Vivien Didelot,

The patch e71cb9e00922: "net: dsa: ksz: fix skb freeing" from Aug 9,
2017, leads to the following static checker warning:

	net/dsa/tag_ksz.c:64 ksz_xmit()
	warn: 'nskb' was already freed.

net/dsa/tag_ksz.c
    35  static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
    36  {
    37          struct dsa_slave_priv *p = netdev_priv(dev);
    38          struct sk_buff *nskb;
    39          int padlen;
    40          u8 *tag;
    41  
    42          padlen = (skb->len >= ETH_ZLEN) ? 0 : ETH_ZLEN - skb->len;
    43  
    44          if (skb_tailroom(skb) >= padlen + KSZ_INGRESS_TAG_LEN) {
    45                  if (skb_put_padto(skb, skb->len + padlen))
    46                          return NULL;
    47  
    48                  nskb = skb;
    49          } else {
    50                  nskb = alloc_skb(NET_IP_ALIGN + skb->len +
    51                                   padlen + KSZ_INGRESS_TAG_LEN, GFP_ATOMIC);
    52                  if (!nskb)
    53                          return NULL;
    54                  skb_reserve(nskb, NET_IP_ALIGN);
    55  
    56                  skb_reset_mac_header(nskb);
    57                  skb_set_network_header(nskb,
    58                                         skb_network_header(skb) - skb->head);
    59                  skb_set_transport_header(nskb,
    60                                           skb_transport_header(skb) - skb->head);
    61                  skb_copy_and_csum_dev(skb, skb_put(nskb, skb->len));
    62  
    63                  if (skb_put_padto(nskb, nskb->len + padlen)) {
    64                          kfree_skb(nskb);
                                ^^^^^^^^^^^^^^
This patch deliberately adds a kfree_skb() here, but it looks like a
double free, and my static checker complains.  My guess is you had
intended to free "skb" instead of "nskb"?  I'm not positive.

    65                          return NULL;
    66                  }
    67  
    68                  kfree_skb(skb);
    69          }
    70  
    71          tag = skb_put(nskb, KSZ_INGRESS_TAG_LEN);
    72          tag[0] = 0;
    73          tag[1] = 1 << p->dp->index; /* destination port */
    74  
    75          return nskb;
    76  }

regards,
dan carpenter
