From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv6-UDP 0x0000 checksum
Date: Thu, 26 Jan 2017 05:44:59 -0800
Message-ID: <1485438299.5145.117.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485437276.14760.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32868 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752208AbdAZNpB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 08:45:01 -0500
In-Reply-To: <1485437276.14760.3.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-26 at 14:27 +0100, Johannes Berg wrote:
> Hi,
> 
> It looks like right now we may have a hardware bug and accept 0x0000 as
> valid, when the outcome of the calculation is 0xffff.
> 
> What do you think we should do about this?
> 
> We could ignore the issue entirely, since 0 wasn't ever supposed to be
> sent anyway - but then we don't drop frames that we should drop. I
> didn't manage to find the code in the IPv6/UDP stack that even does
> that, but I assume it's there somewhere.
> 
> Alternatively, we could parse the packet to find the checksum inside,
> and if it's 0 then don't report CHECKSUM_UNNECESSARY, but that seems
> rather expensive/difficult due to the IPv6 variable header and all
> that. If we wanted to go this route, are there any helper functions for
> this?
> 
> Unfortunately, in the current devices, we neither have a complete
> indication that the packet was even UDP-IPv6, nor do we have the raw
> csum or anything like that. I think they're adding that to the next
> hardware spin, but we probably need to address this issue now.
> 
> johannes

Hi Johannes

I am afraid information is missing.

Is this a xmit or rcv problem ?

I recently fixed an issue, could this be this ?

commit 4f2e4ad56a65f3b7d64c258e373cb71e8d2499f4
Author: Eric Dumazet <edumazet@google.com>
Date:   Sat Oct 29 11:02:36 2016 -0700

    net: mangle zero checksum in skb_checksum_help()
    
    Sending zero checksum is ok for TCP, but not for UDP.
    
    UDPv6 receiver should by default drop a frame with a 0 checksum,
    and UDPv4 would not verify the checksum and might accept a corrupted
    packet.
    
    Simply replace such checksum by 0xffff, regardless of transport.
    
    This error was caught on SIT tunnels, but seems generic.
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Cc: Maciej Żenczykowski <maze@google.com>
    Cc: Willem de Bruijn <willemb@google.com>
    Acked-by: Maciej Żenczykowski <maze@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index 820bac239738eb021354ac95ca5bbdff1840cb8e..eaad4c28069ff523ac784bf2dffd0acff82341a0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2484,7 +2484,7 @@ int skb_checksum_help(struct sk_buff *skb)
                        goto out;
        }
 
-       *(__sum16 *)(skb->data + offset) = csum_fold(csum);
+       *(__sum16 *)(skb->data + offset) = csum_fold(csum) ?: CSUM_MANGLED_0;
 out_set_summed:
        skb->ip_summed = CHECKSUM_NONE;
 out:
