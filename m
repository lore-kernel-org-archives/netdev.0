From: Sam Leffler <sam@errno.com>
Subject: Re: [Acx100-devel] Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Wed, 8 Sep 2004 20:31:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <B67ABFFA-0210-11D9-B232-000A95AD0668@errno.com>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <413F2D33.1000508@atheros.com> <200409082251.45771.vkondra@mail.ru> <200409090019.21105.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Vladimir Kondratiev <vkondra@mail.ru>,
        prism54-devel@prism54.org, greg chesson <greg@atheros.com>,
        acx100-devel@lists.sourceforge.net, jgarzik@pobox.com, hadi@cyberus.ca,
        jkmaline@cc.hut.fi, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <200409090019.21105.vda@port.imtp.ilyichevsk.odessa.ua>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sep 8, 2004, at 2:19 PM, Denis Vlasenko wrote:

> On Wednesday 08 September 2004 22:51, Vladimir Kondratiev wrote:
>> Greg,
>> you missed one important point. Besides data packets, that every 
>> driver now
>> convert .11<->.3 using almost the same code, there is whole story of
>> management. Many modern cards are "softmac" and do all management on 
>> host.
>> I see no point for every driver to implement its own scanning and
>> association. It is simply waste of resources.
>
> This is exactly what I meant. We need generic 802.11 idioc^W management
> handling. And maybe also tx rate control, ACK/retries for 
> "completely-softmac"
> cards like Atheros.

The net80211 code has generic 802.11 management handling based on 
wireless extensions.  Drivers that sit beneath it and have the 
necessary capabilities automatically are usable, for example, with 
wpa_supplicant (and soon hostapd).  At the moment there is one driver 
for Linux--the ath driver for Atheros h/w.

Rate control is another can-o-worms.  The model we've taken is that it 
is driver-specific.

I'd be very surprised to see "softmac" h/w come along that requires the 
host to generate ACK frames explicitly; the timing is very tight and it 
would suck a lot of cycles from the host.

>
> Full spectrum of possible fullmac......softmac designs are not trivial
> to handle...

Experience with net80211 indicates you're fine if you have a good 
802.11 protocol implementation to fall back on.  Then devices that have 
functionality in h/w just supplant the s/w support.  The net80211 code 
defines a set of device capabilities that indicate, for example, when a 
device supports various h/w crypto algorithms.  Class-like method 
override mechanisms are used to handle other issues.

This stuff is constantly evolving as more devices are hooked up but in 
general it's worked out pretty well.  I've tried to avoid a spaghetti 
web of function pointers using callbacks only where it seems most 
drivers will make use of them.  For other cases it often is easier to 
grab control early on so it's easier to optimize+share code.  A 
concrete example of this is the processing of 802.11 management frames 
where the original code (that David saw) had an array of function 
pointers to little routines that handled each frame type--it turned out 
drivers didn't override these pointers  so I removed them and drivers 
that want to override the default processing override the "recv 
management" method to intercept specific frames.

>
>> To make step forward, I suggest the following:
>>
>> 1. Dave's code is at least year old. someone need to start maintain 
>> it,
>> starting with update for current kernel infrastructure. Get it 
>> compile and
>> load for 2.6.9, for example.
>
> /me runs away and hides
>
>> 2. To debug stack, you don't need real driver. I can write dummy .11 
>> driver
>> that will silently discard all Tx, and will provide some way for user 
>> level
>> tool to simulate Rx (ioctl, netlink, does not really matter). For 
>> logic, it
>> is sufficient. Later, when it will come to timing, performance etc, 
>> it will
>> be easy to strip some real driver.

To evaluate a design and implementation show support for a few devices 
at each end of the spectrum.  The Atheros h/w is probably a good 
example of softmac h/w.  ADMTek 8211 is also in this category.  I'd 
consider Prism devices toward the other end.  You also need to be sure 
you handle single- and dual-band operation as each have different 
requirements.  Also 11g support takes work to get right so be sure you 
have a softmac 11g card in the pile.  Past that you get into the 
security protocols, WME/WMM, etc.

Sound like a lot of work?  It is.

	Sam
