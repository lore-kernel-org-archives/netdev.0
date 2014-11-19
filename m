From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH v2 net-next] tcp: make connect() mem charging friendly
Date: Wed, 19 Nov 2014 14:10:42 +0800
Message-ID: <CAK6E8=dUvde2s7VuUS9rHiA2fU0ZT2bS=ronjM+9BOA=0u-rVw@mail.gmail.com>
References: <40bc2b5fcda47d790f1fd247bc409041@visp.net.lb> <1405597918.10255.76.camel@edumazet-glaptop2.roam.corp.google.com>
 <37e25a5815a18a2da507a5b20b58427d@visp.net.lb> <1405604568.10255.80.camel@edumazet-glaptop2.roam.corp.google.com>
 <a927787503c2f0d71c330b879303b14f@visp.net.lb> <1405672897.10255.95.camel@edumazet-glaptop2.roam.corp.google.com>
 <1405676214.10255.96.camel@edumazet-glaptop2.roam.corp.google.com>
 <0b0b74ab8d2222fa85b23e06c6e992ec@visp.net.lb> <1405849675.10255.100.camel@edumazet-glaptop2.roam.corp.google.com>
 <6fc086a122bc3ac728a7aec9e812310f@visp.net.lb> <1406016045.10255.122.camel@edumazet-glaptop2.roam.corp.google.com>
 <3f463c3912608f7959481edaa6d7668d@visp.net.lb> <1406194817.3363.70.camel@edumazet-glaptop2.roam.corp.google.com>
 <8f138d88e3b850130eb9bb15e3e27069@visp.net.lb> <2adbf5346b4dd2bebe1915096c1c567c@visp.net.lb>
 <1415813254.17262.7.camel@edumazet-glaptop2.roam.corp.google.com>
 <64ef227cf22945d373cb06271fe6e051@visp.net.lb> <1416161495.17262.90.camel@edumazet-glaptop2.roam.corp.google.com>
 <8d9b6a2c313db242c1afb3bcd6a12c51@visp.net.lb> <1416168961.17262.96.camel@edumazet-glaptop2.roam.corp.google.com>
 <1416200496.24093.5.camel@edumazet-glaptop2.roam.corp.google.com>
 <9056c6967a870d9fbee54776cf950e48@visp.net.lb> <a65ec407c3f912b218469c16ea1fdfcd@visp.net.lb>
 <1416240651.5102.10.camel@edumazet-glaptop2.roam.corp.google.com>
 <c9a009556b97fcf7399eb73035c7f8a0@visp.net.lb> <1416243011.5102.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <34058cb0ee676b891dd9d54515512733@visp.net.lb> <0487f30ffd58f2ee9b47135fa5404d25@visp.net.lb>
 <1416245491.18588.1.camel@edumazet-glaptop2.roam.corp.google.com>
 <ecd48e5dd70f9f83a4a4db3d758cc615@visp.net.lb> <b2bf14dfc3180a316dd9c9bd89d02c40@visp.net.lb>
 <1416252989.18588.2.camel@edumazet-glaptop2.roam.corp.google.com>
 <2a4554e39649ac6dfbf2e0366794af08@visp.net.lb> <1416254490.18588.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <ed049b2f9ecc47676e25ec8aeafb25c0@visp.net.lb> <1f001a887ec3fb5b962e4374391863b9@visp.net.lb>
 <e33542339748d2f51a149a4020ee5f75@visp.net.lb> <57f78d76af5f78317ba69b613123ff9c@visp.net.lb>
 <d05242d8a607d4e15f3dd9200223699f@visp.net.lb> <1416266755.18588.12.camel@edumazet-glaptop2.roam.corp.google.com>
 <1416268176.18588.26.camel@edumazet-glaptop2.roam.corp.google.com> <1416294380.14060.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:49843 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749AbaKSGLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 01:11:24 -0500
Received: by mail-ie0-f179.google.com with SMTP id rp18so5613552iec.10
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 22:11:23 -0800 (PST)
In-Reply-To: <1416294380.14060.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 3:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> While working on sk_forward_alloc problems reported by Denys
> Fedoryshchenko, we found that tcp connect() (and fastopen) do not call
> sk_wmem_schedule() for SYN packet (and/or SYN/DATA packet), so
> sk_forward_alloc is negative while connect is in progress.
>
> We can fix this by calling regular sk_stream_alloc_skb() both for the
> SYN packet (in tcp_connect()) and the syn_data packet in
> tcp_send_syn_data()
>
> Then, tcp_send_syn_data() can avoid copying syn_data as we simply
> can manipulate syn_data->cb[] to remove SYN flag (and increment seq)
>
> Instead of open coding memcpy_fromiovecend(), simply use this helper.
>
> This leaves in socket write queue clean fast clone skbs.
>
> This was tested against our fastopen packetdrill tests.
>
> Reported-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

Thanks! this simplifies the code a lot.

> ---
> v2: added a kfree_skb(syn_data) if memcpy_fromiovecend() fails,
>     as spotted by Yuchung.
>
>  net/ipv4/tcp_output.c |   68 ++++++++++++++++------------------------
>  1 file changed, 28 insertions(+), 40 deletions(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index eb73a1dccf56b823a45c0ca034e40dc50fc48068..f5bd4bd3f7e669b3fd48a843d55e7313a30a3409 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -3011,9 +3011,9 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
>  {
>         struct tcp_sock *tp = tcp_sk(sk);
>         struct tcp_fastopen_request *fo = tp->fastopen_req;
> -       int syn_loss = 0, space, i, err = 0, iovlen = fo->data->msg_iovlen;
> -       struct sk_buff *syn_data = NULL, *data;
> +       int syn_loss = 0, space, err = 0;
>         unsigned long last_syn_loss = 0;
> +       struct sk_buff *syn_data;
>
>         tp->rx_opt.mss_clamp = tp->advmss;  /* If MSS is not cached */
>         tcp_fastopen_cache_get(sk, &tp->rx_opt.mss_clamp, &fo->cookie,
> @@ -3044,48 +3044,40 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
>         /* limit to order-0 allocations */
>         space = min_t(size_t, space, SKB_MAX_HEAD(MAX_TCP_HEADER));
>
> -       syn_data = skb_copy_expand(syn, MAX_TCP_HEADER, space,
> -                                  sk->sk_allocation);
> -       if (syn_data == NULL)
> +       syn_data = sk_stream_alloc_skb(sk, space, sk->sk_allocation);
> +       if (!syn_data)
>                 goto fallback;
> +       syn_data->ip_summed = CHECKSUM_PARTIAL;
> +       memcpy(syn_data->cb, syn->cb, sizeof(syn->cb));
> +       if (unlikely(memcpy_fromiovecend(skb_put(syn_data, space),
> +                                        fo->data->msg_iov, 0, space))) {
> +               kfree_skb(syn_data);
> +               goto fallback;
> +       }
>
> -       for (i = 0; i < iovlen && syn_data->len < space; ++i) {
> -               struct iovec *iov = &fo->data->msg_iov[i];
> -               unsigned char __user *from = iov->iov_base;
> -               int len = iov->iov_len;
> +       /* No more data pending in inet_wait_for_connect() */
> +       if (space == fo->size)
> +               fo->data = NULL;
> +       fo->copied = space;
>
> -               if (syn_data->len + len > space)
> -                       len = space - syn_data->len;
> -               else if (i + 1 == iovlen)
> -                       /* No more data pending in inet_wait_for_connect() */
> -                       fo->data = NULL;
> +       tcp_connect_queue_skb(sk, syn_data);
>
> -               if (skb_add_data(syn_data, from, len))
> -                       goto fallback;
> -       }
> +       err = tcp_transmit_skb(sk, syn_data, 1, sk->sk_allocation);
>
> -       /* Queue a data-only packet after the regular SYN for retransmission */
> -       data = pskb_copy(syn_data, sk->sk_allocation);
> -       if (data == NULL)
> -               goto fallback;
> -       TCP_SKB_CB(data)->seq++;
> -       TCP_SKB_CB(data)->tcp_flags &= ~TCPHDR_SYN;
> -       TCP_SKB_CB(data)->tcp_flags = (TCPHDR_ACK|TCPHDR_PSH);
> -       tcp_connect_queue_skb(sk, data);
> -       fo->copied = data->len;
> -
> -       /* syn_data is about to be sent, we need to take current time stamps
> -        * for the packets that are in write queue : SYN packet and DATA
> -        */
> -       skb_mstamp_get(&syn->skb_mstamp);
> -       data->skb_mstamp = syn->skb_mstamp;
> +       syn->skb_mstamp = syn_data->skb_mstamp;
>
> -       if (tcp_transmit_skb(sk, syn_data, 0, sk->sk_allocation) == 0) {
> +       /* Now full SYN+DATA was cloned and sent (or not),
> +        * remove the SYN from the original skb (syn_data)
> +        * we keep in write queue in case of a retransmit, as we
> +        * also have the SYN packet (with no data) in the same queue.
> +        */
> +       TCP_SKB_CB(syn_data)->seq++;
> +       TCP_SKB_CB(syn_data)->tcp_flags = TCPHDR_ACK | TCPHDR_PSH;
> +       if (!err) {
>                 tp->syn_data = (fo->copied > 0);
>                 NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPORIGDATASENT);
>                 goto done;
>         }
> -       syn_data = NULL;
>
>  fallback:
>         /* Send a regular SYN with Fast Open cookie request option */
> @@ -3094,7 +3086,6 @@ fallback:
>         err = tcp_transmit_skb(sk, syn, 1, sk->sk_allocation);
>         if (err)
>                 tp->syn_fastopen = 0;
> -       kfree_skb(syn_data);
>  done:
>         fo->cookie.len = -1;  /* Exclude Fast Open option for SYN retries */
>         return err;
> @@ -3114,13 +3105,10 @@ int tcp_connect(struct sock *sk)
>                 return 0;
>         }
>
> -       buff = alloc_skb_fclone(MAX_TCP_HEADER + 15, sk->sk_allocation);
> -       if (unlikely(buff == NULL))
> +       buff = sk_stream_alloc_skb(sk, 0, sk->sk_allocation);
> +       if (unlikely(!buff))
>                 return -ENOBUFS;
>
> -       /* Reserve space for headers. */
> -       skb_reserve(buff, MAX_TCP_HEADER);
> -
>         tcp_init_nondata_skb(buff, tp->write_seq++, TCPHDR_SYN);
>         tp->retrans_stamp = tcp_time_stamp;
>         tcp_connect_queue_skb(sk, buff);
>
>
