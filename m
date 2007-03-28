From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Established connections hash function
Date: 28 Mar 2007 16:14:17 +0200
Message-ID: <p73y7lh316u.fsf@bingen.suse.de>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON>
	<p73lkhi6aj7.fsf@bingen.suse.de>
	<EED7DAB373CC4CB9B576EE1B1FBC9E32@XEON>
	<200703281129.43783.ak@suse.de> <20070328104505.GA18748@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nikb@webmaster.com, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:51136 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750992AbXC1NPb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 09:15:31 -0400
In-Reply-To: <20070328104505.GA18748@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:
> 
> Jenkins hash is far from being simple to crack, although with some
> knowledge it can be done faster.

TCP tends to be initialized early before there is anything
good in the entropy pool.

static void init_std_data(struct entropy_store *r)
{
        struct timeval tv;
        unsigned long flags;

        spin_lock_irqsave(&r->lock, flags);
        r->entropy_count = 0;
        spin_unlock_irqrestore(&r->lock, flags);

        do_gettimeofday(&tv);
        add_entropy_words(r, (__u32 *)&tv, sizeof(tv)/4);
        add_entropy_words(r, (__u32 *)utsname(),
                          sizeof(*(utsname()))/4);
}

utsname is useless here because it runs before user space has 
a chance to set it. The only truly variable thing is the 
boot time, which can be guessed with the ns part being brute forced.

To make it secure you would need to do regular rehash like
the routing cache which would pick up true randomness on the first
rehash.

-Andi
