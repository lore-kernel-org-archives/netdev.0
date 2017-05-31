From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH nf-next] netns: add and use net_ns_barrier
Date: Wed, 31 May 2017 13:13:32 -0500
Message-ID: <87y3tcj3n7.fsf@xmission.com>
References: <20170530093812.10712-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20170530093812.10712-1-fw@strlen.de> (Florian Westphal's message
        of "Tue, 30 May 2017 11:38:12 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Westphal <fw@strlen.de> writes:

> Quoting Joe Stringer:
>   If a user loads nf_conntrack_ftp, sends FTP traffic through a network
>   namespace, destroys that namespace then unloads the FTP helper module,
>   then the kernel will crash.
>
> Events that lead to the crash:
> 1. conntrack is created with ftp helper in netns x
> 2. This netns is destroyed
> 3. netns destruction is scheduled
> 4. netns destruction wq starts, removes netns from global list
> 5. ftp helper is unloaded, which resets all helpers of the conntracks
> via for_each_net()
>
> but because netns is already gone from list the for_each_net() loop
> doesn't include it, therefore all of these conntracks are unaffected.
>
> 6. helper module unload finishes
> 7. netns wq invokes destructor for rmmod'ed helper
>
> CC: "Eric W. Biederman" <ebiederm@xmission.com>
> Reported-by: Joe Stringer <joe@ovn.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Eric, I'd like an explicit (n)ack from you for this one.

This doesn't look too scary but I have the impression we have addressed
this elsewhere with a different solution.

Looking...

Ok.  unregister_pernet_operations takes the net_mutex and thus
gives you this barrier automatically.

Hmm.  Why isn't this working for conntrack, looking...

nf_conntrack_ftp doesn't use unregister_pernet_operations...
nf_conntract_ftp does use nf_conntrack_helpers_unregister

I think I almost see the problem.

What is the per net code that stops dealing with the nf_conntract_ftp?

I am trying to figure out if your netns_barrier is reasonable or if
it treating the symptom.  I am having trouble seeing enough of what
conntrack is doing to judge.

Am I correct in understanding that the root problem is there is
something pointing to ftp_exp_policy at the time of module unload?

Eric


>  include/net/net_namespace.h       |  3 +++
>  net/core/net_namespace.c          | 17 +++++++++++++++++
>  net/netfilter/nf_conntrack_core.c |  9 +++++++++
>  3 files changed, 29 insertions(+)
>
> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> index fe80bb48ab1f..a24a57593202 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -158,6 +158,7 @@ extern struct net init_net;
>  struct net *copy_net_ns(unsigned long flags, struct user_namespace *user_ns,
>  			struct net *old_net);
>  
> +void net_ns_barrier(void);
>  #else /* CONFIG_NET_NS */
>  #include <linux/sched.h>
>  #include <linux/nsproxy.h>
> @@ -168,6 +169,8 @@ static inline struct net *copy_net_ns(unsigned long flags,
>  		return ERR_PTR(-EINVAL);
>  	return old_net;
>  }
> +
> +static inline void net_ns_barrier(void) {}
>  #endif /* CONFIG_NET_NS */
>  
>  
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 1934efd4a9d4..1f15abb1d733 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -482,6 +482,23 @@ static void cleanup_net(struct work_struct *work)
>  		net_drop_ns(net);
>  	}
>  }
> +
> +/**
> + * net_ns_barrier - wait until concurrent net_cleanup_work is done
> + *
> + * cleanup_net runs from work queue and will first remove namespaces
> + * from the global list, then run net exit functions.
> + *
> + * Call this in module exit path to make sure that all netns
> + * ->exit ops have been invoked before the function is removed.
> + */
> +void net_ns_barrier(void)
> +{
> +	mutex_lock(&net_mutex);
> +	mutex_unlock(&net_mutex);
> +}
> +EXPORT_SYMBOL(net_ns_barrier);
> +
>  static DECLARE_WORK(net_cleanup_work, cleanup_net);
>  
>  void __put_net(struct net *net)
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index c3bd9b086dcc..ee972ee7bf81 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1720,6 +1720,8 @@ EXPORT_SYMBOL_GPL(nf_ct_iterate_cleanup_net);
>   * Like nf_ct_iterate_cleanup, but first marks conntracks on the
>   * unconfirmed list as dying (so they will not be inserted into
>   * main table).
> + *
> + * Can only be called in module exit path.
>   */
>  void
>  nf_ct_iterate_destroy(int (*iter)(struct nf_conn *i, void *data), void *data)
> @@ -1734,6 +1736,13 @@ nf_ct_iterate_destroy(int (*iter)(struct nf_conn *i, void *data), void *data)
>  	}
>  	rtnl_unlock();
>  
> +	/* Need to wait for netns cleanup worker to finish, if its
> +	 * running -- it might have deleted a net namespace from
> +	 * the global list, so our __nf_ct_unconfirmed_destroy() might
> +	 * not have affected all namespaces.
> +	 */
> +	net_ns_barrier();
> +
>  	/* a conntrack could have been unlinked from unconfirmed list
>  	 * before we grabbed pcpu lock in __nf_ct_unconfirmed_destroy().
>  	 * This makes sure its inserted into conntrack table.
