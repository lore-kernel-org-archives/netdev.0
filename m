From: "Paul Moore" <paul.moore@hp.com>
Subject: [PATCH 1/2] NetLabel: correct locking in selinux_netlbl_socket_setsid()
Date: Fri, 05 Jan 2007 15:08:21 -0500
Message-ID: <20070105201637.494749925@hp.com>
References: <20070105200820.975960210@hp.com>
Cc: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:53217 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750718AbXAEUQz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jan 2007 15:16:55 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-softirq_lock_safety
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The spinlock protecting the update of the "sksec->nlbl_state" variable is not
currently softirq safe which can lead to problems.  This patch fixes this by
changing the spin_{un}lock() functions into spin_{un}lock_bh() functions.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 security/selinux/ss/services.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: net-2.6.20_bugfix_3/security/selinux/ss/services.c
===================================================================
--- net-2.6.20_bugfix_3.orig/security/selinux/ss/services.c
+++ net-2.6.20_bugfix_3/security/selinux/ss/services.c
@@ -2492,9 +2492,9 @@ static int selinux_netlbl_socket_setsid(
 
 	rc = netlbl_socket_setattr(sock, &secattr);
 	if (rc == 0) {
-		spin_lock(&sksec->nlbl_lock);
+		spin_lock_bh(&sksec->nlbl_lock);
 		sksec->nlbl_state = NLBL_LABELED;
-		spin_unlock(&sksec->nlbl_lock);
+		spin_unlock_bh(&sksec->nlbl_lock);
 	}
 
 netlbl_socket_setsid_return:

--
paul moore
linux security @ hp
