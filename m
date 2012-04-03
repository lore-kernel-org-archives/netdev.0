From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/3] netfilter: xt_CT: remove a compile warning
Date: Tue, 3 Apr 2012 12:39:03 +0200
Message-ID: <20120403103903.GA20689@1984>
References: <1333448001-2507-1-git-send-email-pablo@netfilter.org>
 <1333448001-2507-4-git-send-email-pablo@netfilter.org>
 <201204031927.AIJ09351.FQFMJOOVFSOtHL@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="NzB8fVQJ5HfG6fxh"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39674 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751458Ab2DCKjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 06:39:13 -0400
Content-Disposition: inline
In-Reply-To: <201204031927.AIJ09351.FQFMJOOVFSOtHL@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Tue, Apr 03, 2012 at 07:27:50PM +0900, Tetsuo Handa wrote:
> pablo@netfilter.org:
> > From: Pablo Neira Ayuso <pablo@netfilter.org>
> > 
> > If CONFIG_NF_CONNTRACK_TIMEOUT=n we have following warning :
> > 
> >   CC [M]  net/netfilter/xt_CT.o
> > net/netfilter/xt_CT.c: In function ‘xt_ct_tg_check_v1’:
> > net/netfilter/xt_CT.c:284: warning: label ‘err4’ defined but not used
> > 
> > Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> > ---
> >  net/netfilter/xt_CT.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
> > index 0c8e438..138b75e 100644
> > --- a/net/netfilter/xt_CT.c
> > +++ b/net/netfilter/xt_CT.c
> > @@ -281,8 +281,10 @@ out:
> >  	info->ct = ct;
> >  	return 0;
> >  
> > +#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
> >  err4:
> >  	rcu_read_unlock();
> > +#endif
> >  err3:
> >  	nf_conntrack_free(ct);
> >  err2:
> > -- 
> > 1.7.2.5
> 
> Looking at that function:
> 
[...]
> 262                         }
> 263                         timeout_ext = nf_ct_timeout_ext_add(ct, timeout,
> 264                                                             GFP_KERNEL);
>                             We are under rcu_read_lock() here.

David, can you also apply the following patch?

Thanks.

--NzB8fVQJ5HfG6fxh
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-xt_CT-allocation-has-to-be-GFP_ATOMIC-unde.patch"

>From e21e9622a46a60bd2b8dfb9791bb63dfdd4940d7 Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 3 Apr 2012 12:32:15 +0200
Subject: [PATCH] netfilter: xt_CT: allocation has to be GFP_ATOMIC under rcu_read_lock section

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 138b75e..4babb27 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -261,7 +261,7 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 				goto err4;
 			}
 			timeout_ext = nf_ct_timeout_ext_add(ct, timeout,
-							    GFP_KERNEL);
+							    GFP_ATOMIC);
 			if (timeout_ext == NULL) {
 				ret = -ENOMEM;
 				goto err4;
-- 
1.7.2.5


--NzB8fVQJ5HfG6fxh--
