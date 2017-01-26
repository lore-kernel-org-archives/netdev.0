From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC net-next] packet: always ensure that we pass
 hard_header_len bytes in skb_headlen() to the driver
Date: Thu, 26 Jan 2017 15:21:22 -0500
Message-ID: <CAF=yD-KXqpODBVQ0vUt1a1p_mMXzzQp=5GU33f9GY9_cbPJxDw@mail.gmail.com>
References: <1485274309-201670-1-git-send-email-sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36288 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751880AbdAZUWJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 15:22:09 -0500
Received: by mail-wm0-f67.google.com with SMTP id r126so52931234wmr.3
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 12:22:08 -0800 (PST)
In-Reply-To: <1485274309-201670-1-git-send-email-sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If the application has provided fewer than hard_header_len bytes,
> dev_validate_header() will zero out the skb->data as needed. This is
> acceptable for SOCK_DGRAM/PF_PACKET sockets but in all other cases,

This was added not for datagram sockets, but to be able to bypass
validation. See the message in commit 2793a23aacbd ("net: validate
variable length ll header") and discussion leading up to that patch.

> the application must provide a full L2 header, and the PF_PACKET Tx
> paths must fail with an error when fewer than hard_header_len bytes
> are detected.

As David pointed out, this does not handle variable length headers
correctly. In link layers that support these, hard_header_len defines
the maximum header length. A hard failure on len < hard_header_len
would be incorrect.

The ->validate callback was added to allow specifying additional
constraints on a per protocol basis. This is where a min constraint
can be added, e.g., for ethernet.

> All invocations to dev_validate_header() already adjusts the
> skb's data, len, tail etc pointers based on hard_header_len before
> invoking dev_validate_header(), so additional skb pointers should
> not be needed after dev_validate_header().
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---

> -       if (!dev_validate_header(dev, skb->data, len)) {
> +       newlen = dev_validate_header(dev, skb->data, len);
> +       /* As comments above this function indicate, a full L2 header
> +        * must be passed to this function, so if newlen > len, bail.
> +        */
> +       if (newlen < 0 || newlen > len) {

If callers only care whether the function returned failure or
increased len, which also indicates failure, it is cleaner to leave it
a boolean and fail in cases where len < the minimum for that link
layer type. No caller actually uses newlen.

> +               /* Caller has allocated for copylen in non-paged part of
> +                * skb so we should never find newlen > hdrlen
> +                */
> +               WARN_ON(newlen > hdrlen);

WARN_ON_ONCE is safer.
