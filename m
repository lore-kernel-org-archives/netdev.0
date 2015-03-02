From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 00/14] shrink skb cb to 44 bytes
Date: Mon, 02 Mar 2015 11:49:23 -0800
Message-ID: <1425325763.5130.123.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:36909 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755159AbbCBTtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 14:49:25 -0500
In-Reply-To: <1425318028-26531-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-02 at 18:40 +0100, Florian Westphal wrote:
> Following patches shrink all in-tree users of skb->cb[] so that kernel
> still builds with skb->cb[] set to 44 bytes.
> 
> This would create a 4-byte hole, it would be easy to reorder skb
> members so this hole is filled.
> 
> pahole dump for vmlinux with allyesconfig (+this patch series):
> 
> http://www.strlen.de/fw/pahole.txt.gz
> 
> remarks/known issues:
> - adds __packet attribute to a few structures.
>   Its needed to not have padding at end of the structure, else
>   we get build assertion errors even if all members fit into cb[].
> - checkpatch isn't happy yet.
> - dccp changes are untested (its on my todo list)
> - rxrpc change is untested (on todo list).
> - wireless changes are untested, I don't own any of the affected hw.
> 
> The idea is to figure out what needs to be done to make build_skb() and
> friends only touch the first 3 cachelines of the skb on all architectures.
> 
> We'd need to reduce skbuff by 40 bytes to achieve this for allyesconfig.
> 
> Other sk_buff reduction ideas being worked:
> 
> - move truesize to shinfo (which has 4 byte hole)
> - turn ->data into offset on 64bit platforms (intrusive, > 1000 files
>   affected)
> - move pointers that are ususally not needed (nf_bridge, secpath) to the end,
>   with flag field that tells us when pointer is valid (so we don't have
>   to memset() them unconditionally at allocation time).
> - seems we could already to this for the inner header fields since the're only
>   valid once ->encapsulation / inner_protocol_type is set.
> 
> Comments and more ideas welcome.

Size of skb->cb[] is not the major factor. Trying to gain 4 or 8 bytes
is not going to improve performance a lot.

The real problem is that we clear it in skb_alloc()/build_skb(), instead
of each layer doing so at demand, and only the part that matters for
this layer.

Basically, skb->cb[] could be 80 or 160 bytes instead of 48, and we
should not care, as long as no layer does a stupid/lazy 

memset(skb->cb, 0, sizeof(skb->cb))

Presumably skb_clone() could be extended to receive the length of
skb->cb[] that current layer cares about.
