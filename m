From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Mon, 23 Feb 2015 20:56:33 +0200
Message-ID: <20150223205633.7fbd08d4@halley>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
	<1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: Eyal Birger <eyal.birger@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:64865 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424AbbBWS4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 13:56:46 -0500
Received: by mail-wi0-f174.google.com with SMTP id em10so20125295wid.1
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 10:56:45 -0800 (PST)
In-Reply-To: <1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 23 Feb 2015 19:52:03 +0200 Eyal Birger <eyal.birger@gmail.com> wrote:
> Commit 977750076d98 ("af_packet: add interframe drop cmsg (v6)")
> unionized skb->mark and skb->dropcount in order to allow recording
> of the socket drop count while maintaining struct sk_buff size.
> 
> In order to allow for the skb->mark to be fetched by user-space code
> it needs to be detached from this union; skb->priority is used
> instead.
> 
> The purpose of overloading skb->priority is solely for retaining
> struct sk_buff size; skb->priority is not used after the skb is
> queued to the socket.
> 
> Use of aliased fields, skb->dropcount and skb->reserved_tailroom,
> is either done after the skb is cloned (e.g. in packet_rcv()) or
> before skb->priority is used (e.g. in IGMPv3/MLD/TCP).

Preserving a small skb size is an important cause.

In this case however, it seems that aliasing 'priority' sacrifices
maintainability: 'priority' does not seem "naturally orthogonal" to
'drop_count' or 'reserved_tailroom'.

One might arm 'priority' in various code flows (future and existing),
which may accidentally clash with the aliases. It is unexpected, hard to
remember (especially since 'priority' wasn't formerly aliased), and
sometimes it's simply not trivial to assure there's no clash.

May I suggest to unalias 'mark' out of the union?

Regards,
Shmulik
