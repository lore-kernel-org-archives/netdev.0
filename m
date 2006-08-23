From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] locking bug in fib_semantics.c
Date: Wed, 23 Aug 2006 11:31:19 -0700
Message-ID: <20060823113119.03f47a6a@dxpl.pdx.osdl.net>
References: <20060817093615.GA25553@ms2.inr.ac.ru>
	<20060821081642.GA2637@ff.dom.local>
	<20060821.011703.78716718.davem@davemloft.net>
	<20060821110201.GA3674@ff.dom.local>
	<20060822103556.GA3262@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:36327 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965099AbWHWSbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 14:31:19 -0400
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20060822103556.GA3262@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Aug 2006 12:35:56 +0200
Jarek Poplawski <jarkao2@o2.pl> wrote:

> On Mon, Aug 21, 2006 at 01:02:01PM +0200, Jarek Poplawski wrote:
> > On 21-08-2006 10:17, David Miller wrote:
> > > From: Jarek Poplawski <jarkao2@o2.pl>
> > > Date: Mon, 21 Aug 2006 10:16:43 +0200
> > ...
> > > I was skeptical of this case too, until I checked how
> > > fib_release_info() was called.
> > 
> > I overlooked this - so I've to sharpen my sight and look at it 
> > again - now knowing it's there.
> ...
> 
> Hello,
> I've found it at last but on that occasion I've got some
> doubt according to rcu_read_lock and rcu_call treatment:
> isn't it "illegal to block while in an RCU read-side
> section"? And I think it takes place in:
> 

No, it is perfectly okay for a cpu to acquire a lock
while in an RCU section, it just can't acquire a mutex/semaphore that
will put it to sleep. That is caught by the might_sleep() check.


> fib_lookup(): from tb_insert (fn_hash_insert() or
>   fn_trie_insert()), fib_create_info(), fib_check_nh() 
> 
> fn_trie_lookup(): like above, inet_addr_type(),
>   tb_lookup()
> 
> fib_rule_put(): like #1 above or #2 after tb_lookup(),
>   fib_res_put()
> 
> Shouldn't there be _bh also?

fib_rule_put only does something if refcount == 1 in which
case it is safe.

> 
> Jarek P.
> 
> PS: linux-2.6.18-rc4
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
