From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v4 11/16] net: sched: rcu'ify cls_rsvp
Date: Wed, 10 Sep 2014 18:30:58 -0700
Message-ID: <1410399058.7106.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140910154517.2036.53084.stgit@nitbit.x32>
	 <20140910155116.2036.68040.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:57143 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbaIKBbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 21:31:00 -0400
Received: by mail-pd0-f175.google.com with SMTP id z10so12185397pdj.6
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 18:31:00 -0700 (PDT)
In-Reply-To: <20140910155116.2036.68040.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-10 at 08:51 -0700, John Fastabend wrote:
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_rsvp.h |  157 ++++++++++++++++++++++++++++----------------------
>  1 file changed, 89 insertions(+), 68 deletions(-)
> 
> diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
> index 1020e23..afa508b 100644
> --- a/net/sched/cls_rsvp.h
> +++ b/net/sched/cls_rsvp.h
> @@ -70,31 +70,34 @@ struct rsvp_head {
>  	u32			tmap[256/32];
>  	u32			hgenerator;
>  	u8			tgenerator;
> -	struct rsvp_session	*ht[256];
> +	struct rsvp_session __rcu *ht[256];
> +	struct rcu_head		rcu;
>  };
>  
>  struct rsvp_session {
> -	struct rsvp_session	*next;
> -	__be32			dst[RSVP_DST_LEN];
> -	struct tc_rsvp_gpi 	dpi;
> -	u8			protocol;
> -	u8			tunnelid;
> +	struct rsvp_session __rcu	*next;
> +	__be32				dst[RSVP_DST_LEN];
> +	struct tc_rsvp_gpi		dpi;
> +	u8				protocol;
> +	u8				tunnelid;
>  	/* 16 (src,sport) hash slots, and one wildcard source slot */
> -	struct rsvp_filter	*ht[16 + 1];
> +	struct rsvp_filter __rcu	*ht[16 + 1];
> +	struct rcu_head			rcu;
>  };
>  
> 
>  struct rsvp_filter {
> -	struct rsvp_filter	*next;
> -	__be32			src[RSVP_DST_LEN];
> -	struct tc_rsvp_gpi	spi;
> -	u8			tunnelhdr;
> +	struct rsvp_filter __rcu	*next;
> +	__be32				src[RSVP_DST_LEN];
> +	struct tc_rsvp_gpi		spi;
> +	u8				tunnelhdr;
>  
> -	struct tcf_result	res;
> -	struct tcf_exts		exts;
> +	struct tcf_result		res;
> +	struct tcf_exts			exts;
>  
> -	u32			handle;
> -	struct rsvp_session	*sess;
> +	u32				handle;
> +	struct rsvp_session		*sess;
> +	struct rcu_head			rcu;
>  };
>  
>  static inline unsigned int hash_dst(__be32 *dst, u8 protocol, u8 tunnelid)
> @@ -128,7 +131,7 @@ static inline unsigned int hash_src(__be32 *src)
>  static int rsvp_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>  			 struct tcf_result *res)
>  {
> -	struct rsvp_session **sht = ((struct rsvp_head *)tp->root)->ht;
> +	struct rsvp_head *head = rcu_dereference_bh(tp->root);
>  	struct rsvp_session *s;
>  	struct rsvp_filter *f;
>  	unsigned int h1, h2;
> @@ -169,7 +172,8 @@ restart:
>  	h1 = hash_dst(dst, protocol, tunnelid);
>  	h2 = hash_src(src);
>  
> -	for (s = sht[h1]; s; s = s->next) {
> +	for (s = rcu_dereference_bh(head->ht[h1]); s;
> +	     s = rcu_dereference_bh(s->next)) {
>  		if (dst[RSVP_DST_LEN-1] == s->dst[RSVP_DST_LEN - 1] &&
>  		    protocol == s->protocol &&
>  		    !(s->dpi.mask &
> @@ -181,7 +185,8 @@ restart:
>  #endif
>  		    tunnelid == s->tunnelid) {
>  
> -			for (f = s->ht[h2]; f; f = f->next) {
> +			for (f = rcu_dereference_bh(s->ht[h2]); f;
> +			     f = rcu_dereference_bh(f->next)) {
>  				if (src[RSVP_DST_LEN-1] == f->src[RSVP_DST_LEN - 1] &&
>  				    !(f->spi.mask & (*(u32 *)(xprt + f->spi.offset) ^ f->spi.key))
>  #if RSVP_DST_LEN == 4
> @@ -205,7 +210,8 @@ matched:
>  			}
>  
>  			/* And wildcard bucket... */
> -			for (f = s->ht[16]; f; f = f->next) {
> +			for (f = rcu_dereference_bh(s->ht[16]); f;
> +			     f = rcu_dereference_bh(f->next)) {
>  				*res = f->res;
>  				RSVP_APPLY_RESULT();
>  				goto matched;
> @@ -218,7 +224,7 @@ matched:
>  
>  static unsigned long rsvp_get(struct tcf_proto *tp, u32 handle)
>  {
> -	struct rsvp_session **sht = ((struct rsvp_head *)tp->root)->ht;
> +	struct rsvp_head *head = rtnl_dereference(tp->root);
>  	struct rsvp_session *s;
>  	struct rsvp_filter *f;
>  	unsigned int h1 = handle & 0xFF;
> @@ -227,8 +233,10 @@ static unsigned long rsvp_get(struct tcf_proto *tp, u32 handle)
>  	if (h2 > 16)
>  		return 0;
>  
> -	for (s = sht[h1]; s; s = s->next) {
> -		for (f = s->ht[h2]; f; f = f->next) {
> +	for (s = rtnl_dereference(head->ht[h1]); s;
> +	     s = rtnl_dereference(s->next)) {
> +		for (f = rtnl_dereference(s->ht[h2]); f;
> +		     f = rtnl_dereference(f->next)) {
>  			if (f->handle == handle)
>  				return (unsigned long)f;
>  		}
> @@ -246,7 +254,7 @@ static int rsvp_init(struct tcf_proto *tp)
>  
>  	data = kzalloc(sizeof(struct rsvp_head), GFP_KERNEL);
>  	if (data) {
> -		tp->root = data;
> +		rcu_assign_pointer(tp->root, data);
>  		return 0;
>  	}
>  	return -ENOBUFS;
> @@ -257,53 +265,55 @@ rsvp_delete_filter(struct tcf_proto *tp, struct rsvp_filter *f)
>  {
>  	tcf_unbind_filter(tp, &f->res);
>  	tcf_exts_destroy(tp, &f->exts);
> -	kfree(f);
> +	kfree_rcu(f, rcu);
>  }
>  
>  static void rsvp_destroy(struct tcf_proto *tp)
>  {
> -	struct rsvp_head *data = xchg(&tp->root, NULL);
> -	struct rsvp_session **sht;
> +	struct rsvp_head *data = rtnl_dereference(tp->root);
>  	int h1, h2;
>  
>  	if (data == NULL)
>  		return;
>  
> -	sht = data->ht;
> +	RCU_INIT_POINTER(tp->root, NULL);
>  
>  	for (h1 = 0; h1 < 256; h1++) {
>  		struct rsvp_session *s;
>  
> -		while ((s = sht[h1]) != NULL) {
> -			sht[h1] = s->next;
> +		while ((s = rtnl_dereference(data->ht[h1])) != NULL) {
> +			RCU_INIT_POINTER(data->ht[h1], s->next);
>  
>  			for (h2 = 0; h2 <= 16; h2++) {
>  				struct rsvp_filter *f;
>  
> -				while ((f = s->ht[h2]) != NULL) {
> -					s->ht[h2] = f->next;
> +				while ((f = rtnl_dereference(s->ht[h2])) != NULL) {
> +					rcu_assign_pointer(s->ht[h2], f->next);
>  					rsvp_delete_filter(tp, f);
>  				}
>  			}
> -			kfree(s);
> +			kfree_rcu(s, rcu);
>  		}
>  	}
> -	kfree(data);
> +	RCU_INIT_POINTER(tp->root, NULL);

Strange, you already did the RCU_INIT_POINTER(tp->root, NULL) before the
for(h1 = 0; h1 < 256; h1++) loop

 

> +	kfree_rcu(data, rcu);
>  }
>  
>  static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
>  {
> -	struct rsvp_filter **fp, *f = (struct rsvp_filter *)arg;
> +	struct rsvp_head *head = rtnl_dereference(tp->root);
> +	struct rsvp_filter *nfp, *f = (struct rsvp_filter *)arg;
> +	struct rsvp_filter __rcu **fp;
>  	unsigned int h = f->handle;
> -	struct rsvp_session **sp;
> -	struct rsvp_session *s = f->sess;
> +	struct rsvp_session __rcu **sp;
> +	struct rsvp_session *nsp, *s = f->sess;
>  	int i;
>  
> -	for (fp = &s->ht[(h >> 8) & 0xFF]; *fp; fp = &(*fp)->next) {
> -		if (*fp == f) {
> -			tcf_tree_lock(tp);
> +	fp = &s->ht[(h >> 8) & 0xFF];
> +	for (nfp = rtnl_dereference(*fp); nfp;
> +	     fp = &nfp->next, nfp = rtnl_dereference(*fp)) {
> +		if (nfp == f) {
>  			*fp = f->next;

It seems you do not follow your own convention here ?

RCU_INIT_POINTER(*fp, f->next);

> -			tcf_tree_unlock(tp);
>  			rsvp_delete_filter(tp, f);
>  
>  			/* Strip tree */
> @@ -313,14 +323,12 @@ static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
>  					return 0;
>  
>  			/* OK, session has no flows */
> -			for (sp = &((struct rsvp_head *)tp->root)->ht[h & 0xFF];
> -			     *sp; sp = &(*sp)->next) {
> -				if (*sp == s) {
> -					tcf_tree_lock(tp);
> +			sp = &head->ht[h & 0xFF];
> +			for (nsp = rtnl_dereference(*sp); nsp;
> +			     sp = &nsp->next, nsp = rtnl_dereference(*sp)) {
> +				if (nsp == s) {
>  					*sp = s->next;

Same remark here.

> -					tcf_tree_unlock(tp);
> -
> -					kfree(s);
> +					kfree_rcu(s, rcu);
>  					return 0;
>  				}
>  			}
> @@ -333,7 +341,7 @@ static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)

Thanks !
