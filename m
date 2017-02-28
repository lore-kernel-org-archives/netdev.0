From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [bug report] dp83640: Delay scheduled work.
Date: Tue, 28 Feb 2017 09:36:12 +0300
Message-ID: <20170228063612.GA25830@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: stefan.sorensen@spectralink.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:41606 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751713AbdB1Grw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 01:47:52 -0500
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
        by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v1S6bT69008624
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 06:37:29 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stefan Sørensen,

The patch 4b063258ab93: "dp83640: Delay scheduled work." from Nov 3,
2015, leads to the following static checker warning:

	drivers/net/phy/dp83640.c:1442 dp83640_rxtstamp()
	warn: 'skb' was already freed.

drivers/net/phy/dp83640.c
  1402          struct dp83640_skb_info *skb_info = (struct dp83640_skb_info *)skb->cb;
  1403          struct list_head *this, *next;
  1404          struct rxts *rxts;
  1405          struct skb_shared_hwtstamps *shhwtstamps = NULL;
                                             ^^^^^^^^^^^^^^^^^^
  1406          unsigned long flags;
  1407  
  1408          if (is_status_frame(skb, type)) {
  1409                  decode_status_frame(dp83640, skb);
  1410                  kfree_skb(skb);
  1411                  return true;
  1412          }
  1413  
  1414          if (!dp83640->hwts_rx_en)
  1415                  return false;
  1416  
  1417          if ((type & dp83640->version) == 0 || (type & dp83640->layer) == 0)
  1418                  return false;
  1419  
  1420          spin_lock_irqsave(&dp83640->rx_lock, flags);
  1421          prune_rx_ts(dp83640);
  1422          list_for_each_safe(this, next, &dp83640->rxts) {
  1423                  rxts = list_entry(this, struct rxts, list);
  1424                  if (match(skb, type, rxts)) {
  1425                          shhwtstamps = skb_hwtstamps(skb);
  1426                          memset(shhwtstamps, 0, sizeof(*shhwtstamps));
  1427                          shhwtstamps->hwtstamp = ns_to_ktime(rxts->ns);
  1428                          netif_rx_ni(skb);
                                ^^^^^^^^^^^^^^^
If shhwtstamps is non-NULL then we call netif_rx_ni(skb);.  If this
call returns NET_RX_DROP then that means we've done a kfree_skb(skb).

  1429                          list_del_init(&rxts->list);
  1430                          list_add(&rxts->list, &dp83640->rxpool);
  1431                          break;
  1432                  }
  1433          }
  1434          spin_unlock_irqrestore(&dp83640->rx_lock, flags);
  1435  
  1436          if (!shhwtstamps) {
  1437                  skb_info->ptp_type = type;
  1438                  skb_info->tmo = jiffies + SKB_TIMESTAMP_TIMEOUT;
  1439                  skb_queue_tail(&dp83640->rx_queue, skb);
  1440                  schedule_delayed_work(&dp83640->ts_work, SKB_TIMESTAMP_TIMEOUT);
  1441          } else {
  1442                  netif_rx_ni(skb);


And then we call it a second time outside the spinlock.  When I look at
the commit which added this, it feels like something that was added by
mistake.  But I'm really familiar enough with this code to say if I
haven't missed something.

  1443          }
  1444  
  1445          return true;
  1446  }

regards,
dan carpenter
