From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: TCP performance regression
Date: Mon, 11 Nov 2013 17:38:24 +0100
Message-ID: <52810800.9020402@openwrt.org>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>	<1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>	<21120.29720.673157.151074@gargle.gargle.HOWL>	<1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>	<21120.37647.979237.40802@gargle.gargle.HOWL>	<1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com> <21121.575.539384.948990@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dave Taht <dave.taht@gmail.com>
To: Sujith Manoharan <sujith@msujith.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:59366 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754148Ab3KKQij (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Nov 2013 11:38:39 -0500
In-Reply-To: <21121.575.539384.948990@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-11-11 17:13, Sujith Manoharan wrote:
> Eric Dumazet wrote:
>> We have many choices.
>> 
>> 1) Add back a minimum of ~128 K of outstanding bytes per TCP session,
>>    so that buggy drivers can sustain 'line rate'.
>> 
>>    Note that with 100 concurrent TCP streams, total amount of bytes
>>    queued on the NIC is 12 MB.
>>    And pfifo_fast qdisc will drop packets anyway.
>> 
>>    Thats what we call 'BufferBloat'
>> 
>> 2) Try lower values like 64K. Still bufferbloat.
>> 
>> 3) Fix buggy drivers, using a proper logic, or shorter timers (mvneta
>> case for example)
>> 
>> 4) Add a new netdev attribute, so that well behaving NIC drivers do not
>> have to artificially force TCP stack to queue too many bytes in
>> Qdisc/NIC queues.
> 
> I think the quirks of 802.11 aggregation should be taken into account.
> I am adding Felix to this thread, who would have more to say on latency/bufferbloat
> with wireless drivers.
I don't think this issue is about something as simple as timer handling
for tx completion (or even broken/buggy drivers).

There's simply no way to make 802.11 aggregation work well and have
similar tx completion latency characteristics as Ethernet devices.

802.11 aggregation reduces the per-packet airtime overhead by combining
multiple packets into one transmission (saving a lot of time getting a
tx opportunity, transmitting the PHY header, etc.), which makes the
'line rate' heavily depend on the amount of buffering.

Aggregating multiple packets into one transmission also causes extra
packet loss, which is compensated by retransmission and reordering, thus
introducing additional latency.

I don't think that TSQ can do a decent job of mitigating bufferbloat on
802.11n devices without a significant performance hit, so adding a new
netdev attribute might be a good idea.

- Felix
