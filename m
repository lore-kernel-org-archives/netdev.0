From: Dmitry Vyukov <dvyukov@google.com>
Subject: sctp: bad hash index calculation
Date: Mon, 15 Feb 2016 16:11:22 +0100
Message-ID: <CACT4Y+bKiens=uiZ99t+9ThtXi33W_bQLqh_AgWkQeQDmyUE5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	linux-sctp@vger.kernel.org,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:33731 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbcBOPLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 10:11:43 -0500
Received: by mail-wm0-f49.google.com with SMTP id g62so153064876wme.0
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 07:11:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

While looking into some memory leaks of sctp ports I've noticed that
sctp_init initializes port hash table as follows:

    /* Allocate and initialize the SCTP port hash table.  */
    do {
        sctp_port_hashsize = (1UL << order) * PAGE_SIZE /
                    sizeof(struct sctp_bind_hashbucket);
        if ((sctp_port_hashsize > (64 * 1024)) && order > 0)
            continue;
        sctp_port_hashtable = (struct sctp_bind_hashbucket *)
            __get_free_pages(GFP_KERNEL | __GFP_NOWARN, order);
    } while (!sctp_port_hashtable && --order > 0);

and then hash index is computed as follows:

/* Warning: The following hash functions assume a power of two 'size'. */
/* This is the hash function for the SCTP port hash table. */
static inline int sctp_phashfn(struct net *net, __u16 lport)
{
    return (net_hash_mix(net) + lport) & (sctp_port_hashsize - 1);
}

I don't see what ensures that sctp_port_hashsize is in fact a power-of-2.

spinlock_t in sctp_bind_hashbucket can be 2 words in some configs,
then sizeof(sctp_bind_hashbucket) == 24, which can render half of hash
table unused.

struct sctp_bind_hashbucket {
        spinlock_t      lock;
        struct hlist_head       chain;
};

Am I missing something?
