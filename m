From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP funny-ness when over-driving a 1Gbps link (and wifi)
Date: Fri, 20 May 2011 14:33:16 -0700
Message-ID: <4DD6DE1C.8090607@candelatech.com>
References: <4DD59DF2.2070707@candelatech.com>	 <20110519161827.2ba4b40e@nehalam> <4DD5A5CD.7040303@candelatech.com>	 <4DD5AAFC.8070509@candelatech.com> <1305849940.8149.1122.camel@tardy>	 <4DD5B202.7080701@candelatech.com> <1305851079.8149.1127.camel@tardy>	 <4DD5B7B3.2000505@candelatech.com> <1305852377.8149.1133.camel@tardy> <4DD5E270.3030209@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56726 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab1ETVdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 17:33:20 -0400
In-Reply-To: <4DD5E270.3030209@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2011 08:39 PM, Ben Greear wrote:
> On 05/19/2011 05:46 PM, Rick Jones wrote:
>> On Thu, 2011-05-19 at 17:37 -0700, Ben Greear wrote:
>>> On 05/19/2011 05:24 PM, Rick Jones wrote:
>>>>>>> [root@i7-965-1 igb]# netstat -an|grep tcp|grep 8.1.1
>>>>>>> tcp 0 0 8.1.1.1:33038 0.0.0.0:* LISTEN
>>>>>>> tcp 0 0 8.1.1.1:33040 0.0.0.0:* LISTEN
>>>>>>> tcp 0 0 8.1.1.1:33042 0.0.0.0:* LISTEN
>>>>>>> tcp 0 9328612 8.1.1.2:33039 8.1.1.1:33040 ESTABLISHED
>>>>>>> tcp 0 17083176 8.1.1.1:33038 8.1.1.2:33037 ESTABLISHED
>>>>>>> tcp 0 9437340 8.1.1.2:33037 8.1.1.1:33038 ESTABLISHED
>>>>>>> tcp 0 17024620 8.1.1.1:33040 8.1.1.2:33039 ESTABLISHED
>>>>>>> tcp 0 19557040 8.1.1.1:33042 8.1.1.2:33041 ESTABLISHED
>>>>>>> tcp 0 9416600 8.1.1.2:33041 8.1.1.1:33042 ESTABLISHED
>>>>>>
>>>>>> I take it your system has higher values for the tcp_wmem value:

I tried a different test today:  3 TCP connections between two
wifi station interfaces (using ath9k).  Each connection is
endpoint configured to send 100Mbps of traffic to the peer.

With a single connection, it does OK (maybe 250ms round-trip time max).
With 3 of them running, round-trip user-space to user-space latency
often goes above 3 seconds.

I had set tcp_wmem smaller for this test, and I verified that
the socket SND/RCV buffer setsockopt was not being called.

[root@lec2010-ath9k-1 lanforge]# netstat -an|grep tcp|grep 33
tcp        0      0 12.12.12.4:33040            0.0.0.0:*                   LISTEN
tcp        0      0 12.12.12.4:33042            0.0.0.0:*                   LISTEN
tcp        0      0 12.12.12.4:33044            0.0.0.0:*                   LISTEN
tcp        0 556072 12.12.12.4:33040            12.12.12.3:33039            ESTABLISHED
tcp        0 274916 12.12.12.3:33043            12.12.12.4:33044            ESTABLISHED
tcp        0      0 192.168.100.138:33738       192.168.100.3:2049          ESTABLISHED
tcp        0 205156 12.12.12.4:33042            12.12.12.3:33041            ESTABLISHED
tcp        0 217184 12.12.12.3:33041            12.12.12.4:33042            ESTABLISHED
tcp        0 436552 12.12.12.3:33039            12.12.12.4:33040            ESTABLISHED
tcp        0 288820 12.12.12.4:33044            12.12.12.3:33043            ESTABLISHED

[root@lec2010-ath9k-1 lanforge]# cat /proc/sys/net/ipv4/tcp_wmem
4096	16384	4000000

This is 2.6.39-wl+ kernel.

So, seems a general issue with over-driving links with multiple TCP connections.
Doesn't seem like a regression, and probably not really a bug, but maybe the
buffer-bloat project will help this sort of thing...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

