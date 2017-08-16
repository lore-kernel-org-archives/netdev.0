From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Wed, 16 Aug 2017 19:27:17 -0400
Message-ID: <CAF=yD-JryS8g=8nB7yq9WVdCOjqSb7uNwncrRfWPmMQbdYrh3w@mail.gmail.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1502702846.8411.25.camel@redhat.com>
 <1846443.VTclhqQinN@ring00> <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
 <1502724662.8411.53.camel@redhat.com> <CAF=yD-+ZNPtF1h1OT=_4yuE7=XtireP_OtbyBefHGdwtJ_ontQ@mail.gmail.com>
 <1502811641.3475.7.camel@redhat.com> <CAF=yD-Lacw9T7G0XZBdHZwEb6HgRuaBoyUN1oTvWixu4a0Fy6Q@mail.gmail.com>
 <CAF=yD-+jBim==ktwYUNAFkn-N4eabqgNME8NXM77v9-U_bfWPg@mail.gmail.com>
 <1502875722.3548.11.camel@redhat.com> <CAF=yD-K8FMicoSS6u-0r_J0p0fTyn4GNwhXn7_gRSSMYmAzw5g@mail.gmail.com>
 <1502914822.2796.6.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35805 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752382AbdHPX16 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 19:27:58 -0400
Received: by mail-oi0-f68.google.com with SMTP id q70so4980242oic.2
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 16:27:58 -0700 (PDT)
In-Reply-To: <1502914822.2796.6.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 16, 2017 at 4:20 PM, Paolo Abeni <pabeni@redhat.com> wrote:
> On Wed, 2017-08-16 at 11:18 -0400, Willem de Bruijn wrote:
>> > If I read the above correctly, you are arguining in favor of the
>> > addittional flag version, right?
>>
>> I was. Though if we are going to thread the argument from the caller
>> to __skb_try_recv_from_queue to avoid rereading sk->sk_peek_off,
>> on second thought it might be simpler to do it through off:
> [...]
>> This, of course, requires restricting sk_peek_off to protect against overflow.
>
> Ok, even if I'm not 100% sure overall this will be simpler when adding
> also the overflow check.

Actually, it is safe even without the check. Overflow of the signed integer
is benign here.

>> If I'm not mistaken, the test in udp_recvmsg currently incorrectly sets
>> peeking to false when peeking at offset zero:
>>
>>         peeking = off = sk_peek_offset(sk, flags);
>
> I think you are right, does not look correct.

By shifting the offset by two, we could even make both assignments
become correct. Return 0 without peek, 1 on peek without SO_PEEK_OFF,
2+ otherwise, including overflow up to INT_MIN + 1.

But the end result is more readable if we just separate those two
assignments.

@@ -1574,7 +1574,8 @@ int udp_recvmsg(struct sock *sk, struct msghdr
*msg, size_t len, int noblock,
                return ip_recv_error(sk, msg, len, addr_len);

 try_again:
-       peeking = off = sk_peek_offset(sk, flags);
+       peeking = flags & MSG_PEEK;
+       off = sk_peek_offset(sk, flags);
        skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
        if (!skb)
                return err;

@@ -362,7 +362,8 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr
*msg, size_t len,
                return ipv6_recv_rxpmtu(sk, msg, len, addr_len);

 try_again:
-       peeking = off = sk_peek_offset(sk, flags);
+       peeking = flags & MSG_PEEK;
+       off = sk_peek_offset(sk, flags);
        skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
        if (!skb)
                return err;

At which point there is also no longer a need for the variable shift
at sk_peek_offset. Just pass the raw value down to
__skb_try_recv_from_queue and disambiguate there:

@@ -506,11 +506,8 @@ int sk_set_peek_off(struct sock *sk, int val);

 static inline int sk_peek_offset(struct sock *sk, int flags)
 {
-       if (unlikely(flags & MSG_PEEK)) {
-               s32 off = READ_ONCE(sk->sk_peek_off);
-               if (off >= 0)
-                       return off;
-       }
+       if (unlikely(flags & MSG_PEEK))
+               return READ_ONCE(sk->sk_peek_off);

        return 0;
 }

@@ -169,14 +169,20 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
                                          int *peeked, int *off, int *err,
                                          struct sk_buff **last)
 {
+       bool peek_at_off = false;
        struct sk_buff *skb;
-       int _off = *off;
+       int _off = 0;
+
+       if (flags & MSG_PEEK && (*off) >= 0) {
+               peek_at_off = true;
+               _off = *off;
+       }

        *last = queue->prev;
        skb_queue_walk(queue, skb) {
                if (flags & MSG_PEEK) {
-                       if (_off >= skb->len && (skb->len || _off ||
-                                                skb->peeked)) {
+                       if (peek_at_off && _off >= skb->len &&
+                           (skb->len || _off || skb->peeked)) {
                                _off -= skb->len;
                                continue;
                        }
