From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] fix unsafe set_memory_rw from softirq
Date: Thu, 03 Oct 2013 22:16:38 -0700
Message-ID: <1380863798.3564.12.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380859875-31025-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:50187 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831Ab3JDFQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 01:16:40 -0400
In-Reply-To: <1380859875-31025-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-03 at 21:11 -0700, Alexei Starovoitov wrote:

> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index a6ac848..5d66cd9 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -25,15 +25,20 @@ struct sk_filter
>  {
>  	atomic_t		refcnt;
>  	unsigned int         	len;	/* Number of filter blocks */
> +	struct rcu_head		rcu;
>  	unsigned int		(*bpf_func)(const struct sk_buff *skb,
>  					    const struct sock_filter *filter);
> -	struct rcu_head		rcu;
> +	/* insns start right after bpf_func, so that sk_run_filter() fetches
> +	 * first insn from the same cache line that was used to call into
> +	 * sk_run_filter()
> +	 */
>  	struct sock_filter     	insns[0];
>  };
>  
>  static inline unsigned int sk_filter_len(const struct sk_filter *fp)
>  {
> -	return fp->len * sizeof(struct sock_filter) + sizeof(*fp);
> +	return max(fp->len * sizeof(struct sock_filter),
> +		   sizeof(struct work_struct)) + sizeof(*fp);
>  }

I would use for include/linux/filter.h this (untested) diff :

(Note the include <linux/workqueue.h>)

I also remove your comment about cache lines, since there is nothing
to align stuff on a cache line boundary.

diff --git a/include/linux/filter.h b/include/linux/filter.h
index a6ac848..281b05c 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -6,6 +6,7 @@
 
 #include <linux/atomic.h>
 #include <linux/compat.h>
+#include <linux/workqueue.h>
 #include <uapi/linux/filter.h>
 
 #ifdef CONFIG_COMPAT
@@ -25,15 +26,20 @@ struct sk_filter
 {
 	atomic_t		refcnt;
 	unsigned int         	len;	/* Number of filter blocks */
+	struct rcu_head		rcu;
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
 					    const struct sock_filter *filter);
-	struct rcu_head		rcu;
-	struct sock_filter     	insns[0];
+	union {
+		struct work_struct	work;
+		struct sock_filter	insns[0];
+	};
 };
 
-static inline unsigned int sk_filter_len(const struct sk_filter *fp)
+static inline unsigned int sk_filter_size(const struct sk_filter *fp,
+					  unsigned int proglen)
 {
-	return fp->len * sizeof(struct sock_filter) + sizeof(*fp);
+	return max(sizeof(*fp),
+		   offsetof(struct sk_filter, insns[proglen]));
 }
 
 extern int sk_filter(struct sock *sk, struct sk_buff *skb);



This way, you can use sk_filter_size(fp, fprog->len)
instead of doing the max() games in sk_attach_filter() and
sk_unattached_filter_create()

Other than that, I think your patch is fine.
