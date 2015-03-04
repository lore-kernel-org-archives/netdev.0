From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/6] net: Call skb_get_hash in qdiscs
Date: Wed, 04 Mar 2015 12:03:03 -0800
Message-ID: <1425499383.5130.227.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425494404-24114-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, fw@strlen.de
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:44592 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759852AbbCDUDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 15:03:06 -0500
Received: by igdh15 with SMTP id h15so39780192igd.3
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 12:03:05 -0800 (PST)
In-Reply-To: <1425494404-24114-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-04 at 10:39 -0800, Tom Herbert wrote:

> - The flow keys are passed in cb[] structure. This severely limits
>   our ability to increase the key space. For instance, the folding
>   of IPv6 addresses in flow_dissector to make a 32-bit value
>   represents a significant loss of information (it would be easy
>   to create millions of different 4-tuples that would always produce the
>   same hash value). 


Yes, but then your patch is all about reducing flow compares to a single
u32 comparison in qdiscs (and elsewhere)

choke for example explicitly wants to make sure we drop a companion
if incoming packet belongs to the same flow.

Relying on a 'strong hash' whatever it can be was not considered in
Choke paper. There is no mention of a stochastic match.

If we no longer can store the keys in skb->cb[], fine (although I claim
skb->cb[] size should be irrelevant, see our discussion on this topic
with Florian)
 -> Just recompute the keys, using a local variable, from packet
content. Yes, it will be more expensive, but hey, we get what we want.

Same for sfq : your skb_get_hash_perturb() doesn't address the point I
made earlier.

It is only giving a false sense of security.
I would rather not spread it.
(Note that there is no documentation or changelog to explain the
pro/cons)

I doubt OVS would condense their flow keys in a single u32...
