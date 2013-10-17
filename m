From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/9] bnx2x: Prevent an illegal pointer dereference
 during panic
Date: Thu, 17 Oct 2013 14:21:34 -0400 (EDT)
Message-ID: <20131017.142134.1058688642083607743.davem@davemloft.net>
References: <1381847335-32662-1-git-send-email-yuvalmin@broadcom.com>
	<1381847335-32662-3-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, eilong@broadcom.com,
	dmitry@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762509Ab3JQSVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 14:21:39 -0400
In-Reply-To: <1381847335-32662-3-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Tue, 15 Oct 2013 16:28:48 +0200

> @@ -775,6 +775,15 @@ void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char *lvl)
>  		trace_shmem_base = bp->common.shmem_base;
>  	else
>  		trace_shmem_base = SHMEM2_RD(bp, other_shmem_base_addr);
> +
> +	/* sanity */
> +	if (trace_shmem_base < MCPR_SCRATCH_BASE(bp) ||
> +	    trace_shmem_base > MCPR_SCRATCH_BASE(bp) + 0x28000) {

I would say that this second test should be ">=" rather than ">".

Actually, there are a lot of holes still remaining here.

trace_shmem_base is validated, but then you access the signature at
0x800 bytes before trace_shmem_base value.  That should be accounted
for in the test above too.

And what about that 'mark' value you read?  Any validations needed on
that?

And then you read from "addr" to "mark", and I see no checks that this
range makes any sense either.
