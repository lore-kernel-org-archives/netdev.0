From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: spurious ip forwarding inside namespaces
Date: Sun, 10 Nov 2013 19:12:44 -1000
Message-ID: <CAHo-Oow6h1LRNw5DMb4+6bdwy31WGOTNokKe=C5cj40dDhTyQQ@mail.gmail.com>
References: <CAMEtUuwKD76xEhysPbLum5wDYyJaX5p0JpdBQUcdHged40eHdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Isaku Yamahata <yamahata@valinux.co.jp>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux NetDev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f47.google.com ([209.85.212.47]:45018 "EHLO
	mail-vb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419Ab3KKFMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 00:12:45 -0500
Received: by mail-vb0-f47.google.com with SMTP id g10so667024vbg.20
        for <netdev@vger.kernel.org>; Sun, 10 Nov 2013 21:12:44 -0800 (PST)
In-Reply-To: <CAMEtUuwKD76xEhysPbLum5wDYyJaX5p0JpdBQUcdHged40eHdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've already suggested a month or so back that that patch should be reverted.

On Tue, Nov 5, 2013 at 8:32 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> Hi All,
>
> commit 06a23fe31c
> "core/dev: set pkt_type after eth_type_trans() in dev_forward_skb()"
> and refactoring 64261f230a
> "dev: move skb_scrub_packet() after eth_type_trans()"
>
> are forcing pkt_type to be PACKET_HOST when skb traverses veth.
>
> which means that ip forwarding will kick in inside netns
> even if skb->eth->h_dest != dev->dev_addr
>
> The way we hit the problem is the following:
> create 4 or more of netns with veth and attach them to a bridge.
> disable learning on a bridge (via setageing 0), so it will flood
> packets to all namespaces.
> Since ip forwarding and icmp redirect by default is on,
> single icmp request packet from one netns creates a storm of packets,
> since every netns receives it and incorrectly does ip forward on it
> and also incorrectly sends icmp redirect which are multiplied once
> again by flooding in the bridge.
> ping -c1 generates 1 outgoing packet and ~13K incoming packets with
> just 4 netns.
> Running any tcp traffic between such namespaces becomes impossible
> and ksoftirqd cpu usage goes to 100% on all cpus.
>
> Please suggest how to fix this cleanly.
>
> Thanks
> Alexei
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
