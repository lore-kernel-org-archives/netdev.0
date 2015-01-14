From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v3] rhashtable: Fix race in rhashtable_destroy()
 and use regular work_struct
Date: Wed, 14 Jan 2015 16:25:50 +0300
Message-ID: <54B66E5E.6010507@cogentembedded.com>
References: <1421228256-740-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:38245 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583AbbANNZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 08:25:53 -0500
Received: by mail-lb0-f169.google.com with SMTP id p9so7906314lbv.0
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 05:25:51 -0800 (PST)
In-Reply-To: <1421228256-740-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 1/14/2015 12:37 PM, Ying Xue wrote:

> When we put our declared work task in the global workqueue with
> schedule_delayed_work(), its delay parameter is always zero.
> Therefore, we should define a regular work in rhashtable structure
> instead of a delayed work.

> By the way, we add a condition to check whether resizing functions
> are NULL before cancel the work, avoiding to cancel an uninitialized

    s/before cancel/before cancelling/.

> work.

[...]

> Fixes: 97defe1 ("rhashtable: Per bucket locks & deferred expansion/shrinking")
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Cc: Thomas Graf <tgraf@suug.ch>
> Acked-by: Thomas Graf <tgraf@suug.ch>

[...]

> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index ed6ae1a..1f56189 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
[...]
> @@ -911,12 +911,11 @@ EXPORT_SYMBOL_GPL(rhashtable_init);
>   void rhashtable_destroy(struct rhashtable *ht)
>   {
>   	ht->being_destroyed = true;

    Empty line needed here.

> +	if (ht->p.grow_decision || ht->p.shrink_decision)
> +		cancel_work_sync(&ht->run_work);
>
>   	mutex_lock(&ht->mutex);
> -
> -	cancel_delayed_work(&ht->run_work);
>   	bucket_table_free(rht_dereference(ht->tbl, ht));
> -
>   	mutex_unlock(&ht->mutex);
>   }
>   EXPORT_SYMBOL_GPL(rhashtable_destroy);

WBR, Sergei
