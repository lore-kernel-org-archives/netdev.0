From: Arvid Brodin <arvid.brodin@enea.com>
Subject: Re: bridge: HSR support
Date: Mon, 21 Nov 2011 17:52:16 +0100
Message-ID: <4ECA81C0.2050208@enea.com>
References: <4E948A04.8060400@enea.com> <20111011112821.28cd3e51@nehalam.linuxnetplumber.net> <4E94D67A.9060207@enea.com> <4EA5738B.8080008@enea.com> <4EAACB7A.4090207@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:1986 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751820Ab1KUQwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Nov 2011 11:52:24 -0500
In-Reply-To: <4EAACB7A.4090207@enea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arvid Brodin wrote:
> Arvid Brodin wrote:
>> Stephen Hemminger wrote:
>>> On Tue, 11 Oct 2011 20:25:08 +0200
>>> Arvid Brodin <arvid.brodin@enea.com> wrote:
>>>
>>>> Hi,
>>>>
>>>> I want to add support for HSR ("High-availability Seamless Redundancy",
>>>> IEC-62439-3) to the bridge code. With HSR, all connected units have two network
>>>> ports and are connected in a ring. All new Ethernet packets are sent on both
>>>> ports (or passed through if the current unit is not the originating unit). The
>>>> same packet is never passed twice. Non-HSR units are not allowed in the ring.
>>>>
>>>> This gives instant, reconfiguration-free failover.
>>>>
> *snip*
>> I need to do two things:
>>
>> 1) Bind two network interfaces into one (say, eth0 & eth1 => hsr0). Frames sent on
>>    hsr0 should get an HSR tag (including the correct EtherType) and go out on both
>>    eth0 and eth1.
>>
>> 2) Ingress frames on eth0 & eth1, with EtherType 0x88fb, should be captured and 
>>    handled specially (either received on hsr0 or forwarded to the other bound 
>>    physical interface).
>>
>> Any ideas on the best way to implement this -- what's the nicest place to "hook
>> into" for this?
>>

I need some help with the code for creating virtual hsr devices.

To reiterate, a hsr device acts as a kind of master for two physical ethernet
devices. Any frame sent on the hsrX device should be forwarded to and sent from
both physical devices. Frames coming in on one of the physical devices should
be bridged to the other physical device, or received on the hsr device if the
host is the intended destination.

Questions:

1) net_device features. Should I just logically AND the features fields of the
   physical interfaces to get a correct value for the hsr device?


2) net_device priv_flags / flags:

   I'm guessing I need to clear IFF_XMIT_DST_RELEASE on all involved interfaces
   to be able to send outgoing frames on multiple interfaces?

   Can I set IFF_DONT_BRIDGE on the physical interfaces to prevent them being
   used in a bridge?

   Can I call netdev_set_master() on the physical devices to stop them from
   being used in e.g. a bond?


3) Stats: is there a reason not to use the net_device->stats field for
   statistics on the hsr device? (I see many drivers keep their own
   net_device_stats data and implement ndo_get_stats64() instead.)

-- 
Arvid Brodin
Enea Services Stockholm AB
