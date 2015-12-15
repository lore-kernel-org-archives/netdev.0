From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net 2/2] udp: restrict offloads to one namespace
Date: Tue, 15 Dec 2015 14:39:14 -0800
Message-ID: <CALx6S36ap9-uWPcxskYRahUoH_H+Y99=qzPDc97g_eEyndL3tg@mail.gmail.com>
References: <1450209714-26037-1-git-send-email-hannes@stressinduktion.org>
	<1450209714-26037-2-git-send-email-hannes@stressinduktion.org>
	<CALx6S36bA_PJLpqPbqM_gnZLUE3v7J9iBndGqj=HQLG8hQ_0_w@mail.gmail.com>
	<56707C13.3080707@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34981 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932469AbbLOWjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 17:39:15 -0500
Received: by mail-io0-f178.google.com with SMTP id q126so36093087iof.2
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 14:39:15 -0800 (PST)
In-Reply-To: <56707C13.3080707@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 15, 2015 at 12:46 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 15.12.2015 21:26, Tom Herbert wrote:
>> On Tue, Dec 15, 2015 at 12:01 PM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>>> udp tunnel offloads tend to aggregate datagrams based on inner
>>> headers. gro engine gets notified by tunnel implementations about
>>> possible offloads. The match is solely based on the port number.
>>>
>>> Imagine a tunnel bound to port 53, the offloading will look into all
>>> DNS packets and tries to aggregate them based on the inner data found
>>> within. This could lead to data corruption and malformed DNS packets.
>>>
>>> While this patch minimizes the problem and helps an administrator to find
>>> the issue by querying ip tunnel/fou, a better way would be to match on
>>> the specific destination ip address so if a user space socket is bound
>>> to the same address it will conflict.
>>>
>> I don't know... seems like this is more likely to add code into the
>> critical path rather than solve a problem impacting anyone yet. No
>> other GRO code needs to be namespace aware and none of these fancy HW
>> offloads for UDP encapsulations are going to care anything about
>> namespaces.
>
> HW encapsulation actually already respects namespaces, they only iterate
> over the net_devices in the namespace the tunnel is created in to push
> down the udp port information.
>
> I would like to extend this to destination addresses, too. I am not sure
> this is possible and if hw offloads actually corrupt packets.
>
>> I think you point out the real underlying problem though, the UDP
>> offloads are restricted only be done by destination port and nothing
>> else. A more flexible method would be to allow matching on based
>> addresses, four tuples, interfaces etc. (latter may be needed to
>> offload connected UDP).
>
> With net namespaces a quadruple does not uniquely identify a socket
> anymore, as different netns could have the same ip address bound. So
> separation by netns seems to be the first and easy implementable
> solution to protect against those problems. I am already working to push
> the local address to gro, too.
>
Consider the following scenario with netns:

1) VXLAN is loaded with port number 7777.
2) add_rx_port is caller, driver gets this and then programs device
that port number 7777 means VXLAN.
3) A network name space is added using L3 IPVLAN
4) Application in network space now binds an application (not VXLAN)
to port 7777
5) Packets sent to the application at port 7777 are misinterpreted as
VLXAN by the device

Hopefully, the misinterpretation won't result in corrupted packet (RSS
and checksum offload should not). However, LRO would have the
potential for corruption... Unfortunately,  this is potentially a
problem on the host today with GRO since it appears we are doing GRO
before identifying the packet as IPVLAN :-(

Tom

> Bye,
> Hannes
>
