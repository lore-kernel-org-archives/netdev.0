From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 3/5] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Wed, 17 Aug 2016 09:16:02 -0700
Message-ID: <1471450562.29842.6.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
	 <1471442448-1248-4-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
	davem@davemloft.net, kafai@fb.com, fw@strlen.de,
	pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:32903 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839AbcHQQQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 12:16:04 -0400
Received: by mail-pa0-f67.google.com with SMTP id vy10so7502661pac.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 09:16:04 -0700 (PDT)
In-Reply-To: <1471442448-1248-4-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-17 at 16:00 +0200, Daniel Mack wrote:

> +		progp = is_ingress ? &cgrp->bpf_ingress : &cgrp->bpf_egress;
> +
> +		rcu_read_lock();
> +		old_prog = rcu_dereference(*progp);
> +		rcu_assign_pointer(*progp, prog);
> +
> +		if (old_prog)
> +			bpf_prog_put(old_prog);
> +
> +		rcu_read_unlock();


This is a bogus locking strategy.

You do not want to use rcu_read_lock()/rcu_read_unlock() here, but
appropriate writer exclusion (a mutex probably, or a spinlock)

Then use rcu_dereference_protected() instead of rcu_dereference(*progp);
