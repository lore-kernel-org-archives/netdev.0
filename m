From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath6kl: sdio: fix system panic when doing wifi stress test
Date: Tue, 26 Nov 2013 12:40:19 +0200
Message-ID: <87k3fvjvjg.fsf@kamboji.qca.qualcomm.com>
References: <1384221185-8645-1-git-send-email-r64343@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-arm-kernel@lists.infradead.org>, <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <ath6kl-devel@qca.qualcomm.com>
To: Jason Liu <r64343@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth01.qualcomm.com ([65.197.215.72]:24995 "EHLO
	sabertooth01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754991Ab3KZKkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 05:40:43 -0500
In-Reply-To: <1384221185-8645-1-git-send-email-r64343@freescale.com> (Jason
	Liu's message of "Tue, 12 Nov 2013 09:53:05 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jason,

Jason Liu <r64343@freescale.com> writes:

> When did the wifi iperf test, meet one following kernel panic:
> command: iperf -c $TARGET_IP -i 5 -t 50 -w 1M
>
> Unable to handle kernel paging request at virtual address 1a480000
> pgd = 80004000
> [1a480000] *pgd=00000000
> Internal error: Oops: 805 [#1] SMP ARM

[...]

> The kernel panic is caused by the sg_buf is not set correctly with the
> following code when compiled with Yocto GCC 4.8.1:
>
> drivers/net/wireless/ath/ath6kl/hif.h:
> struct hif_scatter_req {
>         struct list_head list;
>         /* address for the read/write operation */
>         u32 addr;
> 	...
>
>         /* bounce buffer for upper layers to copy to/from */
>         u8 *virt_dma_buf;
>
>         struct hif_scatter_item scat_list[1];
>
>         u32 scat_q_depth;
> };
>
> (Note: the scat_req.scat_list[] will dynamiclly grow with run-time)

There's actually a major bug right there, scat_list can corrupt scat_q_depth.

> The GCC 4.8.1 compiler will not do the for-loop till scat_entries, instead,
> it only run one round loop. This may be caused by that the GCC 4.8.1 thought
> that the scat_list only have one item and then no need to do full iteration,
> but this is simply wrong by looking at the assebly code. This will cause the
> sg buffer not get set when scat_entries > 1 and thus lead to kernel panic.
>
> This patch is a workaround to the GCC 4.8.1 complier issue by passing the
> entry address of the scat_req->scat_list to the for-loop and interate it,
> then, GCC 4.8.1 will do the full for-loop correctly.
> (Note: This issue not observed with GCC 4.7.2, only found on the GCC 4.8.1)
>
> This patch does not change any function logic and no any performance downgrade.

[...]

> +	scat_list = &scat_req->scat_list[0];
> +
>  	/* assemble SG list */
> -	for (i = 0; i < scat_req->scat_entries; i++, sg++) {
> +	for (i = 0; i < scat_req->scat_entries; i++, sg++, scat_list++) {
>  		ath6kl_dbg(ATH6KL_DBG_SCATTER, "%d: addr:0x%p, len:%d\n",
> -			   i, scat_req->scat_list[i].buf,
> -			   scat_req->scat_list[i].len);
> +			   i, scat_list->buf, scat_list->len);
>  
> -		sg_set_buf(sg, scat_req->scat_list[i].buf,
> -			   scat_req->scat_list[i].len);
> +		sg_set_buf(sg, scat_list->buf, scat_list->len);
>  	}

Working around the problem by adding a temporary variable makes me a bit
worried, I would rather fix the root cause. Is the root cause by that we
define the field with scat_list[1]?

Does the patch below help? It would also fix the corruption with
scat_q_depth. Please note that I have only compile tested it. And I
might have also missed something important, so please review it
carefully.

--- a/drivers/net/wireless/ath/ath6kl/hif.h
+++ b/drivers/net/wireless/ath/ath6kl/hif.h
@@ -197,9 +197,9 @@ struct hif_scatter_req {
 	/* bounce buffer for upper layers to copy to/from */
 	u8 *virt_dma_buf;
 
-	struct hif_scatter_item scat_list[1];
-
 	u32 scat_q_depth;
+
+	struct hif_scatter_item scat_list[0];
 };
 
 struct ath6kl_irq_proc_registers {
diff --git a/drivers/net/wireless/ath/ath6kl/sdio.c b/drivers/net/wireless/ath/ath6kl/sdio.c
index 7126bdd..6bf15a3 100644
--- a/drivers/net/wireless/ath/ath6kl/sdio.c
+++ b/drivers/net/wireless/ath/ath6kl/sdio.c
@@ -348,7 +348,7 @@ static int ath6kl_sdio_alloc_prep_scat_req(struct ath6kl_sdio *ar_sdio,
 	int i, scat_req_sz, scat_list_sz, size;
 	u8 *virt_buf;
 
-	scat_list_sz = (n_scat_entry - 1) * sizeof(struct hif_scatter_item);
+	scat_list_sz = n_scat_entry * sizeof(struct hif_scatter_item);
 	scat_req_sz = sizeof(*s_req) + scat_list_sz;
 
 	if (!virt_scat)


-- 
Kalle Valo
