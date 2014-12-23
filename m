From: Jouni Malinen <jkmalinen@gmail.com>
Subject: Re: [PATCH net-next v2] packet: make packet_snd fail on len smaller
 than l2 header
Date: Tue, 23 Dec 2014 12:37:17 +0200
Message-ID: <CANe27jJfsuXd29UXouTgU8dGqb9h8mXuj9N1_Ua6Q_UbZCeCXQ@mail.gmail.com>
References: <1416420616-5029-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, dborkman@redhat.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:45381 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754411AbaLWKhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 05:37:18 -0500
Received: by mail-yk0-f169.google.com with SMTP id 79so2986693ykr.0
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 02:37:18 -0800 (PST)
In-Reply-To: <1416420616-5029-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2014 at 8:10 PM, Willem de Bruijn <willemb@google.com> wrote:
> When sending packets out with PF_PACKET, SOCK_RAW, ensure that the
> packet is at least as long as the device's expected link layer header.
> This check already exists in tpacket_snd, but not in packet_snd.

Was this supposed to be refusing zero-length payload following the
header like the implementation does or accept zero-length payload like
this commit message seems to imply? Based on the commit message, I'd
assume 14 byte buffer on Ethernet netdev should have been accepted.

I just noticed that once pulling this commit in into my automated test
setup, one of the test cases started failing because of the change
here. That test case was trying to transmit a minimum length Ethernet
header using raw packet socket. Not that I care too much since I can
easily change the test case to use one octet longer data to send and
this was not really a real protocol case, but I wanted to confirm what
was the expected behavior here since this commit seems to have number
of inconsistent statements between the commit message, actual
validation step, debug print, and code comment..

> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> @@ -2095,6 +2095,18 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
> +static bool ll_header_truncated(const struct net_device *dev, int len)
> +{
> +       /* net device doesn't like empty head */

I'm not sure how to interpret "empty head". Is that saying that the
data following the header should not be empty? Or that header should
be at least hard_header_len?

> +       if (unlikely(len <= dev->hard_header_len)) {

That would be rejecting exactly hard_header_len, i.e,., I would have
expected < instead of <= here based on the commit message.

> +               net_warn_ratelimited("%s: packet size is too short (%d < %d)\n",
> +                                    current->comm, len, dev->hard_header_len);

But that debug print uses < instead of <= which is not consistent with
the actual condition (and yes, I realize this was there even before
this commit).

- Jouni
