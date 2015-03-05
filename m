From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: [PATCH net-next] ax25: Stop using magic neighbour cache operations.
Date: Thu, 05 Mar 2015 10:14:55 +0000
Message-ID: <54F82C9F.5050307@redhat.com>
References: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org>	<20150302.164426.494515497595921630.davem@davemloft.net>	<874mq22imc.fsf_-_@x220.int.ebiederm.org>	<20150303.144509.1694022322984204895.davem@davemloft.net> <87mw3tzv8u.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org,
	linux-hams@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <87mw3tzv8u.fsf@x220.int.ebiederm.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 03/03/15 20:22, Eric W. Biederman wrote:
> David Miller <davem@davemloft.net> writes:
>
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Tue, 03 Mar 2015 09:41:47 -0600
>>
>>> Before the ax25 stack calls dev_queue_xmit it always calls
>>> ax25_type_trans which sets skb->protocol to ETH_P_AX25.
>>>
>>> Which means that by looking at the protocol type it is possible to
>>> detect IP packets that have not been munged by the ax25 stack in
>>> ndo_start_xmit and call a function to munge them.
>>>
>>> Rename ax25_neigh_xmit to ax25_ip_xmit and tweak the return type and
>>> value to be appropriate for an ndo_start_xmit function.
>>>
>>> Update all of the ax25 devices to test the protocol type for ETH_P_IP
>>> and return ax25_ip_xmit as the first thing they do.  This preserves
>>> the existing semantics of IP packet processing, but the timing will be
>>> a little different as the IP packets now pass through the qdisc layer
>>> before reaching the ax25 ip packet processing.
>>>
>>> Remove the now unnecessary ax25 neighbour table operations.
>>>
>>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> Another nice cleanup, applied, thanks Eric.
> We can almost universally use the same procedures for generating
> link layer headers from neighbour table entries now.  I had hoped
> to optimized things by removing function pointers.
>
> The big hold out is DECnet that sets src_mac based on the DECnet source
> address.
That is a requirement of DECnet I'm afraid - DECnet does not have an 
exact equivalent of ARP/ndisc and many hosts will refuse to communicate 
if the MAC address is not the expected one based on the DECnet address. 
This is one bit of DECnet that is being used (to the best of my 
knowledge) and working.

> Which leads me to the conclusion that since DECnet has a different
> algorithm for setting the src_mac than everything else in the kernel
> DECnet neighbour table entries can not be used for nexthops for other
> protocols :(
>
> DECnet also abuses neigh->output to select by output device which kind
> of DECnet header to put on the packets.  But that is easily fixable.
One way to fix it would be to drop support for non-broadcast devices. We 
don't have an implementation of DDCMP currently. Ethernet is the only 
working DECnet device at the moment. PPP could also potentially work, 
with a bit of tweeking, but strangely PPP is a broadcast device so far 
as DECnet is concerned,

Steve.

