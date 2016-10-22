From: Eric Garver <e@erig.me>
Subject: Re: [PATCH] flow_dissector: avoid uninitialized variable access
Date: Sat, 22 Oct 2016 11:57:52 -0400
Message-ID: <20161022155752.GD26044@egarver>
References: <20161021155626.4020344-1-arnd@arndb.de>
 <20161021163118.GA2155@nanopsycho.orion>
 <5467015.N4DG5uA0DU@wuerfel>
 <3516805.IZ705sLgKU@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>,
        "David S. Miller" <davem@davemloft.net>,
        Alexander Duyck <aduyck@mirantis.com>,
        Tom Herbert <tom@herbertland.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Gao Feng <fgao@48lvckh6395k16k5.yundunddos.com>,
        Amir Vadai <amir@vadai.me>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51922 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934425AbcJVP6A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 22 Oct 2016 11:58:00 -0400
Content-Disposition: inline
In-Reply-To: <3516805.IZ705sLgKU@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 22, 2016 at 12:16:29AM +0200, Arnd Bergmann wrote:
> On Friday, October 21, 2016 11:05:45 PM CEST Arnd Bergmann wrote:
> > 
> > Can you explain why "dissector_uses_key(flow_dissector,
> > FLOW_DISSECTOR_KEY_VLAN) && skb_vlan_tag_present(skb)" implies
> > "eth_type_vlan(proto))"?
> > 
> > If I add uninitialized_var() here, I would at least put that in
> > a comment here.
> 
> Found it now myself: if skb_vlan_tag_present(skb), then we don't
> access 'vlan', otherwise we know it is initialized because
> eth_type_vlan(proto) has to be true.
>  
> > On a related note, I also don't see how
> > "dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_VLAN)"
> > implies that skb is non-NULL. I guess this is related to the
> > first one.
> 
> I'm still unsure about this one.

Only skb_flow_dissect_flow_keys_buf() calls this function with skb ==
NULL. It uses flow_keys_buf_dissector_keys which does not specify
FLOW_DISSECTOR_KEY_VLAN, so the if statement is false.

A similar assumption is made for FLOW_DISSECTOR_KEY_ETH_ADDRS higher up.

> I also found something else that is suspicious: 'vlan' points
> to the local _vlan variable, but that has gone out of scope
> by the time we access the pointer, which doesn't seem safe.

I see no harm in moving _vlan to the same scope as vlan.
