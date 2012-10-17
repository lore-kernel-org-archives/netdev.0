From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v0 3/4] cgroup: net_cls: Pass in task to
 sock_update_classid()
Date: Wed, 17 Oct 2012 15:37:21 +0200
Message-ID: <1350481041.26103.454.camel@edumazet-glaptop>
References: <1350479078-29361-1-git-send-email-wagi@monom.org>
	 <1350479078-29361-4-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Glauber Costa <glommer@parallels.com>,
	Joe Perches <joe@perches.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stanislav Kinsbursky <skinsbursky@parallels.com>,
	Tejun Heo <tj@kernel.org>
To: Daniel Wagner <wagi@monom.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45608 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756824Ab2JQNh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 09:37:27 -0400
In-Reply-To: <1350479078-29361-4-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-17 at 15:04 +0200, Daniel Wagner wrote:
> From: Daniel Wagner <daniel.wagner@bmw-carit.de>
> 
> sock_update_classid() assumes that the update operation always are
> applied on the current task. sock_update_classid() needs to know on
> which tasks to work on in order to be able to migrate task between
> cgroups using the struct cgroup_subsys attach() callback.
> 
...

>  
> -extern void sock_update_classid(struct sock *sk);
> +extern void sock_update_classid(struct sock *sk, struct task_struct *task);
>  
>  #if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
>  static inline u32 task_cls_classid(struct task_struct *p)
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 8a146cf..68c2f3b 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1214,12 +1214,12 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
>  
>  #ifdef CONFIG_CGROUPS
>  #if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
> -void sock_update_classid(struct sock *sk)
> +void sock_update_classid(struct sock *sk, struct task_struct *task)
>  {
>  	u32 classid;
>  
>  	rcu_read_lock();  /* doing current task, which cannot vanish. */
> -	classid = task_cls_classid(current);
> +	classid = task_cls_classid(task);
>  	rcu_read_unlock();


Comment is now misleading (since task might not be current) and
rcu_read_lock()/rcu_read_unlock() protects nothing here, but avoid a
lockdep splat...

Hey task_cls_classid() has its own rcu protection since commit
3fb5a991916091a908d (cls_cgroup: Fix rcu lockdep warning)

So we can safely revert Paul commit (1144182a8757f2a1)
(We no longer need rcu_read_lock/unlock here)

(BTW net-next is not opened yet, its content outdated, although I like
your patch series !)
