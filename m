From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] ipv6: protect skb->sk accesses from recursive
 dereference inside the stack
Date: Wed, 1 Apr 2015 19:55:12 -0700
Message-ID: <CAHA+R7NXpuSOAwWpetFA+TyLh1d_v9kwiKxhPq4f=vowJJKb1Q@mail.gmail.com>
References: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
	<CAHA+R7NvbJyjjBac=4VneQ_Nuxtb-_HEOJp0dujh5SOXj3NSKQ@mail.gmail.com>
	<1427934458.25985.177.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:35858 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbbDBCzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 22:55:13 -0400
Received: by iedm5 with SMTP id m5so59346855ied.3
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 19:55:13 -0700 (PDT)
In-Reply-To: <1427934458.25985.177.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 1, 2015 at 5:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-04-01 at 17:06 -0700, Cong Wang wrote:
>
>> Shouldn't these skb's be orphaned for tunnel cases? Or we still have
>> to keep skb->sk for other valid use?
>
> skb should not be orphaned, until the very last stage.
>
> Many layers depend on this, really.
>
> Simply ask the question to yourself :
>
> What if I do not associate skb to a socket at first. What possibly
> breaks ?
>
> orphaning skb just because they traverse a tunnel would be quite
> horrible.
>

I didn't make it clear, I meant to say "resetting the skb->sk to tunnel
socket". I know sch_fq uses skb->sk for flow classification, but
if skb->sk still points to the user-space socket, its meaning is already
changed after encapsulation, with regarding to this, all traffic goes
out of this tunnel should be one flow.

This also means ipv6 should not use any socket setting for routing
lookup, since after resetting skb->sk in encapsulation skb's belong
to one kernel socket which doesn't have any socket options set.

As I said, there might be still some useful information from their
original skb->sk, I of course never audit all the skb->sk usage
in kernel.

Essentially, carrying L4 information to L2 does make things complicated
when udp tunnels are involved.
