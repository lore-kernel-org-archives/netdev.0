From: Andreas Seelinger <Andreas.Seelinger@rwth-aachen.de>
Subject: [Fwd: Problem with arp request caching]
Date: Thu, 16 Sep 2010 17:21:27 +0200
Message-ID: <1284650487.1858.105.camel@andsee-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:61593 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754481Ab0IPPVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 11:21:30 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0L8U00ABHINTD300@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Thu, 16 Sep 2010 17:21:29 +0200 (CEST)
Received: from [137.226.59.250] ([unknown] [137.226.59.250])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0L8U00FI4INT2660@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Thu, 16 Sep 2010 17:21:29 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

imagine the following scenario:
	Node A(ath0 ip: 172.16.1.5 | ath1 ip: 10.0.1.5)
	Node B(ath0 ip: 172.16.1.6)
	Node C(ath0 ip: 10.0.1.7)

	Node A <-(ath0)-> Node B
	Node A <-(ath1)-> Node C

Node A has no Arp table entries for both nodes.

Actual behavior of two fast ping from Node A to Node C, which looks like
this is a failure of both ping. Even if the second ping SHOULD be
successful.
        [ping -I 172.16.1.5 -c 1 -W 1 10.0.1.7; ping -c 1 10.0.1.7;]

The first ping forces three arp request to Node C (device ath1)
        [arp who-has 10.0.1.7 tell 172.16.1.5 hardware #778]
        
All three arp requests cannot be answered by Node C, because it does not
know the IP 172.16.1.5 of Node A. And so the first ping fails.

The second ping should lead to an successful arp request, BUT no
arp request with the source address "10.0.1.5" is sent (because
ARP cache contains a FAIL?)

If I increase the time between the two pings, than the second ping is
successful (probably because the ARP entry timed out)
   [ping -I 172.16.1.5 -c 1 -W 5 10.0.1.7; ping -c 1 10.0.1.7;]

Expected behavior would be that the host will redo the ARP request,
if the packet has a different source address. In this case a new 
arp request should be performed if the cached one is invalid.

Comments?

Thanks
	Andreas
        


