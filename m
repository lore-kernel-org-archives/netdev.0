From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Mon, 23 Feb 2015 21:25:29 +0200
Message-ID: <CAHsH6Guk-8DK1iyth4ZDSikjb_-xjrsBTRa-hp1nWaavvQ0uuQ@mail.gmail.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
	<1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
	<20150223205633.7fbd08d4@halley>
	<1424718636.5565.58.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:38685 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317AbbBWTZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 14:25:30 -0500
Received: by yhzz6 with SMTP id z6so11860600yhz.5
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 11:25:29 -0800 (PST)
In-Reply-To: <1424718636.5565.58.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 23, 2015 at 9:10 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2015-02-23 at 20:56 +0200, Shmulik Ladkani wrote:
>> Hi,
>>
>> On Mon, 23 Feb 2015 19:52:03 +0200 Eyal Birger <eyal.birger@gmail.com> wrote:
>> > Commit 977750076d98 ("af_packet: add interframe drop cmsg (v6)")
>> > unionized skb->mark and skb->dropcount in order to allow recording
>> > of the socket drop count while maintaining struct sk_buff size.
>> >
>> > In order to allow for the skb->mark to be fetched by user-space code
>> > it needs to be detached from this union; skb->priority is used
>> > instead.
>> >
>> > The purpose of overloading skb->priority is solely for retaining
>> > struct sk_buff size; skb->priority is not used after the skb is
>> > queued to the socket.
>> >
>> > Use of aliased fields, skb->dropcount and skb->reserved_tailroom,
>> > is either done after the skb is cloned (e.g. in packet_rcv()) or
>> > before skb->priority is used (e.g. in IGMPv3/MLD/TCP).
>>
>> Preserving a small skb size is an important cause.
>>
>> In this case however, it seems that aliasing 'priority' sacrifices
>> maintainability: 'priority' does not seem "naturally orthogonal" to
>> 'drop_count' or 'reserved_tailroom'.
>>
>> One might arm 'priority' in various code flows (future and existing),
>> which may accidentally clash with the aliases. It is unexpected, hard to
>> remember (especially since 'priority' wasn't formerly aliased), and
>> sometimes it's simply not trivial to assure there's no clash.
>>
>> May I suggest to unalias 'mark' out of the union?
>
> My suggestion would be to move dropcount in skb->cb[] instead.
>
> mark & reserved_tailroom can stay in the union.
>
>

The original commit introducing dropcount for af_packet
(see http://marc.info/?l=linux-netdev&m=125450261121971) also claimed
the proper location would in fact be skb->cb[]. However, it was also
claimed that
skb->cb[] is all used up.

Things are even more complicated now as dropcount became a socket
level feature and skb->cb[] is handled differently in each protocol family.
