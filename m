From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v2 3/3] tun: fix LSM/SELinux labeling of tun/tap
 devices
Date: Wed, 12 Dec 2012 11:22:36 +0200
Message-ID: <20121212092236.GB4354@redhat.com>
References: <20121205202144.18626.61966.stgit@localhost>
 <20121205202619.18626.98778.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, jasowang@redhat.com
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121205202619.18626.98778.stgit@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 05, 2012 at 03:26:19PM -0500, Paul Moore wrote:
> This patch corrects some problems with LSM/SELinux that were introduced
> with the multiqueue patchset.  The problem stems from the fact that the
> multiqueue work changed the relationship between the tun device and its
> associated socket; before the socket persisted for the life of the
> device, however after the multiqueue changes the socket only persisted
> for the life of the userspace connection (fd open).  For non-persistent
> devices this is not an issue, but for persistent devices this can cause
> the tun device to lose its SELinux label.
> 
> We correct this problem by adding an opaque LSM security blob to the
> tun device struct which allows us to have the LSM security state, e.g.
> SELinux labeling information, persist for the lifetime of the tun
> device.  In the process we tweak the LSM hooks to work with this new
> approach to TUN device/socket labeling and introduce a new LSM hook,
> security_tun_dev_create_queue(), to approve requests to create a new
> TUN queue via TUNSETQUEUE.
> 
> The SELinux code has been adjusted to match the new LSM hooks, the
> other LSMs do not make use of the LSM TUN controls.  This patch makes
> use of the recently added "tun_socket:create_queue" permission to
> restrict access to the TUNSETQUEUE operation.  On older SELinux
> policies which do not define the "tun_socket:create_queue" permission
> the access control decision for TUNSETQUEUE will be handled according
> to the SELinux policy's unknown permission setting.
> 
> Signed-off-by: Paul Moore <pmoore@redhat.com>
> ---
>  drivers/net/tun.c                 |   26 +++++++++++++---
>  include/linux/security.h          |   59 +++++++++++++++++++++++++++++--------
>  security/capability.c             |   24 +++++++++++++--
>  security/security.c               |   28 ++++++++++++++----
>  security/selinux/hooks.c          |   50 ++++++++++++++++++++++++-------
>  security/selinux/include/objsec.h |    4 +++
>  6 files changed, 153 insertions(+), 38 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 14a0454..fb8148b 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -182,6 +182,7 @@ struct tun_struct {
>  	struct hlist_head flows[TUN_NUM_FLOW_ENTRIES];
>  	struct timer_list flow_gc_timer;
>  	unsigned long ageing_time;
> +	void *security;
>  };
>  
>  static inline u32 tun_hashfn(u32 rxhash)
> @@ -465,6 +466,10 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
>  	struct tun_file *tfile = file->private_data;
>  	int err;
>  
> +	err = security_tun_dev_attach(tfile->socket.sk, tun->security);
> +	if (err < 0)
> +		goto out;
> +
>  	err = -EINVAL;
>  	if (rcu_dereference_protected(tfile->tun, lockdep_rtnl_is_held()))
>  		goto out;

This hook triggers with both set_queue and set_iff,
and it also seems to trigger when attaching to a
persistent device and when creating a new one. But I
believe we might want to be able to allow one but not the other.

For example:
	- we might want to allow qemu to do set_queue but not set_iff
	- we might want to configure presistent devices and
	  prevent a user from adding new ones

> @@ -1348,6 +1353,7 @@ static void tun_free_netdev(struct net_device *dev)
>  	struct tun_struct *tun = netdev_priv(dev);
>  
>  	tun_flow_uninit(tun);
> +	security_tun_dev_free_security(tun->security);
>  	free_netdev(dev);
>  }
>  
> @@ -1534,7 +1540,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  
>  		if (tun_not_capable(tun))
>  			return -EPERM;
> -		err = security_tun_dev_attach(tfile->socket.sk);
> +		err = security_tun_dev_open(tun->security);
>  		if (err < 0)
>  			return err;
>  
> @@ -1587,7 +1593,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  
>  		spin_lock_init(&tun->lock);
>  
> -		security_tun_dev_post_create(&tfile->sk);
> +		err = security_tun_dev_alloc_security(&tun->security);
> +		if (err < 0)
> +			goto err_free_dev;
>  
>  		tun_net_init(dev);
>  
> @@ -1767,12 +1775,18 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
>  
>  		tun = netdev_priv(dev);
>  		if (dev->netdev_ops != &tap_netdev_ops &&
> -			dev->netdev_ops != &tun_netdev_ops)
> +			dev->netdev_ops != &tun_netdev_ops) {
>  			ret = -EINVAL;
> -		else if (tun_not_capable(tun))
> +			goto unlock;
> +		}
> +		if (tun_not_capable(tun)) {
>  			ret = -EPERM;
> -		else
> -			ret = tun_attach(tun, file);
> +			goto unlock;
> +		}
> +		ret = security_tun_dev_create_queue(tun->security);
> +		if (ret < 0)
> +			goto unlock;
> +		ret = tun_attach(tun, file);
>  	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE)
>  		__tun_detach(tfile, false);
>  	else
> diff --git a/include/linux/security.h b/include/linux/security.h
> index 05e88bd..8ea923b 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -983,17 +983,29 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
>   *	tells the LSM to decrement the number of secmark labeling rules loaded
>   * @req_classify_flow:
>   *	Sets the flow's sid to the openreq sid.
> + * @tun_dev_alloc_security:
> + *	This hook allows a module to allocate a security structure for a TUN
> + *	device.
> + *	@security pointer to a security structure pointer.
> + *	Returns a zero on success, negative values on failure.
> + * @tun_dev_free_security:
> + *	This hook allows a module to free the security structure for a TUN
> + *	device.
> + *	@security pointer to the TUN device's security structure
>   * @tun_dev_create:
>   *	Check permissions prior to creating a new TUN device.
> - * @tun_dev_post_create:
> - *	This hook allows a module to update or allocate a per-socket security
> - *	structure.
> - *	@sk contains the newly created sock structure.

I worry that removing a hook hurt users that use it in their
ecurity policy.

> + * @tun_dev_create_queue:
> + *	Check permissions prior to creating a new TUN device queue.
> + *	@security pointer to the TUN device's security structure.
>   * @tun_dev_attach:
> - *	Check permissions prior to attaching to a persistent TUN device.  This
> - *	hook can also be used by the module to update any security state
> + *	This hook can be used by the module to update any security state
>   *	associated with the TUN device's sock structure.
>   *	@sk contains the existing sock structure.
> + *	@security pointer to the TUN device's security structure.
> + * @tun_dev_open:
> + *	This hook can be used by the module to update any security state
> + *	associated with the TUN device's security structure.
> + *	@security pointer to the TUN devices's security structure.
>   *
>   * Security hooks for XFRM operations.
>   *
> @@ -1613,9 +1625,12 @@ struct security_operations {
>  	void (*secmark_refcount_inc) (void);
>  	void (*secmark_refcount_dec) (void);
>  	void (*req_classify_flow) (const struct request_sock *req, struct flowi *fl);
> -	int (*tun_dev_create)(void);
> -	void (*tun_dev_post_create)(struct sock *sk);
> -	int (*tun_dev_attach)(struct sock *sk);
> +	int (*tun_dev_alloc_security) (void **security);
> +	void (*tun_dev_free_security) (void *security);
> +	int (*tun_dev_create) (void);
> +	int (*tun_dev_create_queue) (void *security);
> +	int (*tun_dev_attach) (struct sock *sk, void *security);
> +	int (*tun_dev_open) (void *security);
>  #endif	/* CONFIG_SECURITY_NETWORK */
>  
>  #ifdef CONFIG_SECURITY_NETWORK_XFRM
> @@ -2553,9 +2568,12 @@ void security_inet_conn_established(struct sock *sk,
>  int security_secmark_relabel_packet(u32 secid);
>  void security_secmark_refcount_inc(void);
>  void security_secmark_refcount_dec(void);
> +int security_tun_dev_alloc_security(void **security);
> +void security_tun_dev_free_security(void *security);
>  int security_tun_dev_create(void);
> -void security_tun_dev_post_create(struct sock *sk);
> -int security_tun_dev_attach(struct sock *sk);
> +int security_tun_dev_create_queue(void *security);
> +int security_tun_dev_attach(struct sock *sk, void *security);
> +int security_tun_dev_open(void *security);
>  
>  #else	/* CONFIG_SECURITY_NETWORK */
>  static inline int security_unix_stream_connect(struct sock *sock,
> @@ -2720,16 +2738,31 @@ static inline void security_secmark_refcount_dec(void)
>  {
>  }
>  
> +static inline int security_tun_dev_alloc_security(void **security)
> +{
> +	return 0;
> +}
> +
> +static inline void security_tun_dev_free_security(void *security)
> +{
> +}
> +
>  static inline int security_tun_dev_create(void)
>  {
>  	return 0;
>  }
>  
> -static inline void security_tun_dev_post_create(struct sock *sk)
> +static inline int security_tun_dev_create_queue(void *security)
> +{
> +	return 0;
> +}
> +
> +static inline int security_tun_dev_attach(struct sock *sk, void *security)
>  {
> +	return 0;
>  }
>  
> -static inline int security_tun_dev_attach(struct sock *sk)
> +static inline int security_tun_dev_open(void *security)
>  {
>  	return 0;
>  }
> diff --git a/security/capability.c b/security/capability.c
> index b14a30c..bf4cbf2 100644
> --- a/security/capability.c
> +++ b/security/capability.c
> @@ -704,16 +704,31 @@ static void cap_req_classify_flow(const struct request_sock *req,
>  {
>  }
>  
> +static int cap_tun_dev_alloc_security(void **security)
> +{
> +	return 0;
> +}
> +
> +static void cap_tun_dev_free_security(void *security)
> +{
> +}
> +
>  static int cap_tun_dev_create(void)
>  {
>  	return 0;
>  }
>  
> -static void cap_tun_dev_post_create(struct sock *sk)
> +static int cap_tun_dev_create_queue(void *security)
> +{
> +	return 0;
> +}
> +
> +static int cap_tun_dev_attach(struct sock *sk, void *security)
>  {
> +	return 0;
>  }
>  
> -static int cap_tun_dev_attach(struct sock *sk)
> +static int cap_tun_dev_open(void *security)
>  {
>  	return 0;
>  }
> @@ -1044,8 +1059,11 @@ void __init security_fixup_ops(struct security_operations *ops)
>  	set_to_cap_if_null(ops, secmark_refcount_inc);
>  	set_to_cap_if_null(ops, secmark_refcount_dec);
>  	set_to_cap_if_null(ops, req_classify_flow);
> +	set_to_cap_if_null(ops, tun_dev_alloc_security);
> +	set_to_cap_if_null(ops, tun_dev_free_security);
>  	set_to_cap_if_null(ops, tun_dev_create);
> -	set_to_cap_if_null(ops, tun_dev_post_create);
> +	set_to_cap_if_null(ops, tun_dev_create_queue);
> +	set_to_cap_if_null(ops, tun_dev_open);
>  	set_to_cap_if_null(ops, tun_dev_attach);
>  #endif	/* CONFIG_SECURITY_NETWORK */
>  #ifdef CONFIG_SECURITY_NETWORK_XFRM
> diff --git a/security/security.c b/security/security.c
> index 8dcd4ae..4d82654 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -1244,24 +1244,42 @@ void security_secmark_refcount_dec(void)
>  }
>  EXPORT_SYMBOL(security_secmark_refcount_dec);
>  
> +int security_tun_dev_alloc_security(void **security)
> +{
> +	return security_ops->tun_dev_alloc_security(security);
> +}
> +EXPORT_SYMBOL(security_tun_dev_alloc_security);
> +
> +void security_tun_dev_free_security(void *security)
> +{
> +	security_ops->tun_dev_free_security(security);
> +}
> +EXPORT_SYMBOL(security_tun_dev_free_security);
> +
>  int security_tun_dev_create(void)
>  {
>  	return security_ops->tun_dev_create();
>  }
>  EXPORT_SYMBOL(security_tun_dev_create);
>  
> -void security_tun_dev_post_create(struct sock *sk)
> +int security_tun_dev_create_queue(void *security)
>  {
> -	return security_ops->tun_dev_post_create(sk);
> +	return security_ops->tun_dev_create_queue(security);
>  }
> -EXPORT_SYMBOL(security_tun_dev_post_create);
> +EXPORT_SYMBOL(security_tun_dev_create_queue);
>  
> -int security_tun_dev_attach(struct sock *sk)
> +int security_tun_dev_attach(struct sock *sk, void *security)
>  {
> -	return security_ops->tun_dev_attach(sk);
> +	return security_ops->tun_dev_attach(sk, security);
>  }
>  EXPORT_SYMBOL(security_tun_dev_attach);
>  
> +int security_tun_dev_open(void *security)
> +{
> +	return security_ops->tun_dev_open(security);
> +}
> +EXPORT_SYMBOL(security_tun_dev_open);
> +
>  #endif	/* CONFIG_SECURITY_NETWORK */
>  
>  #ifdef CONFIG_SECURITY_NETWORK_XFRM
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 61a5336..f1efb08 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -4399,6 +4399,24 @@ static void selinux_req_classify_flow(const struct request_sock *req,
>  	fl->flowi_secid = req->secid;
>  }
>  
> +static int selinux_tun_dev_alloc_security(void **security)
> +{
> +	struct tun_security_struct *tunsec;
> +
> +	tunsec = kzalloc(sizeof(*tunsec), GFP_KERNEL);
> +	if (!tunsec)
> +		return -ENOMEM;
> +	tunsec->sid = current_sid();
> +
> +	*security = tunsec;
> +	return 0;
> +}
> +
> +static void selinux_tun_dev_free_security(void *security)
> +{
> +	kfree(security);
> +}
> +
>  static int selinux_tun_dev_create(void)
>  {
>  	u32 sid = current_sid();
> @@ -4414,8 +4432,17 @@ static int selinux_tun_dev_create(void)
>  			    NULL);
>  }
>  
> -static void selinux_tun_dev_post_create(struct sock *sk)
> +static int selinux_tun_dev_create_queue(void *security)
>  {
> +	struct tun_security_struct *tunsec = security;
> +
> +	return avc_has_perm(current_sid(), tunsec->sid, SECCLASS_TUN_SOCKET,
> +			    TUN_SOCKET__CREATE_QUEUE, NULL);
> +}
> +
> +static int selinux_tun_dev_attach(struct sock *sk, void *security)
> +{
> +	struct tun_security_struct *tunsec = security;
>  	struct sk_security_struct *sksec = sk->sk_security;
>  
>  	/* we don't currently perform any NetLabel based labeling here and it
> @@ -4425,20 +4452,19 @@ static void selinux_tun_dev_post_create(struct sock *sk)
>  	 * cause confusion to the TUN user that had no idea network labeling
>  	 * protocols were being used */
>  
> -	/* see the comments in selinux_tun_dev_create() about why we don't use
> -	 * the sockcreate SID here */
> -
> -	sksec->sid = current_sid();
> +	sksec->sid = tunsec->sid;
>  	sksec->sclass = SECCLASS_TUN_SOCKET;
> +
> +	return 0;
>  }
>  
> -static int selinux_tun_dev_attach(struct sock *sk)
> +static int selinux_tun_dev_open(void *security)
>  {
> -	struct sk_security_struct *sksec = sk->sk_security;
> +	struct tun_security_struct *tunsec = security;
>  	u32 sid = current_sid();
>  	int err;
>  
> -	err = avc_has_perm(sid, sksec->sid, SECCLASS_TUN_SOCKET,
> +	err = avc_has_perm(sid, tunsec->sid, SECCLASS_TUN_SOCKET,
>  			   TUN_SOCKET__RELABELFROM, NULL);
>  	if (err)
>  		return err;
> @@ -4446,8 +4472,7 @@ static int selinux_tun_dev_attach(struct sock *sk)
>  			   TUN_SOCKET__RELABELTO, NULL);
>  	if (err)
>  		return err;
> -
> -	sksec->sid = sid;
> +	tunsec->sid = sid;
>  
>  	return 0;
>  }
> @@ -5642,9 +5667,12 @@ static struct security_operations selinux_ops = {
>  	.secmark_refcount_inc =		selinux_secmark_refcount_inc,
>  	.secmark_refcount_dec =		selinux_secmark_refcount_dec,
>  	.req_classify_flow =		selinux_req_classify_flow,
> +	.tun_dev_alloc_security =	selinux_tun_dev_alloc_security,
> +	.tun_dev_free_security =	selinux_tun_dev_free_security,
>  	.tun_dev_create =		selinux_tun_dev_create,
> -	.tun_dev_post_create = 		selinux_tun_dev_post_create,
> +	.tun_dev_create_queue =		selinux_tun_dev_create_queue,
>  	.tun_dev_attach =		selinux_tun_dev_attach,
> +	.tun_dev_open =			selinux_tun_dev_open,
>  
>  #ifdef CONFIG_SECURITY_NETWORK_XFRM
>  	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,
> diff --git a/security/selinux/include/objsec.h b/security/selinux/include/objsec.h
> index 26c7eee..aa47bca 100644
> --- a/security/selinux/include/objsec.h
> +++ b/security/selinux/include/objsec.h
> @@ -110,6 +110,10 @@ struct sk_security_struct {
>  	u16 sclass;			/* sock security class */
>  };
>  
> +struct tun_security_struct {
> +	u32 sid;			/* SID for the tun device sockets */
> +};
> +
>  struct key_security_struct {
>  	u32 sid;	/* SID of key */
>  };
