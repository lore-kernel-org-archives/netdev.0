From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net] nfp: refuse offloading filters that redirects to upper devices
Date: Wed, 25 Oct 2017 11:47:05 -0700
Message-ID: <20171025184705.4336-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:54339 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751421AbdJYSrQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 14:47:16 -0400
Received: by mail-pg0-f68.google.com with SMTP id l24so667410pgu.11
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 11:47:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>

Previously we did not ensure that a netdev is a representative netdev
before dereferencing its private data. This can occur when an upper netdev
is created on a representative netdev. This patch corrects this by first
ensuring that the netdev is a representative netdev before using it.
Checking only switchdev_port_same_parent_id is not sufficient to ensure
that we can safely use the netdev. Failing to check that the netdev is also
a representative netdev would result in incorrect dereferencing.

Fixes: 1a1e586f54bf ("nfp: add basic action capabilities to flower offloads")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/action.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/action.c b/drivers/net/ethernet/netronome/nfp/flower/action.c
index db9750695dc7..8ea9320014ee 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/action.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/action.c
@@ -110,6 +110,8 @@ nfp_fl_output(struct nfp_fl_output *output, const struct tc_action *action,
 	 */
 	if (!switchdev_port_same_parent_id(in_dev, out_dev))
 		return -EOPNOTSUPP;
+	if (!nfp_netdev_is_nfp_repr(out_dev))
+		return -EOPNOTSUPP;
 
 	output->port = cpu_to_be32(nfp_repr_get_port_id(out_dev));
 	if (!output->port)
-- 
2.14.1
