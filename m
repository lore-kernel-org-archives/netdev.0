From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v2] packet: make packet_snd fail on len smaller
 than l2 header
Date: Wed, 24 Dec 2014 14:28:11 +0100
Message-ID: <CA+FuTSce7A48KHz+95EQFObFyPRcPJw0iFM+P89LyZ6VQmYD9g@mail.gmail.com>
References: <1416420616-5029-1-git-send-email-willemb@google.com> <CANe27jJfsuXd29UXouTgU8dGqb9h8mXuj9N1_Ua6Q_UbZCeCXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: Jouni Malinen <jkmalinen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:60367 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbaLXN2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 08:28:42 -0500
Received: by mail-qg0-f49.google.com with SMTP id a108so5764336qge.36
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 05:28:41 -0800 (PST)
In-Reply-To: <CANe27jJfsuXd29UXouTgU8dGqb9h8mXuj9N1_Ua6Q_UbZCeCXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 23, 2014 at 11:37 AM, Jouni Malinen <jkmalinen@gmail.com> wrote:
> On Wed, Nov 19, 2014 at 8:10 PM, Willem de Bruijn <willemb@google.com> wrote:
>> When sending packets out with PF_PACKET, SOCK_RAW, ensure that the
>> packet is at least as long as the device's expected link layer header.
>> This check already exists in tpacket_snd, but not in packet_snd.
>
> Was this supposed to be refusing zero-length payload following the
> header like the implementation does or accept zero-length payload like
> this commit message seems to imply? Based on the commit message, I'd
> assume 14 byte buffer on Ethernet netdev should have been accepted.

Fair point. This patch just extended the existing check in tpacket_rcv to
cover packet_rcv, so the code is the authoritative answer. But my
commit message is inconsistent with the patch.

> I just noticed that once pulling this commit in into my automated test
> setup, one of the test cases started failing because of the change
> here. That test case was trying to transmit a minimum length Ethernet
> header using raw packet socket. Not that I care too much since I can
> easily change the test case to use one octet longer data to send and
> this was not really a real protocol case, but I wanted to confirm what
> was the expected behavior here since this commit seems to have number
> of inconsistent statements between the commit message, actual
> validation step, debug print, and code comment..
>
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> @@ -2095,6 +2095,18 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
>> +static bool ll_header_truncated(const struct net_device *dev, int len)
>> +{
>> +       /* net device doesn't like empty head */
>
> I'm not sure how to interpret "empty head". Is that saying that the
> data following the header should not be empty? Or that header should
> be at least hard_header_len?

I read it as the first interpretation. I do not have an immediate example
of stack or driver code that cannot handle Ethernet frames without
payload, but also do not know of any legitimate use for sending such
frames. Minimum frame length on the wire is even longer. The current
test errs on the side of caution based on that existing use, then.

>
>> +       if (unlikely(len <= dev->hard_header_len)) {
>
> That would be rejecting exactly hard_header_len, i.e,., I would have
> expected < instead of <= here based on the commit message.
>
>> +               net_warn_ratelimited("%s: packet size is too short (%d < %d)\n",
>> +                                    current->comm, len, dev->hard_header_len);
>
> But that debug print uses < instead of <= which is not consistent with
> the actual condition (and yes, I realize this was there even before
> this commit).

Thanks, good point. When moving that code, I did not read it closely
enough to notice the inconsistency. This looks sloppy; I can send a one
line patch, unless you want to do it yourself.

> - Jouni
