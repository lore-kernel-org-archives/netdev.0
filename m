From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 3/5] flow_dissector: Correctly handle parsing FCoE
Date: Wed, 24 Feb 2016 09:29:51 -0800
Message-ID: <20160224172951.12339.76173.stgit@localhost.localdomain>
References: <20160224172644.12339.92679.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34876 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758396AbcBXR3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 12:29:53 -0500
Received: by mail-pa0-f46.google.com with SMTP id ho8so16466578pac.2
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 09:29:52 -0800 (PST)
In-Reply-To: <20160224172644.12339.92679.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The flow dissector bits handling FCoE didn't bother to actually validate
that the space there was enough for the FCoE header.  So we need to update
things so that if there is room we add the header and report a good result,
otherwise we do not add the header, and report the bad result.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/core/flow_dissector.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 8bd745f72734..6288153d7f36 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -340,8 +340,11 @@ mpls:
 	}
 
 	case htons(ETH_P_FCOE):
-		key_control->thoff = (u16)(nhoff + FCOE_HEADER_LEN);
-		/* fall through */
+		if ((hlen - nhoff) < FCOE_HEADER_LEN)
+			goto out_bad;
+
+		nhoff += FCOE_HEADER_LEN;
+		goto out_good;
 	default:
 		goto out_bad;
 	}
