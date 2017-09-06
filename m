From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net] net_sched: fix a memory leak of filter chain
Date: Wed, 6 Sep 2017 09:38:39 +0200
Message-ID: <20170906073839.GD2523@nanopsycho>
References: <20170906050310.26474-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        Jiri Pirko <jiri@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34752 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751737AbdIFHim (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 03:38:42 -0400
Received: by mail-wm0-f66.google.com with SMTP id l19so1691793wmi.1
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 00:38:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170906050310.26474-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 06, 2017 at 07:03:10AM CEST, xiyou.wangcong@gmail.com wrote:
>tcf_chain_destroy() is called by tcf_block_put() and tcf_chain_put().
>tcf_chain_put() is refcn'ed and paired with tcf_chain_get(),
>but tcf_block_put() is not, it should be paired with tcf_block_get()
>and we still need to decrease the refcnt. However, tcf_block_put()
>is special, it stores the chains too, we have to detach them if
>it is not the last user.

You don't describe the original issue, or I am missing that from your
description.


>
>What's more, index 0 is not special at all, it should be treated
>like other chains. This also makes the code more readable.

[...]


>@@ -246,10 +246,7 @@ EXPORT_SYMBOL(tcf_chain_get);
> 
> void tcf_chain_put(struct tcf_chain *chain)
> {
>-	/* Destroy unused chain, with exception of chain 0, which is the
>-	 * default one and has to be always present.
>-	 */
>-	if (--chain->refcnt == 0 && !chain->filter_chain && chain->index != 0)
>+	if (--chain->refcnt == 0)

The refcounting is only done for actions holding reference to the chain.
You still need to check is the filter chain is not empty.
See tc_ctl_tfilter.

Also, chain 0 is created by default on a block creation. It has to be
present always for a reason. Please see tcf_block_get. The pointer to
chain 0 is assigned to the qdisc filter list pointer.



> 		tcf_chain_destroy(chain);
> }
> EXPORT_SYMBOL(tcf_chain_put);
>@@ -296,8 +293,11 @@ void tcf_block_put(struct tcf_block *block)
> 
> 	list_for_each_entry_safe(chain, tmp, &block->chain_list, list) {
> 		tcf_chain_flush(chain);
>-		tcf_chain_destroy(chain);
>+		tcf_chain_put(chain);
> 	}
>+	/* If tc actions still hold the chain, just detach it. */
>+	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
>+		tcf_chain_detach(chain);
> 	kfree(block);
> }
> EXPORT_SYMBOL(tcf_block_put);
>-- 
>2.13.0
>
