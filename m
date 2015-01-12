From: tgraf <tgraf@suug.ch>
Subject: Re: nft_hash rhashtable question
Date: Mon, 12 Jan 2015 22:42:49 +0000
Message-ID: <20150112224249.GA11857@casper.infradead.org>
References: <54B44B10.7000009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48022 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbALWmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 17:42:51 -0500
Content-Disposition: inline
In-Reply-To: <54B44B10.7000009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/15 at 02:30pm, John Fastabend wrote:
> >        /* Stop an eventual async resizing */
> >        priv->being_destroyed = true;

This aborts and eventual resize in the background.

> >        mutex_lock(&priv->mutex); <-- get the lock so we have single updater

this ensures that the resize finished.

> >        tbl = rht_dereference(priv->tbl, priv);
> >        for (i = 0; i < tbl->size; i++) {
> >                rht_for_each_entry_safe(he, pos, next, tbl, i, node)
> >                        nft_hash_elem_destroy(set, he);              <-- does a kfree on he?
> >        }
> >        mutex_unlock(&priv->mutex); <-- release the lock
> >
> >        rhashtable_destroy(priv);

Since no insert or removal can occur we can be assured that no new
entry was added in the meantime so we can destroy the rhashtable
without any further protection.

> >}
> 
> 
> Is it really safe to kfree 'he' without waiting a grace
> period for any rcu readers to drop the reference?
> 
> I'm considering what happens if nft_hash_destroy runs in
> parallel with nft_hash_lookup?

The nft_set API ensures that a destroy can't occur in parallel to
an insertion or removal. All we have to ensure is that any resizing
in the background is aborted and completed.

If you look at the code before the rhashtable there was no locking
at all:

static void nft_hash_destroy(const struct nft_set *set)
{
        const struct nft_hash *priv = nft_set_priv(set);
        const struct nft_hash_table *tbl = nft_dereference(priv->tbl);
        struct nft_hash_elem *he, *next;
        unsigned int i;

        for (i = 0; i < tbl->size; i++) {
                for (he = nft_dereference(tbl->buckets[i]); he != NULL;
                     he = next) {
                        next = nft_dereference(he->next);
                        nft_hash_elem_destroy(set, he);
                }
        }
        kfree(tbl);
}
