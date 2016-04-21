From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: bridge not learning from locally sent gratuitous ARP?
Date: Thu, 21 Apr 2016 19:31:38 +0900
Message-ID: <5718AC0A.8090009@lab.ntt.co.jp>
References: <CAJ26g5SKzs=+0MmanfC4Hfuti_jLo5R=e6T6imNc98rXVsA1ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Patrick Schaaf <netdev@bof.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:55314 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520AbcDULZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 07:25:46 -0400
In-Reply-To: <CAJ26g5SKzs=+0MmanfC4Hfuti_jLo5R=e6T6imNc98rXVsA1ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/04/21 15:37, Patrick Schaaf wrote:
> Dear netdev,

Hi,

> 
> I've got a peculiar issue, and hope for clarification / workarounds here.
> 
> Scenario:
> - a bridge interface br0, over some ethernet base
> - a macvlan interface br0-vrrp on top, set up by keepalived, with VRRP VMAC
> - keepalived regularly sending gratuitous ARP with that VRRP VMAC
> - (new) an additional tap interface in br0, for an openvpn link
> 
> In principle, everything is working fine. The base keepalived setup
> has been in operation for a long time, running directly over a VLAN
> interface. The conversion to a bridge interface is also working
> without any issues by itself. The additional tap to openvpn, and the
> VPN setup it realizes, is also working fine, in principle...
> 
> Issue:
> - openvpn runs at 100% CPU ....
> - because it it sent all packets destined to the VRRP VMAC
> - because that VMAC is not in the br0 learned MAC address table (brctl showmacs)
> - thus the (production webserver outbound...) traffic is flooded to
> all br0 ports
> 
> Diagnosis I did so far:
> - with tcpdump, verified that I can see the gratuitous ARPs on both the macvlan
>   and bridge interface.
> - verified that "brctl showmacs" does not contain the VRRP VMAC
> - identical setup for a different VLAN with almost no traffic to the
> VMAC, has openvpn running without the huge CPU consumption
> - straced the openvpn daemon with the issue, seeing the packet rate
> expected as tap reads / sends to the remote site
> 
> Kernel:
> 3.14.48 (vanilla)
> keepalived 1.2.13 (with repeated gratuitous ARP support patched in)
> 
> Can anybody shed a light on how to cope with this issue?

(I understand the problem happens only if you use macvlan on the bridge
device. If wrong, correct me.)

Please use "bridge fdb show" instead of "brctl showmacs". brctl is an
old tool and has limitation in showing fdb entries.

I guess your bridge doesn't have the mac address of the macvlan device
in its fdb. If you can confirm that by bridge command, then add an entry
by hand.

# bridge fdb add <addr of macvlan> dev <brport> master
<brport> can be any device that belongs to the bridge.
This command (without "temp" option) installs an fdb entry that forwards
frames to the bridge device.


Some more analysis:
- bridge adds the fdb entry of br0 mac address permanently. bridge never
learns source mac addresses of frames sent from br0.
- bridge seems not to have an ability to propagate the mac address of
its upper device into fdb.
- vlan device has the same mac address as its real device by default, so
it does not cause the problem.

-- 
Toshiaki Makita
