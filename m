From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: IP-less bridge as a martian source
Date: Wed, 05 Nov 2008 11:30:45 +0100
Message-ID: <87prla79d6.fsf@tac.ki.iif.hu>
References: <87tzb6nodj.fsf@tac.ki.iif.hu> <87wsg0wu78.fsf@tac.ki.iif.hu>
	<48FF614C.7020507@gmail.com> <48FF7AA3.50408@gmail.com>
	<87y707mjbi.fsf@tac.ki.iif.hu> <20081031084124.GA4364@ff.dom.local>
	<877i7novar.fsf@szonett.ki.iif.hu>
	<20081105094303.GA5378@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:58552 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754648AbYKEKaw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 05:30:52 -0500
In-Reply-To: <20081105094303.GA5378@ff.dom.local> (Jarek Poplawski's message
	of "Wed, 5 Nov 2008 09:43:03 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> writes:

> On Sun, Nov 02, 2008 at 12:55:56AM +0100, Ferenc Wagner wrote:
>> Jarek Poplawski <jarkao2@gmail.com> writes:
>> 
>>> On Wed, Oct 29, 2008 at 05:56:17PM +0100, Ferenc Wagner wrote:
>>>
>>>> Jarek Poplawski <jarkao2@gmail.com> writes:
>>>> 
>>>>>>> Ferenc Wagner <wferi@niif.hu> writes:
>>>>>>>
>>>>>>>> I expected an IP-less bridge interface to pick up no IP
>>>>>>>> packets, but apparently this isn't the case: broadcast packets
>>>>>>>> with destination address 255.255.255.255 are reported as
>>>>>>>> martians by the 2.6.18 kernel, which I find counterintuitive (I
>>>>>>>> know 2.6.18 is rather old, but that's the one supported by Xen).
>>>>>>>>
>>>>>>>>   1. Is this the expected behaviour?
>>>>>
>>>>> with IP disabled you shouldn't have any martians!
>>>> 
>>>> In my case, the bridge itself (?) has no IP addresses assigned, but
>>>> an other interface (which isn't a bridge port) does have.  In other
>>>> words, the only network interface of the host is a bond interface
>>>> aggregating the two physical Ethernet interfaces; the two IP
>>>> addresses of the host are assigned to this bond0.
>>>> 
>>>> bond0 is also the raw interface of several .1q VLAN interfaces,
>>>> which are ports of bridges (there is one bridge for each VLAN but
>>>> the native above).  The other ports of the bridges are the virtual
>>>> interfaces of the Xen guests running on this host.  If I run ping
>>>> -b 255.255.255.255 on one such guest, that gives a "martian source
>>>> 255.255.255.255" warning on the given bridge.  Even though
>>>> 255.255.255.255 is the destination address of that ping packet...
>>>> 
>>>> And this happens on 2.6.26.6, too.
>>>
>>> This means that even with IP enabled device ip_mkroute_input() should
>>> be skipped. So it seems it's not about 255.255.255.255 generally, but
>>> just about source address. You didn't give any examples of these
>>> warnings, but I guess it's not a 0 address which is most popular with
>>> 255.255.255.255.
>> 
>> Indeed not, sorry.  If I ping -b 255.255.255.255 on a virtual machine
>> with IP 193.225.14.155, whose virtual interface is a port of br891:
>> 
>> martian source 255.255.255.255 from 193.225.14.155, on dev br891
>
> Hmm, I still have doubts if this bridge is IP or not IP (iconfigs of
> br891 and its components could help).

wferi@xen1:~$ sudo brctl show br891
bridge name	bridge id		STP enabled	interfaces
br891		8000.00065b8e71d5	no		vif3.0
							vif4.0
							vlan891

wferi@xen1:~$ /sbin/ifconfig br891
br891     Link encap:Ethernet  HWaddr 00:06:5b:8e:71:d5  
          inet6 addr: 2001:738:0:701:206:5bff:fe8e:71d5/64 Scope:Global
          inet6 addr: fe80::206:5bff:fe8e:71d5/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:425875 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:22340867 (21.3 MiB)  TX bytes:476 (476.0 B)

wferi@xen1:~$ /sbin/ifconfig vif3.0
vif3.0    Link encap:Ethernet  HWaddr fe:ff:ff:ff:ff:ff  
          inet6 addr: fe80::fcff:ffff:feff:ffff/64 Scope:Link
          UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
          RX packets:759861 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1123300 errors:0 dropped:3 overruns:0 carrier:0
          collisions:0 txqueuelen:32 
          RX bytes:129716290 (123.7 MiB)  TX bytes:172569213 (164.5 MiB)

wferi@xen1:~$ /sbin/ifconfig vif4.0
vif4.0    Link encap:Ethernet  HWaddr fe:ff:ff:ff:ff:ff  
          inet6 addr: fe80::fcff:ffff:feff:ffff/64 Scope:Link
          UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
          RX packets:5944478 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4411137 errors:0 dropped:3 overruns:0 carrier:0
          collisions:0 txqueuelen:32 
          RX bytes:969710414 (924.7 MiB)  TX bytes:465817748 (444.2 MiB)

wferi@xen1:~$ /sbin/ifconfig vlan891
vlan891   Link encap:Ethernet  HWaddr 00:06:5b:8e:71:d5  
          inet6 addr: fe80::206:5bff:fe8e:71d5/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:5475880 errors:0 dropped:0 overruns:0 frame:0
          TX packets:12255410 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:558161949 (532.3 MiB)  TX bytes:1557958522 (1.4 GiB)

I hope it's not the autoconfigured IPv6 addresses...

wferi@xen1:~$ sudo cat /proc/net/vlan/vlan891 
vlan891  VID: 891	 REORDER_HDR: 1  dev->priv_flags: 1
         total frames received      5476270
          total bytes received    558194978
      Broadcast/Multicast Rcvd       258638

      total frames transmitted     12255659
       total bytes transmitted   1558098776
            total headroom inc            0
           total encap on xmit            0
Device: bond0
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
EGRESSS priority Mappings: 

(funny syntax on the last line...)

wferi@xen1:~$ /sbin/ifconfig bond0
bond0     Link encap:Ethernet  HWaddr 00:06:5b:8e:71:d5  
          inet addr:10.253.2.7  Bcast:10.253.2.255  Mask:255.255.255.0
          inet6 addr: fe80::206:5bff:fe8e:71d5/64 Scope:Link
          UP BROADCAST RUNNING PROMISC MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:41596702 errors:0 dropped:16 overruns:0 frame:0
          TX packets:44983056 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:8309642 (7.9 MiB)  TX bytes:2073809325 (1.9 GiB)

wferi@xen1:~$ /sbin/ifconfig bond0:0
bond0:0   Link encap:Ethernet  HWaddr 00:06:5b:8e:71:d5  
          inet addr:10.253.2.9  Bcast:10.253.2.255  Mask:255.255.255.0
          UP BROADCAST RUNNING PROMISC MASTER MULTICAST  MTU:1500  Metric:1

These are the two IPv4 addresses of the host.

> It seems there has to be some IP seen on this br891 yet, and then I
> wonder if it's not a fake problem with input of the bridge surprised
> by a packet with it's own IP as source (but I didn't check for this
> enough). So, the question is if you can get similar warnings without
> such "special", internal pings too.

No, practically I can't.  If I ping the directed broadcast address
instead (ping -c1 -b 193.225.14.255), no warnings are emitted.
"Normal" traffic doesn't elicit them either, only the undirected
broadcasts to 255.255.255.255:

wferi@xen1:~$ zfgrep "martian source" /var/log/kern* | sed 's/.*martian source //' | sort -u
10.253.2.9 from 10.253.2.9, on dev bond0
255.255.255.255 from 193.225.14.155, on dev br891
255.255.255.255 from 193.225.14.179, on dev br891
255.255.255.255 from 193.225.14.195, on dev br891
255.255.255.255 from 193.225.14.201, on dev br891
255.255.255.255 from 193.225.14.251, on dev br891

(The first entry is a corner case which only happened when the
mentioned IP was floated over to this machine after guest migration,
which changed the bridge configuration as well.)

>>> And, if there is some network address we have a problem: AFAIK this
>>> 255.255.255.255 broadcast is special, and it shouldn't be routed to
>>> other networks. Your host doesn't seem to recognize this network, so
>>> it shouldn't happen on this interface. So it seems, you expect the
>>> bridge behavior where it's 2 in 1 (bridge + IP host).
>> 
>> Yes, this machine is an IP host (SSH access is needed) in a private
>> subnet (10.253.2/24) and also bridges traffic belonging to other
>> subnets (like for example the above).  It is not a router, though, so
>> it knows nothing about the bridged subnets.  Actually, it should be
>> totally separated from those, that's why I was alarmed by the martian
>> warnings: these "limited broadcast" (255.255.255.255, not routed, as
>> you note) addressed packets could reach the bridge!
>
> Wasn't this ping done within the bridge's reach?

I'm not sure what you mean.  It was done on a virtual machine, whose
virtual inteface (vif4.0) is a port of br891 (see above).

>>> I'm not sure there is "right" solution for this with any model, but
>>> I can miss something - then more details are needed. Otherwise,
>>> maybe you should simply consider turning off log_martians on these
>>> devices.
>> 
>> I could, but I'm more than a little worried that I don't understand
>> this stuff I'm expected to manage.  That's why I brought up the issue
>> here.  rp_filter is already enabled on all interfaces.  Do you think
>> it already ensures the separation I'm after, and all that's left is to
>> disable log_martians?
>
> rp_filter prevents some kind of suspicious traffic (but legal
> sometimes)

Does it drop anything legal but asymmetrically routed packets?

> but not all. log_martians should tell you if it's something
> serious. If you have some martians "by design" it's probably better
> to get rid of them before rp_filter

By dropping the in the nat table or by ebtables?  Anyway, "martians by
design" does sound particulary sane.

> and save log_martians only for really unexpected cases.

Yes, that's what I did.  And it actually showed something unexpected.

>> Ps: If so, then I'd suggest placing the martian warning after
>> rp_filter, so that it doesn't warn about packets which get dropped
>> anyway, if possible.  Also, flipping the addresses in the martian
>> warning text would reduce confusion.  As it is, it suggests (English
>> is a foreign language for me, mind you) that 255.255.255.255 is the
>> problematic "martian source", while it's just a random destination
>> address in fact.
>
> I guess we turn on log_martians just to see what is dropped.

OK, so those are dropped anyway.

> I agree the syntax of this warning is confusing, but I doubt we
> should change this after so many years - this could break users'
> scripts checking for this.

:) It's surprising after having read stable_api_nonsense.txt...
-- 
Regards,
Feri.
