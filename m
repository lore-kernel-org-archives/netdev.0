From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 0/3] openvswitch: Add STT support.
Date: Wed, 21 Jan 2015 10:30:45 -0800
Message-ID: <CALnjE+po5gy7g8ftmiNcnrN_gRL9tzCRHNtn=fxUafFikKB1rg@mail.gmail.com>
References: <1421785536-19793-1-git-send-email-pshelar@nicira.com>
	<CA+mtBx90TipY9uJvW2uQfrCYL9JNM9Rk75HzdJPhE0qsdy8dnw@mail.gmail.com>
	<CALnjE+rSXpPftiG4Vw3azkN2s2-Ey6ZcZr9Bv422pOdwrvU=tw@mail.gmail.com>
	<CA+mtBx9yM+C8GeEHOGTHPVxNB3fJd7LQG0RaC3jywrO9_tQ58A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:59586 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752892AbbAUSar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 13:30:47 -0500
Received: by mail-ig0-f177.google.com with SMTP id h15so15223679igd.4
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 10:30:45 -0800 (PST)
In-Reply-To: <CA+mtBx9yM+C8GeEHOGTHPVxNB3fJd7LQG0RaC3jywrO9_tQ58A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2015 at 8:51 AM, Tom Herbert <therbert@google.com> wrote:
> On Wed, Jan 21, 2015 at 1:08 AM, Pravin Shelar <pshelar@nicira.com> wrote:
>> On Tue, Jan 20, 2015 at 3:06 PM, Tom Herbert <therbert@google.com> wrote:
>>> On Tue, Jan 20, 2015 at 12:25 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>>>> Following patch series adds support for Stateless Transport
>>>> Tunneling protocol.
>>>> STT uses TCP segmentation offload available in most of NIC. On
>>>> packet xmit STT driver appends STT header along with TCP header
>>>> to the packet. For GSO packet GSO parameters are set according
>>>> to tunnel configuration and packet is handed over to networking
>>>> stack. This allows use of segmentation offload available in NICs
>>>>
>>>> Netperf unidirectional test gives ~9.4 Gbits/s performance on 10Gbit
>>>> NIC with 1500 byte MTU with two TCP streams.
>>>>
>>> Having packets marked TCP which really aren't TCP is a rather scary
>>> prospect to deploy in a real data center (TCP is kind of an important
>>> protocol ;-) ). Can you give some more motivation on this, more data
>>> that shows what the benefits are and how this compares to equivalent
>>> encapsulation protocols that implement GRO and GSO.
>>>
>> There are multi-year deployments of STT, So it is already in real data center.
>> Biggest advantage is STT does not need new NIC with tunnel offload.
>> Any NIC that supports TCP offload can be used to achieve better
>> performance.
>>
>> Following are numbers you asked for.
>> Setup: net-next branch on server and client.
>> netperf: TCP unidirectional tests with 5 streams. Numbers are averaged
>> over 3 runs of 50 sec.
>>
> Please provides more details on your configuration so that others
> might be able to reproduce your results. Also, it would be quite
> helpful if you could implement STT as a normal network interface like
> VXLAN does so that we can isolate performance of the protocol. For
> instance I have no problem getting line rate with VXLAN using 5
> streams with or without RCO in my testing. I assume you tested with
> OVS and maybe VMs which may have a significant impact beyond the
> protocol changes.
>
I used bare metal intel servers. All VXLAN tests were done using linux
kernel device without any VMs. All STT tests are done using OVS bridge
and STT port.

> Another thing to consider in your analysis is the performance with
> flows using small packets. STT should demonstrate better performance
> with bulk flows since LSO and LRO are better performing relative to
> GSO and GRO. But for flows with small packets, I don't see how there
> could be any performance advantage. We already have ways to leverage
> simple UDP checksum offload with UDP encapsulations, seems like STT
> might just represent unnecessary header overhead in those cases.
>
All tunneling protocol has performance issue with small packet, I do
not see how is it related to STT patch. STT also make use of checksum
offload, so there should not be much overhead.

>> VXLAN:
>> CPU
>>   Client: 1.6
>>   Server: 14.2
>> Throughput: 5.6 Gbit/s
>>
>> VXLAN with rcsum:
>> CPU
>>   Client: 0.89
>>   Server: 12.4
>> Throughput: 5.8 Gbit/s
>>
>> STT:
>> CPU
>>   Client: 1.28
>>   Server: 4.0
>> Throughput: 9.5 Gbit/s
>>
> 9.5Gbps? Rounding error or is this 40Gbps or larger than 1500 byte MTU?
>
Nope, its same as VXLAN setup, 10Gbps NIC with 1500MTU.

Thanks.
