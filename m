From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 37/50] netfilter: nf_tables: atomic dump and reset for
 stateful objects
Date: Fri, 09 Dec 2016 06:24:52 -0800
Message-ID: <1481293492.4930.168.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
         <1481147576-5690-38-git-send-email-pablo@netfilter.org>
         <CAP=VYLp-ZBFjR1W9=V_vyPYAi1=Yub3ugq6D8hkoLigcPaaxFg@mail.gmail.com>
         <20161209102432.GA986@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
        netfilter-devel@vger.kernel.org,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34719 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933380AbcLIOYy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 09:24:54 -0500
In-Reply-To: <20161209102432.GA986@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-12-09 at 11:24 +0100, Pablo Neira Ayuso wrote:
> Hi Paul,

Hi Pablo

Given that bytes/packets counters are modified without cmpxchg64()  :

static inline void nft_counter_do_eval(struct nft_counter_percpu_priv *priv,
                                       struct nft_regs *regs,
                                       const struct nft_pktinfo *pkt)
{
        struct nft_counter_percpu *this_cpu;

        local_bh_disable();
        this_cpu = this_cpu_ptr(priv->counter);
        u64_stats_update_begin(&this_cpu->syncp);
        this_cpu->counter.bytes += pkt->skb->len;
        this_cpu->counter.packets++;
        u64_stats_update_end(&this_cpu->syncp);
        local_bh_enable();
}

It means that the cmpxchg64() used to clear the stats is not good enough.

It does not help to make sure stats are properly cleared.

On 64 bit, the ->syncp is not there, so the nft_counter_reset() might
not see that a bytes or packets counter was modified by another cpu.


CPU 1                              CPU 2

LOAD PTR->BYTES into REG_A         old = *counter;
REG_A += skb->len;
                                   cmpxchg64(counter, old, 0);
PTR->BYTES = REG_A

It looks that you want a seqcount, even on 64bit arches,
so that CPU 2 can restart its loop, and more importantly you need
to not accumulate the values you read, because they might be old/invalid.

Another way would be to not use cmpxchg64() at all.
Way to expensive in fast path !

The percpu value would never be modified by an other cpu than the owner.

You need a per cpu seqcount, no need to add a syncp per nft percpu counter.


static DEFINE_PERCPU(seqcount_t, nft_pcpu_seq);

static inline void nft_counter_do_eval(struct nft_counter_percpu_priv *priv,
                                       struct nft_regs *regs,
                                       const struct nft_pktinfo *pkt)
{
        struct nft_counter_percpu *this_cpu;
	seqcount_t *myseq;

        local_bh_disable();
        this_cpu = this_cpu_ptr(priv->counter);
	myseq = this_cpu_ptr(&nft_pcpu_seq);

	write_seqcount_begin(myseq);

        this_cpu->counter.bytes += pkt->skb->len;
        this_cpu->counter.packets++;

	write_seqcount_end(myseq);
	
        local_bh_enable();
}

Thanks !
