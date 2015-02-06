From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Thu, 05 Feb 2015 23:15:49 -0700
Message-ID: <54D45C15.7090602@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>	<20150205173334.08248382@uryu.home.lan> <54D4227B.6080709@gmail.com> <87r3u3vfpr.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:38946 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756AbbBFGPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 01:15:54 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so5953727igb.3
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 22:15:54 -0800 (PST)
In-Reply-To: <87r3u3vfpr.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/5/15 9:14 PM, Eric W. Biederman wrote:
> David Ahern <dsahern@gmail.com> writes:
>
>> On 2/5/15 6:33 PM, Stephen Hemminger wrote:
>>> It is still not clear how adding another level of abstraction
>>> solves the scaling problem. Is it just because you can have one application
>>> connect to multiple VRF's? so you don't need  N routing daemons?
>>>
>>>
>>
>> How do you provide a service in N VRFs? "Service" can be a daemon with a listen
>> socket (e.g., bgpd, sshd) or a monitoring app (e.g., collectd, snmpd). For the
>> current namespace only paradigm the options are:
>> 1. replicate the process for each namespace (e.g., N instances of sshd, bgpd,
>> collectd, snmpd, etc.)
>>
>> 2. a single process spawns a thread for each namespace
>>
>> 3. a single process opens a socket in each namespace
>>
>> All of those options are rather heavyweight and the number of 'things' is linear
>> with the number of VRFs. When multiplied by the number of services needed for a
>> full-featured product the end result is a lot of wasted resources.
>
> If all you want is a single listening socket there are other
> implementation possibilities that are focused on solving just that
> problem, and would be much more generally applicable.

These are examples of the higher level problem -- the current need for 
replicating processes/threads/sockets per namespace, not to mention the 
memory consumed by the creation of the namespace itself which is fairly 
high. i.e., The problem is more than just a listening socket of a single 
process.


>
>> The idea here is to simplify things by allowing a single process to have a
>> presence / provide a service in all VRFs within a namespace without the need to
>> spawn a thread, socket or another process.
>>
>> For example, 1 instance of a monitoring app can still see all of the netdevices
>> in the namespace and in the VRF_ANY context can still report network
>> configuration data. VRF unaware/agnostic L3/L4 apps (e.g., sshd) do not need to
>> be modified and will be able to provide service through any
>> interface.
>
> *Blink*  sshd does not need to be modified????
> Which insecure implementation on which planet?

That would be the current one -- in both cases. It is an example, Eric, 
(admittedly not a good one) that existing code does not *have* to be 
modified to run in a 'VRF any' context. It can be made VRF aware of course.

>
> You mean you are not interested in logging which ip and vrf pair a login
> came from?  You are not interested in performing any reverse DNS
> lookups?
>
> I do believe you are strongly mistaken.  I can not imagine a case where
> making it impossible to know where someone is coming from when they try
> to login to any machine is at all desirable.

Aren't you conflating two problems? Network namespaces does not require 
a separate DNS config for each namespace. A user may create 2+ network 
namespaces and have them share the same /etc/resolv.conf. Correct?

>
> I think it is unrealistic to expect daemons in general to listen on all
> interfaces and in all vrfs, and require trimming down the set of
> interfaces inbound connections can come from with firewall rules.  That
> just seems backwards.  Telling the daemons which interfaces/address to
> listen on explicitly seems much more robust.

Networking products with 1000+ interfaces? Physical, sub-interfaces, 
breakout ports, VLANs, SVIs, port channels, ...

>
> The objection about logging in-bound connections applies to every
> listening daemon I can think of.  I can't see how you can possibly
> seriously be proposing totally changing the networking environment of
> applications and expecting those applications to work with out changes.

Nothing stops me from having xinetd launch /bin/bash as root for all 
connections to 666/tcp. Nothing about the Linux networking stack 
prevents someone from running telnet or ftp. ie., the existing code base 
can be used in insecure ways.

Application code -- open source daemons -- can be modified to be VRF 
aware as needed. Kernel side VRF support would be made a CONFIG option 
that defaults off. The macros will ensure anything VRF related falls 
out, so server deployments would not be impacted.

>
>
> I do think we can come up with an API that is much less awkward than we
> have today, that would allow minimal application changes, but no
> application changes I do not believe.

Can we agree that no L2 apps should require a single line of code to be 
changed? If I create 4000 VRFs -- again an L3 construct -- not one L2 
application (socket based, monitoring, etc) should care. It should not 
have to be replicated or modified. For L3 and up they can be made VRF 
aware as needed, but that is an application problem.

>
>> VRF aware
>> apps (e.g., bgpd) might require modifications per the implementation of the VRF
>> construct but they would able to provide service with a single
>> instance.
>
> A single service instance is all that is required with network
> namespaces.

N VRFs = N namespaces = N instances of every single process, where N is 
1024, 2048, 4096, and up. Someone has already done the analysis for 
quagga with 1024 instances showing what a huge waste of memory that is.

>
> I do not see how code modifications that result in a slower network
> stack can possibly solve any kind of scaling problem.

I'll see what I can do to remove the skb change. That is the only 
comment you have made about performance. Do you have other concerns 
about performance impacts of the higher level proposal -- s/struct 
net/struct net_ctx/ where net_ctx is a namespace and a VRF?

David
