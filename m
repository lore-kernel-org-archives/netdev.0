From: Eric Paris <netdev@parisplace.org>
Subject: Re: [RFC PATCH v1 1/2] lsm: Add hooks to the TUN driver
Date: Wed, 5 Aug 2009 09:03:12 -0400
Message-ID: <7e0fb38c0908050603k57d59b76l30a46aacd15d38f3@mail.gmail.com>
References: <20090804211304.10798.65601.stgit@flek.lan>
	 <20090804212158.10798.34592.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f172.google.com ([209.85.212.172]:59856 "EHLO
	mail-vw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933326AbZHENDN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 09:03:13 -0400
In-Reply-To: <20090804212158.10798.34592.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 4, 2009 at 5:21 PM, Paul Moore<paul.moore@hp.com> wrote:
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

> diff --git a/security/commoncap.c b/security/commoncap.c
> index 48b7e02..07125a6 100644
> --- a/security/commoncap.c
> +++ b/security/commoncap.c
> @@ -984,3 +984,29 @@ int cap_vm_enough_memory(struct mm_struct *mm, l=
ong pages)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cap_sys_admin =3D 1;
> =A0 =A0 =A0 =A0return __vm_enough_memory(mm, pages, cap_sys_admin);
> =A0}
> +
> +/**
> + * cap_tun_dev_create - Determine if creation of a new TUN device is=
 allowed
> + *
> + * Determine if the user is allowed to create a new TUN device, hist=
orically
> + * this has always required the CAP_NET_ADMIN permission.
> + */
> +int cap_tun_dev_create(void)
> +{
> + =A0 =A0 =A0 if (!capable(CAP_NET_ADMIN))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/**
> + * cap_tun_dev_attach - Determine if attaching to an TUN device is a=
llowed
> + *
> + * Determine if the user is allowed to attach to an existing persist=
ent TUN
> + * device, historically this has always required the CAP_NET_ADMIN p=
ermission.
> + */
> +int cap_tun_dev_attach(void)
> +{
> + =A0 =A0 =A0 if (!capable(CAP_NET_ADMIN))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> + =A0 =A0 =A0 return 0;
> +}
> diff --git a/security/security.c b/security/security.c
> index dc7674f..14ebf82 100644
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
> +void security_tun_dev_post_create(struct sock *tun_sk)
> +{
> + =A0 =A0 =A0 return security_ops->tun_dev_post_create(tun_sk);
> +}
> +EXPORT_SYMBOL(security_tun_dev_post_create);
> +
> +int security_tun_dev_attach(struct sock *tun_sk)
> +{
> + =A0 =A0 =A0 return security_ops->tun_dev_attach(tun_sk);
> +}
> +EXPORT_SYMBOL(security_tun_dev_attach);
> +
> =A0#endif /* CONFIG_SECURITY_NETWORK */
>
> =A0#ifdef CONFIG_SECURITY_NETWORK_XFRM

You also must add cap_tun_dev_post_create in security/capability.c and
you need to call set_to_cap_if_null() for all 3 of these new
functions.  I believe you'll see a wonderful null pointer panic if you
tried with selinux=3D0.....

-Eric
