From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next v2] net_sched: use idr to allocate u32 filter
 handles
Date: Mon, 25 Sep 2017 21:00:31 +0200
Message-ID: <20170925190031.GB1936@nanopsycho.orion>
References: <20170925171351.4956-3-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Chris Mi <chrism@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:49809 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933306AbdIYTAd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 15:00:33 -0400
Received: by mail-wm0-f65.google.com with SMTP id r74so530435wme.4
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 12:00:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170925171351.4956-3-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 25, 2017 at 07:13:51PM CEST, xiyou.wangcong@gmail.com wrote:
>Instead of calling u32_lookup_ht() in a loop to find
>a unused handle, just switch to idr API to allocate
>new handles. u32 filters are special as the handle
>could contain a hash table id and a key id, so we
>need two IDR to allocate each of them.
>
>Cc: Chris Mi <chrism@mellanox.com>
>Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>---

[...]

>@@ -311,19 +313,19 @@ static void *u32_get(struct tcf_proto *tp, u32 handle)
> 	return u32_lookup_key(ht, handle);
> }
> 
>-static u32 gen_new_htid(struct tc_u_common *tp_c)
>+static u32 gen_new_htid(struct tc_u_common *tp_c, struct tc_u_hnode *ptr)
> {
>-	int i = 0x800;
>+	unsigned long idr_index;
>+	int err;
> 
>-	/* hgenerator only used inside rtnl lock it is safe to increment
>+	/* This is only used inside rtnl lock it is safe to increment
> 	 * without read _copy_ update semantics
> 	 */
>-	do {
>-		if (++tp_c->hgenerator == 0x7FF)
>-			tp_c->hgenerator = 1;
>-	} while (--i > 0 && u32_lookup_ht(tp_c, (tp_c->hgenerator|0x800)<<20));
>-
>-	return i > 0 ? (tp_c->hgenerator|0x800)<<20 : 0;
>+	err = idr_alloc_ext(&tp_c->handle_idr, ptr, &idr_index,
>+			    1, 0x7FF, GFP_KERNEL);

Interesting, any idea why this is not 0x7FFFFFFF as well?

I wonder if we could have 0x7FFFFFFF magic defined somewhere.

Otherwise, "patchset" looks good. Thank you for taking care of this!
