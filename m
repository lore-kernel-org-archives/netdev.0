From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH] wcn36xx: Close SMD channel on device removal
Date: Mon,  8 May 2017 21:36:37 -0700
Message-ID: <20170509043637.28179-1-bjorn.andersson@linaro.org>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Eyal Ilsar <c_eilsar@qti.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35631 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbdEIEgl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 00:36:41 -0400
Received: by mail-pf0-f179.google.com with SMTP id v14so43128461pfd.2
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 21:36:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SMD channel is not the primary WCNSS channel and must explicitly be
closed as the device is removed, or the channel will already by open on
a subsequent probe call in e.g. the case of reloading the kernel module.

This issue was introduced because I simplified the underlying SMD
implementation while the SMD adaptions of the driver sat on the mailing
list, but missed to update these patches. The patch does however only
apply back to the transition to rpmsg, hence the limited Fixes.

Fixes: 5052de8deff5 ("soc: qcom: smd: Transition client drivers from smd to rpmsg")
Reported-by: Eyal Ilsar <c_eilsar@qti.qualcomm.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index d5e993dc9b23..517a315e259b 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -1271,6 +1271,8 @@ static int wcn36xx_remove(struct platform_device *pdev)
 	qcom_smem_state_put(wcn->tx_enable_state);
 	qcom_smem_state_put(wcn->tx_rings_empty_state);
 
+	rpmsg_destroy_ept(wcn->smd_channel);
+
 	iounmap(wcn->dxe_base);
 	iounmap(wcn->ccu_base);
 
-- 
2.12.0
