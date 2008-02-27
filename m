From: Nathan Grennan <linux-netdev@cygnusx-1.org>
Subject: Re: sky2 0000:02:00.0: error interrupt status=0x8
Date: Tue, 26 Feb 2008 20:37:32 -0800
Message-ID: <47C4E90C.3090600@cygnusx-1.org>
References: <47C4CB57.2060004@cygnusx-1.org> <20080226194818.1ee41099@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from okcforum.org ([69.17.49.173]:48245 "EHLO mail.okcforum.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753639AbYB0Ehd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 23:37:33 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.okcforum.org (Postfix) with ESMTP id 33F9952B167
	for <netdev@vger.kernel.org>; Tue, 26 Feb 2008 20:37:33 -0800 (PST)
Received: from mail.okcforum.org ([127.0.0.1])
	by localhost (okcforum.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id L23bipFyZjDi for <netdev@vger.kernel.org>;
	Tue, 26 Feb 2008 20:37:33 -0800 (PST)
Received: from proton.cygnusx-1.org (proton.cygnusx-1.org [69.17.49.61])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.okcforum.org (Postfix) with ESMTP id 12FC152B11B
	for <netdev@vger.kernel.org>; Tue, 26 Feb 2008 20:37:33 -0800 (PST)
In-Reply-To: <20080226194818.1ee41099@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 26 Feb 2008 18:30:47 -0800
> Nathan Grennan <linux-netdev@cygnusx-1.org> wrote:
>
>   
>>     I am using the sky2 driver in kernel-2.6.23.15-137.fc8.x86_64 with 
>> my Marvell 88E8056 to do iSCSI. I have many errors in dmesg like the 
>> ones below. If I count just the lines that match the first one, there 
>> are over 1500. If I include the suppressed lines it is over 100k. At 
>> first I got three of these doing something and then didn't see it for a 
>> while. I suspect the 100k came from a download of an 8gb file from the 
>> internet that was being written to the remote machine via iSCSI. The 
>> download took about an hour and fifteen minutes. I would ignore just 
>> three of these, but 100k of them suggests a real problem to me.
>>
>> sky2 0000:02:00.0: error interrupt status=0x8
>> printk: 77 messages suppressed.
>>     
>
> That status comes from the MAC getting an error.
> Most likely the receive FIFO is getting overrun. Look at the receive
> errors, RX fifo is probably non-zero.
>
> $ ip -s -s li show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
>     link/ether 00:00:5a:9b:0e:76 brd ff:ff:ff:ff:ff:ff
>     RX: bytes  packets  errors  dropped overrun mcast   
>     199873594  240394   0       0       0       0      
>     RX errors: length  crc     frame   fifo    missed
>                0        0       0       0       0      
>                                         ^
>
>
> Make sure and use hardware flow control if you are using jumbo frames because
> it is real easy to get the ram buffer full, and frames lost.
>
>   
I couldn't find mention of the flow control till I downed and upped the 
interface.

sky2 eth2: Link is up at 1000 Mbps, full duplex, flow control both


Yes, I do have fifo/overrun errors and the count is around the 100k 
mark, but not on RX. It is on TX.

ifconfig eth2
eth2      Link encap:Ethernet  HWaddr 00:18:F3:7C:38:5A 
          inet addr:192.168.254.1  Bcast:192.168.254.255  Mask:255.255.255.0
          inet6 addr: fe80::218:f3ff:fe7c:385a/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:9000  Metric:1
          RX packets:3196945 errors:69 dropped:69 overruns:2 frame:69
          TX packets:2930128 errors:0 dropped:0 overruns:111324 carrier:0
          collisions:0 txqueuelen:10000
          RX bytes:15313780678 (14.2 GiB)  TX bytes:14583689334 (13.5 GiB)
          Interrupt:17


ip -s -s li show dev eth2
6: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc pfifo_fast 
qlen 10000
    link/ether 00:18:f3:7c:38:5a brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast  
    2428878890 3196946  69      69      69      0     
    RX errors: length  crc     frame   fifo    missed
               0        0       0       2       0     
    TX: bytes  packets  errors  dropped carrier collsns
    1698787626 2930130  0       0       0       0     
    TX errors: aborted fifo    window  heartbeat
               0        111324  0       0     




I also notice I can't turn on TX checksumming. I can't turn on any of 
the others either, except generic segmentation offload.

ethtool -k eth2         
Offload parameters for eth2:
Cannot get device udp large send offload settings: Operation not supported
rx-checksumming: on
tx-checksumming: off
scatter-gather: off
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off



ethtool -K eth2 tx on
Cannot set device tx csum settings: Invalid argument
