From: Ben Greear <greearb@candelatech.com>
Subject: Send-to-self TCP connection hangs in 2.6.38-rc3.
Date: Mon, 07 Feb 2011 16:34:44 -0800
Message-ID: <4D508FA4.6090500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34669 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755396Ab1BHAep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 19:34:45 -0500
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p180Yi9l026028
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 7 Feb 2011 16:34:44 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm seeing something weird on the latest wireless-testing kernel
(I have some wifi hacks in here, but no modifications to the basic
networking system, no proprietary modules loaded.)
Wireless-testing is currently based on 2.6.38-rc3.
This has been happening for a while, but I'm not sure
exactly when it started.

I am sending-to-self across some virtual wifi stations.  UDP runs fine,
but TCP connections tend to hang after a while..often in only one
direction.

The ip rules seem right, I'm detecting no spurious link admin up/down.  I suspect
conn-tracking.  Notice that the dport and sport do not match the netstat output
in the entry marked 'UNREPLIED'.  What sort of thing could cause that?

Here's some conntrack output for a broken connection:

ipv4     2 tcp      6 299 ESTABLISHED src=33.1.2.35 dst=33.1.2.32 sport=33381 dport=33382 src=33.1.2.32 dst=33.1.2.35 sport=33382 dport=33381 [ASSURED] mark=0 
zone=0 use=2
ipv4     2 tcp      6 431687 ESTABLISHED src=33.1.2.32 dst=33.1.2.35 sport=33194 dport=33193 [UNREPLIED] src=33.1.2.35 dst=33.1.2.32 sport=33193 dport=33194 
mark=0 zone=0 use=2
ipv4     2 udp      17 179 src=33.1.2.35 dst=33.1.2.32 sport=33381 dport=33382 src=33.1.2.32 dst=33.1.2.35 sport=33382 dport=33381 [ASSURED] mark=0 zone=0 use=2

The 33.1.2.32 side seems unable to send to the peer, though the peer can send to .32

[root@lec2010-ath9k-1 lanforge]# netstat -an|grep 1.2.32
tcp        0      0 33.1.2.32:33382             0.0.0.0:*                   LISTEN
tcp        0   5852 33.1.2.32:33382             33.1.2.35:33381             ESTABLISHED
tcp        0      0 33.1.2.35:33381             33.1.2.32:33382             ESTABLISHED
udp        0      0 33.1.2.32:33382             0.0.0.0:*
udp        0      0 33.1.2.32:123               0.0.0.0:*

Here's the same connection after re-starting it.  It appears to be passing traffic
properly.

[root@lec2010-ath9k-1 lanforge]# netstat -an|grep 1.2.32
tcp        0      0 33.1.2.32:33480             0.0.0.0:*                   LISTEN
tcp        0      0 33.1.2.35:33479             33.1.2.32:33480             ESTABLISHED
tcp        0      0 33.1.2.32:33480             33.1.2.35:33479             ESTABLISHED
udp        0      0 33.1.2.32:123               0.0.0.0:*
udp        0      0 33.1.2.32:33484             0.0.0.0:*
[root@lec2010-ath9k-1 lanforge]# cat /proc/net/nf_conntrack|grep 1.2.32
ipv4     2 udp      17 179 src=33.1.2.35 dst=33.1.2.32 sport=33483 dport=33484 src=33.1.2.32 dst=33.1.2.35 sport=33484 dport=33483 [ASSURED] mark=0 zone=0 use=2
ipv4     2 tcp      6 430352 ESTABLISHED src=33.1.2.32 dst=33.1.2.35 sport=33194 dport=33193 [UNREPLIED] src=33.1.2.35 dst=33.1.2.32 sport=33193 dport=33194 
mark=0 zone=0 use=2
ipv4     2 udp      17 161 src=33.1.2.35 dst=33.1.2.32 sport=33381 dport=33382 src=33.1.2.32 dst=33.1.2.35 sport=33382 dport=33381 [ASSURED] mark=0 zone=0 use=2
ipv4     2 tcp      6 431999 ESTABLISHED src=33.1.2.35 dst=33.1.2.32 sport=33479 dport=33480 src=33.1.2.32 dst=33.1.2.35 sport=33480 dport=33479 [ASSURED] 
mark=0 zone=0 use=2



Here's a connection that had been running for several minutes and seems
to have been passing traffic fine.  I'm not sure about what the
CLOSE_WAIT thing is...

[root@lec2010-ath9k-1 lanforge]# netstat -an|grep 1.2.20
tcp        0      0 33.1.2.18:33362             33.1.2.20:33361             ESTABLISHED
tcp        1      0 33.1.2.18:33202             33.1.2.20:33201             CLOSE_WAIT
tcp        0      0 33.1.2.20:33361             33.1.2.18:33362             ESTABLISHED
udp        0      0 33.1.2.20:33361             0.0.0.0:*
udp        0      0 33.1.2.20:123               0.0.0.0:*
[root@lec2010-ath9k-1 lanforge]# cat /proc/net/nf_conntrack|grep 1.2.20
ipv4     2 tcp      6 431999 ESTABLISHED src=33.1.2.20 dst=33.1.2.18 sport=33361 dport=33362 src=33.1.2.18 dst=33.1.2.20 sport=33362 dport=33361 [ASSURED] 
mark=0 zone=0 use=2
ipv4     2 udp      17 178 src=33.1.2.20 dst=33.1.2.18 sport=33361 dport=33362 src=33.1.2.18 dst=33.1.2.20 sport=33362 dport=33361 [ASSURED] mark=0 zone=0 use=2


I'll be happy to provide more details..just ask.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

