From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] sock: consistent errqueue errors and signals
Date: Tue, 2 Sep 2014 11:20:34 -0400
Message-ID: <CA+FuTScAYY1ZhQPwY=pqW9hXf3UYB70Dxq5+aPH4D4pB7QRPbg@mail.gmail.com>
References: <1409534896-372-1-git-send-email-willemb@google.com> <1409606744.21965.37.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:36275 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbaIBPVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 11:21:06 -0400
Received: by mail-qa0-f50.google.com with SMTP id cm18so6274831qab.23
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 08:21:04 -0700 (PDT)
In-Reply-To: <1409606744.21965.37.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From my experience in IPv6 code, we only do sk->sk_err updates directly
> in protocol error handling code. In case of UDP IPv6 errors for example
> we now notify sk_error_report two times with this patch (before the
> patch we did sk_data_ready (this is what you changed) and
> sk_error_report).

If the event is that an error is ready, is this not correct? The
wake up key should be POLLERR in both cases. In implementation
of sock_def_error_report and sock_def_readable, the difference
otherwise seems slim. I haven't checked all sk_data_ready and
sk_error_report implementations, though, so may have missed
differences for specific protocols. If this is not as obviously a strict
improvement as I thought, I'll just drop it.

> I really wonder if setting sk->sk_err in this function is the right
> thing to do.

I agree, in that it is hard to verify that this does not overwrite
an existing error. This patch only makes the behavior
consistent between enqueue and dequeue, but perhaps a
better way to achieve that is to change the dequeue side:
remove the assignment to sk->sk_err there. If so, then all
locations that currently check the state of sk->sk_err should
be changed to also check the qlen of the error queue and
if non-zero return the embedded error of the first skb. I'll
take a look whether that is feasible without adding locks
or atomics in the common path.

> It also depends on socket state bits (e.g. np->recverr) if
> the update happens. So we still cannot get rid of the protocol dependent
> sk->sk_err updates.
>
> It looks like we have to check all error handling functions in the
> protocols. Maybe timestamp code needs to adapt?

Does the above sound okay, or did you mean something else?

>
> Thanks,
> Hannes
>
>
