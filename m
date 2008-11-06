From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: IP-less bridge as a martian source
Date: Thu, 06 Nov 2008 15:31:44 +0100
Message-ID: <87r65px6wf.fsf@tac.ki.iif.hu>
References: <87wsg0wu78.fsf@tac.ki.iif.hu> <48FF614C.7020507@gmail.com>
	<48FF7AA3.50408@gmail.com> <87y707mjbi.fsf@tac.ki.iif.hu>
	<20081031084124.GA4364@ff.dom.local>
	<877i7novar.fsf@szonett.ki.iif.hu>
	<20081105094303.GA5378@ff.dom.local> <87prla79d6.fsf@tac.ki.iif.hu>
	<20081106100032.GA4809@ff.dom.local> <873ai5yshm.fsf@tac.ki.iif.hu>
	<20081106131544.GB4809@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:58811 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774AbYKFObr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 09:31:47 -0500
In-Reply-To: <20081106131544.GB4809@ff.dom.local> (Jarek Poplawski's message
	of "Thu, 6 Nov 2008 13:15:44 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> writes:

> On Thu, Nov 06, 2008 at 01:00:05PM +0100, Ferenc Wagner wrote:
>> Jarek Poplawski <jarkao2@gmail.com> writes:
>>
>>>> wferi@xen1:~$ sudo cat /proc/net/vlan/vlan891 
>>>> [...]
>>>> EGRESSS priority Mappings: 
>>>
>>> Should be corrected: maybe you will send a patch? (Otherwise let me now.)
>> 
>> I sent one.  Hope it's OK.
>
> Looks OK to me.

Still I'm afraid it would break some users' scripts... ;)

>> My question is: why does the IP-less bridge pick up any packets?
>> Does the host-based addressing model require this, if the host has
>> any IP address at all (on some other interface)?
>
> Do you mean why it's routed at all?

Yes, probably that's what I mean.  I expected such packages to stay in
the link layer (http://ebtables.sourceforge.net/br_fw_ia/PacketFlow.png)
Hmm.  In my case the only possible way out is "Bridging Decision" in
the input phase.  That surely kicks in, as these packages are destined
to ff:ff:ff:ff:ff:ff...  Confirmed: after ebtables -A INPUT -j DROP
those "martian source" warnings don't appear anymore.

Btw what is that "Processing decision" right after Qdisc Deque(ue)?  A
check whether the destination MAC is ours?  I also wonder where
tcpdump attaches its probe on that picture...

> Probably it's something about bridge configs, like BRIDGE_EBT_BROUTE
> etc. You could try to analyze net/bridge/br_input.c/br_handle_frame()
> for cases when it returns skb (instead of NULL).

Thanks, that set me on track.  Although ebtable_broute was not loaded
originally, now ebtable_filter is.

>> I didn't mean separating the ports of the bridge, but separating the
>> host running the bridge from the traffic the bridge forwards.  It
>> should be able to forward all the strangest IP or non-IP traffic of
>> the world and stay totally unaffected.
>
> Yes, I missed your point. So I think this should be configurable.

Turns out it is, sort of, by ebtables.

But the directed broadcast pings (destined to the network broadcast
address) also have full-one destination MAC, and they weren't
logged...  Even though the host didn't know about those networks
either.  So part of the mistery remains.

> Are you sure they use something else then 0.0.0.0 as a source address
> with these 255.255.255.255 packets?

Yes, as my previous log summary shows, they usually carry the actual
source address.  DHCP is different in this respect.  Also, there are
different types of WoL, some masquerade as UDP, some do not.
-- 
Regards,
Feri.
