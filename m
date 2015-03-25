From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] ipvlan: fix addr hash list corruption
Date: Wed, 25 Mar 2015 09:58:51 +0100
Message-ID: <20150325095851.1d8d1622@griffin>
References: <2ca7312e5e3df10ce129315f89c3ab5d82d4d428.1427145009.git.jbenc@redhat.com>
	<20150324.130037.1897087027068811494.davem@davemloft.net>
	<20150324180628.278017fb@griffin>
	<CAF2d9jh+VozezamrEK_6vfTvY8LZSzw9n-bJjSX3G11RXmfz3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>, dcbw@redhat.com
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38595 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752058AbbCYI6z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2015 04:58:55 -0400
In-Reply-To: <CAF2d9jh+VozezamrEK_6vfTvY8LZSzw9n-bJjSX3G11RXmfz3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Mar 2015 16:16:38 -0700, Mahesh Bandewar wrote:
> Well, we already have hlist_unhashed().The following patch should fix
> the duplicate addition as well as deletion. Please give it a try.

Good idea, it's surely better than adding a new boolean.

However, I'm wondering that when there's apparently no problem with the
addresses being on the hash list when interface is down, what's the
point in clearing the hash list in the ndo_stop handler and
repopulating it in ndo_open?

The following patch fixes the problem, too, and as a bonus removes code:

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 4f4099d5603d..03def841b1a9 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -149,10 +149,6 @@ static int ipvlan_open(struct net_device *dev)
 	else
 		dev->flags &= ~IFF_NOARP;
 
-	if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
-		list_for_each_entry(addr, &ipvlan->addrs, anode)
-			ipvlan_ht_addr_add(ipvlan, addr);
-	}
 	return dev_uc_add(phy_dev, phy_dev->dev_addr);
 }
 
@@ -166,11 +162,6 @@ static int ipvlan_stop(struct net_device *dev)
 	dev_mc_unsync(phy_dev, dev);
 
 	dev_uc_del(phy_dev, phy_dev->dev_addr);
-
-	if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
-		list_for_each_entry(addr, &ipvlan->addrs, anode)
-			ipvlan_ht_addr_del(addr, !dev->dismantle);
-	}
 	return 0;
 }
 

What do you think? Should I submit this formally?

 Jiri

-- 
Jiri Benc
