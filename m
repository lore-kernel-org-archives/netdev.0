From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net] igmp, mld: Fix memory leak in igmpv3/mld_del_delrec()
Date: Wed,  8 Feb 2017 21:16:45 +0800
Message-ID: <1486559805-28482-1-git-send-email-liuhangbin@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36790 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932489AbdBHNRF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 08:17:05 -0500
Received: by mail-pf0-f194.google.com with SMTP id 19so11678084pfo.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 05:17:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function igmpv3/mld_add_delrec() we allocate pmc and put it in
idev->mc_tomb, so we should free it when we don't need it in del_delrec().
But I removed kfree(pmc) incorrectly in latest two patches. Now fix it.

Fixes: 24803f38a5c0 ("igmp: do not remove igmp souce list info when ...")
Fixes: 1666d49e1d41 ("mld: do not remove mld souce list info when ...")
Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/ipv4/igmp.c  | 1 +
 net/ipv6/mcast.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 5b15459..44fd86d 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1172,6 +1172,7 @@ static void igmpv3_del_delrec(struct in_device *in_dev, struct ip_mc_list *im)
 				psf->sf_crcount = im->crcount;
 		}
 		in_dev_put(pmc->interface);
+		kfree(pmc);
 	}
 	spin_unlock_bh(&im->lock);
 }
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 7139fff..1bdc703 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -779,6 +779,7 @@ static void mld_del_delrec(struct inet6_dev *idev, struct ifmcaddr6 *im)
 				psf->sf_crcount = im->mca_crcount;
 		}
 		in6_dev_put(pmc->idev);
+		kfree(pmc);
 	}
 	spin_unlock_bh(&im->mca_lock);
 }
-- 
2.5.5
