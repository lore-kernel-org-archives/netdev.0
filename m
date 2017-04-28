From: Waldemar Rymarkiewicz <waldemar.rymarkiewicz@gmail.com>
Subject: Re: Network cooling device and how to control NIC speed on thermal condition
Date: Fri, 28 Apr 2017 10:04:05 +0200
Message-ID: <CAHKzcEO-75r5Gmew9x1eprh9ACf_NQKCHQg9svOLM1OmVX0JgQ@mail.gmail.com>
References: <CAHKzcEMQPQzg6PYCSuv7Ufad+4AZ2gnqMgz3-VH5NTeb_pv4zQ@mail.gmail.com>
 <20170425144501.0cfe27a5@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alan Cox <gnomes@lxorguk.ukuu.org.uk>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:33077 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932429AbdD1IEr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 04:04:47 -0400
In-Reply-To: <20170425144501.0cfe27a5@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25 April 2017 at 15:45, Alan Cox <gnomes@lxorguk.ukuu.org.uk> wrote:
>> I am looking on Linux thermal framework and on how to cool down the
>> system effectively when it hits thermal condition. Already existing
>> cooling methods cpu_cooling and clock_cooling are good. However, I
>> wanted to go further and dynamically control also a switch ports'
>> speed based on thermal condition. Lowering speed means less power,
>> less power means lower temp.
>>
>> Is there any in-kernel interface to configure switch port/NIC from other driver?
>
> No but you can always hook that kind of functionality to the thermal
> daemon. However I'd be careful with your assumptions. Lower speed also
> means more time active.
>
> https://github.com/01org/thermal_daemon

This is one of the option indeed. Will consider this option as well. I
would see, however,  a generic solution in the kernel  (configurable
of course) as every network device can generate higher heat with
higher link speed.

> For example if you run a big encoding job on an atom instead of an Intel
> i7, the atom will often not only take way longer but actually use more
> total power than the i7 did.
>
> Thus it would often be far more efficient to time synchronize your
> systems, batch up data on the collecting end, have the processing node
> wake up on an alarm, collect data from the other node and then actually
> go back into suspend.

Yes, that's true in a normal thermal conditions. However, if the
platform reaches max temp trip we don't really care about performance
and time efficiency  we just try to avoid critical trip and system
shutdown by cooling the system eg. lowering cpu freq, limiting usb phy
speed, or net  link speed etc.

I did a quick test to show you what I am about.

I collect SoC temp every a few secs. Meantime, I use ethtool -s ethX
speed <speed> to manipulate link speed and to see how it impacts SoC
temp. My 4 PHYs and switch are integrated into SoC and I always
change link speed for all PHYs , no traffic on the link for this test.
Starting with 1Gb/s and then scaling down to 100 Mb/s and then to
10Mb/s, I see significant  ~10 *C drop in temp while link is set to
10Mb/s.

So, throttling link speed can really help to dissipate heat
significantly when the platform is under threat.

Renegotiating link speed costs something I agree, it also impacts user
experience, but such a thermal condition will not occur often I
believe.


/Waldek
