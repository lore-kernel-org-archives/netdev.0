From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v4 2/4] wcn36xx: Transition driver to SMD client
Date: Thu, 08 Sep 2016 15:16:21 +0300
Message-ID: <87k2emsi22.fsf@kamboji.qca.qualcomm.com>
References: <1473200312-22438-1-git-send-email-bjorn.andersson@linaro.org>
        <1473200312-22438-2-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
        wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, Andy Gross <andy.gross@linaro.org>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473200312-22438-2-git-send-email-bjorn.andersson@linaro.org>
        (Bjorn Andersson's message of "Tue, 6 Sep 2016 15:18:30 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Andersson <bjorn.andersson@linaro.org> writes:

> The wcn36xx wifi driver follows the life cycle of the WLAN_CTRL SMD
> channel, as such it should be a SMD client. This patch makes this
> transition, now that we have the necessary frameworks available.
>
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
> ---
>
> Changes since v3:
> - Made msg_header const in wcn36xx_smd_rsp_process()
>
> Changes since v2:
> - Correct the call to the new ieee80211_scan_completed()
>
>  drivers/net/wireless/ath/wcn36xx/dxe.c     | 16 +++---
>  drivers/net/wireless/ath/wcn36xx/main.c    | 79 ++++++++++++++++++++----------
>  drivers/net/wireless/ath/wcn36xx/smd.c     | 31 +++++-------
>  drivers/net/wireless/ath/wcn36xx/smd.h     |  5 ++
>  drivers/net/wireless/ath/wcn36xx/wcn36xx.h | 21 +++-----
>  5 files changed, 86 insertions(+), 66 deletions(-)

This doesn't compile for me:

  CC [M]  drivers/net/wireless/ath/wcn36xx/main.o
  CC [M]  drivers/net/wireless/ath/wcn36xx/dxe.o
  CC [M]  drivers/net/wireless/ath/wcn36xx/txrx.o
  CC [M]  drivers/net/wireless/ath/wcn36xx/smd.o
  CC [M]  drivers/net/wireless/ath/wcn36xx/pmc.o
  CC [M]  drivers/net/wireless/ath/wcn36xx/debug.o
  LD [M]  drivers/net/wireless/ath/wcn36xx/wcn36xx.o
drivers/net/wireless/ath/wcn36xx/smd.o: In function `qcom_smd_get_drvdata':
/home/kvalo/ath10k/src/ath/./include/linux/soc/qcom/smd.h:87: multiple definition of `qcom_smd_get_drvdata'
drivers/net/wireless/ath/wcn36xx/main.o:/home/kvalo/ath10k/src/ath/./include/linux/soc/qcom/smd.h:87: first defined here
drivers/net/wireless/ath/wcn36xx/smd.o: In function `qcom_smd_set_drvdata':
/home/kvalo/ath10k/src/ath/./include/linux/soc/qcom/smd.h:94: multiple definition of `qcom_smd_set_drvdata'
drivers/net/wireless/ath/wcn36xx/main.o:/home/kvalo/ath10k/src/ath/./include/linux/soc/qcom/smd.h:94: first defined here
make[5]: *** [drivers/net/wireless/ath/wcn36xx/wcn36xx.o] Error 1

I fixed it with the diff below. Please let me know if it looks ok to
you, the patch is not applied yet so it's easy to make changes. The full
commit in my pending branch:

https://git.kernel.org/cgit/linux/kernel/git/kvalo/ath.git/commit/?h=pending&id=dba68ea7a404a9959d0ab44bc13c844187db6d6a

--- a/include/linux/soc/qcom/smd.h
+++ b/include/linux/soc/qcom/smd.h
@@ -83,14 +83,14 @@ qcom_smd_open_channel(struct qcom_smd_channel *channel,
        return NULL;
 }
 
-void *qcom_smd_get_drvdata(struct qcom_smd_channel *channel)
+static inline void *qcom_smd_get_drvdata(struct qcom_smd_channel *channel)
 {
        /* This shouldn't be possible */
        WARN_ON(1);
        return NULL;
 }
 
-void qcom_smd_set_drvdata(struct qcom_smd_channel *channel, void *data)
+static inline void qcom_smd_set_drvdata(struct qcom_smd_channel *channel, void *data)
 {
        /* This shouldn't be possible */
        WARN_ON(1);


-- 
Kalle Valo
