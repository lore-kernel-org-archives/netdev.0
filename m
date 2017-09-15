From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] packet: hold bind lock when rebinding to fanout hook
Date: Fri, 15 Sep 2017 11:33:07 -0700
Message-ID: <CAM_iQpXOS3cB8GtuVZaQq7AnFkHQXxcBqkg0azMU-JpMtv4NRw@mail.gmail.com>
References: <20170914211441.67326-1-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        nixiaoming <nixiaoming@huawei.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34804 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbdIOSd2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 14:33:28 -0400
Received: by mail-pf0-f196.google.com with SMTP id g65so1589505pfe.1
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 11:33:28 -0700 (PDT)
In-Reply-To: <20170914211441.67326-1-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 14, 2017 at 2:14 PM, Willem de Bruijn <willemb@google.com> wrote:
> Packet socket bind operations must hold the po->bind_lock. This keeps
> po->running consistent with whether the socket is actually on a ptype
> list to receive packets.
>
> fanout_add unbinds a socket and its packet_rcv/tpacket_rcv call, then
> binds the fanout object to receive through packet_rcv_fanout.
>
> Make it hold the po->bind_lock when testing po->running and rebinding.
> Else, it can race with other rebind operations, such as that in
> packet_set_ring from packet_rcv to tpacket_rcv. Concurrent updates
> can result in a socket being added to a fanout group twice, causing
> use-after-free KASAN bug reports, among others.
>
> Reported independently by both trinity and syzkaller.
> Verified that the syzkaller reproducer passes after this patch.
>
> Reported-by: nixioaming <nixiaoming@huawei.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  net/packet/af_packet.c | 16 +++++++++++-----
>  1 file changed, 11 insertions(+), 5 deletions(-)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index c26172995511..d288f52c53f7 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1684,10 +1684,6 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
>
>         mutex_lock(&fanout_mutex);
>
> -       err = -EINVAL;
> -       if (!po->running)
> -               goto out;
> -
>         err = -EALREADY;
>         if (po->fanout)
>                 goto out;
> @@ -1749,7 +1745,10 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
>                 list_add(&match->list, &fanout_list);
>         }
>         err = -EINVAL;
> -       if (match->type == type &&
> +
> +       spin_lock(&po->bind_lock);
> +       if (po->running &&


As you move the po->running check later after setting po->rollover, I wonder
if po->rollover possibly depends on po>running on other path?


> +           match->type == type &&
>             match->prot_hook.type == po->prot_hook.type &&
>             match->prot_hook.dev == po->prot_hook.dev) {
>                 err = -ENOSPC;
> @@ -1761,6 +1760,13 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
>                         err = 0;
>                 }
>         }
> +       spin_unlock(&po->bind_lock);
> +
> +       if (err && !refcount_read(&match->sk_ref)) {
> +               list_del(&match->list);
> +               kfree(match);
> +       }

This looks correct but still seems odd, it smells you don't use refcnt in an
expected way.
