From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [RFC PATCH 2/2] selinux: implement support for dynamic net hook
 [de-]registration
Date: Wed, 6 Apr 2016 15:32:07 -0700
Message-ID: <57058E67.5020502@schaufler-ca.com>
References: <cover.1459934322.git.pabeni@redhat.com>
 <b7f1a4578e0617c7361dd392282e03556aa37b46.1459934322.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Paul Moore <paul@paul-moore.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>,
	linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm36-vm2.bullet.mail.bf1.yahoo.com ([72.30.238.138]:53809 "EHLO
	nm36-vm2.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753348AbcDFWiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 18:38:24 -0400
In-Reply-To: <b7f1a4578e0617c7361dd392282e03556aa37b46.1459934322.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/6/2016 2:51 AM, Paolo Abeni wrote:
> This patch leverage the netlbl_changed() hook to perform on demand
> registration and deregistration of the netfilter hooks and the
> socket_sock_rcv_skb hook.
>
> With default policy and empty netfilter/netlabel configuration, the
> above hooks are not registered and this allows avoiding nf_hook_slow
> in the xmit path and socket_sock_rcv_skb() in the rx path.

There is no reason to assume that there is a relationship between
a netlabel configuration and a netfilter configuration. Smack always
has a netlabel configuration. Security modules (e.g. AppArmor) may
well use netfilter without netlabel.

Please stop assuming that security == SELinux. 

>
> This gives measurable network performance improvement in both
> directions.

In the case where SELinux is enabled and netfilter is not.

> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  security/selinux/hooks.c            | 72 +++++++++++++++++++++++++++++++------
>  security/selinux/include/security.h |  1 +
>  security/selinux/ss/services.c      |  1 +
>  security/selinux/xfrm.c             |  4 +++
>  4 files changed, 68 insertions(+), 10 deletions(-)
>
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 912deee..a3baa69 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -4745,11 +4745,13 @@ static int selinux_secmark_relabel_packet(u32 sid)
>  static void selinux_secmark_refcount_inc(void)
>  {
>  	atomic_inc(&selinux_secmark_refcount);
> +	selinux_net_update();
>  }
>  
>  static void selinux_secmark_refcount_dec(void)
>  {
>  	atomic_dec(&selinux_secmark_refcount);
> +	selinux_net_update();
>  }
>  
>  static void selinux_req_classify_flow(const struct request_sock *req,
> @@ -4836,6 +4838,11 @@ static int selinux_tun_dev_open(void *security)
>  	return 0;
>  }
>  
> +static void selinux_netlbl_changed(void)
> +{
> +	selinux_net_update();
> +}
> +
>  static int selinux_nlmsg_perm(struct sock *sk, struct sk_buff *skb)
>  {
>  	int err = 0;
> @@ -6091,7 +6098,6 @@ static struct security_hook_list selinux_hooks[] = {
>  	LSM_HOOK_INIT(socket_getsockopt, selinux_socket_getsockopt),
>  	LSM_HOOK_INIT(socket_setsockopt, selinux_socket_setsockopt),
>  	LSM_HOOK_INIT(socket_shutdown, selinux_socket_shutdown),
> -	LSM_HOOK_INIT(socket_sock_rcv_skb, selinux_socket_sock_rcv_skb),
>  	LSM_HOOK_INIT(socket_getpeersec_stream,
>  			selinux_socket_getpeersec_stream),
>  	LSM_HOOK_INIT(socket_getpeersec_dgram, selinux_socket_getpeersec_dgram),
> @@ -6113,6 +6119,7 @@ static struct security_hook_list selinux_hooks[] = {
>  	LSM_HOOK_INIT(tun_dev_attach_queue, selinux_tun_dev_attach_queue),
>  	LSM_HOOK_INIT(tun_dev_attach, selinux_tun_dev_attach),
>  	LSM_HOOK_INIT(tun_dev_open, selinux_tun_dev_open),
> +	LSM_HOOK_INIT(netlbl_changed, selinux_netlbl_changed),
>  
>  #ifdef CONFIG_SECURITY_NETWORK_XFRM
>  	LSM_HOOK_INIT(xfrm_policy_alloc_security, selinux_xfrm_policy_alloc),
> @@ -6145,6 +6152,11 @@ static struct security_hook_list selinux_hooks[] = {
>  #endif
>  };
>  
> +/* dynamically registered/unregisterd */
> +static struct security_hook_list selinux_sock_hooks[] = {
> +	LSM_HOOK_INIT(socket_sock_rcv_skb, selinux_socket_sock_rcv_skb),
> +};
> +
>  static __init int selinux_init(void)
>  {
>  	if (!security_module_enable("selinux")) {
> @@ -6240,7 +6252,9 @@ static struct nf_hook_ops selinux_nf_ops[] = {
>  #endif	/* IPV6 */
>  };
>  
> -static int __init selinux_nf_ip_init(void)
> +static bool nf_hooks_registered;
> +
> +static int selinux_nf_ip_init(void)
>  {
>  	int err;
>  
> @@ -6253,25 +6267,21 @@ static int __init selinux_nf_ip_init(void)
>  	if (err)
>  		panic("SELinux: nf_register_hooks: error %d\n", err);
>  
> +	nf_hooks_registered = true;
>  	return 0;
>  }
>  
> -__initcall(selinux_nf_ip_init);
> -
> -#ifdef CONFIG_SECURITY_SELINUX_DISABLE
>  static void selinux_nf_ip_exit(void)
>  {
>  	printk(KERN_DEBUG "SELinux:  Unregistering netfilter hooks\n");
>  
>  	nf_unregister_hooks(selinux_nf_ops, ARRAY_SIZE(selinux_nf_ops));
> +	nf_hooks_registered = false;
>  }
> -#endif
>  
>  #else /* CONFIG_NETFILTER */
>  
> -#ifdef CONFIG_SECURITY_SELINUX_DISABLE
>  #define selinux_nf_ip_exit()
> -#endif
>  
>  #endif /* CONFIG_NETFILTER */
>  
> @@ -6300,8 +6310,8 @@ int selinux_disable(void)
>  	/* Try to destroy the avc node cache */
>  	avc_disable();
>  
> -	/* Unregister netfilter hooks. */
> -	selinux_nf_ip_exit();
> +	/* Unregister net hooks. */
> +	selinux_net_update();
>  
>  	/* Unregister selinuxfs. */
>  	exit_sel_fs();
> @@ -6309,3 +6319,45 @@ int selinux_disable(void)
>  	return 0;
>  }
>  #endif
> +
> +DEFINE_MUTEX(selinux_net_mutex);
> +
> +static bool nf_hooks_required(void)
> +{
> +	return (selinux_secmark_enabled() || selinux_peerlbl_enabled() ||
> +		!selinux_policycap_netpeer) && selinux_enabled;
> +}
> +
> +static bool sock_hooks_required(void)
> +{
> +	return (!selinux_policycap_netpeer || selinux_secmark_enabled() ||
> +		selinux_peerlbl_enabled()) && selinux_enabled;
> +}
> +
> +static bool sock_hooks_registered;
> +
> +void selinux_net_update(void)
> +{
> +	if ((nf_hooks_required() == nf_hooks_registered) &&
> +	    (sock_hooks_required() == sock_hooks_registered))
> +		return;
> +
> +	mutex_lock(&selinux_net_mutex);
> +	if (nf_hooks_required() != nf_hooks_registered) {
> +		if (!nf_hooks_registered)
> +			selinux_nf_ip_init();
> +		else
> +			selinux_nf_ip_exit();
> +	}
> +
> +	if (sock_hooks_required() != sock_hooks_registered) {
> +		if (!sock_hooks_registered)
> +			security_add_hooks(selinux_sock_hooks,
> +					   ARRAY_SIZE(selinux_sock_hooks));
> +		else
> +			security_delete_hooks(selinux_sock_hooks,
> +					      ARRAY_SIZE(selinux_sock_hooks));
> +		sock_hooks_registered = !sock_hooks_registered;
> +	}
> +	mutex_unlock(&selinux_net_mutex);
> +}
> diff --git a/security/selinux/include/security.h b/security/selinux/include/security.h
> index 38feb55..0428ab4 100644
> --- a/security/selinux/include/security.h
> +++ b/security/selinux/include/security.h
> @@ -261,6 +261,7 @@ extern void selinux_status_update_setenforce(int enforcing);
>  extern void selinux_status_update_policyload(int seqno);
>  extern void selinux_complete_init(void);
>  extern int selinux_disable(void);
> +extern void selinux_net_update(void);
>  extern void exit_sel_fs(void);
>  extern struct path selinux_null;
>  extern struct vfsmount *selinuxfs_mount;
> diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
> index ebda973..c509018 100644
> --- a/security/selinux/ss/services.c
> +++ b/security/selinux/ss/services.c
> @@ -2016,6 +2016,7 @@ static void security_load_policycaps(void)
>  						  POLICYDB_CAPABILITY_OPENPERM);
>  	selinux_policycap_alwaysnetwork = ebitmap_get_bit(&policydb.policycaps,
>  						  POLICYDB_CAPABILITY_ALWAYSNETWORK);
> +	selinux_net_update();
>  }
>  
>  static int security_preserve_bools(struct policydb *p);
> diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
> index 56e354f..cc2b0d4 100644
> --- a/security/selinux/xfrm.c
> +++ b/security/selinux/xfrm.c
> @@ -112,6 +112,7 @@ static int selinux_xfrm_alloc_user(struct xfrm_sec_ctx **ctxp,
>  
>  	*ctxp = ctx;
>  	atomic_inc(&selinux_xfrm_refcount);
> +	selinux_net_update();
>  	return 0;
>  
>  err:
> @@ -128,6 +129,7 @@ static void selinux_xfrm_free(struct xfrm_sec_ctx *ctx)
>  		return;
>  
>  	atomic_dec(&selinux_xfrm_refcount);
> +	selinux_net_update();
>  	kfree(ctx);
>  }
>  
> @@ -303,6 +305,7 @@ int selinux_xfrm_policy_clone(struct xfrm_sec_ctx *old_ctx,
>  	if (!new_ctx)
>  		return -ENOMEM;
>  	atomic_inc(&selinux_xfrm_refcount);
> +	selinux_net_update();
>  	*new_ctxp = new_ctx;
>  
>  	return 0;
> @@ -370,6 +373,7 @@ int selinux_xfrm_state_alloc_acquire(struct xfrm_state *x,
>  
>  	x->security = ctx;
>  	atomic_inc(&selinux_xfrm_refcount);
> +	selinux_net_update();
>  out:
>  	kfree(ctx_str);
>  	return rc;
