From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net-next 0/16] Proposal for VRF-lite - v3
Date: Tue, 28 Jul 2015 10:02:01 -0600
Message-ID: <55B7A779.6040906@cumulusnetworks.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com> <87egjtz6kn.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	ddutt@cumulusnetworks.com, hannes@stressinduktion.org,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hadi@mojatatu.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34842 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbbG1QCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 12:02:06 -0400
Received: by pdrg1 with SMTP id g1so72982823pdr.2
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 09:02:04 -0700 (PDT)
In-Reply-To: <87egjtz6kn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/27/15 2:30 PM, Eric W. Biederman wrote:
> This paragraph is false when it comes to sockets, as I have already
> pointed out.
>
> - VPN Routing and Forwarding (RFC4364 and it's kin) implies isolation
>    strong enough to allow using the the same ip on different machines
>    in different VPN instances and not have confusion.
>
> - The routing table is not the only table in the kernel that uses
>    an ip address as a key.
>
>    The result is that you can combine packets fragments that come in
>    on different interfaces (irrespective of your VPN), confuse tcp
>    parameters between interfaces, scramble your ipsec connections and I
>    don't know what else.

The duplicate IP address is a problem with the networking stack today; 
the VRF device does not introduce it. The VRF device does allow 
duplicate IP addresses within a namespace but separate VRFs, though yes 
various places that rely solely on source address like IP fragmentation 
do need to be fixed.

I looked at the IPv4 fragmentation code yesterday and will continue 
today. So help me with the history: is there any reason why the device 
index is not used today? It seems like a straight forward change.

1. simple netdevices with the same IP address
--> no problem using index in the lookup

2. 2 ipsec tunnels -- different netdevices, same IP address
--> no problem using index

3. stacked devices like bonding and team interfaces appear to the stack 
as a single device
--> no problem using index of stacked device

4. If an interface is deleted and a new one is created with the same IP 
address then we want to fail the lookup
--> no problem using index

5. other???

Is there a use case where I can't add ifindex of the incoming device (or 
higher level device if skb->dev is changed) to the hash and lookup for 
fragments?


>> Version 3
>> - addressed comments from first 2 RFCs with the exception of the name
>>    Nicolas: We will do the name conversion once we agree on what the
>>             correct name should be (vrf, mrf or something else)
>
> Not so.  I described the deep problems between your goals and your
> implementation and they are not even mentioned let alone addressed.

I have addressed comments to the extent that I can. As I stated in my 
last followup to you Eric I did not understand your point. I asked for 
clarification, a --verbose if you will. I can't read your mind, so I 
need you to elaborate on your points to be able to respond and address 
your concerns.

>
>> -  packets flow through the VRF device in both directions allowing the
>>     following:
>>     - tcpdump -i vrf<n>
>>     - tc rules on vrf device
>>     - netfilter rules on vrf device
>>
>> Ingo/Andy: I added you two as a start point for the proposed task related
>>             changes. Not sure who should be the reviewer; please let me know
>>             if someone else is more appropriate. Thanks.
>
> It looks like you are trying to implement a namespace that isn't a
> namespace.  Given that it is broken by design you have my nack.

This is an L3 separation within a namespace, not a device level 
separation which is what namespaces provide.

David
