From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Sun, 8 Dec 2013 17:21:43 +0200
Message-ID: <52A48E87.1010704@mellanox.com>
References: <529DF340.70602@mellanox.com> <1386084620.30495.28.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZJ9WM1H9zKNzT5MvQ2UH7RxkTLk2Rhzsk9vdvKz6d2uAw@mail.gmail.com> <alpine.LFD.2.03.1312031310140.23893@intel.com> <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com> <alpine.LFD.2.03.1312031500020.570@intel.com> <CAJZOPZLT_3msfz_XY45GOBMWK_y8WEYBTq3rGRUijpYyXE1ddg@mail.gmail.com> <alpine.LFD.2.03.1312031626400.7539@intel.com> <CAJZOPZJKsrj2+SQJsgq-w7BrNwDR0OsYWiF+1CcRQ3-KhejZhQ@mail.gmail.com> <alpine.LFD.2.03.1312040113290.14367@intel.com> <CAJZOPZJVBpqm-OduV4K2YwbXESP7awhsk0HbjuHazAiQJZTLWQ@mail.gmail.com> <52A197DF.5010806@mellanox.com> <alpine.LFD.2.03.1312060205220.3499@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, <jeffrey.t.kirsher@intel.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jerry Chu <hkchu@google.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:36095 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755254Ab3LHPV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 10:21:56 -0500
In-Reply-To: <alpine.LFD.2.03.1312060205220.3499@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2013 12:30, Joseph Gasparakis wrote:
> On Fri, 6 Dec 2013, Or Gerlitz wrote:
>
>
>> 1. on which kernel did you manage to get along fine vxlan performance wise
>> with this hack?
>>
> I was running 3.10.6.
>
>> 2. did the hack helped for both veth host traffic or only on PV VM traffic?
>>
> No, just VM. I haven't tried veth.
>
> If you leave the DODGY bit, does your traffic get droped on Tx, after it
> leaves vxlan and before it hits your driver, which is what I had seen. Is
> that right?
>
> If you unset it, do you recover?
>
> What is the output of your ethtool -k on the interface you are
> transmitting from?
>
>> Currently it doesn't converge with 3.12.x or net.git, with veth/vxlan the
>> DODGE bit isn't set when looking on the skb in the vxlan xmit time, so there's
>> nothing for me to hack there. For VMs without unsetting the bit things don't
>> really work, but unsetting it for itself so far didn't get me far performance
>> wise.
>>
>> BTW guys, I saw the issues with both bridge/openvswitch configuration - seems
>> that we might have here somehow large breakage of the system w.r.t vxlan
>> traffic for rates that go over few Gbs -- so would love to get feedback of any
>> kind from the people that were involved with vxlan over the last months/year.
>>
>>

OK!! so finally I managed to get some hacked but stable ground to step 
on .... indeed  with 3.10.X (I tried 3.10.19) if you

1. reduce the VM PV NIC MTU to account for the vxlan tunneling overhead 
(e.g to 1450 vs 1500)
2. unset the DODGY bit for GSO packets in the vxlan driver 
handle_offloads function

--> You get sane vxlan performance when the VM xmits, without HW 
offloads I got up to 4-5 Gbs for single VM and with HW offloads > 30Gbs 
for single VM when the VM is sending to a peer hypervisor.

On VM RX side, it doesn't go too much higher, e.g stays in the order of 
3-4Gbs for single receiving VM, I am pretty sure this relates to the no 
GRO for vxlan which is pretty much terrible for VM traffic.

So it seems the TODO here is the following:

1. manage to get the hack for vm-vxlan traffic to work on the net tree
2. fix the bug that make the hack necessary
3. find the problem with veth-vxlan traffic on the net tree
4. add GRO support for encapsulated/vxlan traffic


Or.

Or.
