From: Adrian Bunk <bunk@kernel.org>
Subject: ip_frag_reasm() can return uninitialized variable
Date: Thu, 18 Oct 2007 12:52:03 +0200
Message-ID: <20071018105203.GJ3778@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:44755 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761758AbXJRKvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 06:51:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit 1706d58763c36133d7fce6cc78b1444fd40db28c ip_frag_reasm() 
can return the value of an uninitialized variable:

<--  snip  -->

...
static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
                         struct net_device *dev)
{
        struct iphdr *iph;
        struct sk_buff *fp, *head = qp->q.fragments;
        int len;
        int ihlen;
        int err;

        ipq_kill(qp);

        /* Make the one we just received the head. */
        if (prev) {
                head = prev->next;
                fp = skb_clone(head, GFP_ATOMIC);

                if (!fp)
                        goto out_nomem;
...
out_nomem:
        LIMIT_NETDEBUG(KERN_ERR "IP: queue_glue: no memory for gluing "
                              "queue %p\n", qp);
        goto out_fail;
...
out_fail:
        IP_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
        return err;
}
...

<--  snip  -->

Spotted by the Coverity checker.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

