From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Tue, 15 Aug 2017 12:45:23 -0400
Message-ID: <CAF=yD-Lacw9T7G0XZBdHZwEb6HgRuaBoyUN1oTvWixu4a0Fy6Q@mail.gmail.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1502702846.8411.25.camel@redhat.com>
 <1846443.VTclhqQinN@ring00> <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
 <1502724662.8411.53.camel@redhat.com> <CAF=yD-+ZNPtF1h1OT=_4yuE7=XtireP_OtbyBefHGdwtJ_ontQ@mail.gmail.com>
 <1502811641.3475.7.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:38722 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751573AbdHOQqF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 12:46:05 -0400
Received: by mail-oi0-f66.google.com with SMTP id s21so1226643oie.5
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 09:46:05 -0700 (PDT)
In-Reply-To: <1502811641.3475.7.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 11:40 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> On Mon, 2017-08-14 at 21:35 -0400, Willem de Bruijn wrote:
>> It is not infeasible to fix that and fix up all callers, as Matthew's
>> patch does. But perhaps this patch is simpler to reason about. Thoughts?
>>
>> +static inline bool sk_peek_at_offset(struct sock *sk)
>> +{
>> +       return READ_ONCE(sk->sk_peek_off) >= 0;
>> +}
>> +
>>  static inline int sk_peek_offset(struct sock *sk, int flags)
>>  {
>>         if (unlikely(flags & MSG_PEEK)) {
>> diff --git a/net/core/datagram.c b/net/core/datagram.c
>> index ee5647bd91b3..30b53932af73 100644
>> --- a/net/core/datagram.c
>> +++ b/net/core/datagram.c
>> @@ -175,12 +175,14 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
>>         *last = queue->prev;
>>         skb_queue_walk(queue, skb) {
>>                 if (flags & MSG_PEEK) {
>> -                       if (_off >= skb->len && (skb->len || _off ||
>> -                                                skb->peeked)) {
>> +                       if (_off >= skb->len && sk_peek_at_offset(sk) &&
>> +                           (skb->len || _off || skb->peeked)) {
>
> I like the idea a lot, but I think/fear that bad things could happen
> since sk_peek_off is read twice at different times: one in
> sk_peek_offset() and one in the above chunk.
>
> If the above is not an issue (I am not sure) I'm very fine with this
> approach.

Good point. I don't think we need to read it in the callers at all.
Then int *off is only used to return to offset within the skb back
to the callers.

Though it should be read only once here, outside the loop.

Something like (also untested):

diff --git a/net/core/datagram.c b/net/core/datagram.c
index ee5647bd91b3..06bad8726612 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -170,13 +170,15 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
                                          struct sk_buff **last)
 {
        struct sk_buff *skb;
-       int _off = *off;
+       int _off;
+       bool peek_at_off;

+       _off = sk_peek_offset(sk, flags);
+       peek_at_off = _off >= 0;
        *last = queue->prev;
        skb_queue_walk(queue, skb) {
                if (flags & MSG_PEEK) {
-                       if (_off >= skb->len && (skb->len || _off ||
-                                                skb->peeked)) {
+                       if (peek_at_off && off >= skb->len &&
+                           (skb->len || _off || skb->peeked)) {
                                _off -= skb->len;
                                continue;
                        }

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index a7c804f73990..4b51b9853406 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1574,7 +1574,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr
*msg, size_t len, int noblock,
                return ip_recv_error(sk, msg, len, addr_len);

 try_again:
-       peeking = off = sk_peek_offset(sk, flags);
+       peeking = flags & MSG_PEEK;
        skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
        if (!skb)
                return err;

The explicit peek_at_off is a bit verbose, but we need to be careful
about signedness between _off and skb->len.

> For the record, I thought something like the following (uncomplete,
> does not even compile):
> ---
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index 8b13db5163cc..5085cf003b88 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -286,6 +286,7 @@ struct ucred {
>  #define MSG_SENDPAGE_NOTLAST 0x20000 /* sendpage() internal : not the last page */
>  #define MSG_BATCH      0x40000 /* sendmmsg(): more messages coming */
>  #define MSG_EOF         MSG_FIN
> +#define MSG_PEEK_OFF   0x80000

Yes, that also works well.

I'm afraid about exhausting the MSG_* flag space here for a
feature that is not exposed to userspace. We don't have many flags
left. We could shadow an existing flag that is unused in this context.

There is another difference between reading sk_peek_offset in the
caller or in __skb_try_recv_from_queue. The latter is called repeatedly
when it returns NULL. Each call can modify *off. I believe that it needs
to restart with _off at sk->sk_peek_off each time, as it restarts from the
head of the queue each time.

>
>  #define MSG_FASTOPEN   0x20000000      /* Send data in TCP SYN */
>  #define MSG_CMSG_CLOEXEC 0x40000000    /* Set close_on_exec for file
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 7c0632c7e870..e75e024b55d2 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -504,12 +504,14 @@ enum sk_pacing {
>
>  int sk_set_peek_off(struct sock *sk, int val);
>
> -static inline int sk_peek_offset(struct sock *sk, int flags)
> +static inline int sk_peek_offset(struct sock *sk, int *flags)
>  {
> -       if (unlikely(flags & MSG_PEEK)) {
> +       if (unlikely(*flags & MSG_PEEK)) {
>                 s32 off = READ_ONCE(sk->sk_peek_off);
> -               if (off >= 0)
> +               if (off >= 0) {
> +                       *flags |= MSG_PEEK_OFF;
>                         return off;
> +               }
>         }
>
>         return 0;
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index ee5647bd91b3..91e1d014d64c 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -175,8 +175,8 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
>         *last = queue->prev;
>         skb_queue_walk(queue, skb) {
>                 if (flags & MSG_PEEK) {
> -                       if (_off >= skb->len && (skb->len || _off ||
> -                                                skb->peeked)) {
> +                       if (flags & MSG_PEEK_OFF && _off >= skb->len &&
> +                           (skb->len || _off || skb->peeked)) {
>                                 _off -= skb->len;
>                                 continue;
>                         }
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index a7c804f73990..7e1bcd3500f4 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1574,7 +1574,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
>                 return ip_recv_error(sk, msg, len, addr_len);
>
>  try_again:
> -       peeking = off = sk_peek_offset(sk, flags);
> +       peeking = off = sk_peek_offset(sk, &flags);
>         skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
>         if (!skb)
>                 return err;
> ---
> Paolo
