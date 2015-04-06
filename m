From: Fred Chou <fred.chou.nd@gmail.com>
Subject: Re: [PATCH] ath9k_htc: check seq number instead of cmd id for timeout
Date: Mon, 06 Apr 2015 14:33:15 +0800
Message-ID: <552228AB.8060000@gmail.com>
References: <1426235558-13787-1-git-send-email-fred.chou.nd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ath9k-devel@qca.qualcomm.com, kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33054 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbbDFGdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 02:33:18 -0400
In-Reply-To: <1426235558-13787-1-git-send-email-fred.chou.nd@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

May I have an update on the patch status please?

Thanks and regards,
Fred

On 13/3/2015 4:32 PM, Fred Chou wrote:
> From: Fred Chou <fred.chou.nd@gmail.com>
> 
> As the driver may send multiple wmi commands with identical cmd id,
> it is more robust to check seq number for timeout instead.
> 
> Signed-off-by: Fred Chou <fred.chou.nd@gmail.com>
> ---
>  drivers/net/wireless/ath/ath9k/wmi.c | 12 ++++++------
>  drivers/net/wireless/ath/ath9k/wmi.h |  2 +-
>  2 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/ath9k/wmi.c b/drivers/net/wireless/ath/ath9k/wmi.c
> index 65c8894..aba909f 100644
> --- a/drivers/net/wireless/ath/ath9k/wmi.c
> +++ b/drivers/net/wireless/ath/ath9k/wmi.c
> @@ -224,7 +224,7 @@ static void ath9k_wmi_ctrl_rx(void *priv, struct sk_buff *skb,
>  
>  	/* Check if there has been a timeout. */
>  	spin_lock(&wmi->wmi_lock);
> -	if (cmd_id != wmi->last_cmd_id) {
> +	if (be16_to_cpu(hdr->seq_no) != wmi->last_seq_id) {
>  		spin_unlock(&wmi->wmi_lock);
>  		goto free_skb;
>  	}
> @@ -272,11 +272,16 @@ static int ath9k_wmi_cmd_issue(struct wmi *wmi,
>  			       enum wmi_cmd_id cmd, u16 len)
>  {
>  	struct wmi_cmd_hdr *hdr;
> +	unsigned long flags;
>  
>  	hdr = (struct wmi_cmd_hdr *) skb_push(skb, sizeof(struct wmi_cmd_hdr));
>  	hdr->command_id = cpu_to_be16(cmd);
>  	hdr->seq_no = cpu_to_be16(++wmi->tx_seq_id);
>  
> +	spin_lock_irqsave(&wmi->wmi_lock, flags);
> +	wmi->last_seq_id = wmi->tx_seq_id;
> +	spin_unlock_irqrestore(&wmi->wmi_lock, flags);
> +
>  	return htc_send_epid(wmi->htc, skb, wmi->ctrl_epid);
>  }
>  
> @@ -292,7 +297,6 @@ int ath9k_wmi_cmd(struct wmi *wmi, enum wmi_cmd_id cmd_id,
>  	struct sk_buff *skb;
>  	u8 *data;
>  	int time_left, ret = 0;
> -	unsigned long flags;
>  
>  	if (ah->ah_flags & AH_UNPLUGGED)
>  		return 0;
> @@ -320,10 +324,6 @@ int ath9k_wmi_cmd(struct wmi *wmi, enum wmi_cmd_id cmd_id,
>  	wmi->cmd_rsp_buf = rsp_buf;
>  	wmi->cmd_rsp_len = rsp_len;
>  
> -	spin_lock_irqsave(&wmi->wmi_lock, flags);
> -	wmi->last_cmd_id = cmd_id;
> -	spin_unlock_irqrestore(&wmi->wmi_lock, flags);
> -
>  	ret = ath9k_wmi_cmd_issue(wmi, skb, cmd_id, cmd_len);
>  	if (ret)
>  		goto out;
> diff --git a/drivers/net/wireless/ath/ath9k/wmi.h b/drivers/net/wireless/ath/ath9k/wmi.h
> index 0db37f2..2aad6dc 100644
> --- a/drivers/net/wireless/ath/ath9k/wmi.h
> +++ b/drivers/net/wireless/ath/ath9k/wmi.h
> @@ -143,7 +143,7 @@ struct wmi {
>  	enum htc_endpoint_id ctrl_epid;
>  	struct mutex op_mutex;
>  	struct completion cmd_wait;
> -	enum wmi_cmd_id last_cmd_id;
> +	u16 last_seq_id;
>  	struct sk_buff_head wmi_event_queue;
>  	struct tasklet_struct wmi_event_tasklet;
>  	u16 tx_seq_id;
> 
