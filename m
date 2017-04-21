From: Jamie Bainbridge <jbainbri@redhat.com>
Subject: Re: [PATCH 2/2] ipv6: don't deliver packets with zero length to raw sockets
Date: Fri, 21 Apr 2017 21:18:00 +1000
Message-ID: <CAOTh05AEQe=QMoStwdXckQ7pPW_ZuDAAj5W78rNqSR-6hNZGSQ@mail.gmail.com>
References: <1492747124-31821-1-git-send-email-jbainbri@redhat.com>
 <1492747124-31821-2-git-send-email-jbainbri@redhat.com> <20170421100112.GA4824@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:36624 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1038550AbdDULSB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 07:18:01 -0400
Received: by mail-oi0-f54.google.com with SMTP id s131so3806508oia.3
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 04:18:01 -0700 (PDT)
In-Reply-To: <20170421100112.GA4824@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sabrina,

On Fri, Apr 21, 2017 at 8:01 PM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> Hi Jamie,
>
> 2017-04-21, 13:58:44 +1000, Jamie Bainbridge wrote:
>> IPv6 assumes there is data after the network header and blindly delivers
>> skbs to raw sockets without checking the presence of data.
>>
>> With an application in a common loop where it checks select/poll/epoll
>> then ioctl(SIOCINQ/FIONREAD) is positive before continuing to
>> recvfrom(), this behaviour can cause the application to loop forever
>> on ioctl() because there is a zero-length skb to receive.
>>
>> With this, it is very easy to make a Denial of Service attack by
>> crafting a packet which declares a Next Header in the IPv6 header but
>> does not actually supply a transport header and/or payload.
>>
>> skb->len is already correctly set in ip6_input_finish() with pskb_pull()
>> so check this length before delivering zero data to raw sockets.
>
> Isn't that changing behavior? recv() currently returns 0 when a packet
> that stops right after the IP header arrives. After this, the userspace
> program won't receive anything in this case?

The recv() never occurs. The skb will not be cloned or passed into
rawv6_rcv(), the socket notification method (select/poll/epoll) will
not trigger, and the userspace program won't be informed the packet
has arrived. The behaviour is the same as if there was no raw socket,
or as if the Next Header did not match the raw socket's protocol.

As you know, IPv6 raw sockets do not offer access to the network
header by design (RFC3542). An IPv6 raw socket only receives data
after the network header. It's not like IPv4 where the raw socket
would still get the network header in the same situation.

If the raw socket is watching for data with valid transport headers,
or the user has implemented their own transport protocol, or the user
is sending raw data with no transport header, those are still
correctly cloned and passed to rawv6_rcv() to be received by the raw
socket. Nothing is broken for cases where there is data after the
network header, I tested both paged and unpaged skbs and both worked
properly.

I cannot see the use in delivering a skb with zero bytes after the
network header to a raw socket. That is like suggesting a TCP ACK with
no data payload should result in a 0-byte skb being delivered to a
stream socket, which is obviously wrong and would result in many
notification-ioctl loops just like it has here.

Jamie
