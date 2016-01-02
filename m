From: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Patch net] nfc: check sock state in llcp_sock_getname()
Date: Sat, 2 Jan 2016 09:03:19 +0100
Message-ID: <CACT4Y+Y6YCYA_v=--spYpPDYj3Jo0cXcntFRe8XzYS3NJFUwqQ@mail.gmail.com>
References: <1451694857-21873-1-git-send-email-xiyou.wangcong@gmail.com> <1451694857-21873-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1451694857-21873-2-git-send-email-xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 2, 2016 at 1:34 AM, Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> llcp_sock_getname() checks llcp_sock->dev to make sure
> llcp_sock is already connected or bound, however, we could
> be in the middle of llcp_sock_bind() where llcp_sock->dev
> is bound and llcp_sock->service_name_len is set,
> but llcp_sock->service_name is not, in this case we would
> lead to copy some bytes from a NULL pointer.
>
> We should just check if sk->sk_state is still closed since
> both connect() and bind() will update this state at the end.

Hi Cong,

This is still racy. If you want to play lock-free then you also need
proper memory barriers. Stores to sk_state need to be
smp_store_release, while the load needs to be smp_load_acquire.
Otherwise getname still can see partially initialized socket.


> Reported-by: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Cc: Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>
> Cc: Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>
> Cc: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> Signed-off-by: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  net/nfc/llcp_sock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
> index ecf0a01..5a91997 100644
> --- a/net/nfc/llcp_sock.c
> +++ b/net/nfc/llcp_sock.c
> @@ -500,7 +500,7 @@ static int llcp_sock_getname(struct socket *sock, struct sockaddr *uaddr,
>         struct nfc_llcp_sock *llcp_sock = nfc_llcp_sock(sk);
>         DECLARE_SOCKADDR(struct sockaddr_nfc_llcp *, llcp_addr, uaddr);
>
> -       if (llcp_sock == NULL || llcp_sock->dev == NULL)
> +       if (llcp_sock == NULL || sk->sk_state == LLCP_CLOSED)
>                 return -EBADFD;
>
>         pr_debug("%p %d %d %d\n", sk, llcp_sock->target_idx,
> --
> 1.8.3.1
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
