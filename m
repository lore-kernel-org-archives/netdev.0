From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG ?] ipv6: addrconf: Adds a missing in6_ifa_hold()
Date: Mon, 30 Oct 2017 20:53:37 -0700
Message-ID: <1509422017.17752.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:55134 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751422AbdJaDxk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 23:53:40 -0400
Received: by mail-pf0-f182.google.com with SMTP id n89so12715156pfk.11
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 20:53:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, I was looking at addrconf_permanent_addr() and wondered
if there is not some problem with it.

It seems we need to increment ifp refcount before calling
ipv6_del_addr()

Could you double check if this patch is needed, I am guessing you have a
test suite exercising this code path ?

Thanks.

PS : Presumably CONFIG_REFCOUNT_FULL=y should have warned you of the
problem.

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4a96ebbf8eda5f59a6ff88e836d666a404d2bf0d..8a1c846d3df949a4638589f187120db22a3525ba 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3335,6 +3335,7 @@ static void addrconf_permanent_addr(struct net_device *dev)
 		if ((ifp->flags & IFA_F_PERMANENT) &&
 		    fixup_permanent_addr(idev, ifp) < 0) {
 			write_unlock_bh(&idev->lock);
+			in6_ifa_hold(ifp);
 			ipv6_del_addr(ifp);
 			write_lock_bh(&idev->lock);
 
