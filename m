From: Matteo Croce <mcroce@redhat.com>
Subject: [PATCH] ipv6: fix net.ipv6.conf.all.accept_dad behaviour for real
Date: Thu,  5 Oct 2017 19:03:05 +0200
Message-ID: <20171005170305.30065-1-mcroce@redhat.com>
To: netdev@vger.kernel.org, Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:51086 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751144AbdJERDJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 13:03:09 -0400
Received: by mail-wm0-f54.google.com with SMTP id u138so3292361wmu.5
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 10:03:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 35e015e1f577 ("ipv6: fix net.ipv6.conf.all interface DAD handlers")
was intended to affect accept_dad flag handling in such a way that
DAD operation and mode on a given interface would be selected
according to the maximum value of conf/{all,interface}/accept_dad.

However, addrconf_dad_begin() checks for particular cases in which we
need to skip DAD, and this check was modified in the wrong way.

Namely, it was modified so that, if the accept_dad flag is 0 for the
given interface *or* for all interfaces, DAD would be skipped.

We have instead to skip DAD if accept_dad is 0 for the given interface
*and* for all interfaces.

Fixes: 35e015e1f577 ("ipv6: fix net.ipv6.conf.all interface DAD handlers")
Acked-by: Stefano Brivio <sbrivio@redhat.com>
Signed-off-by: Matteo Croce <mcroce@redhat.com>
---
 net/ipv6/addrconf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 96861c702c06..4a96ebbf8eda 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3820,8 +3820,8 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
 		goto out;
 
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
-	    dev_net(dev)->ipv6.devconf_all->accept_dad < 1 ||
-	    idev->cnf.accept_dad < 1 ||
+	    (dev_net(dev)->ipv6.devconf_all->accept_dad < 1 &&
+	     idev->cnf.accept_dad < 1) ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
 		bump_id = ifp->flags & IFA_F_TENTATIVE;
-- 
2.13.6
