From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] net: qrtr: potential use after free in qrtr_sendmsg()
Date: Thu, 20 Apr 2017 13:21:30 +0300
Message-ID: <20170420102130.jhafz7e532y5iqd4@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        Stephen Boyd <sboyd@codeaurora.org>,
        Johannes Berg <johannes.berg@intel.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Courtney Cavin <courtney.cavin@sonymobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44888 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761595AbdDTKV5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 06:21:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If skb_pad() fails then it frees the skb so we should check for errors.

Fixes: bdabad3e363d ("net: Add Qualcomm IPC router")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index c36b0ec364a4..a9a8c7d5a4a9 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -658,7 +658,9 @@ static int qrtr_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	}
 
 	if (plen != len) {
-		skb_pad(skb, plen - len);
+		rc = skb_pad(skb, plen - len);
+		if (rc)
+			goto out_node;
 		skb_put(skb, plen - len);
 	}
 
