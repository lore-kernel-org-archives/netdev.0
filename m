From: Timo Teras <timo.teras@iki.fi>
Subject: Re: ip_forward_use_pmtu and forwarding to xfrm'ed gre
Date: Wed, 8 Jul 2015 19:17:51 +0300
Message-ID: <20150708191751.3fc42725@vostro>
References: <20150708163032.5b5df2ec@vostro>
	<1436370752.3846.36.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:33531 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758378AbbGHQR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 12:17:57 -0400
Received: by laar3 with SMTP id r3so229321768laa.0
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 09:17:55 -0700 (PDT)
In-Reply-To: <1436370752.3846.36.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 08 Jul 2015 17:52:32 +0200
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> On Wed, 2015-07-08 at 16:30 +0300, Timo Teras wrote:
> > This probably is due to the way how the xfrm+gre work together. On
> > first packet, the gre tunnel driver updates pmtu for the inner flow,
> > which is expected to be honored always. And if the 'ttl' value is
> > set for gre tunnel, no re-fragmentation is allowed as the inner flow
> > should know better. This does how the side effect that if the very
> > first packet is large, it'll be dropped to 'learn' the pmtu. 
> > 
> > It's probably not possible to detect this kind of target easily, as 
> > the xfrm can be applied or not even on per inner target IP basis (as
> > then tunnel destination IP can be dynamic for nbma tunnels).
> 
> I am currently not sure if we actually have resolved the xfrm path at
> the time we enter ip_forward, I actually thought we do. In this case
> we should be able to use skb_dst->dst->path->header_len and substract
> it before using it to fragment the packets. I hope it is so easy... :)

It is not. The inner skb just knows that it's going from ethX -> greX.
And that's what contains the path MTU, and that's what ip_forward will
use.

Only on gre_xmit it is resolved where the tunnel packet goes, and the
xfrm resolved. Thus the update_pmtu work fully internally here.

> I would actually avoid telling anyone to enable using the path mtu
> information in forwarding ever again.

The problem here is that pmtu framework is used internally to relay the
trusted stacking pmtu in addition to the from-the-wire learned pmtu.

> > So I wonder if ip_gre driver can workaround this somehow, by e.g.
> > refragmenting if necessary. Or if we just should update the sysctl's
> > help text to say that this another scenario where it needs to be
> > turned on.
> 
> If above idea does not work, we could simply add an option to gre
> driver to set skb->ignore_df, but I don't like that much.

This is not acceptable. The gre driver has two operating modes: DF and
non-DF mode (which is triggered by 'ttl inherit' or 'ttl <number>'
option on tunnel creation). The DF mode intentionally sets DF on all
tunnel packets so the pmtu is learned and relayed up the stack. In
non-DF mode the tunnel packets DF is derived from encapsulated packet.

Basically this info could be used. If the target is gre1 in DF mode, we
should be trusting the pmtu. Otherwise the existing internal mechanism
breaks.

Thoughts?
