From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net: Fix RPF to work with policy routing
Date: Fri, 23 Oct 2009 18:40:12 -0400
Message-ID: <1256337612.4878.14.camel@dogo.mojatatu.com>
References: <1255867954.4815.25.camel@dogo.mojatatu.com>
	 <1255868019.4815.27.camel@dogo.mojatatu.com>
	 <20091022.214943.105371652.davem@davemloft.net>
	 <1256295075.6264.59.camel@dogo.mojatatu.com>
	 <4AE1CD19.8090901@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	atis@mikrotik.com, eric.dumazet@gmail.com, zenczykowski@gmail.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.221.174]:63180 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbZJWWnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 18:43:20 -0400
Received: by qyk4 with SMTP id 4so6951934qyk.33
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 15:43:24 -0700 (PDT)
In-Reply-To: <4AE1CD19.8090901@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-10-23 at 08:34 -0700, Ben Greear wrote:

> I implemented something similar while allowing for virtual router like
> applications.  I had to add a mark very early in the pkt rx logic in dev.c,
> and had to add a 'skb_default_mark' member to the netdevice because
> the route lookup is done before the normal iptables logic ran.  

You dont need to add a new construct to netdev.
Here's how youd tag all packets coming on eth0 with mark 7:
----
tc filter add dev eth0 parent ffff: protocol ip \
pref 10 u32 match u32 0 0 flowid 1:17 \
action skbedit mark 7
---

Of course you could also be very flow specific, example:

----
tc filter add dev eth0 parent ffff: protocol ip \
pref 9 u32 match ip src 64.233.169.99/32 flowid 1:5 \
action skbedit mark 5
---

Or even use iptable marker
---
tc filter add dev eth2 parent 1:0 protocol ip \
prio 5 u32 match ip dst 10.0.0.90/32 flowid 1:12 \
action ipt -j mark --set-mark 2
----

You could even slice bread with this stuff. Example
you could use certain policy routing tables only
if a flow misbehaved (works well with routing not
local destined packets), example

---
tc filter add dev eth0 parent ffff: protocol ip prio 1 u32 \
match ip src 10.0.0.90/32 flowid 1:10 \
action ipt -j mark --set-mark 1 \
action police rate 100kbit burst 90k pipe \
action ipt -j mark --set-mark 2 \
action police rate 50kbit burst 50k pipe \
action ipt -j mark --set-mark 3 \
action police rate 50kbit burst 50k drop
----

As a warning ipt could be shaky in some distros because
of the morphing iptables interface.

> Without
> this, if a flow already existed for pkts coming in eth1, if the packet came
> back in eth2, it would use eth1's flow.

True. Of course you can avoid that with the patch i posted 
meeting the conditions i described with RPF.

> I'll dig out the patch if anyone is interested...

If you can do overlapping IP addresses, it would be interesting
to see. Otherwise all is achievable with smart policy routing.

cheers,
jamal

