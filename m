From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/6] qed: Allow chance for fast ramrod
 completions
Date: Sun, 09 Oct 2016 17:08:35 -0700
Message-ID: <1476058115.28155.282.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1476026738-26069-1-git-send-email-Yuval.Mintz@qlogic.com>
         <1476026738-26069-6-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:32973 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbcJJAIi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 20:08:38 -0400
Received: by mail-it0-f66.google.com with SMTP id m138so34768itm.0
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2016 17:08:38 -0700 (PDT)
In-Reply-To: <1476026738-26069-6-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-10-09 at 18:25 +0300, Yuval Mintz wrote:
> From: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
> 
> Whenever a ramrod is being sent for some device configuration,
> the driver is going to sleep at least 5ms between each iteration
> of polling on the completion of the ramrod.
> 
> However, in almost every configuration scenario the firmware
> would be able to comply and complete the ramrod in a manner of
> several usecs. This is especially important in cases where there
> might be a lot of sequential configurations applying to the hardware
> [e.g., RoCE], in which case the existing scheme might cause some
> visible user delays.
> 
> This patch changes the completion scheme - instead of immediately
> starting to sleep for a 'long' period, allow the device to quickly
> poll on the first iteration after a couple of usecs.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
> ---
>  drivers/net/ethernet/qlogic/qed/qed_spq.c | 85 +++++++++++++++++++++----------
>  1 file changed, 59 insertions(+), 26 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
> index caff415..259a615 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
> +++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
> @@ -37,7 +37,11 @@
>  ***************************************************************************/
>  
>  #define SPQ_HIGH_PRI_RESERVE_DEFAULT    (1)
> -#define SPQ_BLOCK_SLEEP_LENGTH          (1000)
> +
> +#define SPQ_BLOCK_DELAY_MAX_ITER        (10)
> +#define SPQ_BLOCK_DELAY_US              (10)
> +#define SPQ_BLOCK_SLEEP_MAX_ITER        (1000)
> +#define SPQ_BLOCK_SLEEP_MS              (5)
>  
>  /***************************************************************************
>  * Blocking Imp. (BLOCK/EBLOCK mode)
> @@ -57,53 +61,81 @@ static void qed_spq_blocking_cb(struct qed_hwfn *p_hwfn,
>  	smp_wmb();
>  }
>  
> -static int qed_spq_block(struct qed_hwfn *p_hwfn,
> -			 struct qed_spq_entry *p_ent,
> -			 u8 *p_fw_ret)
> +static int __qed_spq_block(struct qed_hwfn *p_hwfn,
> +			   struct qed_spq_entry *p_ent,
> +			   u8 *p_fw_ret, bool sleep_between_iter)
>  {
> -	int sleep_count = SPQ_BLOCK_SLEEP_LENGTH;
>  	struct qed_spq_comp_done *comp_done;
> -	int rc;
> +	u32 iter_cnt;
>  
>  	comp_done = (struct qed_spq_comp_done *)p_ent->comp_cb.cookie;
> -	while (sleep_count) {
> -		/* validate we receive completion update */
> +	iter_cnt = sleep_between_iter ? SPQ_BLOCK_SLEEP_MAX_ITER
> +				      : SPQ_BLOCK_DELAY_MAX_ITER;
> +
> +	while (iter_cnt--) {
> +		/* Validate we receive completion update */
>  		smp_rmb();
>  		if (comp_done->done == 1) {
>  			if (p_fw_ret)
>  				*p_fw_ret = comp_done->fw_return_code;
>  			return 0;
>  		}

Note that this smp_rmb() and accesses to ->done and ->fw_return_code are
racy.

fq_return_code needs to be written _before_ done.

Something like the following patch would make sense...

diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index caff41544898baed09f45a41829cb0ba9c719fb9..eefa45eab3728791f4d15a088c4550f318a1d1da 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -50,11 +50,9 @@ static void qed_spq_blocking_cb(struct qed_hwfn *p_hwfn,
 
 	comp_done = (struct qed_spq_comp_done *)cookie;
 
-	comp_done->done			= 0x1;
-	comp_done->fw_return_code	= fw_return_code;
+	comp_done->fw_return_code = fw_return_code;
 
-	/* make update visible to waiting thread */
-	smp_wmb();
+	smp_store_release(&comp_done->done, 0x1);
 }
 
 static int qed_spq_block(struct qed_hwfn *p_hwfn,
@@ -68,8 +66,8 @@ static int qed_spq_block(struct qed_hwfn *p_hwfn,
 	comp_done = (struct qed_spq_comp_done *)p_ent->comp_cb.cookie;
 	while (sleep_count) {
 		/* validate we receive completion update */
-		smp_rmb();
-		if (comp_done->done == 1) {
+		if (READ_ONCE(comp_done->done) == 1) {
+			smp_read_barrier_depends();
 			if (p_fw_ret)
 				*p_fw_ret = comp_done->fw_return_code;
 			return 0;
@@ -87,8 +85,8 @@ static int qed_spq_block(struct qed_hwfn *p_hwfn,
 	sleep_count = SPQ_BLOCK_SLEEP_LENGTH;
 	while (sleep_count) {
 		/* validate we receive completion update */
-		smp_rmb();
-		if (comp_done->done == 1) {
+		if (READ_ONCE(comp_done->done) == 1) {
+			smp_read_barrier_depends();
 			if (p_fw_ret)
 				*p_fw_ret = comp_done->fw_return_code;
 			return 0;
@@ -97,7 +95,8 @@ static int qed_spq_block(struct qed_hwfn *p_hwfn,
 		sleep_count--;
 	}
 
-	if (comp_done->done == 1) {
+	if (READ_ONCE(comp_done->done) == 1) {
+		smp_read_barrier_depends();
 		if (p_fw_ret)
 			*p_fw_ret = comp_done->fw_return_code;
 		return 0;
