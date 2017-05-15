From: Mauro Rodrigues <maurosr@linux.vnet.ibm.com>
Subject: Re: [PATCH net v2] i40e/i40evf: proper update of the page_offset
 field
Date: Mon, 15 May 2017 09:45:52 -0300
Message-ID: <20170515124552.GA9601@korriban>
References: <20170515045200.27789-1-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:56978 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752352AbdEOMp7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 08:45:59 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4FChiT8141260
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 08:45:59 -0400
Received: from e24smtp05.br.ibm.com (e24smtp05.br.ibm.com [32.104.18.26])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2ae3rpgehc-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 08:45:58 -0400
Received: from localhost
        by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <maurosr@linux.vnet.ibm.com>;
        Mon, 15 May 2017 09:45:57 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
        by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4FCjsXm20644296
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 09:45:54 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
        by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4FCjslh021993
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 09:45:54 -0300
Received: from korriban (korriban.br.ibm.com [9.18.239.165])
        by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id v4FCjrNG021950
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 09:45:54 -0300
Content-Disposition: inline
In-Reply-To: <20170515045200.27789-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 15, 2017 at 06:52:00AM +0200, Björn Töpel wrote:
> From: Björn Töpel <bjorn.topel@intel.com>
> 
> In f8b45b74cc62 ("i40e/i40evf: Use build_skb to build frames")
> i40e_build_skb updates the page_offset field with an incorrect offset,
> which can lead to data corruption. This patch updates page_offset
> correctly, by properly setting truesize.
> 
> Note that the bug only appears on architectures where PAGE_SIZE is
> 8192 or larger.
> 
> Fixes: f8b45b74cc62 ("i40e/i40evf: Use build_skb to build frames")
> Signed-off-by: Björn Töpel <bjorn.topel@intel.com>

I tested the fix and it solves the problem for me! Thank you!

> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 3 ++-
>  drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 3 ++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> index 29321a6167a6..cd894f4023b1 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> @@ -1854,7 +1854,8 @@ static struct sk_buff *i40e_build_skb(struct i40e_ring *rx_ring,
>  #if (PAGE_SIZE < 8192)
>  	unsigned int truesize = i40e_rx_pg_size(rx_ring) / 2;
>  #else
> -	unsigned int truesize = SKB_DATA_ALIGN(size);
> +	unsigned int truesize = SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) +
> +				SKB_DATA_ALIGN(I40E_SKB_PAD + size);
>  #endif
>  	struct sk_buff *skb;
> 
> diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> index dfe241a12ad0..12b02e530503 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> @@ -1190,7 +1190,8 @@ static struct sk_buff *i40e_build_skb(struct i40e_ring *rx_ring,
>  #if (PAGE_SIZE < 8192)
>  	unsigned int truesize = i40e_rx_pg_size(rx_ring) / 2;
>  #else
> -	unsigned int truesize = SKB_DATA_ALIGN(size);
> +	unsigned int truesize = SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) +
> +				SKB_DATA_ALIGN(I40E_SKB_PAD + size);
>  #endif
>  	struct sk_buff *skb;
> 
> -- 
> 2.11.0
> 
