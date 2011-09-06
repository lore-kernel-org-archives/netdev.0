From: Paul Stewart <pstew@chromium.org>
Subject: Re: [PATCH] ipv6: Create module parameter for use_tempaddr
Date: Tue, 6 Sep 2011 16:56:36 -0700
Message-ID: <CAMcMvsgZ8t=dh5G=QuFKODCyrBX56nveztq=0QBwaUfO46KL9Q@mail.gmail.com>
References: <20110901062754.5D1642043D@glenhelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roque@di.fc.ul.pt, kuznet@ms2.inr.ac.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:35017 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755408Ab1IFX4j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 19:56:39 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p86NucAQ028126
	for <netdev@vger.kernel.org>; Tue, 6 Sep 2011 16:56:38 -0700
Received: from yia28 (yia28.prod.google.com [10.243.65.28])
	by wpaz29.hot.corp.google.com with ESMTP id p86NtU6K020196
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 6 Sep 2011 16:56:37 -0700
Received: by yia28 with SMTP id 28so4075112yia.6
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2011 16:56:37 -0700 (PDT)
In-Reply-To: <20110901062754.5D1642043D@glenhelen.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2011 at 11:03 PM, Paul Stewart <pstew@chromium.org> wro=
te:
> When ipv6 is used as a module, there is no good place to set
> the default value for use_tempaddr. =A0Using sysctl.conf will
> set this parameter too early -- before the module is loaded.
> To solve this, create a module parameter that will set the
> default value of use_tempaddr for all devices.
>
> Signed-off-by: Paul Stewart <pstew@chromium.org>
> ---
> =A0include/linux/ipv6.h | =A0 =A01 +
> =A0net/ipv6/addrconf.c =A0| =A0 =A03 +++
> =A0net/ipv6/af_inet6.c =A0| =A0 =A08 ++++++++
> =A03 files changed, 12 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index 0c99776..0d45a7c 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -178,6 +178,7 @@ struct ipv6_devconf {
> =A0struct ipv6_params {
> =A0 =A0 =A0 =A0__s32 disable_ipv6;
> =A0 =A0 =A0 =A0__s32 autoconf;
> + =A0 =A0 =A0 __s32 use_tempaddr;
> =A0};
> =A0extern struct ipv6_params ipv6_defaults;
> =A0#endif
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index f012ebd..27314a2 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -4609,6 +4609,9 @@ static int __net_init addrconf_init_net(struct =
net *net)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* these will be inherited by all name=
spaces */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dflt->autoconf =3D ipv6_defaults.autoc=
onf;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dflt->disable_ipv6 =3D ipv6_defaults.d=
isable_ipv6;
> +#ifdef CONFIG_IPV6_PRIVACY
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dflt->use_tempaddr =3D ipv6_defaults.us=
e_tempaddr;
> +#endif
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0net->ipv6.devconf_all =3D all;
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 3b5669a..5022950 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -76,6 +76,9 @@ static DEFINE_SPINLOCK(inetsw6_lock);
> =A0struct ipv6_params ipv6_defaults =3D {
> =A0 =A0 =A0 =A0.disable_ipv6 =3D 0,
> =A0 =A0 =A0 =A0.autoconf =3D 1,
> +#ifdef CONFIG_IPV6_PRIVACY
> + =A0 =A0 =A0 .use_tempaddr =3D 0,
> +#endif
> =A0};
>
> =A0static int disable_ipv6_mod =3D 0;
> @@ -89,6 +92,11 @@ MODULE_PARM_DESC(disable_ipv6, "Disable IPv6 on al=
l interfaces");
> =A0module_param_named(autoconf, ipv6_defaults.autoconf, int, 0444);
> =A0MODULE_PARM_DESC(autoconf, "Enable IPv6 address autoconfiguration =
on all interfaces");
>
> +#ifdef CONFIG_IPV6_PRIVACY
> +module_param_named(use_tempaddr, ipv6_defaults.use_tempaddr, int, 04=
44);
> +MODULE_PARM_DESC(use_tempaddr, "Enable IPv6 address privacy for auto=
configuration by default");
> +#endif
> +
> =A0static __inline__ struct ipv6_pinfo *inet6_sk_generic(struct sock =
*sk)
> =A0{
> =A0 =A0 =A0 =A0const int offset =3D sk->sk_prot->obj_size - sizeof(st=
ruct ipv6_pinfo);
> --
> 1.7.3.1
>
>
