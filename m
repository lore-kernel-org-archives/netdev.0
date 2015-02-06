From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Thu, 05 Feb 2015 22:14:40 -0600
Message-ID: <87r3u3vfpr.fsf@x220.int.ebiederm.org>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
	<20150205173334.08248382@uryu.home.lan> <54D4227B.6080709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:36772 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbbBFERx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 23:17:53 -0500
In-Reply-To: <54D4227B.6080709@gmail.com> (David Ahern's message of "Thu, 05
	Feb 2015 19:10:03 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsahern@gmail.com> writes:

> On 2/5/15 6:33 PM, Stephen Hemminger wrote:
>> It is still not clear how adding another level of abstraction
>> solves the scaling problem. Is it just because you can have one application
>> connect to multiple VRF's? so you don't need  N routing daemons?
>>
>>
>
> How do you provide a service in N VRFs? "Service" can be a daemon with a listen
> socket (e.g., bgpd, sshd) or a monitoring app (e.g., collectd, snmpd). For the
> current namespace only paradigm the options are:
> 1. replicate the process for each namespace (e.g., N instances of sshd, bgpd,
> collectd, snmpd, etc.)
>
> 2. a single process spawns a thread for each namespace
>
> 3. a single process opens a socket in each namespace
>
> All of those options are rather heavyweight and the number of 'things' is linear
> with the number of VRFs. When multiplied by the number of services needed for a
> full-featured product the end result is a lot of wasted resources.

If all you want is a single listening socket there are other
implementation possibilities that are focused on solving just that
problem, and would be much more generally applicable.

> The idea here is to simplify things by allowing a single process to have a
> presence / provide a service in all VRFs within a namespace without the need to
> spawn a thread, socket or another process.
>
> For example, 1 instance of a monitoring app can still see all of the netdevices
> in the namespace and in the VRF_ANY context can still report network
> configuration data. VRF unaware/agnostic L3/L4 apps (e.g., sshd) do not need to
> be modified and will be able to provide service through any
> interface. 

*Blink*  sshd does not need to be modified????
Which insecure implementation on which planet?

You mean you are not interested in logging which ip and vrf pair a login
came from?  You are not interested in performing any reverse DNS
lookups?

I do believe you are strongly mistaken.  I can not imagine a case where
making it impossible to know where someone is coming from when they try
to login to any machine is at all desirable.

I think it is unrealistic to expect daemons in general to listen on all
interfaces and in all vrfs, and require trimming down the set of
interfaces inbound connections can come from with firewall rules.  That
just seems backwards.  Telling the daemons which interfaces/address to
listen on explicitly seems much more robust.

The objection about logging in-bound connections applies to every
listening daemon I can think of.  I can't see how you can possibly
seriously be proposing totally changing the networking environment of
applications and expecting those applications to work with out changes.


I do think we can come up with an API that is much less awkward than we
have today, that would allow minimal application changes, but no
application changes I do not believe.

> VRF aware
> apps (e.g., bgpd) might require modifications per the implementation of the VRF
> construct but they would able to provide service with a single
> instance.

A single service instance is all that is required with network
namespaces.

I do not see how code modifications that result in a slower network
stack can possibly solve any kind of scaling problem.

Eric
