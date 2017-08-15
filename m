From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Mon, 14 Aug 2017 21:35:52 -0400
Message-ID: <CAF=yD-+ZNPtF1h1OT=_4yuE7=XtireP_OtbyBefHGdwtJ_ontQ@mail.gmail.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1502702846.8411.25.camel@redhat.com>
 <1846443.VTclhqQinN@ring00> <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
 <1502724662.8411.53.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35603 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752833AbdHOBgd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 21:36:33 -0400
Received: by mail-oi0-f67.google.com with SMTP id q70so10892006oic.2
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 18:36:33 -0700 (PDT)
In-Reply-To: <1502724662.8411.53.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 14, 2017 at 11:31 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> On Mon, 2017-08-14 at 11:03 -0400, Willem de Bruijn wrote:
>> > I'm actually surprised that only unix sockets can have negative values.  Is
>> > there a reason for that?  I had assumed that sk_set_peek_off would allow
>> > negative values as the code already has to support negative values due to what
>> > the initial value is.
>>
>> A negative initial value indicates that PEEK_OFF is disabled. It only
>> makes sense to peek from a positive offset from the start of the data.
>
> With the current code, the user space can disable peeking with offset
> setting a negative offset value, after that peeking with offset has
> been enabled. But only for UNIX sockets. I think the same should be
> allowed for UDP sockets.

Agreed. Reverting to no-offset should be allowed.

>> > > I'm wondering adding an explicit SOCK_PEEK_OFF/MSG_PEEK_OFF socket flag
>> > > would help simplyifing the code:
>>
>> The behavior needs to be bifurcated between peeking with
>> offset and without offset.
>>
>> When peeking with offset is enabled by setting SO_PEEK_OFF,
>> subsequent reads do move the offset, so the observed behavior
>> is correct.
>>
>> When sk->sk_peek_offset is negative, offset mode is disabled
>> and the same packet must be read twice.
>>
>> An explicit boolean flag to discern between the two may make
>> the code simpler to understand, not sure whether that is logically
>> required.
>
> Yes, an explicit PEEK_OFF flag is just to keep the code simpler, so
> that there is no need to add checks at every sk_peek_offset() call site
> and the relevant logic can be fully encapsulated under the MSG_PEEK
> branch in __skb_try_recv_from_queue(), I think/hope.
> It's not a functional requirement.

It is a problematic that sk_peek_offset returns zero both on zero offset
and when peeking at offset is disabled.

It is not infeasible to fix that and fix up all callers, as Matthew's
patch does. But perhaps this patch is simpler to reason about. Thoughts?

+static inline bool sk_peek_at_offset(struct sock *sk)
+{
+       return READ_ONCE(sk->sk_peek_off) >= 0;
+}
+
 static inline int sk_peek_offset(struct sock *sk, int flags)
 {
        if (unlikely(flags & MSG_PEEK)) {
diff --git a/net/core/datagram.c b/net/core/datagram.c
index ee5647bd91b3..30b53932af73 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -175,12 +175,14 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
        *last = queue->prev;
        skb_queue_walk(queue, skb) {
                if (flags & MSG_PEEK) {
-                       if (_off >= skb->len && (skb->len || _off ||
-                                                skb->peeked)) {
+                       if (_off >= skb->len && sk_peek_at_offset(sk) &&
+                           (skb->len || _off || skb->peeked)) {
