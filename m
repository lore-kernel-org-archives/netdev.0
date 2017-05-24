From: Kees Cook <keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] nfc: Fix the sockaddr length sanitization in llcp_sock_connect
Date: Wed, 24 May 2017 09:58:23 -0700
Message-ID: <CAGXu5jJRXhJSC34vSc19mPQ9Wetf92daar71He0OXDUebXu0bA@mail.gmail.com>
References: <20170524102620.13806-1-mjurczyk@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Mateusz Jurczyk <mjurczyk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170524102620.13806-1-mjurczyk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, May 24, 2017 at 3:26 AM, Mateusz Jurczyk <mjurczyk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> Fix the sockaddr length verification in the connect() handler of NFC/LLCP
> sockets, to compare against the size of the actual structure expected on
> input (sockaddr_nfc_llcp) instead of its shorter version (sockaddr_nfc).
>
> Both structures are defined in include/uapi/linux/nfc.h. The fields
> specific to the _llcp extended struct are as follows:
>
>    276          __u8 dsap; /* Destination SAP, if known */
>    277          __u8 ssap; /* Source SAP to be bound to */
>    278          char service_name[NFC_LLCP_MAX_SERVICE_NAME]; /* Service name URI */;
>    279          size_t service_name_len;
>
> If the caller doesn't provide a sufficiently long sockaddr buffer, these
> fields remain uninitialized (and they currently originate from the stack
> frame of the top-level sys_connect handler). They are then copied by
> llcp_sock_connect() into internal storage (nfc_llcp_sock structure), and
> could be subsequently read back through the user-mode getsockname()
> function (handled by llcp_sock_getname()). This would result in the
> disclosure of up to ~70 uninitialized bytes from the kernel stack to
> user-mode clients capable of creating AFC_NFC sockets.
>
> Signed-off-by: Mateusz Jurczyk <mjurczyk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Acked-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

-Kees

> ---
>  net/nfc/llcp_sock.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
> index 2ffb18e73df6..d0d12bea65cb 100644
> --- a/net/nfc/llcp_sock.c
> +++ b/net/nfc/llcp_sock.c
> @@ -662,8 +662,7 @@ static int llcp_sock_connect(struct socket *sock, struct sockaddr *_addr,
>
>         pr_debug("sock %p sk %p flags 0x%x\n", sock, sk, flags);
>
> -       if (!addr || len < sizeof(struct sockaddr_nfc) ||
> -           addr->sa_family != AF_NFC)
> +       if (!addr || len < sizeof(*addr) || addr->sa_family != AF_NFC)
>                 return -EINVAL;
>
>         if (addr->service_name_len == 0 && addr->dsap == 0)
> --
> 2.13.0.219.gdb65acc882-goog
>



-- 
Kees Cook
Pixel Security
