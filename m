From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH net-next] ipv6: Make 'addrconf_rs_timer' send Router Solicitations (and re-arm itself) if Router Advertisements are accepted
Date: Sun,  2 Dec 2012 13:44:53 +0200
Message-ID: <1354448693-32155-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, Tore Anderson <tore@fud.no>,
	Ami Koren <amikoren@yahoo.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:39994 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292Ab2LBLp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2012 06:45:27 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so1083415eek.19
        for <netdev@vger.kernel.org>; Sun, 02 Dec 2012 03:45:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As of 026359b [ipv6: Send ICMPv6 RSes only when RAs are accepted],
Router Solicitations are sent whenever kernel accepts Router
Advertisements on the interface.

However, this logic isn't reflected in 'addrconf_rs_timer'.

The timer fails to issue subsequent RS messages (and fails to re-arm
itself) if forwarding is enabled and the special hybrid mode is
enabled (accept_ra=2).

Fix the condition determining whether next RS should be sent, by using
'ipv6_accept_ra()'.

Reported-by: Ami Koren <amikoren@yahoo.com>
Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 net/ipv6/addrconf.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ca1ed8a..3b990a2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2843,7 +2843,7 @@ static void addrconf_rs_timer(unsigned long data)
 	if (idev->dead || !(idev->if_flags & IF_READY))
 		goto out;
 
-	if (idev->cnf.forwarding)
+	if (!ipv6_accept_ra(idev))
 		goto out;
 
 	/* Announcement received after solicitation was sent */
-- 
1.7.9
