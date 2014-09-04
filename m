From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] sock: consistent errqueue errors and signals
Date: Thu, 4 Sep 2014 14:13:13 -0400
Message-ID: <CA+FuTSeJDbWN82LOZ5MoHtdY6Qe1GywBMC2QGrT3Z-n7O0727w@mail.gmail.com>
References: <1409534896-372-1-git-send-email-willemb@google.com>
 <1409746453.14224.14.camel@localhost> <CA+FuTSfsCiE8HvBHVd1HXG_WXZgZ1D7YjJetmSgsSO46nVtMaA@mail.gmail.com>
 <1409789836.3347097.163379629.7D1B7A44@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:48572 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754673AbaIDSNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 14:13:46 -0400
Received: by mail-qc0-f175.google.com with SMTP id c9so10887124qcz.6
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 11:13:45 -0700 (PDT)
In-Reply-To: <1409789836.3347097.163379629.7D1B7A44@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I was concerned that we report the error twice. Once in the sendmsg path
> and again on recvmsg or sendmsg, which finally clears sk_err.

I had overlooked that messages can be queued onto the error queue
during send call processing (most cases of ip_local_error) as well as from
asynchronous events (ip_icmp_error, skb_complete_tx_timestamp, ..).

For the second case, the patch fixes that an enqueued message does
not have its error returned on the first subsequent system call. By
setting sk->sk_err unconditionally, the patch indeed introduces a
double notification in the other case.

Both paths can be made correct if sk->sk_err is set on enqueue
only when not called from inside the send() context. The easiest
change for timestamping is to set it in __skb_tstamp_tx directly.
Slightly more general would be to add

* /* queue errors from asynchronous events: report the error on the
next syscall */
+ int sock_queue_err_skb_and_notify(struct sock *sk, struct sk_buff *skb)
+ {
+  int ret = sock_queue_err_skb(sk);
+  if (!ret)
+    sk->sk_err = SKB_EXT_ERR(skb)->ee.ee_errno;
+ }

and call this from __skb_tstamp_tx, skb_complete_tx_timestamp,
skb_complete_wifi_ack. It is perhaps also safe to call from
ip[v6]_icmp_error, but as you point out there are many legacy expectations
there, so it may be best to leave that code path as is.

>> If socket option IP_RECVERR is set, the process should immediately
>> read the error queue when a send call fails with EMSGSIZE or any other
>> relevant error. In that case, the error is not reported more than
>> once.
>
> I agree but am afraid of applications start to break.
>
>> The alternative patch does not overwrite sk->sk_err, but results in
>> this same modified user-visible behavior.
>>
>> Without the patch, after a send call fails in the above code, the
>> process can continue calling send/recv normally while ignoring the
>> error, since all "if (sk->sk_err)" checks fall through. If we have to
>> treat this as legacy behavior, then neither patch should be applied.
>> Then, the semantics are that queued errors are non-blocking. In that
>> case, the only patch needed for consistent semantics is to remove the
>> sk->sk_err assigment in skb_dequeue_err_skb.
>
> I am afraid that we need to go down this route. :/
>
> I would even let the sk->sk_error_report call be handled by the protocol
> error reporting function, as it would need to deal with sk->sk_err, too.
>
> Most applications susceptible to breakage here are ping and
> tracepath/traceroute. I don't think they all check MSG_ERRQUEUE always
> on every error. But it shouldn't matter that much because they are only
> short running apps and error queue will be freed if application exits
> before socket accounting will shut down the socket. If we start to
> report one instance of an error event multiple times, I think they might
> become confused.
>
>> On a related note, when returning an error, returning the errno from
>> the item on the queue is a confusing signal. Some error codes are the
>> result of protocol processing and have nothing queued (e.g., EINVAL),
>> others are due to an queued error (ENOMSG) and some are simply
>> ambiguous (EMSGSIZE). It is not reasonable to expect processes to
>> figure out the three sets. One solution would be to dedicate a special
>> error code to denote "there is a message queued onto sk_error_queue,
>> read the actual errno from there". This choice only relevant if we
>> decide to return an error, at all, of course.
>
> errno messages are higly sensitive regarding backwards compatibility. I
> am totally with you that a special errno marker to indicate that a
> packet was enqueued on the error queue would be much better. Currently
> applications always have to query error queue on error indication,
> otherwise socket accounting might shut down the socket at some point.
> Sadly I don't see this change to happen.
>
> Bye,
> Hannes
