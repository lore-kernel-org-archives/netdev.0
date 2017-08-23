From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 0/3] nfp: fix SR-IOV deadlock and representor bugs
Date: Tue, 22 Aug 2017 23:22:41 -0700
Message-ID: <20170823062244.26580-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34835 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751988AbdHWGWv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 02:22:51 -0400
Received: by mail-pg0-f46.google.com with SMTP id u191so3850294pgc.2
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 23:22:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series tackles the bug I've already tried to fix in commit 
6d48ceb27af1 ("nfp: allocate a private workqueue for driver work").
I created a separate workqueue to avoid possible deadlock, and
the lockdep error disappeared, coincidentally.  The way workqueues
are operating, separate workqueue doesn't necessarily mean separate
thread of execution.  Luckily we can safely forego the lock.

Second fix changes the order in which vNIC netdevs and representors
are created/destroyed.  The fix is kept small and should be sufficient
for net because of how flower uses representors, a more thorough fix 
will be targeted at net-next.

Third fix avoids leaking mapped frame buffers if FW sent a frame with
unknown portid.

Jakub Kicinski (3):
  nfp: don't hold PF lock while enabling SR-IOV
  nfp: make sure representors are destroyed before their lower netdev
  nfp: avoid buffer leak when representor is missing

 drivers/net/ethernet/netronome/nfp/nfp_main.c      | 16 +++++++---------
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 10 +++++-----
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 22 ++++++++++++++--------
 3 files changed, 26 insertions(+), 22 deletions(-)

-- 
2.11.0
