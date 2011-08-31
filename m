From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 1/2] Define security_sk_getsecctx
Date: Wed, 31 Aug 2011 08:43:06 -0700
Message-ID: <4E5E568A.4050407@schaufler-ca.com>
References: <1314779777-12669-1-git-send-email-rongqing.li@windriver.com> <1314779777-12669-2-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org,
	Casey Schaufler <casey@schaufler-ca.com>
To: rongqing.li@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm17-vm0.access.bullet.mail.mud.yahoo.com ([66.94.236.21]:43921
	"HELO nm17-vm0.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756264Ab1HaPst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 11:48:49 -0400
In-Reply-To: <1314779777-12669-2-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/31/2011 1:36 AM, rongqing.li@windriver.com wrote:
> From: Roy.Li <rongqing.li@windriver.com>
>
> Define security_sk_getsecctx to return the security
> context of a sock.

So, what is the intended use of the information
coming from this hook? If I wanted to write the
Smack hook, which of the "contexts" would I want
to return? There are potentially three. If I know
what the caller is looking for, I can (hopefully)
select the correct information.

> Signed-off-by: Roy.Li <rongqing.li@windriver.com>
> ---
>  include/linux/security.h |   13 +++++++++++++
>  security/capability.c    |    6 ++++++
>  security/security.c      |    6 ++++++
>  security/selinux/hooks.c |    9 +++++++++
>  4 files changed, 34 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/security.h b/include/linux/security.h
> index ebd2a53..6bb8e0c 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -959,6 +959,12 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
>   * @sk_getsecid:
>   *	Retrieve the LSM-specific secid for the sock to enable caching of network
>   *	authorizations.
> + * @sk_getsecctx:
> + *	Returns a string containing sock security context information
> + *	@sk whom we wish to get the security context.
> + *	@ctx is the address of the pointer to where to place the allocated
> + *	security context.
> + *	@ctxlen points to the value of the length of the security context.
>   * @sock_graft:
>   *	Sets the socket's isec sid to the sock's sid.
>   * @inet_conn_request:
> @@ -1600,6 +1606,7 @@ struct security_operations {
>  	void (*sk_free_security) (struct sock *sk);
>  	void (*sk_clone_security) (const struct sock *sk, struct sock *newsk);
>  	void (*sk_getsecid) (struct sock *sk, u32 *secid);
> +	int (*sk_getsecctx) (struct sock *sk, void **ctx, u32 *ctxlen);
>  	void (*sock_graft) (struct sock *sk, struct socket *parent);
>  	int (*inet_conn_request) (struct sock *sk, struct sk_buff *skb,
>  				  struct request_sock *req);
> @@ -2574,6 +2581,7 @@ void security_secmark_refcount_dec(void);
>  int security_tun_dev_create(void);
>  void security_tun_dev_post_create(struct sock *sk);
>  int security_tun_dev_attach(struct sock *sk);
> +int security_sk_getsecctx(struct sock *sk, void **ctx, u32 *ctxlen);
>  
>  #else	/* CONFIG_SECURITY_NETWORK */
>  static inline int security_unix_stream_connect(struct sock *sock,
> @@ -2751,6 +2759,11 @@ static inline int security_tun_dev_attach(struct sock *sk)
>  {
>  	return 0;
>  }
> +
> +static int security_sk_getsecctx(struct sock *sk, void **ctx, u32 *ctxlen)
> +{
> +	return -EOPNOTSUPP;
> +}
>  #endif	/* CONFIG_SECURITY_NETWORK */
>  
>  #ifdef CONFIG_SECURITY_NETWORK_XFRM
> diff --git a/security/capability.c b/security/capability.c
> index 2984ea4..89256a6 100644
> --- a/security/capability.c
> +++ b/security/capability.c
> @@ -664,6 +664,11 @@ static void cap_sk_getsecid(struct sock *sk, u32 *secid)
>  {
>  }
>  
> +static int cap_sk_getsecctx(struct sock *sk, void **ctx, u32 *ctxlen)
> +{
> +	return 0;
> +}
> +
>  static void cap_sock_graft(struct sock *sk, struct socket *parent)
>  {
>  }
> @@ -1032,6 +1037,7 @@ void __init security_fixup_ops(struct security_operations *ops)
>  	set_to_cap_if_null(ops, sk_free_security);
>  	set_to_cap_if_null(ops, sk_clone_security);
>  	set_to_cap_if_null(ops, sk_getsecid);
> +	set_to_cap_if_null(ops, sk_getsecctx);
>  	set_to_cap_if_null(ops, sock_graft);
>  	set_to_cap_if_null(ops, inet_conn_request);
>  	set_to_cap_if_null(ops, inet_csk_clone);
> diff --git a/security/security.c b/security/security.c
> index 0e4fccf..a939f5c 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -757,6 +757,12 @@ void security_task_getsecid(struct task_struct *p, u32 *secid)
>  }
>  EXPORT_SYMBOL(security_task_getsecid);
>  
> +int security_sk_getsecctx(struct sock *sk, void **ctx, u32 *ctxlen)
> +{
> +	return security_ops->sk_getsecctx(sk, ctx, ctxlen);
> +}
> +EXPORT_SYMBOL(security_sk_getsecctx);
> +
>  int security_task_setnice(struct task_struct *p, int nice)
>  {
>  	return security_ops->task_setnice(p, nice);
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 266a229..6e96f01 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -4284,6 +4284,14 @@ static void selinux_sk_getsecid(struct sock *sk, u32 *secid)
>  	}
>  }
>  
> +static int selinux_sk_getsecctx(struct sock *sk, void **ctx, u32 *ctxlen)
> +{
> +	u32 secid;
> +
> +	selinux_sk_getsecid(sk, &secid);
> +	return security_sid_to_context(secid, ctx, ctxlen);
> +}
> +
>  static void selinux_sock_graft(struct sock *sk, struct socket *parent)
>  {
>  	struct inode_security_struct *isec = SOCK_INODE(parent)->i_security;
> @@ -5613,6 +5621,7 @@ static struct security_operations selinux_ops = {
>  	.sk_free_security =		selinux_sk_free_security,
>  	.sk_clone_security =		selinux_sk_clone_security,
>  	.sk_getsecid =			selinux_sk_getsecid,
> +	.sk_getsecctx =                 selinux_sk_getsecctx,
>  	.sock_graft =			selinux_sock_graft,
>  	.inet_conn_request =		selinux_inet_conn_request,
>  	.inet_csk_clone =		selinux_inet_csk_clone,
