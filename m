From: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
Subject: Re: [PATCH V2 0/1] neighbour: Support broadcast ARP in neighbor PROPE
 state
Date: Wed, 18 Mar 2015 09:51:02 +0100
Message-ID: <55093C76.3030208@ericsson.com>
References: <1426143501-30827-1-git-send-email-Yanjun.Zhu@windriver.com> <55013BD4.2080605@windriver.com> <5501518D.2070405@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "YOSHIFUJI Hideaki (USAGI Project)" <yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	yzhu1 <Yanjun.Zhu@windriver.com>, <brian.haley@hp.com>,
	<davem@davemloft.net>, <alexandre.dietsch@windriver.com>,
	<clinton.slabbert@windriver.com>, <kuznet@ms2.inr.ac.ru>,
	<jmorris@namei.org>, <kaber@trash.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:65046 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975AbbCRIvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 04:51:06 -0400
In-Reply-To: <5501518D.2070405@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/12/2015 09:42 AM, YOSHIFUJI Hideaki wrote:
> Hello.
>
> yzhu1 wrote:
>> The state machine is in the attachment.
>>
>> Best Regards!
>> Zhu Yanjun
>> On 03/12/2015 02:58 PM, Zhu Yanjun wrote:
>>> V2:
>>>    set ARP_PROBE_BCAST default N.
>>>
>>> V1:
>>>    Have a problem with an HP router at a certain location, which
>>>    is configured to only answer to broadcast ARP requests.
>>>    That cannot be changed.
>>>
>>>    The first ARP request the kernel sends out, is a broadcast request,
>>>    which is fine, but after the reply, the kernel sends unicast 
>>> requests,
>>>    which will not get any replies.
>>>
>>>    The ARP entry will after some time enter STALE state,
>>>    and if nothing is done it will time out, and be removed.
>>>    This process takes to long, and I have been told that it is
>>>    difficult to makes changes that will eventually remove it.
>>>
>>>    Have tried to change the state from STALE to INCOMPLETE, which 
>>> failed,
>>>    and then tried to change the state to PROBE which also failed.
>>>
>>>    The stack is only sending out unicasts, and never broadcast.
>>>    Is there any way to get the stack to send out a broadcast ARP
>>>    without having to wait for the entry to be removed?
>
> Neighbour subsystem will send multicast probes after unicast
> probes in NUD_PROBE state if mcast_solicit is more than
> ucast_solicit.  Try setting net.ipv4.neigh.*.ucast_solicit to
> the value less than net.ipv4.neigh.*.mcast_solicit, please?
> e.g.
>
> net.ipv4.neigh.eth0.mcast_solicit = 3
> net.ipv4.neigh.eth0.ucast_solicit = 1
>
> --yoshfuji
>
I dont see how, and I would like to focus on code discussion.

Below is simplified pseudo code of the timer handler
after you have reached REACHABLE the first time.

     "mcast_solicit" is not used at all.

It is only used when in INCOMPLETE state as far as I can tell.

I do not see that the stack is returning to INCOMPLETE
after it has reached REACHABLE once.

Can it do so? In that case, in what part of the code.

=============================
int    confirmed;     /* time of last ARP reply */
int    ucast_solicit;    /* sysctl */
int    app_solicit;    /* sysctl */
neigh_timer_handler()
begin
     if (in REACHABLE) then
         if ("current time" <=( confirmed + reachable)) then
             we are OK, test later
         else if ("current time" <= used + DELAY_PROBE_TIME) then
             set state to DELAY
         else
             set state to STALE
         end if
     else if (in DELAY) then
         if ("current time" <= confirmed + DELAY_PROBE_TIME) then
             change state to REACHABLE
             send notification
         else
             change state to PROBE
             probes = 0;
             do not send notification
         end if

     if (in PROBE state) then
         if (probes >= (ucast_solicit + app_solicit)) then
             change state to FAILED
             send notification
         end if
     end if

     if (in PROBE state) then
         send ARP request;
     end if

     if (notify) then
         send notification
     end if
end

====================
Anyway, the behaviour I would like to see is:

INCOMPLETE:
     Send 3 broadcast ARP
PROBE
     Send 3 unicast ARP
     Send 3 broadcast ARP

which not possible with your suggestion
I do not want to send 6 broadcast ARP in INCOMPLETE state.


Best Regards,
Ulf Samuelsson



>
>>>
>>>    I think the recommended behaviour in IPv6 is to send out 3 unicasts
>>>    and if all fails, to send out broadcasts.
>>>
>>> Zhu Yanjun (1):
>>>    neighbour: Support broadcast ARP in neighbor PROPE state
>>>
>>>   include/net/neighbour.h        |  7 ++++++
>>>   include/uapi/linux/neighbour.h |  6 +++++
>>>   include/uapi/linux/sysctl.h    |  3 +++
>>>   kernel/sysctl_binary.c         |  3 +++
>>>   net/core/neighbour.c           | 44 +++++++++++++++++++++++++++++---
>>>   net/ipv4/Kconfig               | 57 
>>> ++++++++++++++++++++++++++++++++++++++++++
>>>   net/ipv4/arp.c                 |  7 ++++--
>>>   7 files changed, 121 insertions(+), 6 deletions(-)
>>>
>>
>
