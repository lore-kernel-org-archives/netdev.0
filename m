From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Fri, 28 Aug 2015 13:09:29 +0200
Message-ID: <20150828110929.GI32206@pox.localdomain>
References: <1440757685-14241-1-git-send-email-phil@nwl.cc>
 <1440757685-14241-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37155 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbbH1LJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 07:09:31 -0400
Received: by wicfv10 with SMTP id fv10so8703406wic.0
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 04:09:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1440757685-14241-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/15 at 12:28pm, Phil Sutter wrote:
> After adding cond_resched() calls to threadfunc(), a surprisingly high
> rate of insert failures occurred probably due to table resizes getting a
> better chance to run in background. To not soften up the remaining
> tests, retry inserts until they either succeed or fail permanently.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  lib/test_rhashtable.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
> index 63654e3..093cf84 100644
> --- a/lib/test_rhashtable.c
> +++ b/lib/test_rhashtable.c
> @@ -244,7 +244,7 @@ static int thread_lookup_test(struct thread_data *tdata)
>  
>  static int threadfunc(void *data)
>  {
> -	int i, step, err = 0, insert_fails = 0;
> +	int i, step, err = 0, retries = 0;
>  	struct thread_data *tdata = data;
>  
>  	up(&prestart_sem);
> @@ -253,21 +253,22 @@ static int threadfunc(void *data)
>  
>  	for (i = 0; i < entries; i++) {
>  		tdata->objs[i].value = (tdata->id << 16) | i;
> +insert_retry:
>  		cond_resched();
>  		err = rhashtable_insert_fast(&ht, &tdata->objs[i].node,
>  		                             test_rht_params);
>  		if (err == -ENOMEM || err == -EBUSY) {
> -			tdata->objs[i].value = TEST_INSERT_FAIL;
> -			insert_fails++;
> +			retries++;
> +			goto insert_retry;

Is it safe to retry indefinitely on ENOMEM? Retrying on EBUSY is
definitely an improvement and we should do the same in the non
threaded test as well.
