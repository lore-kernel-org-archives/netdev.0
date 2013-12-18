From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH net-next] ipv4: introduce ip_dst_mtu_secure and protect
 forwarding path against pmtu spoofing
Date: Wed, 18 Dec 2013 18:55:13 -0500
Message-ID: <CABrhC0nG8Z01G-zVtObe40OuyDo0Jm5y+Lzy_r-zr2zmjfaKjQ@mail.gmail.com>
References: <20131215022336.GA27866@order.stressinduktion.org>
	<20131218.173442.336109133942416102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: hannes@stressinduktion.org, Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:60184 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367Ab3LRXzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 18:55:15 -0500
Received: by mail-wi0-f181.google.com with SMTP id hq4so1429025wib.14
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 15:55:13 -0800 (PST)
In-Reply-To: <20131218.173442.336109133942416102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 5:34 PM, David Miller <davem@davemloft.net> wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Sun, 15 Dec 2013 03:23:36 +0100
>
>> While forwarding we should not use the protocol path mtu to calculate
>> the mtu for a forwarded packet but instead use the interface mtu.
>>
>> We mark forwarded skbs in ip_forward with IPSKB_FORWARDED which was
>> introduced for multicast forwarding. But as it does not conflict with
>> our usage in unicast code path it is perfect for reuse.
>>
>> I moved the functions ip_sk_accept_pmtu, ip_sk_use_pmtu and ip_skb_dst_mtu
>> along with the new ip_dst_mtu_secure to net/ip.h to fix circular
>> dependencies because of IPSKB_FORWARDED.
>>
>> Because someone might have written a software which does probe
>> destinations manually and expects the kernel to honour those path mtus
>> I introduced a new per-namespace "forwarding_uses_pmtu" knob so someone
>> can disable this new behaviour. We also use mtus which are locked on a
>> route for forwarding.
>>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: David Miller <davem@davemloft.net>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>
> Sockets aren't the only entity that create cached PMTU information
> we might like to use during forwarding, tunnels do too.
>
> I'm afraid what the side effects of this change will be in that
> situation, because the dst_mtu() is exactly what will allow us
> to relay the ICMP back to the pre-decapsulation source address
> properly.
>
> In any event, this code was made to explicitly behave this way
> back in 2007 by John Heffner, maybe he has some opinions too.

I added IP_PMTUDISC_PROBE, intended for use with MTU diagnostic tools,
i.e., tracepath.

I don't keep up that well these days with Linux networking, but I see
now the recent addition of IP_PMTUDISC_INTERFACE.  As an aside, I'm a
bit skeptical that we'd actually want to send out packets with DF
unset.  (One, there is no equivalent in IPv6, plus all the
well-documented bad things that happen when you do this.)  But this is
already committed...

On using the interface MTU for all forwarded packets, I have a similar
reaction as David.  And why are forwarded packets more special than
local ones, from the routing code's point of view?  It seems like
there could be other ways to harden a router, like firewall rules.

  -John
