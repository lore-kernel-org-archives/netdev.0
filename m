From: Phil Oester <kernel@linuxace.com>
Subject: Re: [PATCH nf] netfilter: use RCU safe kfree for conntrack extensions
Date: Wed, 11 Sep 2013 10:09:47 -0700
Message-ID: <20130911170946.GA2926@linuxace.com>
References: <20130911090900.0129AE8AFF@unicorn.suse.cz>
 <20130911145715.GA2882@linuxace.com>
 <20130911152804.GA5397@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:64305 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755658Ab3IKRJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 13:09:40 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so9342075pbb.24
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 10:09:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130911152804.GA5397@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 11, 2013 at 05:28:05PM +0200, Michal Kubecek wrote:
> > Looking at
> > your proposed fix, the NAT extension data should have been cleaned
> > from the bysource list in nf_nat_cleanup_conntrack (via __nf_ct_ext_destroy)
> > before reaching the kfree.  Would you agree?
> 
> It is cleaned from the list but as it is an RCU list, other readers can
> still be holding pointers to it. We have to wait for the RCU grace
> period before we can reuse it.

Agreed - looks like your fix should work.  However, two nits:

1) normally RCU functions have _rcu suffixes.  So nf_ct_ext_free should
become nf_ct_ext_free_rcu.

2) kfree_rcu was not added to the kernel until 3.0.  All of the bug
reports I've been looking into (including the original in netfilter bugzilla
at http://bugzilla.netfilter.org/show_bug.cgi?id=714) have been reported in
2.6.32 or earlier kernels.  So a different fix would need to be backported for
-stable.  For that, we would probably export __nf_ct_ext_free_rcu from
nf_conntrack_extend.c and change the kfree call in nf_ct_ext_free_rcu to
call_rcu(&ct->ext->rcu, __nf_ct_ext_free_rcu). Of course the alternative
is just to use this fix for both old and new kernels for simplicity.

> No, it is a bugreport from our customer. And even that customer
> encountered it only once so far. Which is not very surprising as to
> reproduce it, you have to be (un)lucky twice: first to have someone
> overwrite the area soon enough and second to have someone access the
> area after it is overwritten.

Yes, hitting this seems dependent upon phase of the moon.

Phil
