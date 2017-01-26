From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [patch net-next] smc: some potential use after free bugs
Date: Thu, 26 Jan 2017 12:23:02 +0100
Message-ID: <d66e8e35-0be7-ea04-6e1e-7c214cc6c50b@linux.vnet.ibm.com>
References: <20170126090527.GA966@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-s390@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:54919 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750998AbdAZLXL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 06:23:11 -0500
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0QBJZf1119174
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 06:23:10 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2870k4f7xt-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 06:23:10 -0500
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 26 Jan 2017 11:23:07 -0000
In-Reply-To: <20170126090527.GA966@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 01/26/2017 10:05 AM, Dan Carpenter wrote:
> Say we got really unlucky and these failed on the last iteration, then
> it could lead to a use after free bug.
thanks for reporting this! I had already a similar patch prepared, but not
yet submitted. It contains all your added lines plus these additional
pre-initializations at definition time:

@@ -509,7 +509,7 @@ int smc_sndbuf_create(struct smc_sock *smc)
        struct smc_connection *conn = &smc->conn;
        struct smc_link_group *lgr = conn->lgr;
        int tmp_bufsize, tmp_bufsize_short;
-   struct smc_buf_desc *sndbuf_desc;
+ struct smc_buf_desc *sndbuf_desc = NULL;
        int rc;
 
        /* use socket send buffer size (w/o overhead) as start value */

@@ -573,7 +575,7 @@ int smc_rmb_create(struct smc_sock *smc)
        struct smc_connection *conn = &smc->conn;
        struct smc_link_group *lgr = conn->lgr;
        int tmp_bufsize, tmp_bufsize_short;
-   struct smc_buf_desc *rmb_desc;
+ struct smc_buf_desc *rmb_desc = NULL;
        int rc;
 
        /* use socket recv buffer size (w/o overhead) as start value */

If you do not contradict, I will post my enhanced patch version.
> 
> Fixes: cd6851f30386 ("smc: remote memory buffers (RMBs)")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
> index 8b1d34378829..941279e1504e 100644
> --- a/net/smc/smc_core.c
> +++ b/net/smc/smc_core.c
> @@ -535,6 +535,7 @@ int smc_sndbuf_create(struct smc_sock *smc)
>  			/* if send buffer allocation has failed,
>  			 * try a smaller one
>  			 */
> +			sndbuf_desc = NULL;
>  			continue;
>  		}
>  		rc = smc_ib_buf_map(lgr->lnk[SMC_SINGLE_LINK].smcibdev,
> @@ -543,6 +544,7 @@ int smc_sndbuf_create(struct smc_sock *smc)
>  		if (rc) {
>  			kfree(sndbuf_desc->cpu_addr);
>  			kfree(sndbuf_desc);
> +			sndbuf_desc = NULL;
>  			continue; /* if mapping failed, try smaller one */
>  		}
>  		sndbuf_desc->used = 1;
> @@ -599,6 +601,7 @@ int smc_rmb_create(struct smc_sock *smc)
>  			/* if RMB allocation has failed,
>  			 * try a smaller one
>  			 */
> +			rmb_desc = NULL;
>  			continue;
>  		}
>  		rc = smc_ib_buf_map(lgr->lnk[SMC_SINGLE_LINK].smcibdev,
> @@ -607,6 +610,7 @@ int smc_rmb_create(struct smc_sock *smc)
>  		if (rc) {
>  			kfree(rmb_desc->cpu_addr);
>  			kfree(rmb_desc);
> +			rmb_desc = NULL;
>  			continue; /* if mapping failed, try smaller one */
>  		}
>  		rc = smc_ib_get_memory_region(lgr->lnk[SMC_SINGLE_LINK].roce_pd,
> @@ -619,6 +623,7 @@ int smc_rmb_create(struct smc_sock *smc)
>  					 DMA_FROM_DEVICE);
>  			kfree(rmb_desc->cpu_addr);
>  			kfree(rmb_desc);
> +			rmb_desc = NULL;
>  			continue;
>  		}
>  		rmb_desc->used = 1;
> 
