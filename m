From: John Fastabend <john.fastabend@gmail.com>
Subject: nft_hash rhashtable question
Date: Mon, 12 Jan 2015 14:30:40 -0800
Message-ID: <54B44B10.7000009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: tgraf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:64691 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbbALWaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 17:30:55 -0500
Received: by mail-oi0-f44.google.com with SMTP id a141so22758498oig.3
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 14:30:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

I'm looking at the rhashtable usage.

But as I read the nft_hash_destroy() its not clear to me how
rht_for_each_entry_safe() and  nft_hash_elem_destroy() keep everything
in sync.

Here is the code in question,

> static void nft_hash_destroy(const struct nft_set *set)
> {
>         struct rhashtable *priv = nft_set_priv(set);
>         const struct bucket_table *tbl;
>         struct nft_hash_elem *he;
>         struct rhash_head *pos, *next;
>         unsigned int i;
>
>         /* Stop an eventual async resizing */
>         priv->being_destroyed = true;
>         mutex_lock(&priv->mutex); <-- get the lock so we have single updater
>
>         tbl = rht_dereference(priv->tbl, priv);
>         for (i = 0; i < tbl->size; i++) {
>                 rht_for_each_entry_safe(he, pos, next, tbl, i, node)
>                         nft_hash_elem_destroy(set, he);              <-- does a kfree on he?
>         }
>         mutex_unlock(&priv->mutex); <-- release the lock
>
>         rhashtable_destroy(priv);
> }


Is it really safe to kfree 'he' without waiting a grace
period for any rcu readers to drop the reference?

I'm considering what happens if nft_hash_destroy runs in
parallel with nft_hash_lookup?

Thanks,
John


-- 
John Fastabend         Intel Corporation
