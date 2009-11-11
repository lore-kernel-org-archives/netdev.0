From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] decnet: add RTNL lock when reading address list
Date: Wed, 11 Nov 2009 09:39:27 -0800
Message-ID: <20091111093927.4a08999d@nehalam>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.615305929@vyatta.com>
	<4AF9B449.6040708@gmail.com>
	<20091110105053.16687e93@nehalam>
	<20091110182436.GA13374@fogou.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christine Caulfield <christine.caulfield@googlemail.com>,
	Hannes Eder <hannes@hanneseder.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Steven Whitehouse <swhiteho@redhat.com>,
	netdev@vger.kernel.org, linux-decnet-users@lists.sourceforge.net
To: steve@chygwyn.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56990 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757947AbZKKRlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 12:41:00 -0500
In-Reply-To: <20091110182436.GA13374@fogou.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing locking in the case of auto binding to the
default device. The address list might change while this code is looking
at the list. 

Compile tested only, I am not a decnet user.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/decnet/dn_dev.c	2009-11-11 09:18:02.935313559 -0800
+++ b/net/decnet/dn_dev.c	2009-11-11 09:22:32.157313924 -0800
@@ -828,13 +828,17 @@ static int dn_dev_get_first(struct net_d
 	struct dn_dev *dn_db = (struct dn_dev *)dev->dn_ptr;
 	struct dn_ifaddr *ifa;
 	int rv = -ENODEV;
+
 	if (dn_db == NULL)
 		goto out;
+
+	rtnl_lock();
 	ifa = dn_db->ifa_list;
 	if (ifa != NULL) {
 		*addr = ifa->ifa_local;
 		rv = 0;
 	}
+	rtnl_unlock();
 out:
 	return rv;
 }
