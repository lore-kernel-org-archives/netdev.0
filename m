From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] sock: consistent errqueue errors and signals
Date: Thu, 04 Sep 2014 02:17:16 +0200
Message-ID: <1409789836.3347097.163379629.7D1B7A44@webmail.messagingengine.com>
References: <1409534896-372-1-git-send-email-willemb@google.com>
 <1409746453.14224.14.camel@localhost>
 <CA+FuTSfsCiE8HvBHVd1HXG_WXZgZ1D7YjJetmSgsSO46nVtMaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:53922 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751167AbaIDARR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 20:17:17 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id ACE65207C8
	for <netdev@vger.kernel.org>; Wed,  3 Sep 2014 20:17:16 -0400 (EDT)
In-Reply-To: <CA+FuTSfsCiE8HvBHVd1HXG_WXZgZ1D7YjJetmSgsSO46nVtMaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Sep 3, 2014, at 21:40, Willem de Bruijn wrote:
> > I just noticed another problem with this approach why I think we cannot
> > use it.
> >
> > In case we generate an error back to the socket locally because
> > something (e.g. the packet was too big) in output path, we must not
> > update sk->sk_err because we return it immediately to the sender but
> > nonetheless must update the error queue.
> >
> > It seems to me that this patch would report the same error two times to
> > the program then.
> 
> For instance in __ip_append_data reaching
> 
>   ip_local_error(sk, EMSGSIZE, ..);
>   return -EMSGSIZE;
> 
> With this patch, where sk->sk_err is set, the error will continuously
> be returned on send/recv until the caller reads from the error queue.
> A recvmsg MSG_ERRQUEUE will cause the error to be reset immediately.

sk->sk_err will be reset by sock_error(), called from
__skb_recv_datagram or sock_alloc_send_pskb. So a normal receive or send
(even without MSG_ERRQUEUE) should clean the error code and report it.
No further looks into the error queue should happen currently (I am
currently talking about the patch in this thread).

I was concerned that we report the error twice. Once in the sendmsg path
and again on recvmsg or sendmsg, which finally clears sk_err.

> If socket option IP_RECVERR is set, the process should immediately
> read the error queue when a send call fails with EMSGSIZE or any other
> relevant error. In that case, the error is not reported more than
> once.

I agree but am afraid of applications start to break.
 
> The alternative patch does not overwrite sk->sk_err, but results in
> this same modified user-visible behavior.
> 
> Without the patch, after a send call fails in the above code, the
> process can continue calling send/recv normally while ignoring the
> error, since all "if (sk->sk_err)" checks fall through. If we have to
> treat this as legacy behavior, then neither patch should be applied.
> Then, the semantics are that queued errors are non-blocking. In that
> case, the only patch needed for consistent semantics is to remove the
> sk->sk_err assigment in skb_dequeue_err_skb.

I am afraid that we need to go down this route. :/

I would even let the sk->sk_error_report call be handled by the protocol
error reporting function, as it would need to deal with sk->sk_err, too.

Most applications susceptible to breakage here are ping and
tracepath/traceroute. I don't think they all check MSG_ERRQUEUE always
on every error. But it shouldn't matter that much because they are only
short running apps and error queue will be freed if application exits
before socket accounting will shut down the socket. If we start to
report one instance of an error event multiple times, I think they might
become confused.

> On a related note, when returning an error, returning the errno from
> the item on the queue is a confusing signal. Some error codes are the
> result of protocol processing and have nothing queued (e.g., EINVAL),
> others are due to an queued error (ENOMSG) and some are simply
> ambiguous (EMSGSIZE). It is not reasonable to expect processes to
> figure out the three sets. One solution would be to dedicate a special
> error code to denote "there is a message queued onto sk_error_queue,
> read the actual errno from there". This choice only relevant if we
> decide to return an error, at all, of course.

errno messages are higly sensitive regarding backwards compatibility. I
am totally with you that a special errno marker to indicate that a
packet was enqueued on the error queue would be much better. Currently
applications always have to query error queue on error indication,
otherwise socket accounting might shut down the socket at some point.
Sadly I don't see this change to happen.

Bye,
Hannes
