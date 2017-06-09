From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/5] nfp: make sure to cancel port refresh on the error path
Date: Thu,  8 Jun 2017 20:56:10 -0700
Message-ID: <20170609035614.12691-2-jakub.kicinski@netronome.com>
References: <20170609035614.12691-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:35433 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751495AbdFID5y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 23:57:54 -0400
Received: by mail-pg0-f46.google.com with SMTP id k71so22349972pgd.2
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 20:57:54 -0700 (PDT)
In-Reply-To: <20170609035614.12691-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If very last stages of netdev registering and init fail some
other netdevs and devlink ports may have been visible to user
space before we torn them back down.  In this case there is a
slight chance user may have triggered port refresh.  We need
to make sure the async work is cancelled.

We have to cancel after releasing pf->lock, so we will always
try to cancel, regardless of which part of probe has failed.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 5f27703060c2..cdd25dc5988d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -813,6 +813,7 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 	nfp_cpp_area_release_free(pf->data_vnic_bar);
 err_unlock:
 	mutex_unlock(&pf->lock);
+	cancel_work_sync(&pf->port_refresh_work);
 	return err;
 }
 
-- 
2.11.0
