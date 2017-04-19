From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] dp83640: don't recieve time stamps twice
Date: Wed, 19 Apr 2017 12:31:35 +0200
Message-ID: <20170419103135.GA1670@localhost.localdomain>
References: <20170418191426.GA17838@mwanda>
 <1492593414.3108.1.camel@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: =?iso-8859-1?B?U/hyZW5zZW4s?= Stefan
        <Stefan.Sorensen@spectralink.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1492593414.3108.1.camel@spectralink.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 19, 2017 at 09:16:56AM +0000, Sørensen, Stefan wrote:
> You are correct that these lines was added accidentally.

Can we please fix this in another way?  There is no need to hold the
spin lock during the callback into the networking stack.  Instead, how
about the following diff, which also fixes the other call site...

Thanks,
Richard

---
diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index e2460a5..593e533 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -874,14 +874,15 @@ static void decode_rxts(struct dp83640_private *dp83640,
 			shhwtstamps = skb_hwtstamps(skb);
 			memset(shhwtstamps, 0, sizeof(*shhwtstamps));
 			shhwtstamps->hwtstamp = ns_to_ktime(rxts->ns);
-			netif_rx_ni(skb);
 			list_add(&rxts->list, &dp83640->rxpool);
 			break;
 		}
 	}
 	spin_unlock(&dp83640->rx_queue.lock);
 
-	if (!shhwtstamps)
+	if (shhwtstamps)
+		netif_rx_ni(skb);
+	else
 		list_add_tail(&rxts->list, &dp83640->rxts);
 out:
 	spin_unlock_irqrestore(&dp83640->rx_lock, flags);
@@ -1425,7 +1426,6 @@ static bool dp83640_rxtstamp(struct phy_device *phydev,
 			shhwtstamps = skb_hwtstamps(skb);
 			memset(shhwtstamps, 0, sizeof(*shhwtstamps));
 			shhwtstamps->hwtstamp = ns_to_ktime(rxts->ns);
-			netif_rx_ni(skb);
 			list_del_init(&rxts->list);
 			list_add(&rxts->list, &dp83640->rxpool);
 			break;
