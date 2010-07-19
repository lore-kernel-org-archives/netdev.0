From: Tom Herbert <therbert@google.com>
Subject: Re: Very low latency TCP for clusters
Date: Mon, 19 Jul 2010 14:16:10 -0700
Message-ID: <AANLkTinTEtFfsezwurgSSoOcOmXNPmy0dCxR-DIUBifq@mail.gmail.com>
References: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
	<63E39990-7D25-41A5-82F2-DABC53D58A6B@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mitchell Erblich <erblichs@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:21231 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965514Ab0GSVQO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 17:16:14 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o6JLGCA6013329
	for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 14:16:13 -0700
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by kpbe17.cbf.corp.google.com with ESMTP id o6JLGBCQ021351
	for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 14:16:11 -0700
Received: by pvg12 with SMTP id 12so4119928pvg.11
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 14:16:11 -0700 (PDT)
In-Reply-To: <63E39990-7D25-41A5-82F2-DABC53D58A6B@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 19, 2010 at 12:46 PM, Mitchell Erblich
<erblichs@earthlink.net> wrote:
> Tom, et al,
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0To possibly remove 3-way handshake cos=
ts for
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0small data transfers a number of years=
 ago, their
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0was an experimental RFC that was a Tra=
nsactional
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0TCP, where the SYN, data, and FIN were=
 sent as
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0a tuple in the first segmernt.
>
In the context of this discussion, latency is about how fast packets
can be sent and received between applications over an established
connection.  The application would likely be doing some form of RPC
over long lived connections,  reducing latency here allows for more
tightly coupled computing models.  This sort of thing would be used on
a well connected, low-loss cluster within a data center.

Separately, there is interest in speeding up 3WHS primarily for
connections to the Internet.  We have already proposed to reduce
latency by raising the the initial congestion window (there's another
netdev thread on this if your interested).  T/TCP, which your
referring to, was abandoned due to unsolved security issues and
susceptibility to denial of service attacks.  I believe the current
IETF answer to this would be to use SCTP, but that represents a
deployment conundrum.  Address these issues to get data with the TCP
SYN is still compelling IMO.

Tom


> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0If a company has control of the two en=
d systems
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0and the intermediate systems, then it =
should be
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0possible for an app to declare in a se=
tsockopt call
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0this experimental flow.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Mitchell Erblich
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> On Jul 19, 2010, at 10:05 AM, Tom Herbert wrote:
>
>> We have been looking at best case TCP latencies that might be achiev=
ed
>> within a cluster (low loss fabric). =A0The goal is to have latency
>> numbers roughly comparable to that which can be produced using RDMA/=
IB
>> in a low latency configuration =A0(<5 usecs round trip on netperf TC=
P_RR
>> test with one byte data for directly connected hosts as a starting
>> point). =A0This would be without changing sockets API, fabric, and
>> preferably not using TCP offload or a user space stack.
>>
>> I think there are at least two techniques that will drive down TCP
>> latency: per connection queues and polling queues. =A0Per connection
>> queues (supported by device) should eliminate costs of connection
>> look-up, hopefully some locking. =A0Polling becomes viable as core
>> counts on systems increase, and burning a few CPUs for networking
>> polling on behalf of very low-latency threads would be reasonable.
>>
>> Are there any efforts in progress to integrate per connection queues
>> in the stack or integrate polling of queues?
>>
>> Thanks,
>> Tom
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
