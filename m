From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v2 4/5] mpls: Per-device enabling of packet forwarding
Date: Mon, 23 Mar 2015 13:42:57 +0000
Message-ID: <55101861.6040101@brocade.com>
References: <1426800772-22378-1-git-send-email-rshearma@brocade.com>	<1426866170-28739-1-git-send-email-rshearma@brocade.com>	<1426866170-28739-5-git-send-email-rshearma@brocade.com>	<87iods7qbz.fsf@x220.int.ebiederm.org> <87zj746abf.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:24955 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752173AbbCWNnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 09:43:03 -0400
In-Reply-To: <87zj746abf.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/03/15 20:34, Eric W. Biederman wrote:
> ebiederm@xmission.com (Eric W. Biederman) writes:
>
>> Robert Shearman <rshearma@brocade.com> writes:
>>
>>> An MPLS network is a single trust domain where the edges must be in
>>> control of what labels make their way into the core. The simplest way
>>> of ensuring for the edge device to always impose the labels, and not
>>> allow forward labeled traffic from untrusted neighbours. This is
>>> achieved by allowing a per-device configuration of whether MPLS
>>> traffic received over that interface should be forwarded or not.
>>>
>>> To be secure by default, MPLS is now intially disabled on all
>>> interfaces (except the loopback) until explicitly enabled and no
>>> global option is provided to change the default. Whilst this differs
>>> from other protocols (e.g. IPv6), network operators are used to
>>> explicitly enabling MPLS forwarding on interfaces, and with the number
>>> of links to the MPLS core typically fairly low this doesn't present
>>> too much of a burden on operators.
>>
>> Overall this patch looks like the correct direction to go.
>>
>> And a default disable is the right way to go for new features, that way
>> even if the code is compiled in people don't get surprised by new
>> behavior when they upgrade kernels.
>>
>> It would be very nice if the check for ARPHRD types was moved from
>> mpls_route_add to mpls_add_dev.  Which would save memory and complexity
>> when mpls is not supported on a network device type.
>
> There is also a question of do we want "forwarding" to be the parameter
> we are controlling.  The other option is not "forwarding" but mpls
> "enable".
>
> Completely disabling mpls on a device might be too strong as it would
> presumably work for output as well as input.
>
> Forwarding at least for ipv4 and ipv6 has the semantic that you can
> still accept packets that are routed to yourself, which your
> implementation of forwarding does not.

Arguably, the implementation here doesn't implement routes to itself 
(i.e. you'd need a reswitch to deaggregate first). However, I can see 
the argument that this might be confusing for users more familiar with 
ipv4/ipv6 semantics.

> So I expect what we actually want here is either "enable" or two
> knobs "input" and "output".

The semantics of enable or output become confusing because would they 
control whether MPLS routes would be allowed out of that interface, or 
would they control whether traffic could go out as MPLS (in the light of 
patch 3, i.e. allow only IP)? I think it would have to be the latter to 
be useful. There's also the question of what the default value should be 
(i.e. it's safe for it to be enabled by default, unlike on input).

 From a practical perspective, I don't really see the need at the moment 
for a flag to control whether traffic can be sent out of that interfaces 
or not. The user can already control that by installing or not 
installing routes out of that interface as desired.

Therefore, to keep the code simple I propose that I rename the parameter 
to "input" as you suggest and someone else can implement "output" if 
they find a use case for it.

Thanks,
Rob
