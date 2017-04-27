From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH v6 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to
 prevent overflow
Date: Thu, 27 Apr 2017 13:30:16 +0200
Message-ID: <20170427113016.GA12448@bistromath.localdomain>
References: <20170425155215.4835-1-Jason@zx2c4.com>
 <20170425184734.26563-1-Jason@zx2c4.com>
 <CAHmME9qDmcvzF_xeaxegC2RpBOs8PziJOaKEqv6Z_X1pUFbR0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>,
        kernel-hardening@lists.openwall.com,
        David Miller <davem@davemloft.net>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52402 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935655AbdD0LaU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 07:30:20 -0400
Content-Disposition: inline
In-Reply-To: <CAHmME9qDmcvzF_xeaxegC2RpBOs8PziJOaKEqv6Z_X1pUFbR0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-04-27, 11:21:51 +0200, Jason A. Donenfeld wrote:
> However, perhaps there's the chance that fraglist skbs having
> separate fraglists are actually forbidden? Is this the case?

Hmm, I think this can actually happen:

    /*  net/ipv4/ip_fragment.c  */
    static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
    			 struct net_device *dev)
    {
    
    ...
    
    	/* If the first fragment is fragmented itself, we split
    	 * it to two chunks: the first with data and paged part
    	 * and the second, holding only fragments. */
    	if (skb_has_frag_list(head)) {
    		struct sk_buff *clone;
    		int i, plen = 0;
    
    		clone = alloc_skb(0, GFP_ATOMIC);
    		if (!clone)
    			goto out_nomem;
    		clone->next = head->next;
    		head->next = clone;
    		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
    		skb_frag_list_init(head);
    		for (i = 0; i < skb_shinfo(head)->nr_frags; i++)
    			plen += skb_frag_size(&skb_shinfo(head)->frags[i]);
    		clone->len = clone->data_len = head->data_len - plen;
    		head->data_len -= clone->len;
    		head->len -= clone->len;
    		clone->csum = 0;
    		clone->ip_summed = head->ip_summed;
    		add_frag_mem_limit(qp->q.net, clone->truesize);
    	}
    
    ...
    }
    

You can test that with a vxlan tunnel on top of a vxlan tunnel ("real"
MTU is 1500, first tunnel MTU set to 10000, second tunnel MTU set to
40000 -- or anything, as long as they both get fragmented).

-- 
Sabrina
