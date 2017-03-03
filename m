From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] selinux: check for address length in selinux_socket_bind()
Date: Fri, 3 Mar 2017 09:35:49 -0800
Message-ID: <CANn89i+RB0o98-uVPTMfx919T8M+X0AGt7U636O6ERK=685gsQ@mail.gmail.com>
References: <20170303172330.83421-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <paul@paul-moore.com>, sds@tycho.nsa.gov,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, selinux@tycho.nsa.gov
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170303172330.83421-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 9:23 AM, Alexander Potapenko <glider@google.com> wrote:
> This happens because bind() unconditionally copies |size| bytes of
> |addr| to the kernel, leaving the rest uninitialized. Then
> security_socket_bind() reads the IP address bytes, including the
> uninitialized ones, to determine the port, or e.g. pass them further to
> sel_netnode_find(), which uses them to calculate a hash.
>
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
>  security/selinux/hooks.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 0a4b4b040e0a..eba54489b11b 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -4351,10 +4351,19 @@ static int selinux_socket_bind(struct socket *sock, struct sockaddr *address, in
>                 u32 sid, node_perm;
>
>                 if (family == PF_INET) {
> +                       if (addrlen != sizeof(struct sockaddr_in)) {

Please take a look at inet_bind()

The correct test would be :

                     if (addrlen < sizeof(struct sockaddr_in))
                                     err = -EINVAL;
...


> +                               err = -EINVAL;
> +                               goto out;
> +                       }
>                         addr4 = (struct sockaddr_in *)address;
>                         snum = ntohs(addr4->sin_port);
>                         addrp = (char *)&addr4->sin_addr.s_addr;
> +
>                 } else {
> +                       if (addrlen != sizeof(struct sockaddr_in6)) {

Look at inet6_bind()

                    if (addrlen < SIN6_LEN_RFC2133)

> +                               err = -EINVAL;
> +                               goto out;
> +                       }
>                         addr6 = (struct sockaddr_in6 *)address;
>                         snum = ntohs(addr6->sin6_port);
>                         addrp = (char *)&addr6->sin6_addr.s6_addr;
> --
> 2.12.0.rc1.440.g5b76565f74-goog
>
