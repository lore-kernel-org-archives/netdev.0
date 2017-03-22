From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 01/15] nfp: disallow sharing mutexes on the same machine
Date: Tue, 21 Mar 2017 17:59:07 -0700
Message-ID: <20170322005921.10965-2-jakub.kicinski@netronome.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36830 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758539AbdCVBHv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:07:51 -0400
Received: by mail-pf0-f170.google.com with SMTP id o126so86729039pfb.3
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:07:45 -0700 (PDT)
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NFP can be connected to multiple machines via PCI or other buses.
Access to hardware resources is arbitrated using locks residing
in device memory.  Currently nfpcore only respects the mutexes
when it comes to inter-host locking, but if we try to acquire
the same lock again, on one host - it will simply return success
because owner of the lock is already set to that host.

This makes the locks useless for arbitration within one host
and unfair because whichever host grabbed the lock will have
a chance to reacquire it without others getting a shot.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
index 40108e66c654..e2267b421af0 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
@@ -1736,11 +1736,5 @@ int nfp_cpp_mutex_trylock(struct nfp_cpp_mutex *mutex)
 		return 0;
 	}
 
-	/* Already locked by us? Success! */
-	if (tmp == value) {
-		mutex->depth = 1;
-		return 0;
-	}
-
 	return nfp_mutex_is_locked(tmp) ? -EBUSY : -EINVAL;
 }
-- 
2.11.0
