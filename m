From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC] netlink broadcast return value
Date: Tue, 10 Feb 2009 19:51:45 +0100
Message-ID: <4991CCC1.7080308@netfilter.org>
References: <4985A4C5.4050908@netfilter.org> <20090202.140533.121159038.davem@davemloft.net> <49903B03.2040302@trash.net> <4990B38A.3020207@netfilter.org> <4990BADA.7040309@trash.net> <4990C337.3040704@netfilter.org> <4991863F.3030800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57278 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754219AbZBJSv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2009 13:51:59 -0500
In-Reply-To: <4991863F.3030800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Pablo Neira Ayuso wrote:
>> Patrick McHardy wrote:
>>> Pablo Neira Ayuso wrote:
>>
>>> But unless I'm missing something, there's nothing wrong with this
>>> as long as the error is ignored. The fact that something was received
>>> by some listener doesn't have any meaning anyways, it might have
>>> been "ip monitor". Which somehow raises doubt about your proposed
>>> interface change though, I think anything that wants a reliable
>>> answer whether a packet was delivered to a process handling it
>>> appropriately should use unicast.
>>
>> Don't get me wrong, I agree with you that all netlink_broadcast callers
>> in the kernel should ignore the return value...
>>
>> ... unless they have "some way" (like in Netfilter) to make event
>> delivery reliable: I have attached a patch that I didn't send you yet,
>> I'm still reviewing and testing it. It adds an entry to /proc to enable
>> reliable event delivery over netlink by dropping packets whose events
>> were not delivered, you mentioned that possibility once during one of
>> our conversations ;).
> 
> I know, but in the mean time I think its wrong :) The delivery
> isn't reliable and what the admin is effectively expressing by
> setting your sysctl is "I don't have any listeners besides the
> synchronization daemon running". So it might as well use unicast.

No :), this setting means "state-changes over ctnetlink will be reliable
at the cost of dropping packets (if needed)", it's an optional
trade-off. You may also have more listeners like a logging daemon
(ulogd), similarly this will be useful to ensure that ulogd doesn't leak
logging information which may happen under very heavy load. This option
is *not* only oriented to state-synchronization.

Using unicast would not do any different from broadcast as you may have
two listeners receiving state-changes from ctnetlink via unicast, so the
problem would be basically the same as above if you want reliable
state-change information at the cost of dropping packets.

BTW, the netlink_broadcast return value looked to me inconsistent before
the patch. It returned ENOBUFS if it could not clone the skb, but zero
when at least one message was delivered. How useful can be this return
value for the callers? I would expect to have a similar behaviour to the
one of netlink_unicast (reporting EAGAIN error when it could not deliver
the message), even if the return value for most callers should be
ignored as it is not of any help.

>> I'm aware of that this option may be dangerous if used by a buggy
>> process that trigger frequent overflows but it the cost of having
>> realible logging for ctnetlink (still, this behaviour is not the one by
>> default!).
>>
>> And I need this option to make conntrackd synchronize state-changes
>> appropriately under very heavy load: I've testing the daemon with these
>> patches and it reliably synchronizes state-changes (my system were 100%
>> busy filtering traffic and fully synchronizing all TCP state-changes in
>> near real-time effort, with a noticeable performance drop of 30% in
>> terms of filtered connections).
> 
> So you're dropping the packet if you can't manage to synchronize.
> Doesn't that defeat the entire purpose of synchronizing, which is
> *increasing* reliability? :)

This reduces communications reliability a bit under very heavy load,
yes, because it may drop some packets but it adds reliable flow-based
logging accounting / state-synchronization in return. Both refers to
reliability in different contexts. In the end, it's a trade-off world.
There's some point at which you may want to choose which one you prefer,
reliable communications if the system is under heavy load or reliable
logging (no leaks in the logging) / state-synchronization (the backup
firewall is able to follow state-changes of the master under heavy load).

In my experiments, reaching 100% of CPU consumption, the number of
packets drop where in fact very few indeed, but the harm in logging and
state-synchronization reliability is considerable in the long run, as
the backup starts getting unsynchronized (thus, becoming useless to
increase cluster reliability but consuming resources) and you also have
to interpret log information without forgetting the margin of error in
the case of logging.

BTW, I did not tell you, I can give you access to my testbed platform at
any time, of course ;).

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
