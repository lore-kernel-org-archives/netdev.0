From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH v1 1/1] l2tp: Use existing macros instead of literal number
Date: Fri, 19 Aug 2016 07:02:36 +0800
Message-ID: <CA+6hz4pcNULAT6Y6Q6mZeMf0gkZHgp0OqnNdQoVZK4-DAvD7Fw@mail.gmail.com>
References: <1471503919-30889-1-git-send-email-fgao@ikuai8.com> <20160818184139.rmijicrbbktcuis4@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gao Feng <fgao@ikuai8.com>, jchapman@katalix.com,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:34218 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754752AbcHSBIM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:08:12 -0400
Received: by mail-ua0-f194.google.com with SMTP id d97so4567287uad.1
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 18:08:11 -0700 (PDT)
In-Reply-To: <20160818184139.rmijicrbbktcuis4@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2016 at 2:41 AM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> On Thu, Aug 18, 2016 at 03:05:19PM +0800, fgao@ikuai8.com wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> 1. Use PPP_ALLSTATIONS/PPP_UI instead of literal 0xff/0x03;
>> 2. Use one static const global fixed_ppphdr instead of two same
>> static variable ppph in two different functions;
>> 3. Use SEND_SHUTDOWN instead of literal 2;
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> ---
>>  v1: Initial patch
> No need to send 'v1' for the initial series.

OK, I get it.

>
>> --- a/net/l2tp/l2tp_ppp.c
>> +++ b/net/l2tp/l2tp_ppp.c
>> @@ -138,6 +138,8 @@ static const struct ppp_channel_ops pppol2tp_chan_ops = {
>>
>>  static const struct proto_ops pppol2tp_ops;
>>
>> +static const unsigned char fixed_ppphdr[2] = {PPP_ALLSTATIONS, PPP_UI};
>> +
>>  /* Helpers to obtain tunnel/session contexts from sockets.
>>   */
>>  static inline struct l2tp_session *pppol2tp_sock_to_session(struct sock *sk)
>> @@ -174,11 +176,11 @@ static int pppol2tp_recv_payload_hook(struct sk_buff *skb)
>>        * Note that skb->data[] isn't dereferenced from a u16 ptr here since
>>        * the field may be unaligned.
>>        */
>> -     if (!pskb_may_pull(skb, 2))
>> +     if (!pskb_may_pull(skb, sizeof(fixed_ppphdr)))
>>               return 1;
>>
>> -     if ((skb->data[0] == 0xff) && (skb->data[1] == 0x03))
>> -             skb_pull(skb, 2);
>> +     if ((PPP_ADDRESS(skb->data) == PPP_ALLSTATIONS) && (PPP_CONTROL(skb->data) == PPP_UI))
>> +             skb_pull(skb, sizeof(fixed_ppphdr));
>>
> Sorry, but I find the original code clearer. It's important to be
> explicit about what's done with the sk_buff. Hiding skb->data[x] behind
> macros certainly doesn't help.
>
> Same thing for the use of sizeof(fixed_ppphdr) in pskb_may_pull(). The
> size of fixed_ppphdr isn't used aftewards, so it's unclear why its size
> was pulled. 2 was not a magic number here, it was directly related with
> the operations done on the skb (i.e. accessing skb->data[0] and
> skb->data[1]). So pskb_may_pull(skb, 2) makes perfect sense.

Agree now because of detail explanation.
Thanks.

>
> OTOH, replacing 0xff and 0x03 with PPP_ALLSTATIONS and PPP_UI is fine.

OK. get it.

>
>> @@ -312,7 +313,7 @@ static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
>>       error = -ENOMEM;
>>       skb = sock_wmalloc(sk, NET_SKB_PAD + sizeof(struct iphdr) +
>>                          uhlen + session->hdr_len +
>> -                        sizeof(ppph) + total_len,
>> +                        sizeof(fixed_ppphdr) + total_len,
>>                          0, GFP_KERNEL);
>>       if (!skb)
>>               goto error_put_sess_tun;
>> @@ -325,9 +326,9 @@ static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
>>       skb_reserve(skb, uhlen);
>>
>>       /* Add PPP header */
>> -     skb->data[0] = ppph[0];
>> -     skb->data[1] = ppph[1];
>> -     skb_put(skb, 2);
>> +     PPP_ADDRESS(skb->data) = fixed_ppphdr[0];
>> +     PPP_CONTROL(skb->data) = fixed_ppphdr[1];
>> +     skb_put(skb, sizeof(fixed_ppphdr));
>>
> Same here. What about
> + skb->data[0] = PPP_ALLSTATIONS;
> + skb->data[1] = PPP_UI;
> + skb_put(skb, 2);
> and removing ppph entirely?

Agree with you.

>
>>       /* Copy user data into skb */
>>       error = memcpy_from_msg(skb_put(skb, total_len), m, total_len);
>> @@ -369,7 +370,6 @@ error:
>>   */
>>  static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
>>  {
>> -     static const u8 ppph[2] = { 0xff, 0x03 };
>>       struct sock *sk = (struct sock *) chan->private;
>>       struct sock *sk_tun;
>>       struct l2tp_session *session;
>> @@ -398,14 +398,14 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
>>                  sizeof(struct iphdr) + /* IP header */
>>                  uhlen +              /* UDP header (if L2TP_ENCAPTYPE_UDP) */
>>                  session->hdr_len +   /* L2TP header */
>> -                sizeof(ppph);        /* PPP header */
>> +                sizeof(fixed_ppphdr); /* PPP header */
>>       if (skb_cow_head(skb, headroom))
>>               goto abort_put_sess_tun;
>>
>>       /* Setup PPP header */
>> -     __skb_push(skb, sizeof(ppph));
>> -     skb->data[0] = ppph[0];
>> -     skb->data[1] = ppph[1];
>> +     __skb_push(skb, sizeof(fixed_ppphdr));
>> +     skb->data[0] = fixed_ppphdr[0];
>> +     skb->data[1] = fixed_ppphdr[1];
>>
> Same as for pppol2tp_sendmsg().
>
>> @@ -440,7 +440,7 @@ static void pppol2tp_session_close(struct l2tp_session *session)
>>       BUG_ON(session->magic != L2TP_SESSION_MAGIC);
>>
>>       if (sock) {
>> -             inet_shutdown(sock, 2);
>> +             inet_shutdown(sock, SEND_SHUTDOWN);
>>
> Ok.

Regards
Feng
