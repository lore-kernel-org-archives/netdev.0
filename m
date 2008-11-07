From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: IP-less bridge as a martian source
Date: Fri, 7 Nov 2008 10:19:46 +0000
Message-ID: <20081107101946.GA4207@ff.dom.local>
References: <48FF7AA3.50408@gmail.com> <87y707mjbi.fsf@tac.ki.iif.hu> <20081031084124.GA4364@ff.dom.local> <877i7novar.fsf@szonett.ki.iif.hu> <20081105094303.GA5378@ff.dom.local> <87prla79d6.fsf@tac.ki.iif.hu> <20081106100032.GA4809@ff.dom.local> <873ai5yshm.fsf@tac.ki.iif.hu> <20081106131544.GB4809@ff.dom.local> <87r65px6wf.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ferenc Wagner <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:35802 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbYKGKTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 05:19:53 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1127009ugf.37
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2008 02:19:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <87r65px6wf.fsf@tac.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 06, 2008 at 03:31:44PM +0100, Ferenc Wagner wrote:
> Jarek Poplawski <jarkao2@gmail.com> writes:
> 
> > On Thu, Nov 06, 2008 at 01:00:05PM +0100, Ferenc Wagner wrote:
> >> Jarek Poplawski <jarkao2@gmail.com> writes:
> >>
> >>>> wferi@xen1:~$ sudo cat /proc/net/vlan/vlan891 
> >>>> [...]
> >>>> EGRESSS priority Mappings: 
> >>>
> >>> Should be corrected: maybe you will send a patch? (Otherwise let me now.)
> >> 
> >> I sent one.  Hope it's OK.
> >
> > Looks OK to me.
> 
> Still I'm afraid it would break some users' scripts... ;)

Don't worry! (I don't use vlans...;)

> 
> >> My question is: why does the IP-less bridge pick up any packets?
> >> Does the host-based addressing model require this, if the host has
> >> any IP address at all (on some other interface)?
> >
> > Do you mean why it's routed at all?
> 
> Yes, probably that's what I mean.  I expected such packages to stay in
> the link layer (http://ebtables.sourceforge.net/br_fw_ia/PacketFlow.png)
> Hmm.  In my case the only possible way out is "Bridging Decision" in
> the input phase.  That surely kicks in, as these packages are destined
> to ff:ff:ff:ff:ff:ff...  Confirmed: after ebtables -A INPUT -j DROP
> those "martian source" warnings don't appear anymore.
> 
> Btw what is that "Processing decision" right after Qdisc Deque(ue)?  A
> check whether the destination MAC is ours?  I also wonder where
> tcpdump attaches its probe on that picture...

This picture isn't probably exact enough. Have a look at net/core/dev.c
netif_receive_skb(). There are hooks for: netpoll(netconsole), bond,
taps (e.g. tcpdump), ingress qdisc, bridge, macvlan and protocols loop
(e.g. ip with routing, iptables etc.) These hooks can usually stop later
processing returning NULL. So, there are more processing decisions, and
maybe this one on the picture should be renamed to "Bridge Processing
Decission".

> But the directed broadcast pings (destined to the network broadcast
> address) also have full-one destination MAC, and they weren't
> logged...  Even though the host didn't know about those networks
> either.  So part of the mistery remains.

This is probably because of this special treatment of 255.255.255.255
(FFFFFFFF) in ip_route_input_slow(). Others could simply get
EHOSTUNREACH return only.

Regards,
Jarek P.
