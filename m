From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] bonding: ignore updelay param when there is no active slave
Date: Fri, 24 Apr 2009 15:57:29 +0200
Message-ID: <20090424135728.GA12304@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35212 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757570AbZDXN5d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2009 09:57:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pointed out by Sean E. Millichamp.

Quote from Documentation/networking/bonding.txt:
"Note that when a bonding interface has no active links, the
driver will immediately reuse the first link that goes up, even if the
updelay parameter has been specified (the updelay is ignored in this
case).  If there are slave interfaces waiting for the updelay timeout
to expire, the interface that first went into that state will be
immediately reused.  This reduces down time of the network if the
value of updelay has been overestimated, and since this occurs only in
cases with no connectivity, there is no additional penalty for
ignoring the updelay."

This patch actually changes the behaviour in this way.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

 drivers/net/bonding/bond_main.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 63369b6..da6106b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2249,6 +2249,9 @@ static int bond_miimon_inspect(struct bonding *bond)
 {
 	struct slave *slave;
 	int i, link_state, commit = 0;
+	bool ignore_updelay;
+
+	ignore_updelay = !bond->curr_active_slave ? true : false;
 
 	bond_for_each_slave(bond, slave, i) {
 		slave->new_link = BOND_LINK_NOCHANGE;
@@ -2313,6 +2316,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 				       ": %s: link status up for "
 				       "interface %s, enabling it in %d ms.\n",
 				       bond->dev->name, slave->dev->name,
+				       ignore_updelay ? 0 :
 				       bond->params.updelay *
 				       bond->params.miimon);
 			}
@@ -2331,9 +2335,13 @@ static int bond_miimon_inspect(struct bonding *bond)
 				continue;
 			}
 
+			if (ignore_updelay)
+				slave->delay = 0;
+
 			if (slave->delay <= 0) {
 				slave->new_link = BOND_LINK_UP;
 				commit++;
+				ignore_updelay = false;
 				continue;
 			}
 
