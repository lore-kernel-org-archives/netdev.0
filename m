From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH] net: fix rtnetlink IFF_PROMISC and IFF_ALLMULTI handling
Date: Fri, 27 Jul 2012 14:58:22 +0200
Message-ID: <20120727145822.7efd10d4@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Max Matveev <makc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751356Ab2G0M6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2012 08:58:25 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q6RCwPMt004114
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 08:58:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When device flags are set using rtnetlink, IFF_PROMISC and IFF_ALLMULTI
flags are handled specially. Function dev_change_flags sets IFF_PROMISC and
IFF_ALLMULTI bits in dev->gflags according to the passed value but
do_setlink passes a result of rtnl_dev_combine_flags which takes those bits
from dev->flags.

This can be easily trigerred by doing:

tcpdump -i eth0 &
ip l s up eth0

ip sets IFF_UP flag in ifi_flags and ifi_change, which is combined with
IFF_PROMISC by rtnl_dev_combine_flags, causing __dev_change_flags to set
IFF_PROMISC in gflags.

Reported-by: Max Matveev <makc@redhat.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>

---
 net/core/rtnetlink.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -659,6 +659,12 @@ static void set_operstate(struct net_dev
 	}
 }
 
+static unsigned int rtnl_dev_get_flags(const struct net_device *dev)
+{
+	return (dev->flags & ~(IFF_PROMISC | IFF_ALLMULTI)) |
+	       (dev->gflags & (IFF_PROMISC | IFF_ALLMULTI));
+}
+
 static unsigned int rtnl_dev_combine_flags(const struct net_device *dev,
 					   const struct ifinfomsg *ifm)
 {
@@ -667,7 +673,7 @@ static unsigned int rtnl_dev_combine_fla
 	/* bugwards compatibility: ifi_change == 0 is treated as ~0 */
 	if (ifm->ifi_change)
 		flags = (flags & ifm->ifi_change) |
-			(dev->flags & ~ifm->ifi_change);
+			(rtnl_dev_get_flags(dev) & ~ifm->ifi_change);
 
 	return flags;
 }
