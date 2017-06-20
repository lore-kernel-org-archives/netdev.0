From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH] net: introduce SO_PEERGROUPS getsockopt
Date: Tue, 20 Jun 2017 12:18:53 +0200
Message-ID: <CAG-2HqVFVGamosZbY_=TvG0uFx=-NsKOWsqhY79Ag6-8=GZbiA@mail.gmail.com>
References: <20170616203124.4632-1-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Michal Sekletar <msekleta@redhat.com>,
        Simon McVittie <simon.mcvittie@collabora.co.uk>
To: David Herrmann <dh.herrmann@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35818 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750863AbdFTKTP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 06:19:15 -0400
Received: by mail-lf0-f66.google.com with SMTP id n136so2375852lfn.2
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 03:19:14 -0700 (PDT)
In-Reply-To: <20170616203124.4632-1-dh.herrmann@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 16, 2017 at 10:31 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
> This adds the new getsockopt(2) option SO_PEERGROUPS on SOL_SOCKET to
> retrieve the auxiliary groups of the remote peer. It is designed to
> naturally extend SO_PEERCRED. That is, the underlying data is from the
> same credentials. Regarding its syntax, it is based on SO_PEERSEC. That
> is, if the provided buffer is too small, ERANGE is returned and @optlen
> is updated. Otherwise, the information is copied, @optlen is set to the
> actual size, and 0 is returned.
>
> While SO_PEERCRED (and thus `struct ucred') already returns the primary
> group, it lacks the auxiliary group vector. However, nearly all access
> controls (including kernel side VFS and SYSVIPC, but also user-space
> polkit, DBus, ...) consider the entire set of groups, rather than just
> the primary group. But this is currently not possible with pure
> SO_PEERCRED. Instead, user-space has to work around this and query the
> system database for the auxiliary groups of a UID retrieved via
> SO_PEERCRED.
>
> Unfortunately, there is no race-free way to query the auxiliary groups
> of the PID/UID retrieved via SO_PEERCRED. Hence, the current user-space
> solution is to use getgrouplist(3p), which itself falls back to NSS and
> whatever is configured in nsswitch.conf(3). This effectively checks
> which groups we *would* assign to the user if it logged in *now*. On
> normal systems it is as easy as reading /etc/group, but with NSS it can
> resort to quering network databases (eg., LDAP), using IPC or network
> communication.
>
> Long story short: Whenever we want to use auxiliary groups for access
> checks on IPC, we need further IPC to talk to the user/group databases,
> rather than just relying on SO_PEERCRED and the incoming socket. This
> is unfortunate, and might even result in dead-locks if the database
> query uses the same IPC as the original request.
>
> So far, those recursions / dead-locks have been avoided by using
> primitive IPC for all crucial NSS modules. However, we want to avoid
> re-inventing the wheel for each NSS module that might be involved in
> user/group queries. Hence, we would preferably make DBus (and other IPC
> that supports access-management based on groups) work without resorting
> to the user/group database. This new SO_PEERGROUPS ioctl would allow us
> to make dbus-daemon work without ever calling into NSS.
>
> Cc: Michal Sekletar <msekleta@redhat.com>
> Cc: Simon McVittie <simon.mcvittie@collabora.co.uk>
> Cc: Tom Gundersen <teg@jklm.no>

Reviewed-by: Tom Gundersen <teg@jklm.no>

> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
> ---
>  arch/alpha/include/uapi/asm/socket.h   |  2 ++
>  arch/frv/include/uapi/asm/socket.h     |  2 ++
>  arch/ia64/include/uapi/asm/socket.h    |  2 ++
>  arch/m32r/include/uapi/asm/socket.h    |  2 ++
>  arch/mips/include/uapi/asm/socket.h    |  2 ++
>  arch/mn10300/include/uapi/asm/socket.h |  2 ++
>  arch/parisc/include/uapi/asm/socket.h  |  2 ++
>  arch/powerpc/include/uapi/asm/socket.h |  2 ++
>  arch/s390/include/uapi/asm/socket.h    |  2 ++
>  arch/sparc/include/uapi/asm/socket.h   |  2 ++
>  arch/xtensa/include/uapi/asm/socket.h  |  2 ++
>  include/uapi/asm-generic/socket.h      |  2 ++
>  net/core/sock.c                        | 33 +++++++++++++++++++++++++++++++++
>  13 files changed, 57 insertions(+)
>
> diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
> index 148d7a32754e..975c5cbf9a86 100644
> --- a/arch/alpha/include/uapi/asm/socket.h
> +++ b/arch/alpha/include/uapi/asm/socket.h
> @@ -105,4 +105,6 @@
>
>  #define SO_COOKIE              57
>
> +#define SO_PEERGROUPS          58
> +
>  #endif /* _UAPI_ASM_SOCKET_H */
> diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
> index 1ccf45657472..8e53a149b216 100644
> --- a/arch/frv/include/uapi/asm/socket.h
> +++ b/arch/frv/include/uapi/asm/socket.h
> @@ -98,5 +98,7 @@
>
>  #define SO_COOKIE              57
>
> +#define SO_PEERGROUPS          58
> +
>  #endif /* _ASM_SOCKET_H */
>
> diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
> index 2c3f4b48042a..d122c30429ae 100644
> --- a/arch/ia64/include/uapi/asm/socket.h
> +++ b/arch/ia64/include/uapi/asm/socket.h
> @@ -107,4 +107,6 @@
>
>  #define SO_COOKIE              57
>
> +#define SO_PEERGROUPS          58
> +
>  #endif /* _ASM_IA64_SOCKET_H */
> diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
> index ae6548d29a18..7e689cc14668 100644
> --- a/arch/m32r/include/uapi/asm/socket.h
> +++ b/arch/m32r/include/uapi/asm/socket.h
> @@ -98,4 +98,6 @@
>
>  #define SO_COOKIE              57
>
> +#define SO_PEERGROUPS          58
> +
>  #endif /* _ASM_M32R_SOCKET_H */
> diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
> index 3418ec9c1c50..5c0947d063cc 100644
> --- a/arch/mips/include/uapi/asm/socket.h
> +++ b/arch/mips/include/uapi/asm/socket.h
> @@ -116,4 +116,6 @@
>
>  #define SO_COOKIE              57
>
> +#define SO_PEERGROUPS          58
> +
>  #endif /* _UAPI_ASM_SOCKET_H */
> diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
> index 4526e92301a6..219f516eb6ad 100644
> --- a/arch/mn10300/include/uapi/asm/socket.h
> +++ b/arch/mn10300/include/uapi/asm/socket.h
> @@ -98,4 +98,6 @@
>
>  #define SO_COOKIE              57
>
> +#define SO_PEERGROUPS          58
> +
>  #endif /* _ASM_SOCKET_H */
> diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
> index 514701840bd9..2dd2c132047e 100644
> --- a/arch/parisc/include/uapi/asm/socket.h
> +++ b/arch/parisc/include/uapi/asm/socket.h
> @@ -97,4 +97,6 @@
>
>  #define SO_COOKIE              0x4032
>
> +#define SO_PEERGROUPS          0x4033
> +
>  #endif /* _UAPI_ASM_SOCKET_H */
> diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
> index 58e2ec0310fc..2ce8c4503b1c 100644
> --- a/arch/powerpc/include/uapi/asm/socket.h
> +++ b/arch/powerpc/include/uapi/asm/socket.h
> @@ -105,4 +105,6 @@
>
>  #define SO_COOKIE              57
>
> +#define SO_PEERGROUPS          58
> +
>  #endif /* _ASM_POWERPC_SOCKET_H */
> diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
> index e8e5ecf673fd..90f0899a1064 100644
> --- a/arch/s390/include/uapi/asm/socket.h
> +++ b/arch/s390/include/uapi/asm/socket.h
> @@ -104,4 +104,6 @@
>
>  #define SO_COOKIE              57
>
> +#define SO_PEERGROUPS          58
> +
>  #endif /* _ASM_SOCKET_H */
> diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
> index 3f4ad19d9ec7..5dd96465bc5e 100644
> --- a/arch/sparc/include/uapi/asm/socket.h
> +++ b/arch/sparc/include/uapi/asm/socket.h
> @@ -94,6 +94,8 @@
>
>  #define SO_COOKIE              0x003b
>
> +#define SO_PEERGROUPS          0x003c
> +
>  /* Security levels - as per NRL IPv6 - don't actually do anything */
>  #define SO_SECURITY_AUTHENTICATION             0x5001
>  #define SO_SECURITY_ENCRYPTION_TRANSPORT       0x5002
> diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
> index 1eb6d2fe70d3..e6df5066b9e3 100644
> --- a/arch/xtensa/include/uapi/asm/socket.h
> +++ b/arch/xtensa/include/uapi/asm/socket.h
> @@ -109,4 +109,6 @@
>
>  #define SO_COOKIE              57
>
> +#define SO_PEERGROUPS          58
> +
>  #endif /* _XTENSA_SOCKET_H */
> diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
> index 2b488565599d..79634c00611b 100644
> --- a/include/uapi/asm-generic/socket.h
> +++ b/include/uapi/asm-generic/socket.h
> @@ -100,4 +100,6 @@
>
>  #define SO_COOKIE              57
>
> +#define SO_PEERGROUPS          58
> +
>  #endif /* __ASM_GENERIC_SOCKET_H */
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 727f924b7f91..1987bf13d755 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1074,6 +1074,18 @@ static void cred_to_ucred(struct pid *pid, const struct cred *cred,
>         }
>  }
>
> +static int groups_to_user(gid_t __user *dst, const struct group_info *src)
> +{
> +       struct user_namespace *user_ns = current_user_ns();
> +       int i;
> +
> +       for (i = 0; i < src->ngroups; i++)
> +               if (put_user(from_kgid_munged(user_ns, src->gid[i]), dst + i))
> +                       return -EFAULT;
> +
> +       return 0;
> +}
> +
>  int sock_getsockopt(struct socket *sock, int level, int optname,
>                     char __user *optval, int __user *optlen)
>  {
> @@ -1227,6 +1239,27 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
>                 goto lenout;
>         }
>
> +       case SO_PEERGROUPS:
> +       {
> +               int ret, n;
> +
> +               if (!sk->sk_peer_cred)
> +                       return -ENODATA;
> +
> +               n = sk->sk_peer_cred->group_info->ngroups;
> +               if (len < n * sizeof(gid_t)) {
> +                       len = n * sizeof(gid_t);
> +                       return put_user(len, optlen) ? -EFAULT : -ERANGE;
> +               }
> +               len = n * sizeof(gid_t);
> +
> +               ret = groups_to_user((gid_t __user *)optval,
> +                                    sk->sk_peer_cred->group_info);
> +               if (ret)
> +                       return ret;
> +               goto lenout;
> +       }
> +
>         case SO_PEERNAME:
>         {
>                 char address[128];
> --
> 2.13.1
>
