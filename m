From: Paul Moore <paul@paul-moore.com>
Subject: Re: linux-next: build failure after merge of the selinux tree
Date: Tue, 10 Jan 2017 22:11:15 -0500
Message-ID: <CAHC9VhR_fa1q4F5hd4SG3LcNhS8zCsG57Luwg2hgn8eA0R0h_Q@mail.gmail.com>
References: <20170110122703.2dbdfd18@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Stephen Smalley <sds@tycho.nsa.gov>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:34857 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936101AbdAKDLR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 22:11:17 -0500
Received: by mail-vk0-f65.google.com with SMTP id 23so4095088vkc.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 19:11:17 -0800 (PST)
In-Reply-To: <20170110122703.2dbdfd18@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 9, 2017 at 8:27 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi Paul,
>
> After merging the selinux tree, today's linux-next build (x86_64
> allmodconfig) failed like this:
>
> In file included from /home/sfr/next/next/security/selinux/avc.c:35:0:
> /home/sfr/next/next/security/selinux/include/classmap.h:242:2: error: #error New address family defined, please update secclass_map.
>  #error New address family defined, please update secclass_map.
>   ^
> /home/sfr/next/next/security/selinux/hooks.c: In function 'socket_type_to_security_class':
> /home/sfr/next/next/security/selinux/hooks.c:1409:2: error: #error New address family defined, please update this function.
>
> Caused by commit
>
>   da69a5306ab9 ("selinux: support distinctions among all network address families")
>
> interacting with commit
>
>   ac7138746e14 ("smc: establish new socket family")
>
> from the net-next tree.
>
> I added the following merge fix patch:

Thanks Stephen.

There are still some concerns around which protocol/address families
require their own SELinux object class, but it looks like SMC should
have it's own object class.  If the "selinux: support distinctions
among all network address families" commit doesn't go up to Linus
during the next merge window I'll make sure it is updated for PF_SMC.

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 10 Jan 2017 12:22:21 +1100
> Subject: [PATCH] selinux: merge fix for "smc: establish new socket family"
>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  security/selinux/hooks.c            | 4 +++-
>  security/selinux/include/classmap.h | 4 +++-
>  2 files changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index bada3cd42b9c..712fd0e7c91d 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -1405,7 +1405,9 @@ static inline u16 socket_type_to_security_class(int family, int type, int protoc
>                         return SECCLASS_KCM_SOCKET;
>                 case PF_QIPCRTR:
>                         return SECCLASS_QIPCRTR_SOCKET;
> -#if PF_MAX > 43
> +               case PF_SMC:
> +                       return SECCLASS_SMC_SOCKET;
> +#if PF_MAX > 44
>  #error New address family defined, please update this function.
>  #endif
>                 }
> diff --git a/security/selinux/include/classmap.h b/security/selinux/include/classmap.h
> index 0dfd26d0b8d8..40f1d4f8bc2a 100644
> --- a/security/selinux/include/classmap.h
> +++ b/security/selinux/include/classmap.h
> @@ -235,9 +235,11 @@ struct security_class_mapping secclass_map[] = {
>           { COMMON_SOCK_PERMS, NULL } },
>         { "qipcrtr_socket",
>           { COMMON_SOCK_PERMS, NULL } },
> +       { "smc_socket",
> +         { COMMON_SOCK_PERMS, NULL } },
>         { NULL }
>    };
>
> -#if PF_MAX > 43
> +#if PF_MAX > 44
>  #error New address family defined, please update secclass_map.
>  #endif
> --
> 2.10.2
>
> --
> Cheers,
> Stephen Rothwell



-- 
paul moore
www.paul-moore.com
