From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 86851] New: Reproducible panic on heavy UDP traffic
Date: Sun, 26 Oct 2014 17:47:06 -0700
Message-ID: <1414370826.16231.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141025141038.26fa5ac2@uryu.home.lan>
	 <20141025214448.GB28407@breakpoint.cc> <544D8386.9030609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:58114 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769AbaJ0ArI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2014 20:47:08 -0400
Received: by mail-pd0-f178.google.com with SMTP id fp1so1328933pdb.9
        for <netdev@vger.kernel.org>; Sun, 26 Oct 2014 17:47:07 -0700 (PDT)
In-Reply-To: <544D8386.9030609@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-27 at 00:28 +0100, Nikolay Aleksandrov wrote:

> 
> Thanks for CCing me.
> I'll dig in the code tomorrow but my first thought when I saw this was
> could it be possible that we have a race condition between
> ip_frag_queue() and inet_frag_evict(), more precisely between the
> ipq_kill() calls from ip_frag_queue and inet_frag_evict since the frag
> could be found before we have entered the evictor which then can add it to
> its expire list but the ipq_kill() from ip_frag_queue() can do a list_del
> after we release the chain lock in the evictor so we may end up like this ?

Yes, either we use hlist_del_init() but loose poison aid, or test if
frag was evicted :

Not sure about refcount.

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 9eb89f3f0ee4..894ec30c5896 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -285,7 +285,8 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
 	struct inet_frag_bucket *hb;
 
 	hb = get_frag_bucket_locked(fq, f);
-	hlist_del(&fq->list);
+	if (!(fq->flags & INET_FRAG_EVICTED))
+		hlist_del(&fq->list);
 	spin_unlock(&hb->chain_lock);
 }
 
