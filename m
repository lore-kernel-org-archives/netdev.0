From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: SRIOV as bridge Re: [PATCH net-next RESEND] net: Do not call
 ndo_dflt_fdb_dump if ndo_fdb_dump is defined.
Date: Mon, 22 Dec 2014 07:10:27 -0500
Message-ID: <54980A33.6000801@mojatatu.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com> <54902E5E.2070405@mojatatu.com> <54905F67.2090509@gmail.com> <5496D8E2.1090700@mojatatu.com> <54971A93.6050700@cumulusnetworks.com> <54971D2F.1090802@mojatatu.com> <54972140.30704@cumulusnetworks.com> <54972859.7050108@mojatatu.com> <549731A1.3090307@cumulusnetworks.com> <54978C3C.4
 040102@mojatatu.com> <5497B916.1020605@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:48440 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754684AbaLVMKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 07:10:32 -0500
Received: by mail-ig0-f172.google.com with SMTP id hl2so3838500igb.17
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 04:10:31 -0800 (PST)
In-Reply-To: <5497B916.1020605@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/14 01:24, Roopa Prabhu wrote:
> On 12/21/14, 7:13 PM, Jamal Hadi Salim wrote:

>> For SRIOV it is. Example to add via pf eth10 an
>> fdb entry to the igb hardware fdb to point to vf1:
>> ip link set eth10 vf 1 mac aa:bb:cc:dd:ee:ff vlan 10
>> That last part "vf 1 mac aa:bb:cc:dd:ee:ff vlan 10" is typically
>> part of an "fdb add semantic" - but we explicitly call out
>> eth10, the parent. The PF has control of the hardware fdb.
>
> Ah......i did not know this syntax with 'ip link set'. thanks for
> pointing out.
> I always thought that you can still use 'bridge fdb add' for vfs.
> Curious why its not that way.
>

It was there before bridge command showed up. I think thats why
John feels it can be repaired. The main challenge is that most
of the time the VFs are "migrated" from host to VMs, so you cant
even list them on the host.
Actually you cant list them as netdevs (please someone
correct me if i am wrong). What you see are PCI devices.

 From my notes:
---
modprobe igb max_vfs=6
# lspci | grep 82576
0b:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Network 
Connection (rev 01)
0b:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Network 
Connection(rev 01)
0b:10.0 Ethernet controller: Intel Corporation 82576 Virtual Function 
(rev 01)
0b:10.1 Ethernet controller: Intel Corporation 82576 Virtual Function 
(rev 01)
..
...
....
---

And then you can tell qemu to use one of these devices as a network
device and holla it disappears from the host.

What you can do from the host side is tell the embedded hardware switch
to add an fdb which sends  packets to a VF using the above syntax (via
PF). I think PF as control interface to the VFs is a convinience issue.
It just happened to be there and could be used as the anchor.
This is why i was mapping it instead to theclassthingy which i think
is more generic.

>
>> So what do you do if the user sets either one of master/self and it
>> doesnt make sense?
>
> Am guessing it will continue to do what it does today. If there is no
> master or if there is master and the master does not support the op, it
> will return -EOPNOTSUPP. And, self does not make sense in cases where
> the port driver does not support the op. In which case again you will
> get a -EOPNOTSUPP. Have not thought through all the other cases yet.
>

So master is only valid if there is a software device parent?
Again note - none of these VFs are attached to a bridge today.
It doesnt seem to me like it even makes sense people want to
do that.
The PF could be and in such a case its master is the bridge.

cheers,
jamal
