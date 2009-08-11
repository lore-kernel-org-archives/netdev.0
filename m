From: Eric Paris <eparis@parisplace.org>
Subject: Re: [RFC PATCH v2 1/2] lsm: Add hooks to the TUN driver
Date: Tue, 11 Aug 2009 16:34:34 -0400
Message-ID: <7e0fb38c0908111334q7cd53b9bo8b22ccd591118fff@mail.gmail.com>
References: <20090810172238.7946.34247.stgit@flek.lan>
	 <20090810172844.7946.43287.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090810172844.7946.43287.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 10, 2009 at 1:28 PM, Paul Moore<paul.moore@hp.com> wrote:
> The TUN driver lacks any LSM hooks which makes it difficult for LSM m=
odules,
> such as SELinux, to enforce access controls on network traffic genera=
ted by
> TUN users; this is particularly problematic for virtualization apps s=
uch as
> QEMU and KVM. =A0This patch adds three new LSM hooks designed to cont=
rol the
> creation and attachment of TUN devices, the hooks are:
>
> =A0* security_tun_dev_create()
> =A0 Provides access control for the creation of new TUN devices
>
> =A0* security_tun_dev_post_create()
> =A0 Provides the ability to create the necessary socket LSM state for=
 newly
> =A0 created TUN devices
>
> =A0* security_tun_dev_attach()
> =A0 Provides access control for attaching to existing, persistent TUN=
 devices
> =A0 and the ability to update the TUN device's socket LSM state as ne=
cessary

Looks good to me, feel free to add my Ack.

-Eric
> ---
>
> =A0drivers/net/tun.c =A0 =A0 =A0 =A0| =A0 22 +++++++++++++++-------
> =A0include/linux/security.h | =A0 31 +++++++++++++++++++++++++++++++
> =A0security/capability.c =A0 =A0| =A0 19 +++++++++++++++++++
> =A0security/security.c =A0 =A0 =A0| =A0 18 ++++++++++++++++++
> =A04 files changed, 83 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 027f7ab..e6667ce 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -130,17 +130,10 @@ static inline struct tun_sock *tun_sk(struct so=
ck *sk)
> =A0static int tun_attach(struct tun_struct *tun, struct file *file)
> =A0{
> =A0 =A0 =A0 =A0struct tun_file *tfile =3D file->private_data;
> - =A0 =A0 =A0 const struct cred *cred =3D current_cred();
> =A0 =A0 =A0 =A0int err;
>
> =A0 =A0 =A0 =A0ASSERT_RTNL();
>
> - =A0 =A0 =A0 /* Check permissions */
> - =A0 =A0 =A0 if (((tun->owner !=3D -1 && cred->euid !=3D tun->owner)=
 ||
> - =A0 =A0 =A0 =A0 =A0 =A0(tun->group !=3D -1 && !in_egroup_p(tun->gro=
up))) &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 !capable(CAP_NET_ADMIN))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> -
> =A0 =A0 =A0 =A0netif_tx_lock_bh(tun->dev);
>
> =A0 =A0 =A0 =A0err =3D -EINVAL;
> @@ -926,6 +919,8 @@ static int tun_set_iff(struct net *net, struct fi=
le *file, struct ifreq *ifr)
>
> =A0 =A0 =A0 =A0dev =3D __dev_get_by_name(net, ifr->ifr_name);
> =A0 =A0 =A0 =A0if (dev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct cred *cred =3D current_cre=
d();
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ifr->ifr_flags & IFF_TUN_EXCL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EBUSY;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((ifr->ifr_flags & IFF_TUN) && dev-=
>netdev_ops =3D=3D &tun_netdev_ops)
> @@ -935,6 +930,14 @@ static int tun_set_iff(struct net *net, struct f=
ile *file, struct ifreq *ifr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (((tun->owner !=3D -1 && cred->euid =
!=3D tun->owner) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(tun->group !=3D -1 && !in_e=
group_p(tun->group))) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !capable(CAP_NET_ADMIN))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D security_tun_dev_attach(tun->sk=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D tun_attach(tun, file);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
> @@ -947,6 +950,9 @@ static int tun_set_iff(struct net *net, struct fi=
le *file, struct ifreq *ifr)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!capable(CAP_NET_ADMIN))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D security_tun_dev_create();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Set dev type */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ifr->ifr_flags & IFF_TUN) {
> @@ -989,6 +995,8 @@ static int tun_set_iff(struct net *net, struct fi=
le *file, struct ifreq *ifr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tun->sk =3D sk;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0container_of(sk, struct tun_sock, sk)-=
>tun =3D tun;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 security_tun_dev_post_create(sk);
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tun_net_init(dev);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (strchr(dev->name, '%')) {
> diff --git a/include/linux/security.h b/include/linux/security.h
> index 5eff459..d8efc35 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -974,6 +974,17 @@ static inline void security_free_mnt_opts(struct=
 security_mnt_opts *opts)
> =A0* =A0 =A0 Sets the connection's peersid to the secmark on skb.
> =A0* @req_classify_flow:
> =A0* =A0 =A0 Sets the flow's sid to the openreq sid.
> + * @tun_dev_create:
> + * =A0 =A0 Check permissions prior to creating a new TUN device.
> + * @tun_dev_post_create:
> + * =A0 =A0 This hook allows a module to update or allocate a per-soc=
ket security
> + * =A0 =A0 structure.
> + * =A0 =A0 @sk contains the newly created sock structure.
> + * @tun_dev_attach:
> + * =A0 =A0 Check permissions prior to attaching to a persistent TUN =
device. =A0This
> + * =A0 =A0 hook can also be used by the module to update any securit=
y state
> + * =A0 =A0 associated with the TUN device's sock structure.
> + * =A0 =A0 @sk contains the existing sock structure.
> =A0*
> =A0* Security hooks for XFRM operations.
> =A0*
> @@ -1572,6 +1583,9 @@ struct security_operations {
> =A0 =A0 =A0 =A0void (*inet_csk_clone) (struct sock *newsk, const stru=
ct request_sock *req);
> =A0 =A0 =A0 =A0void (*inet_conn_established) (struct sock *sk, struct=
 sk_buff *skb);
> =A0 =A0 =A0 =A0void (*req_classify_flow) (const struct request_sock *=
req, struct flowi *fl);
> + =A0 =A0 =A0 int (*tun_dev_create)(void);
> + =A0 =A0 =A0 void (*tun_dev_post_create)(struct sock *sk);
> + =A0 =A0 =A0 int (*tun_dev_attach)(struct sock *sk);
> =A0#endif /* CONFIG_SECURITY_NETWORK */
>
> =A0#ifdef CONFIG_SECURITY_NETWORK_XFRM
> @@ -2557,6 +2571,9 @@ void security_inet_csk_clone(struct sock *newsk=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct request_s=
ock *req);
> =A0void security_inet_conn_established(struct sock *sk,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct sk_buff *skb);
> +int security_tun_dev_create(void);
> +void security_tun_dev_post_create(struct sock *sk);
> +int security_tun_dev_attach(struct sock *sk);
>
> =A0#else =A0/* CONFIG_SECURITY_NETWORK */
> =A0static inline int security_unix_stream_connect(struct socket *sock=
,
> @@ -2707,6 +2724,20 @@ static inline void security_inet_conn_establis=
hed(struct sock *sk,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct sk_buff *skb)
> =A0{
> =A0}
> +
> +static inline int security_tun_dev_create(void)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static inline void security_tun_dev_post_create(struct sock *sk)
> +{
> +}
> +
> +static inline int security_tun_dev_attach(struct sock *sk)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> =A0#endif /* CONFIG_SECURITY_NETWORK */
>
> =A0#ifdef CONFIG_SECURITY_NETWORK_XFRM
> diff --git a/security/capability.c b/security/capability.c
> index 21b6cea..a10a44a 100644
> --- a/security/capability.c
> +++ b/security/capability.c
> @@ -710,10 +710,26 @@ static void cap_inet_conn_established(struct so=
ck *sk, struct sk_buff *skb)
> =A0{
> =A0}
>
> +
> +
> =A0static void cap_req_classify_flow(const struct request_sock *req,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0st=
ruct flowi *fl)
> =A0{
> =A0}
> +
> +static int cap_tun_dev_create(void)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void cap_tun_dev_post_create(struct sock *sk)
> +{
> +}
> +
> +static int cap_tun_dev_attach(struct sock *sk)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> =A0#endif /* CONFIG_SECURITY_NETWORK */
>
> =A0#ifdef CONFIG_SECURITY_NETWORK_XFRM
> @@ -1029,6 +1045,9 @@ void security_fixup_ops(struct security_operati=
ons *ops)
> =A0 =A0 =A0 =A0set_to_cap_if_null(ops, inet_csk_clone);
> =A0 =A0 =A0 =A0set_to_cap_if_null(ops, inet_conn_established);
> =A0 =A0 =A0 =A0set_to_cap_if_null(ops, req_classify_flow);
> + =A0 =A0 =A0 set_to_cap_if_null(ops, tun_dev_create);
> + =A0 =A0 =A0 set_to_cap_if_null(ops, tun_dev_post_create);
> + =A0 =A0 =A0 set_to_cap_if_null(ops, tun_dev_attach);
> =A0#endif /* CONFIG_SECURITY_NETWORK */
> =A0#ifdef CONFIG_SECURITY_NETWORK_XFRM
> =A0 =A0 =A0 =A0set_to_cap_if_null(ops, xfrm_policy_alloc_security);
> diff --git a/security/security.c b/security/security.c
> index dc7674f..dc6953c 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -1112,6 +1112,24 @@ void security_inet_conn_established(struct soc=
k *sk,
> =A0 =A0 =A0 =A0security_ops->inet_conn_established(sk, skb);
> =A0}
>
> +int security_tun_dev_create(void)
> +{
> + =A0 =A0 =A0 return security_ops->tun_dev_create();
> +}
> +EXPORT_SYMBOL(security_tun_dev_create);
> +
> +void security_tun_dev_post_create(struct sock *sk)
> +{
> + =A0 =A0 =A0 return security_ops->tun_dev_post_create(sk);
> +}
> +EXPORT_SYMBOL(security_tun_dev_post_create);
> +
> +int security_tun_dev_attach(struct sock *sk)
> +{
> + =A0 =A0 =A0 return security_ops->tun_dev_attach(sk);
> +}
> +EXPORT_SYMBOL(security_tun_dev_attach);
> +
> =A0#endif /* CONFIG_SECURITY_NETWORK */
>
> =A0#ifdef CONFIG_SECURITY_NETWORK_XFRM
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-secur=
ity-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
