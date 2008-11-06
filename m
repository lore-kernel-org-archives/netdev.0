From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: IP-less bridge as a martian source
Date: Thu, 06 Nov 2008 13:00:05 +0100
Message-ID: <873ai5yshm.fsf@tac.ki.iif.hu>
References: <87tzb6nodj.fsf@tac.ki.iif.hu> <87wsg0wu78.fsf@tac.ki.iif.hu>
	<48FF614C.7020507@gmail.com> <48FF7AA3.50408@gmail.com>
	<87y707mjbi.fsf@tac.ki.iif.hu> <20081031084124.GA4364@ff.dom.local>
	<877i7novar.fsf@szonett.ki.iif.hu>
	<20081105094303.GA5378@ff.dom.local> <87prla79d6.fsf@tac.ki.iif.hu>
	<20081106100032.GA4809@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:32872 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753586AbYKFMAI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 07:00:08 -0500
In-Reply-To: <20081106100032.GA4809@ff.dom.local> (Jarek Poplawski's message
	of "Thu, 6 Nov 2008 10:00:32 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> writes:

> On Wed, Nov 05, 2008 at 11:30:45AM +0100, Ferenc Wagner wrote:
>> Jarek Poplawski <jarkao2@gmail.com> writes:
>> 
>>> On Sun, Nov 02, 2008 at 12:55:56AM +0100, Ferenc Wagner wrote:
>>>> Jarek Poplawski <jarkao2@gmail.com> writes:
>>>> 
>>>>> On Wed, Oct 29, 2008 at 05:56:17PM +0100, Ferenc Wagner wrote:
>>>>>
>>>>>> Jarek Poplawski <jarkao2@gmail.com> writes:
>>>>>> 
>>>>>>>>> Ferenc Wagner <wferi@niif.hu> writes:
>>>>>>>>>
>>>>>>>>>> I expected an IP-less bridge interface to pick up no IP
>>>>>>>>>> packets, but apparently this isn't the case: broadcast packets
>>>>>>>>>> with destination address 255.255.255.255 are reported as
>>>>>>>>>> martians by the 2.6.18 kernel, which I find counterintuitive (I
>>>>>>>>>> know 2.6.18 is rather old, but that's the one supported by Xen).
>>>>>>>>>>
>>>>>>>>>>   1. Is this the expected behaviour?
>>>>>>>
>>>>>>> with IP disabled you shouldn't have any martians!
>>>>>> 
>>>>>> In my case, the bridge itself (?) has no IP addresses assigned, but
>>>>>> an other interface (which isn't a bridge port) does have.  In other
>>>>>> words, the only network interface of the host is a bond interface
>>>>>> aggregating the two physical Ethernet interfaces; the two IP
>>>>>> addresses of the host are assigned to this bond0.
>>>>>> 
>>>>>> bond0 is also the raw interface of several .1q VLAN interfaces,
>>>>>> which are ports of bridges (there is one bridge for each VLAN but
>>>>>> the native above).  The other ports of the bridges are the virtual
>>>>>> interfaces of the Xen guests running on this host.  If I run ping
>>>>>> -b 255.255.255.255 on one such guest, that gives a "martian source
>>>>>> 255.255.255.255" warning on the given bridge.  Even though
>>>>>> 255.255.255.255 is the destination address of that ping packet...
>>>>>> 
>>>>>> And this happens on 2.6.26.6, too.
>>>>>
>>>>> This means that even with IP enabled device ip_mkroute_input() should
>>>>> be skipped. So it seems it's not about 255.255.255.255 generally, but
>>>>> just about source address. You didn't give any examples of these
>>>>> warnings, but I guess it's not a 0 address which is most popular with
>>>>> 255.255.255.255.
>>>> 
>>>> Indeed not, sorry.  If I ping -b 255.255.255.255 on a virtual machine
>>>> with IP 193.225.14.155, whose virtual interface is a port of br891:
>>>> 
>>>> martian source 255.255.255.255 from 193.225.14.155, on dev br891
>> 
>> I hope it's not the autoconfigured IPv6 addresses...
>
> I hope too... Anyway, I did some checking and this all seems to be a
> real puzzle. As I wrote earlier (according to the comment): "with IP
> disabled you shouldn't have any martians!". But it looks like deleting
> all inet addresses isn't enough to have this "IP disabled" status
> (maybe it's about multicasts or something... - I still have to find the
> reason), but it's probably not critical for this problem.
>
> Then I guess we can reconsider this problem like this: since this is a
> bridge device without any IP address, and "we" expect treating this as
> IP disabled devices, IMHO it doesn't make much sense to turn rp_filter
> for such a device; log_martians can report us some other strange
> address combinations, so it could be useful if there is not too much
> of this.

Yes, rp_filter doesn't make any sense on this bridge interface, as
there should be no traffic to/from the bridging host through this
bridge.  Still, it shouldn't hurt either, should it?

>> wferi@xen1:~$ sudo cat /proc/net/vlan/vlan891 
>> [...]
>> EGRESSS priority Mappings: 
>
> Should be corrected: maybe you will send a patch? (Otherwise let me now.)

I sent one.  Hope it's OK.

> Yes, but this 255.255.255.255 address is (or was) special. According
> to this:
> http://en.wikipedia.org/wiki/Classful_network
> and especially this:
> http://tools.ietf.org/html/draft-wilson-class-e-02
>
> it could be changed soon.

Yes, but I fail to see how this is relevant in either case.  My
question is: why does the IP-less bridge pick up any packets?
Does the host-based addressing model require this, if the host has any
IP address at all (on some other interface)?

>>>>> And, if there is some network address we have a problem: AFAIK this
>>>>> 255.255.255.255 broadcast is special, and it shouldn't be routed to
>>>>> other networks. Your host doesn't seem to recognize this network, so
>>>>> it shouldn't happen on this interface. So it seems, you expect the
>>>>> bridge behavior where it's 2 in 1 (bridge + IP host).
>>>> 
>>>> Yes, this machine is an IP host (SSH access is needed) in a private
>>>> subnet (10.253.2/24) and also bridges traffic belonging to other
>>>> subnets (like for example the above).  It is not a router, though, so
>>>> it knows nothing about the bridged subnets.  Actually, it should be
>>>> totally separated from those, that's why I was alarmed by the martian
>>>> warnings: these "limited broadcast" (255.255.255.255, not routed, as
>>>> you note) addressed packets could reach the bridge!
>>>
>>> Wasn't this ping done within the bridge's reach?
>> 
>> I'm not sure what you mean.  It was done on a virtual machine, whose
>> virtual inteface (vif4.0) is a port of br891 (see above).
>
> I'm not sure what you mean by "totally separated". Bridges usually
> don't help to separate, and packets with proper or not proper (for some
> network) addresses are forwarded.

I didn't mean separating the ports of the bridge, but separating the
host running the bridge from the traffic the bridge forwards.  It
should be able to forward all the strangest IP or non-IP traffic of
the world and stay totally unaffected.

>>> but not all. log_martians should tell you if it's something
>>> serious. If you have some martians "by design" it's probably
>>> better to get rid of them before rp_filter
>> 
>> By dropping the in the nat table or by ebtables?  Anyway, "martians by
>> design" does sound particulary sane.
>
> I mean e.g. when you really have to treat packets with such unusual
> addresses as in your pings.

Yes, I have to.  Some Wake-on-LAN packets also carry 255.255.255.255
as their destination address.  Just like various Windows/MacOS
"neighbour discovery" services.

>>> I agree the syntax of this warning is confusing, but I doubt we
>>> should change this after so many years - this could break users'
>>> scripts checking for this.
>> 
>> :) It's surprising after having read stable_api_nonsense.txt...
>
> Hmm... Could you point me to this most :) point?

For me, the first paragraph says that the user space interface is the
syscall interface, and that's the only one you can count on being
stable; in other cases technical superiority overrides compatibility.
Not that I feel too strongly in this case.
-- 
Regards,
Feri.
