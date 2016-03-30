From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: ipv4: Multipath needs to handle unreachable
 nexthops
Date: Tue, 29 Mar 2016 22:16:21 -0500
Message-ID: <56FB4505.8000208@cumulusnetworks.com>
References: <1458833154-39091-1-git-send-email-dsa@cumulusnetworks.com>
 <alpine.LFD.2.11.1603242201200.1795@ja.home.ssi.bg>
 <56F49CD3.1060406@cumulusnetworks.com>
 <alpine.LFD.2.11.1603251024390.1896@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:34716 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbcC3DQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 23:16:25 -0400
Received: by mail-yw0-f177.google.com with SMTP id h129so43254431ywb.1
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 20:16:25 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1603251024390.1896@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/25/16 4:05 AM, Julian Anastasov wrote:
>
> 	Hello,
>
> On Thu, 24 Mar 2016, David Ahern wrote:
>
>> On 3/24/16 4:33 PM, Julian Anastasov wrote:
>>> 	But for multipath routes we can also consider the
>>> nexthops as "alternatives", so it depends on how one uses
>>> the multipath mechanism. The ability to fallback to
>>> another nexthop assumes one connection is allowed to
>>> move from one ISP to another. What if the second ISP
>>> decides to reject the connection? What we have is a
>>> broken connection just because the retransmits
>>> were diverted to wrong place in the hurry. So, the
>>> nexthops can be compatible or incompatible. For your
>>> setup they are, for others they are not.
>>
>> I am not sure I completely understand your point. Are you saying that within a
>> single multipath route some connections to nexthops are allowed and others are
>> not?
>>
>> So to put that paragraph into an example
>>
>> 15.0.0.0/16
>> 	nexthop via 12.0.0.2  dev swp1 weight 1
>> 	nexthop via 12.0.0.3  dev swp1 weight 1
>>
>> Hosts from 15.0/16 could have TCP connections use 12.0.0.2, but not 12.0.0.3
>> because 12.0.0.3 could be a different ISP and not allow TCP connections from
>> this address space?
>
> 	Yes. Two cases are possible:
>
> 1. ISP2 filters saddr, traffic with saddr from ISP1 is dropped.
>
> 2. ISP2 allows any saddr. But how the responses from
> world with daddr=IP_from_ISP1 will come from ISP2 link?
> If the nexthops are for different ISP the connection
> can survive only if sticks to its ISP. An ISP will
> not work as a backup link for another ISP.

Seems to me this is a problem that is addressed by VRFs, not multipath 
routes where some nexthops are actually deadends because they attempt to 
cross ISPs.


>> After that if it has information that says that a nexthop is dead, why would
>> it continue to try to probe? Any traffic that selects that nh is dead. That to
>
> 	If entry becomes FAILED this state is preserved
> if we do not direct traffic to this entry. If there was a
> single connection that was rejected after 3 failed probes
> the next connection (with your patch) will fallback to
> another neigh and the first entry will remain in FAILED
> state until expiration. If one wants to refresh the state
> often, a script/tool that pings all GWs is needed, so that
> you can notice the available or failed paths faster.
>
>> me defies the basis of having multiple paths.
>
> 	We do not know how long is the outage. Long living
> connections may prefer to survive with retransmits.
> Say you are using SSH via wifi link doing important work.
> Do you want your connection to break just because link was
> down for a while?

neighbor entries have a timeout and when it drops from the cache the arp 
will try again. This suggested patch is not saying 'never try a nexthop 
again' it is saying 'I have multiple paths and since path 1 is down try 
another one'.

I'll send an updated patch when I get time (traveling at the moment); I 
guess a sysctl is going to be needed if the behavior you mention with 
ISPs is reasonable.
