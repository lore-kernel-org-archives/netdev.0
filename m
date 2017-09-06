From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net_sched: fix a memory leak of filter chain
Date: Wed, 6 Sep 2017 10:25:51 -0700
Message-ID: <CAM_iQpVJ8PmF7cL2aNpc6nH6JmTBTJ_LS_ekwU4sQhOcdoAA8g@mail.gmail.com>
References: <20170906050310.26474-1-xiyou.wangcong@gmail.com> <20170906073839.GD2523@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:38671 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932130AbdIFR0M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 13:26:12 -0400
Received: by mail-pf0-f195.google.com with SMTP id q76so3329860pfq.5
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 10:26:12 -0700 (PDT)
In-Reply-To: <20170906073839.GD2523@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 6, 2017 at 12:38 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Sep 06, 2017 at 07:03:10AM CEST, xiyou.wangcong@gmail.com wrote:
>>tcf_chain_destroy() is called by tcf_block_put() and tcf_chain_put().
>>tcf_chain_put() is refcn'ed and paired with tcf_chain_get(),
>>but tcf_block_put() is not, it should be paired with tcf_block_get()
>>and we still need to decrease the refcnt. However, tcf_block_put()
>>is special, it stores the chains too, we have to detach them if
>>it is not the last user.
>
> You don't describe the original issue, or I am missing that from your
> description.

The original issue is the mismatch of tcf_block_put() and tcf_block_get()
w.r.t. refcnt. Think it in this way: if you call tcf_bock_put() immediately
after tcf_block_get(), would you get effectively a nop?


>
>
>>
>>What's more, index 0 is not special at all, it should be treated
>>like other chains. This also makes the code more readable.
>
> [...]
>
>
>>@@ -246,10 +246,7 @@ EXPORT_SYMBOL(tcf_chain_get);
>>
>> void tcf_chain_put(struct tcf_chain *chain)
>> {
>>-      /* Destroy unused chain, with exception of chain 0, which is the
>>-       * default one and has to be always present.
>>-       */
>>-      if (--chain->refcnt == 0 && !chain->filter_chain && chain->index != 0)
>>+      if (--chain->refcnt == 0)
>
> The refcounting is only done for actions holding reference to the chain.
> You still need to check is the filter chain is not empty.
> See tc_ctl_tfilter.

With my patch refcnt is done for block too, if you notice the
tcf_chain_put() in tcf_block_put().


>
> Also, chain 0 is created by default on a block creation. It has to be
> present always for a reason. Please see tcf_block_get. The pointer to
> chain 0 is assigned to the qdisc filter list pointer.

Sure, this is why block holds a refcnt to chain (not just chain 0) with
my patch, aka why the initial refcnt is 1 rather than 0.
