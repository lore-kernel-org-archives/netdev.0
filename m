From: John Hughes <john@calva.com>
Subject: Re: When a TCP segment is split up (to be sent through a TUN device
 with a small MTU) who should recalculate the checksum?
Date: Fri, 15 Nov 2013 15:02:08 +0100
Message-ID: <52862960.6090408@calva.com>
References: <5285E0BC.4090402@atlantech.com> <1384520815.28716.63.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Hughes <john@atlantech.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from olympic.calvaedi.com ([89.202.194.163]:47603 "EHLO
	olympic.calvaedi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807Ab3KOOQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 09:16:43 -0500
In-Reply-To: <1384520815.28716.63.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/11/13 14:06, Eric Dumazet wrote:
> On Fri, 2013-11-15 at 09:52 +0100, John Hughes wrote:
>> I have two offices, joined by a OpenVPN tunnel.  I've upgraded the
>> kernels in the machines running the tunnel to 3.10.  All of a sudden I'm
>> getting horrible transmission delays between the two offices.
>>
>> office1 LAN--------office1 tunnel machine
>>                               |
>>                               | openvpn tunnel
>>                               |
>>                       office2 tunnel machine------office2 LAN
>>                                     
>>
>> What seems to be happening is that packets are arriving at the LAN
>> interface of the machine running the tunnel and being combined by
>> generic-receive-offload.  These packets then have to be split up again
>> as they are too big for the tunnels MTU.
>>
>> But when the packets are split the TCP checksum doesn't seem to be being
>> recalculated, so the systems on the other end of the tunnel ignore them,
>> forcing many retries and the observed delays.
>>
>>
> Thanks for the report
>
> It depends on the offload capabilities of the NIC forwarding packets

The NIC is a kernel tun device.
>
> ethtool -k eth0

# ethtool -k tun1
Features for tun1:
rx-checksumming: off [fixed]
tx-checksumming: off
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: off [requested on]
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
...

It seems someone has asked the tunnel to compute checksums 
(tx-checksum-ip-generic), but it can't do that.


>
> TCP checksums can be recomputed by tcp_gso_segment() (it was named
> tcp_tso_segment() in linux 3.10), unless the NIC told it was doing the
> checksum computation itself.
>
> ethtool -K eth0 tx off
>
> Should request stack to perform the cheksums.
>
> What is the NIC doing the transmits ?
>
>
>
