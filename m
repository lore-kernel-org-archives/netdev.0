From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net] nfc: close a race condition in llcp_sock_getname()
Date: Wed, 24 Feb 2016 10:54:37 -0800
Message-ID: <CAM_iQpWyVswsMn7nHAF3F_EtRnG1Gs5AiYD24ZQn6693pMdyZQ@mail.gmail.com>
References: <1454096260-20396-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:35775 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbcBXSyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 13:54:37 -0500
In-Reply-To: <1454096260-20396-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 11:37 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> llcp_sock_getname() checks llcp_sock->dev to make sure
> llcp_sock is already connected or bound, however, we could
> be in the middle of llcp_sock_bind() where llcp_sock->dev
> is bound and llcp_sock->service_name_len is set,
> but llcp_sock->service_name is not, in this case we would
> lead to copy some bytes from a NULL pointer.
>
> Just lock the sock since this is not a hot path anyway.
>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
> Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
> Cc: Samuel Ortiz <sameo@linux.intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Samuel, please take a look at this one too.


> ---
>  net/nfc/llcp_sock.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
> index ecf0a01..b9edf5f 100644
> --- a/net/nfc/llcp_sock.c
> +++ b/net/nfc/llcp_sock.c
> @@ -509,6 +509,11 @@ static int llcp_sock_getname(struct socket *sock, struct sockaddr *uaddr,
>         memset(llcp_addr, 0, sizeof(*llcp_addr));
>         *len = sizeof(struct sockaddr_nfc_llcp);
>
> +       lock_sock(sk);
> +       if (!llcp_sock->dev) {
> +               release_sock(sk);
> +               return -EBADFD;
> +       }
>         llcp_addr->sa_family = AF_NFC;
>         llcp_addr->dev_idx = llcp_sock->dev->idx;
>         llcp_addr->target_idx = llcp_sock->target_idx;
> @@ -518,6 +523,7 @@ static int llcp_sock_getname(struct socket *sock, struct sockaddr *uaddr,
>         llcp_addr->service_name_len = llcp_sock->service_name_len;
>         memcpy(llcp_addr->service_name, llcp_sock->service_name,
>                llcp_addr->service_name_len);
> +       release_sock(sk);
>
>         return 0;
>  }
> --
> 1.8.3.1
>
