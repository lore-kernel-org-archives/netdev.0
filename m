From: Patrick McHardy <kaber@trash.net>
Subject: netfilter: ctnetlink: fix scheduling while atomic
Date: Wed, 21 Jan 2009 12:01:50 +0100
Message-ID: <4977009E.3020806@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070905030903040301050403"
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51474 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768AbZAULBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 06:01:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070905030903040301050403
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit



--------------070905030903040301050403
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline;
 filename="01.diff"

commit 334055b92c6bf132d7d9ba52fadfdebd71ba586b
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 21 11:59:14 2009 +0100

    netfilter: ctnetlink: fix scheduling while atomic
    
    Caused by call to request_module() while holding nf_conntrack_lock.
    
    Reported-and-tested-by: Kövesdi György <kgy@teledigit.hu>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 3dddec6..c32a7e8 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -831,13 +831,16 @@ ctnetlink_parse_nat_setup(struct nf_conn *ct,
 	if (!parse_nat_setup) {
 #ifdef CONFIG_MODULES
 		rcu_read_unlock();
+		spin_unlock_bh(&nf_conntrack_lock);
 		nfnl_unlock();
 		if (request_module("nf-nat-ipv4") < 0) {
 			nfnl_lock();
+			spin_lock_bh(&nf_conntrack_lock);
 			rcu_read_lock();
 			return -EOPNOTSUPP;
 		}
 		nfnl_lock();
+		spin_lock_bh(&nf_conntrack_lock);
 		rcu_read_lock();
 		if (nfnetlink_parse_nat_setup_hook)
 			return -EAGAIN;

--------------070905030903040301050403--
