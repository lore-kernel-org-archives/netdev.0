From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] sock: consistent errqueue errors and signals
Date: Wed, 3 Sep 2014 15:40:59 -0400
Message-ID: <CA+FuTSfsCiE8HvBHVd1HXG_WXZgZ1D7YjJetmSgsSO46nVtMaA@mail.gmail.com>
References: <1409534896-372-1-git-send-email-willemb@google.com> <1409746453.14224.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:45729 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754834AbaICTlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 15:41:35 -0400
Received: by mail-qg0-f50.google.com with SMTP id q108so8698165qgd.37
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 12:41:30 -0700 (PDT)
In-Reply-To: <1409746453.14224.14.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I just noticed another problem with this approach why I think we cannot
> use it.
>
> In case we generate an error back to the socket locally because
> something (e.g. the packet was too big) in output path, we must not
> update sk->sk_err because we return it immediately to the sender but
> nonetheless must update the error queue.
>
> It seems to me that this patch would report the same error two times to
> the program then.

For instance in __ip_append_data reaching

  ip_local_error(sk, EMSGSIZE, ..);
  return -EMSGSIZE;

With this patch, where sk->sk_err is set, the error will continuously
be returned on send/recv until the caller reads from the error queue.
A recvmsg MSG_ERRQUEUE will cause the error to be reset immediately.
If socket option IP_RECVERR is set, the process should immediately
read the error queue when a send call fails with EMSGSIZE or any other
relevant error. In that case, the error is not reported more than
once.

The alternative patch does not overwrite sk->sk_err, but results in
this same modified user-visible behavior.

Without the patch, after a send call fails in the above code, the
process can continue calling send/recv normally while ignoring the
error, since all "if (sk->sk_err)" checks fall through. If we have to
treat this as legacy behavior, then neither patch should be applied.
Then, the semantics are that queued errors are non-blocking. In that
case, the only patch needed for consistent semantics is to remove the
sk->sk_err assigment in skb_dequeue_err_skb.

On a related note, when returning an error, returning the errno from
the item on the queue is a confusing signal. Some error codes are the
result of protocol processing and have nothing queued (e.g., EINVAL),
others are due to an queued error (ENOMSG) and some are simply
ambiguous (EMSGSIZE). It is not reasonable to expect processes to
figure out the three sets. One solution would be to dedicate a special
error code to denote "there is a message queued onto sk_error_queue,
read the actual errno from there". This choice only relevant if we
decide to return an error, at all, of course.
