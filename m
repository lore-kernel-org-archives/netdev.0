From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: never disappearing neighbors with netlink arp
Date: Wed, 03 Jun 2009 21:35:02 +0300
Message-ID: <4A26C256.9060606@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:45841 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755714AbZFCTAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 15:00:14 -0400
Received: by bwz9 with SMTP id 9so209828bwz.37
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2009 12:00:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I found a very peculiar problem related to neighbor cache when using the
netlink arp api. I never noticed this earlier until recently one of the nodes
with a lot of traffic started getting "Neighbour table overflow" messages.

I made my opennhrp daemon reply immediately with NUD_INVALID if the address is
known to be unreachable which sounds like the proper thing to do.

However, after some tedious reading of sources, it looks that:
1. Packet triggers new neighbor solicitation, entry goes to NUD_INCOMPLETE,
   the skb gets queued and based on my neightable config the first solicit
   is sent directly via netlink.
2. Userland receives and sends immediately back an update to NUD_INVALID.
3. Now it looks like net/core/neighbour.c:neigh_update() first checks for
   !(new & NUD_VALID), this matches and does the state transition, but the
   queued skb:s are not dequeued / error reported. Which leaves refs to the
   neigh entry.

Now what happens after this is still a bit unclear to me, but it looks like
the entry never gets garbage collected after this.

I can probably workaround this from userland by just not replying at all
for non-existent neighbors. But what would be the proper fix for this?
It sounds bad if userland can flood never expiring entries to kernel.
Would just a simple skb queue flush / error reporting be enough? Do we
need to update time stamps too? Do something additional?

Cheers,
  Timo
