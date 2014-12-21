From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: SRIOV as bridge Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump
 if ndo_fdb_dump is defined.
Date: Sun, 21 Dec 2014 09:27:46 -0500
Message-ID: <5496D8E2.1090700@mojatatu.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com> <54902E5E.2070405@mojatatu.com> <54905F67.2090509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:54724 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbaLUO1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 09:27:50 -0500
Received: by mail-ie0-f182.google.com with SMTP id x19so3176902ier.13
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2014 06:27:49 -0800 (PST)
In-Reply-To: <54905F67.2090509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry for the latency, Ive been down with a bad flu (its bad when i cant
type on my keyboard sitting infront of me;->),  recovering and the
thread seems to have caught on - should be able to catchup in the
next few days.
I am beginning to reach a conclusion that the current switchdev approach
is *not* going to work for SRIOV. I also worry it may be too late
to change that.
Shrijeet wanted to set up a BOF for netdev to have hopefully final 
consensus. Shrijeet, are you going to make an official request for the BOF?

Sorry John, I dont have enough energy to address all your points but i
will try to just focus on SRIOV and will save a few bytes while at it.


On 12/16/14 11:35, John Fastabend wrote:

> But in the SR-IOV case you have multiple "Cpu ports" and you want
> to send packets to each of them depending on the configuration.
>
>
>     port0   port1     port2  port3
>      |        |        |      |      uplinks
>   +------------------------------+
>   |                              |
>   |       SRIOV edge relay       |
>   |                              |
>   +------------------------------+
>                   |                   downlink
>
>

Two points above:
1) Did you flip uplink vs down link above?
(I Thought URP was the wire link)
2) What you are not showing above which is *very important* is that
infact there is an underlying embedded fdb.

point #2 brings out a lot of the weird things in some of the bridge
code. IOW, you have an *offloaded* bridge with _bridge ports_
visible in the kernel but not the bridge that is controlled
by standard Linux bridge tools. I am not saying that the model is
wrong; on the contrary what Ben had exposed may fall under the
same category i.e you have E_BRIDGE flag on the netdev to say it sits
on top of an offloaded bridge and you dont need a br0 to run
bridge command on. But then we need some proxy (TheClassThingy) to act
as intemediary to the offloaded hardware.
If you do that then the vf becomes simply a bridge port - which
means bridge port ops apply.

SRIOV it seems to have morphed its own toolkit.
The PF port, when acting as the control interface, is actually
TheClassThingy we discuss on/off.
To add an fdb entry to point to vf 1, where TheClassThingy is eth1:
ip link set eth1 vf 1 mac aa:bb:cc:dd:ee:ff vlan 10

IMO, SRIOV should expose these ports with names and ifindices
(probably does already) and pre-populated master or something
which points to its parent, then i can do the following:
bridge fdb add aa:bb:cc:dd:ee:ff vlan 10 dev vf1 master

master in such a case will go to TheClassThingy which would pass
such control to the underlying hardware.
The PF still stays but not as the management interface.

Ok, promised to keep this short ;-> I should respond to the other points
in a separate email.

cheers,
jamal
