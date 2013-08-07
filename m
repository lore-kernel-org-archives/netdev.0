From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skbs delivered to 'wrong' packet_type handler
Date: Wed, 07 Aug 2013 06:55:43 -0700
Message-ID: <1375883743.4004.26.camel@edumazet-glaptop>
References: <20130807130856.GI3165@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, ying.xue@windriver.com
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:63876 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933097Ab3HGNzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 09:55:45 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so2190403pab.29
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 06:55:44 -0700 (PDT)
In-Reply-To: <20130807130856.GI3165@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-07 at 15:08 +0200, Erik Hugne wrote:
> We have a race condition in TIPC when using both the parent ethernet 
> device, and a vlan on top of this device as TIPC bearers. For some reason, 
> net/core/dev.c is delivering vlan packets to packet handlers registered to 
> the native device. This only seems to occur when a packet_type handler is 
> registered on both the vlan device and it's parent ethernet device. This 
> causes all kinds of weird behaviour in TIPC, from cross-vlan links being 
> established to oopses.
> 
> At first, i thought this was due to a missing PACKET_OTHERHOST filtering
> in the TIPC ethernet code, but adding that check did not resolve the issue.
> Adding an explicit check for skb->dev vs packet_type->dev does work, but
> i dont think that's the proper way to solve it.
> What's the purpose of having a dev entry in the packet_type if it's ignored 
> by the lower layers?

Its not ignored, quite the contrary if you look at the code :

vi +3595 net/core/dev.c

        type = skb->protocol;
        list_for_each_entry_rcu(ptype,
                        &ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
                if (ptype->type == type &&
                    (ptype->dev == null_or_dev || ptype->dev == skb->dev ||
                     ptype->dev == orig_dev)) {
                        if (pt_prev)
                                ret = deliver_skb(skb, pt_prev, orig_dev);
                        pt_prev = ptype;
                }
        }


pkt->dev being set is only meaningful for packet sockets.

Protocols themselves should not care. If they want to care, they must
add their own checks.

Socket API has SO_BINDTODEVICE for this purpose.
IP layer has RP filtering.

A protocol should register a single ptype with NULL dev.
