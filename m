From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] rhashtable: Make sure max_size is non zero
Date: Thu, 27 Apr 2017 15:32:41 -0700
Message-ID: <bb1475bc-a129-865f-be43-829a76e99dc9@gmail.com>
References: <56843a86-9a09-16e8-acec-05a80396f282@gmail.com>
 <20170427222824.31936-1-florian.fainelli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, fw@strlen.de,
        tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33784 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423366AbdD0Wco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 18:32:44 -0400
Received: by mail-qk0-f194.google.com with SMTP id o85so6766604qkh.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 15:32:43 -0700 (PDT)
In-Reply-To: <20170427222824.31936-1-florian.fainelli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/27/2017 03:28 PM, Florian Fainelli wrote:
> After commit 6d684e54690c ("rhashtable: Cap total number of
> entries to 2^31"), we would be hitting a panic() in net/core/rtnetlink.c
> during initialization. The call stack would look like this:
> 
> register_pernet_subsys()
>     ...
>     ops->init()
> 	rtnetlink_net_init()
> 	  netlink_kernel_create()
> 	     netlink_insert()
> 		__netlink_insert()
> 		   rhashtable_lookup_insert_key()
> 		      __rhashtable_insert_fast()
> 			rht_grow_above_max()
> 
> And here, we have rht_grow_above_max() return true, because ht->nelemts = 0 (legit)
> && ht->max_elems = 0 (looks bogus).
> 
> Eventually, we would be return -E2BIG from __rhashtable_insert_fast()
> and propagate this all the way back to the caller.
> 
> After commit 6d684e54690c what changed is that we would take the
> following condition:
> 
> if (ht->p.max_size < ht->max_elems / 2)
> 	ht->max_elems = ht->p.max_size * 2;
> 
> and since ht->p.max_size = 0, we would set ht->max_elems to 0 as well.
> 
> Fix this by taking this branch only when ht->p.max_size is non-zero
> 
> Fixes: Fixes: 6d684e54690c ("rhashtable: Cap total number of entries to 2^31")
> Signed-off-by: Florian Fainelli <florian.fainelli@broadcom.com>

Sent another version with the correct email address and marked this one
as superseded in patchwork, not that this email is not valid, but it's
all about consistency.

David pleas apply this one instead:
http://patchwork.ozlabs.org/patch/756172/

/me remembers to stop switching between machines.
-- 
Florian
