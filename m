From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] Remove lots of IS_ERR_VALUE abuses.
Date: Thu, 07 Jul 2016 10:10:14 +0200
Message-ID: <5371430.pWs0YMj39t@wuerfel>
References: <1467832663-5653-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>, leoli@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:56999 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756087AbcGGIHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 04:07:04 -0400
In-Reply-To: <1467832663-5653-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, July 7, 2016 12:47:43 AM CEST Arvind Yadav wrote:
>     Most users of IS_ERR_VALUE() in the kernel are wrong, as they
>     pass an 'int' into a function that takes an 'unsigned long'
>     argument. This happens to work because the type is sign-extended
>     on 64-bit architectures before it gets converted into an
>     unsigned type.
> 
>     However, anything that passes an 'unsigned short' or 'unsigned int'
>     argument into IS_ERR_VALUE() is guaranteed to be broken, as are
>     8-bit integers and types that are wider than 'unsigned long'.
> 
>     Andrzej Hajda has already fixed a lot of the worst abusers that
>     were causing actual bugs, but it would be nice to prevent any
>     users that are not passing 'unsigned long' arguments.
> 
>     This patch changes all users of IS_ERR_VALUE() that I could find
>     on 32-bit ARM randconfig builds and x86 allmodconfig. For the
>     moment, this doesn't change the definition of IS_ERR_VALUE()
>     because there are probably still architecture specific users
>     elsewhere.
> 
>     Almost all the warnings I got are for files that are better off
>     using 'if (err)' or 'if (err < 0)'.
>     The only legitimate user I could find that we get a warning for
>     is the (32-bit only) freescale gigabit ethernet driver.
> 
>     I was using this definition for testing:
> 
>      #define IS_ERR_VALUE(x) ((unsigned long*)NULL == (typeof (x)*)NULL && \
>       unlikely((unsigned long long)(x) >= (unsigned long long)(typeof(x))-MAX_ERRNO))
> 
>     which ends up making all 16-bit or wider types work correctly with
>     the most plausible interpretation of what IS_ERR_VALUE() was supposed
>     to return according to its users, but also causes a compile-time
>     warning for any users that do not pass an 'unsigned long' argument.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

The above is my changelog text for commit 287980e49f, but it's not my patch.

Your changes look fine, but reusing my description there seems wrong.
Can you add a new description and just point to my commit instead?

	Arnd

>  drivers/net/ethernet/freescale/ucc_geth.c | 30 +++++++++++++++---------------
>  1 file changed, 15 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
> index 5bf1ade..c1ead2c 100644
> --- a/drivers/net/ethernet/freescale/ucc_geth.c
> +++ b/drivers/net/ethernet/freescale/ucc_geth.c
> @@ -289,7 +289,7 @@ static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
>  		else {
>  			init_enet_offset =
>  			    qe_muram_alloc(thread_size, thread_alignment);
> -			if (IS_ERR_VALUE(init_enet_offset)) {
> +			if (init_enet_offset < 0) {
>  				if (netif_msg_ifup(ugeth))
>  					pr_err("Can not allocate DPRAM memory\n");
>  				qe_put_snum((u8) snum);
> @@ -2234,7 +2234,7 @@ static int ucc_geth_alloc_tx(struct ucc_geth_private *ugeth)
>  			ugeth->tx_bd_ring_offset[j] =
>  			    qe_muram_alloc(length,
>  					   UCC_GETH_TX_BD_RING_ALIGNMENT);
> -			if (!IS_ERR_VALUE(ugeth->tx_bd_ring_offset[j]))
> +			if (!ugeth->tx_bd_ring_offset[j])
>  				ugeth->p_tx_bd_ring[j] =
>  				    (u8 __iomem *) qe_muram_addr(ugeth->
>  							 tx_bd_ring_offset[j]);
> @@ -2311,7 +2311,7 @@ static int ucc_geth_alloc_rx(struct ucc_geth_private *ugeth)
>  			ugeth->rx_bd_ring_offset[j] =
>  			    qe_muram_alloc(length,
>  					   UCC_GETH_RX_BD_RING_ALIGNMENT);
> -			if (!IS_ERR_VALUE(ugeth->rx_bd_ring_offset[j]))
> +			if (!ugeth->rx_bd_ring_offset[j])
>  				ugeth->p_rx_bd_ring[j] =
>  				    (u8 __iomem *) qe_muram_addr(ugeth->
>  							 rx_bd_ring_offset[j]);
> @@ -2521,7 +2521,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
>  	ugeth->tx_glbl_pram_offset =
>  	    qe_muram_alloc(sizeof(struct ucc_geth_tx_global_pram),
>  			   UCC_GETH_TX_GLOBAL_PRAM_ALIGNMENT);
> -	if (IS_ERR_VALUE(ugeth->tx_glbl_pram_offset)) {
> +	if (ugeth->tx_glbl_pram_offset < 0) {
>  		if (netif_msg_ifup(ugeth))
>  			pr_err("Can not allocate DPRAM memory for p_tx_glbl_pram\n");
>  		return -ENOMEM;
> @@ -2541,7 +2541,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
>  			   sizeof(struct ucc_geth_thread_data_tx) +
>  			   32 * (numThreadsTxNumerical == 1),
>  			   UCC_GETH_THREAD_DATA_ALIGNMENT);
> -	if (IS_ERR_VALUE(ugeth->thread_dat_tx_offset)) {
> +	if (ugeth->thread_dat_tx_offset < 0) {
>  		if (netif_msg_ifup(ugeth))
>  			pr_err("Can not allocate DPRAM memory for p_thread_data_tx\n");
>  		return -ENOMEM;
> @@ -2568,7 +2568,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
>  	    qe_muram_alloc(ug_info->numQueuesTx *
>  			   sizeof(struct ucc_geth_send_queue_qd),
>  			   UCC_GETH_SEND_QUEUE_QUEUE_DESCRIPTOR_ALIGNMENT);
> -	if (IS_ERR_VALUE(ugeth->send_q_mem_reg_offset)) {
> +	if (ugeth->send_q_mem_reg_offset < 0) {
>  		if (netif_msg_ifup(ugeth))
>  			pr_err("Can not allocate DPRAM memory for p_send_q_mem_reg\n");
>  		return -ENOMEM;
> @@ -2609,7 +2609,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
>  		ugeth->scheduler_offset =
>  		    qe_muram_alloc(sizeof(struct ucc_geth_scheduler),
>  				   UCC_GETH_SCHEDULER_ALIGNMENT);
> -		if (IS_ERR_VALUE(ugeth->scheduler_offset)) {
> +		if (ugeth->scheduler_offset < 0) {
>  			if (netif_msg_ifup(ugeth))
>  				pr_err("Can not allocate DPRAM memory for p_scheduler\n");
>  			return -ENOMEM;
> @@ -2656,7 +2656,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
>  		    qe_muram_alloc(sizeof
>  				   (struct ucc_geth_tx_firmware_statistics_pram),
>  				   UCC_GETH_TX_STATISTICS_ALIGNMENT);
> -		if (IS_ERR_VALUE(ugeth->tx_fw_statistics_pram_offset)) {
> +		if (ugeth->tx_fw_statistics_pram_offset < 0) {
>  			if (netif_msg_ifup(ugeth))
>  				pr_err("Can not allocate DPRAM memory for p_tx_fw_statistics_pram\n");
>  			return -ENOMEM;
> @@ -2693,7 +2693,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
>  	ugeth->rx_glbl_pram_offset =
>  	    qe_muram_alloc(sizeof(struct ucc_geth_rx_global_pram),
>  			   UCC_GETH_RX_GLOBAL_PRAM_ALIGNMENT);
> -	if (IS_ERR_VALUE(ugeth->rx_glbl_pram_offset)) {
> +	if (ugeth->rx_glbl_pram_offset < 0) {
>  		if (netif_msg_ifup(ugeth))
>  			pr_err("Can not allocate DPRAM memory for p_rx_glbl_pram\n");
>  		return -ENOMEM;
> @@ -2712,7 +2712,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
>  	    qe_muram_alloc(numThreadsRxNumerical *
>  			   sizeof(struct ucc_geth_thread_data_rx),
>  			   UCC_GETH_THREAD_DATA_ALIGNMENT);
> -	if (IS_ERR_VALUE(ugeth->thread_dat_rx_offset)) {
> +	if (ugeth->thread_dat_rx_offset < 0) {
>  		if (netif_msg_ifup(ugeth))
>  			pr_err("Can not allocate DPRAM memory for p_thread_data_rx\n");
>  		return -ENOMEM;
> @@ -2733,7 +2733,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
>  		    qe_muram_alloc(sizeof
>  				   (struct ucc_geth_rx_firmware_statistics_pram),
>  				   UCC_GETH_RX_STATISTICS_ALIGNMENT);
> -		if (IS_ERR_VALUE(ugeth->rx_fw_statistics_pram_offset)) {
> +		if (ugeth->rx_fw_statistics_pram_offset < 0) {
>  			if (netif_msg_ifup(ugeth))
>  				pr_err("Can not allocate DPRAM memory for p_rx_fw_statistics_pram\n");
>  			return -ENOMEM;
> @@ -2753,7 +2753,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
>  	    qe_muram_alloc(ug_info->numQueuesRx *
>  			   sizeof(struct ucc_geth_rx_interrupt_coalescing_entry)
>  			   + 4, UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT);
> -	if (IS_ERR_VALUE(ugeth->rx_irq_coalescing_tbl_offset)) {
> +	if (ugeth->rx_irq_coalescing_tbl_offset < 0) {
>  		if (netif_msg_ifup(ugeth))
>  			pr_err("Can not allocate DPRAM memory for p_rx_irq_coalescing_tbl\n");
>  		return -ENOMEM;
> @@ -2819,7 +2819,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
>  			   (sizeof(struct ucc_geth_rx_bd_queues_entry) +
>  			    sizeof(struct ucc_geth_rx_prefetched_bds)),
>  			   UCC_GETH_RX_BD_QUEUES_ALIGNMENT);
> -	if (IS_ERR_VALUE(ugeth->rx_bd_qs_tbl_offset)) {
> +	if (ugeth->rx_bd_qs_tbl_offset < 0) {
>  		if (netif_msg_ifup(ugeth))
>  			pr_err("Can not allocate DPRAM memory for p_rx_bd_qs_tbl\n");
>  		return -ENOMEM;
> @@ -2905,7 +2905,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
>  		ugeth->exf_glbl_param_offset =
>  		    qe_muram_alloc(sizeof(struct ucc_geth_exf_global_pram),
>  		UCC_GETH_RX_EXTENDED_FILTERING_GLOBAL_PARAMETERS_ALIGNMENT);
> -		if (IS_ERR_VALUE(ugeth->exf_glbl_param_offset)) {
> +		if (ugeth->exf_glbl_param_offset < 0) {
>  			if (netif_msg_ifup(ugeth))
>  				pr_err("Can not allocate DPRAM memory for p_exf_glbl_param\n");
>  			return -ENOMEM;
> @@ -3039,7 +3039,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
>  
>  	/* Allocate InitEnet command parameter structure */
>  	init_enet_pram_offset = qe_muram_alloc(sizeof(struct ucc_geth_init_pram), 4);
> -	if (IS_ERR_VALUE(init_enet_pram_offset)) {
> +	if (init_enet_pram_offset < 0) {
>  		if (netif_msg_ifup(ugeth))
>  			pr_err("Can not allocate DPRAM memory for p_init_enet_pram\n");
>  		return -ENOMEM;
> 
