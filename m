From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 2/4] flowcache: make flow_cache_hash_size() return
 "unsigned int"
Date: Mon, 20 Mar 2017 09:08:30 +0300
Message-ID: <20170320060830.GA1789@avx2>
References: <20170319222449.GB17015@avx2>
 <1489965221.16816.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34362 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752998AbdCTGRJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 02:17:09 -0400
Received: by mail-lf0-f67.google.com with SMTP id y193so9221552lfd.1
        for <netdev@vger.kernel.org>; Sun, 19 Mar 2017 23:17:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1489965221.16816.14.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 19, 2017 at 04:13:41PM -0700, Eric Dumazet wrote:
> On Mon, 2017-03-20 at 01:24 +0300, Alexey Dobriyan wrote:
> > Hash size can't negative so "unsigned int" is logically correct.
> 
> 
> >  	struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, cpu);
> > -	size_t sz = sizeof(struct hlist_head) * flow_cache_hash_size(fc);
> > +	unsigned int sz = sizeof(struct hlist_head) * flow_cache_hash_size(fc);
> >  
> >  	if (!fcp->hash_table) {
> >  		fcp->hash_table = kzalloc_node(sz, GFP_KERNEL, cpu_to_node(cpu));
> >  		if (!fcp->hash_table) {
> > -			pr_err("NET: failed to allocate flow cache sz %zu\n", sz);
> > +			pr_err("NET: failed to allocate flow cache sz %u\n", sz);
> 
> 
> I do not see any improvement here.
> 
> What is wrong with size_t exactly ?

REX prefixes and sign extensions, lots of them.

Before:
	ffffffff8505b1b5:       41 bd 01 00 00 00       mov    r13d,0x1
	ffffffff8505b1bb:       41 d3 e5                shl    r13d,cl
	ffffffff8505b1be:       4d 63 ed                movsxd r13,r13d
	ffffffff8505b1c1:       49 c1 e5 03             shl    r13,0x3
	ffffffff8505b1c5:       e8 86 28 0a fc          call   __cpu_to_node
			...
	ffffffff8505b20b:       4c 89 ee                mov    rsi,r13

After:
	ffffffff8505b1b5:       41 bd 08 00 00 00       mov    r13d,0x8
	ffffffff8505b1bb:       41 d3 e5                shl    r13d,cl
	ffffffff8505b1be:       e8 8d 28 0a fc          call   __cpu_to_node
			...
	ffffffff8505b1c3:       44 89 ef                mov    edi,r13d

Basically, one can do s/size_t/unsigned int/g across whole networking
stack and nothing will change but the code becomes smaller (including
things like sendmsg() because VFS truncates lengths at INT_MAX).
