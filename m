From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 3/5] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Wed, 17 Aug 2016 11:10:20 -0700
Message-ID: <20160817181018.GC98226@ast-mbp.thefacebook.com>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <1471442448-1248-4-git-send-email-daniel@zonque.org>
 <1471450562.29842.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel@zonque.org>, htejun@fb.com,
	daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
	kafai@fb.com, fw@strlen.de, pablo@netfilter.org, harald@redhat.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33228 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993AbcHQSXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 14:23:31 -0400
Received: by mail-pa0-f66.google.com with SMTP id vy10so7738517pac.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 11:23:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1471450562.29842.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 09:16:02AM -0700, Eric Dumazet wrote:
> On Wed, 2016-08-17 at 16:00 +0200, Daniel Mack wrote:
> 
> > +		progp = is_ingress ? &cgrp->bpf_ingress : &cgrp->bpf_egress;
> > +
> > +		rcu_read_lock();
> > +		old_prog = rcu_dereference(*progp);
> > +		rcu_assign_pointer(*progp, prog);
> > +
> > +		if (old_prog)
> > +			bpf_prog_put(old_prog);
> > +
> > +		rcu_read_unlock();
> 
> 
> This is a bogus locking strategy.

yep. this rcu_lock/unlock won't solve the race between parallel
bpf_prog_attach calls.
please use xchg() similar to bpf_fd_array_map_update_elem()
Then prog pointer will be swapped automically and bpf_prog_put()
will free it via call_rcu.
The reader side in sk_filter_cgroup_bpf() looks correct.
 
