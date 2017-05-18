From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v4 net-next 6/7] net: allow simultaneous SW and HW
 transmit timestamping
Date: Thu, 18 May 2017 16:16:26 -0400
Message-ID: <CAF=yD-KVwq+WXZNoZH+Vbs8-aMWF969AxzTqBZSKfFyDqszRNQ@mail.gmail.com>
References: <20170518130656.24163-1-mlichvar@redhat.com> <20170518130656.24163-7-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:32919 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755635AbdERURI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 16:17:08 -0400
Received: by mail-oi0-f68.google.com with SMTP id h4so9221886oib.0
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 13:17:07 -0700 (PDT)
In-Reply-To: <20170518130656.24163-7-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 9:06 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> Add SOF_TIMESTAMPING_OPT_TX_SWHW option to allow an outgoing packet to
> be looped to the socket's error queue with a software timestamp even
> when a hardware transmit timestamp is expected to be provided by the
> driver.
>
> Applications using this option will receive two separate messages from
> the error queue, one with a software timestamp and the other with a
> hardware timestamp. As the hardware timestamp is saved to the shared skb
> info, which may happen before the first message with software timestamp
> is received by the application, the hardware timestamp is copied to the
> SCM_TIMESTAMPING control message only when the skb has no software
> timestamp or it is an incoming packet.
>
> While changing sw_tx_timestamp(), inline it in skb_tx_timestamp() as
> there are no other users.
>
> CC: Richard Cochran <richardcochran@gmail.com>
> CC: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
> ---

> +/* On transmit, software and hardware timestamps are returned independently.
> + * As the two skb clones share the hardware timestamp, which may be updated
> + * before the software timestamp is received, a hardware TX timestamp may be
> + * returned only if there is no software TX timestamp. A false software
> + * timestamp made for SOCK_RCVTSTAMP when a real timestamp is missing must
> + * be ignored.

Please expand on why this case can be ignored. It is quite subtle. How about
something like

*
* A false software timestamp is one made inside the __sock_recv_timestamp
* call itself. These are generated whenever SO_TIMESTAMP(NS) is enabled
* on the socket, even when the timestamp reported is for another option, such
* as hardware tx timestamp.
*
* Ignore these when deciding whether a timestamp source is hw or sw.
*/

And perhaps move the comment to the branch itself.

> + */
> +static bool skb_is_swtx_tstamp(const struct sk_buff *skb,
> +                              const struct sock *sk, int false_tstamp)
> +{
> +       if (false_tstamp && sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TX_SWHW)

Also, why is it ignored only for the new mode?

> +               return 0;
> +
> +       return skb->tstamp && skb_is_err_queue(skb);
> +}
