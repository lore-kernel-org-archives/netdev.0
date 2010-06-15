From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 2/8] user_ns: Introduce user_nsmap_uid and
 user_ns_map_gid.
Date: Tue, 15 Jun 2010 15:58:19 -0500
Message-ID: <20100615205819.GD22129@hallyn.com>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>
 <m1d3vvhxlj.fsf@fess.ebiederm.org>
 <m17hm3hxjw.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Containers <containers@lists.osdl.org>,
	Serge Hallyn <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@parallels.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:61398 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758455Ab0FOU6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 16:58:04 -0400
Content-Disposition: inline
In-Reply-To: <m17hm3hxjw.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric W. Biederman (ebiederm@xmission.com):
> 
> Define what happens when a we view a uid from one user_namespace
> in another user_namepece.
> 
> - If the user namespaces are the same no mapping is necessary.
> 
> - For most cases of difference use overflowuid and overflowgid,
>   the uid and gid currently used for 16bit apis when we have a 32bit uid
>   that does fit in 16bits.  Effectively the situation is the same,
>   we want to return a uid or gid that is not assigned to any user.
> 
> - For the case when we happen to be mapping the uid or gid of the
>   creator of the target user namespace use uid 0 and gid as confusing

Looks good, except for 'uid 0 and gid' in commit msg will be confusing.
Just "use uid and gid 0".

>   that user with root is not a problem.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: Serge E. Hallyn <serue@us.ibm.com>

Mind you, like you I *am* still conflicted.

I believe the ideal behavior for the case where we're looking up a mapping
for a uid in a namespace created by ns, would be to return the creator's
uid, but then also support returning the POSIX capabilities targeted at
ns, which would be the empty set.

The path leading there is to start with this patch, then support sending
full credentials, and then we can modify this behavior.

(IMO)

thanks for pushing this.

-serge

> ---
>  include/linux/user_namespace.h |   14 ++++++++++++
>  kernel/user_namespace.c        |   44 ++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 58 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> index cc4f453..8178156 100644
> --- a/include/linux/user_namespace.h
> +++ b/include/linux/user_namespace.h
> @@ -36,6 +36,9 @@ static inline void put_user_ns(struct user_namespace *ns)
>  		kref_put(&ns->kref, free_user_ns);
>  }
>  
> +uid_t user_ns_map_uid(struct user_namespace *to, const struct cred *cred, uid_t uid);
> +gid_t user_ns_map_gid(struct user_namespace *to, const struct cred *cred, gid_t gid);
> +
>  #else
>  
>  static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
> @@ -52,6 +55,17 @@ static inline void put_user_ns(struct user_namespace *ns)
>  {
>  }
>  
> +static inline uid_t user_ns_map_uid(struct user_namespace *to,
> +	const struct cred *cred, uid_t uid)
> +{
> +	return uid;
> +}
> +static inline gid_t user_ns_map_gid(struct user_namespace *to,
> +	const struct cred *cred, gid_t gid)
> +{
> +	return gid;
> +}
> +
>  #endif
>  
>  #endif /* _LINUX_USER_H */
> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> index 076c7c8..825abfb 100644
> --- a/kernel/user_namespace.c
> +++ b/kernel/user_namespace.c
> @@ -9,6 +9,7 @@
>  #include <linux/nsproxy.h>
>  #include <linux/slab.h>
>  #include <linux/user_namespace.h>
> +#include <linux/highuid.h>
>  #include <linux/cred.h>
>  
>  /*
> @@ -82,3 +83,46 @@ void free_user_ns(struct kref *kref)
>  	schedule_work(&ns->destroyer);
>  }
>  EXPORT_SYMBOL(free_user_ns);
> +
> +uid_t user_ns_map_uid(struct user_namespace *to, const struct cred *cred, uid_t uid)
> +{
> +	struct user_namespace *tmp;
> +
> +	if (likely(to == cred->user->user_ns))
> +		return uid;
> +
> +
> +	/* Is cred->user the creator of the target user_ns
> +	 * or the creator of one of it's parents?
> +	 */
> +	for ( tmp = to; tmp != &init_user_ns;
> +	      tmp = tmp->creator->user_ns ) {
> +		if (cred->user == tmp->creator) {
> +			return (uid_t)0;
> +		}
> +	}
> +
> +	/* No useful relationship so no mapping */
> +	return overflowuid;
> +}
> +
> +gid_t user_ns_map_gid(struct user_namespace *to, const struct cred *cred, gid_t gid)
> +{
> +	struct user_namespace *tmp;
> +
> +	if (likely(to == cred->user->user_ns))
> +		return gid;
> +
> +	/* Is cred->user the creator of the target user_ns
> +	 * or the creator of one of it's parents?
> +	 */
> +	for ( tmp = to; tmp != &init_user_ns;
> +	      tmp = tmp->creator->user_ns ) {
> +		if (cred->user == tmp->creator) {
> +			return (gid_t)0;
> +		}
> +	}
> +
> +	/* No useful relationship so no mapping */
> +	return overflowgid;
> +}
> -- 
> 1.6.5.2.143.g8cc62
> 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
