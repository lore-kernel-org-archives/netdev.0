From: Anton Blanchard <anton@samba.org>
Subject: acenic lockup
Date: Wed, 7 May 2003 17:06:57 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030507070657.GC30976@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jes@trained-monkey.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

Ive got a bucketload of acenic adapters in a ppc64 box. I get random
tx timeouts, I suspect there is a missing memory barrier (power4 is
good at catching those). Still looking.

I did manage to lock a card up in ace_start_xmit:

restart:
...
        if (tx_ring_full(ap, ap->tx_ret_csm, idx))
	                goto overflow;
...
overflow:
        /*
         * This race condition is unavoidable with lock-free drivers.
         * We wake up the queue _before_ tx_prd is advanced, so that we
         * can
         * enter hard_start_xmit too early, while tx ring still looks
         * closed.
         * This happens ~1-4 times per 100000 packets, so that we can
         * allow
         * to loop syncing to other CPU. Probably, we need an additional
         * wmb() in ace_tx_intr as well.
         *
         * Note that this race is relieved by reserving one more entry
         * in tx ring than it is necessary (see original non-SG driver).
         * However, with SG we need to reserve 2*MAX_SKB_FRAGS+1, which
         * is already overkill.
         *
         * Alternative is to return with 1 not throttling queue. In this
         * case loop becomes longer, no more useful effects.
         */
        barrier();
        goto restart;

Its stuck there and never coming out. Alexey: I have a feeling you
wrote this code, is that correct? :)

Anton
