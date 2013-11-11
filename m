From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: spurious ip forwarding inside namespaces
Date: Sun, 10 Nov 2013 22:51:54 -0800
Message-ID: <CAMEtUuz70qyDgB1-EH9xPK71PagxwHFVCzmrnwC2uWum_gxxFg@mail.gmail.com>
References: <CAMEtUuwKD76xEhysPbLum5wDYyJaX5p0JpdBQUcdHged40eHdg@mail.gmail.com>
	<CAHo-Oow6h1LRNw5DMb4+6bdwy31WGOTNokKe=C5cj40dDhTyQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux NetDev <netdev@vger.kernel.org>
To: =?ISO-8859-2?Q?Maciej_=AFenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:62999 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab3KKGv6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 01:51:58 -0500
Received: by mail-wg0-f49.google.com with SMTP id x13so240013wgg.16
        for <netdev@vger.kernel.org>; Sun, 10 Nov 2013 22:51:54 -0800 (PST)
In-Reply-To: <CAHo-Oow6h1LRNw5DMb4+6bdwy31WGOTNokKe=C5cj40dDhTyQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 10, 2013 at 9:12 PM, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
> I've already suggested a month or so back that that patch should be r=
everted.

Isaku's email (author of offending patch) was bouncing whole week.
Didn't have time last week to come up with a good fix.
Reverting fixes 'spurious ip forwarding', but Isaku's original problem
needs to be fixed somehow.
May be going through loopback should set pkt_type?

Alexei

> On Tue, Nov 5, 2013 at 8:32 PM, Alexei Starovoitov <ast@plumgrid.com>=
 wrote:
>> Hi All,
>>
>> commit 06a23fe31c
>> "core/dev: set pkt_type after eth_type_trans() in dev_forward_skb()"
>> and refactoring 64261f230a
>> "dev: move skb_scrub_packet() after eth_type_trans()"
>>
>> are forcing pkt_type to be PACKET_HOST when skb traverses veth.
>>
>> which means that ip forwarding will kick in inside netns
>> even if skb->eth->h_dest !=3D dev->dev_addr
>>
>> The way we hit the problem is the following:
>> create 4 or more of netns with veth and attach them to a bridge.
>> disable learning on a bridge (via setageing 0), so it will flood
>> packets to all namespaces.
>> Since ip forwarding and icmp redirect by default is on,
>> single icmp request packet from one netns creates a storm of packets=
,
>> since every netns receives it and incorrectly does ip forward on it
>> and also incorrectly sends icmp redirect which are multiplied once
>> again by flooding in the bridge.
>> ping -c1 generates 1 outgoing packet and ~13K incoming packets with
>> just 4 netns.
>> Running any tcp traffic between such namespaces becomes impossible
>> and ksoftirqd cpu usage goes to 100% on all cpus.
>>
>> Please suggest how to fix this cleanly.
>>
>> Thanks
>> Alexei
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
