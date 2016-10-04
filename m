From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: fix garbage collect vs. MSG_PEEK
Date: Mon, 03 Oct 2016 21:51:03 -0400 (EDT)
Message-ID: <20161003.215103.2267442887041931968.davem@davemloft.net>
References: <1475150954-10152-1-git-send-email-mszeredi@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        hannes@stressinduktion.org, kernel@kyup.com
To: mszeredi@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475150954-10152-1-git-send-email-mszeredi@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <mszeredi@redhat.com>
Date: Thu, 29 Sep 2016 14:09:14 +0200

> @@ -1550,6 +1550,17 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
>  	return max_level;
>  }
>  
> +static void unix_peek_fds(struct scm_cookie *scm, struct sk_buff *skb)
> +{
> +	scm->fp = scm_fp_dup(UNIXCB(skb).fp);
> +	/*
> +	 * During garbage collection it is assumed that in-flight sockets don't
> +	 * get a new external reference.  So we need to wait until current run
> +	 * finishes.
> +	 */
> +	unix_gc_barrier();
> +}
 ...
> @@ -266,6 +266,11 @@ void wait_for_unix_gc(void)
>  	wait_event(unix_gc_wait, gc_in_progress == false);
>  }
>  
> +void unix_gc_barrier(void)
> +{
> +	spin_unlock_wait(&unix_gc_lock);
> +}

Can you explain why wait_for_unix_gc() isn't appropriate?  I'm a little
bit uncomfortable with a spinlock wait like this, and would rather see
something like the existing helper used.

Thanks.
