From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] selinux: check for address length in
 selinux_socket_bind()
Date: Mon, 06 Mar 2017 11:29:02 -0800
Message-ID: <1488828542.9415.391.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170306184614.20056-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, keescook@chromium.org,
        edumazet@google.com, paul@paul-moore.com, sds@tycho.nsa.gov,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        selinux@tycho.nsa.gov
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170306184614.20056-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-03-06 at 19:46 +0100, Alexander Potapenko wrote:
> KMSAN (KernelMemorySanitizer, a new error detection tool) reports use of
> uninitialized memory in selinux_socket_bind():
> 
...
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
> Changes since v1:
>  - fixed patch description
>  - fixed addrlen tests to match those in inet_bind() and inet6_bind()
>    (per comment from Eric Dumazet)
> ---
>  security/selinux/hooks.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 0a4b4b040e0a..ddc4aca6c840 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -4351,10 +4351,19 @@ static int selinux_socket_bind(struct socket *sock, struct sockaddr *address, in
>  		u32 sid, node_perm;
>  
>  		if (family == PF_INET) {
> +			if (addrlen < sizeof(struct sockaddr_in)) {
> +				err = -EINVAL;
> +				goto out;
> +			}
>  			addr4 = (struct sockaddr_in *)address;
>  			snum = ntohs(addr4->sin_port);
>  			addrp = (char *)&addr4->sin_addr.s_addr;
> +
>  		} else {
> +			if (addrlen < SIN6_LEN_RFC2133) {
> +				err = -EINVAL;
> +				goto out;
> +			}
>  			addr6 = (struct sockaddr_in6 *)address;
>  			snum = ntohs(addr6->sin6_port);
>  			addrp = (char *)&addr6->sin6_addr.s6_addr;

Acked-by: Eric Dumazet <edumazet@google.com>
