From: Michael Smith <msmith@cbnco.com>
Subject: IPsec tunnel forwarding in net-next-2.6 since 452edd59
Date: Tue, 15 Mar 2011 14:30:44 -0400
Message-ID: <4D7FB054.2090902@cbnco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cbnco.com ([207.164.182.72]:58543 "EHLO smtp.cbnco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758283Ab1COSat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 14:30:49 -0400
Received: from localhost (localhost [127.0.0.1])
	by smtp.cbnco.com (Postfix) with ESMTP id 3A65CA9B02D
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 14:30:48 -0400 (EDT)
Received: from smtp.cbnco.com ([127.0.0.1])
 by localhost (mail.cbnco.com [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 08787-02 for <netdev@vger.kernel.org>;
 Tue, 15 Mar 2011 14:30:48 -0400 (EDT)
Received: from [172.20.22.83] (dmzgw2.cbnco.com [207.164.182.65])
	by smtp.cbnco.com (Postfix) with ESMTPSA id 8236BA9B027
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 14:30:45 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm able to ping across a tunnel to a peer running net-next-2.6, but 
only to an interface on the peer; trying to ping a host behind the peer 
fails. The incoming packet shows up in encrypted and decrypted form in 
tcpdump, but it's not forwarded. None of the XFRM error counters are 
incremented; the packets just silently fail to be forwarded.

There are no iptables rules and net.ipv4.ip_forward=1. The same config 
works on 2.6.38-rc8. git bisect pointed me to commit 452edd59 from March 2:

     xfrm: Return dst directly from xfrm_lookup()

     Instead of on the stack.


ip xfrm policy:

src 192.168.136.0/24 dst 192.168.137.0/24
         dir out priority 2344 ptype main
         tmpl src 1.1.1.136 dst 1.1.1.137
                 proto esp reqid 16385 mode tunnel

src 192.168.137.0/24 dst 192.168.136.0/24
         dir fwd priority 2344 ptype main
         tmpl src 1.1.1.137 dst 1.1.1.136
                 proto esp reqid 16385 mode tunnel

src 192.168.137.0/24 dst 192.168.136.0/24
         dir in priority 2344 ptype main
         tmpl src 1.1.1.137 dst 1.1.1.136
                 proto esp reqid 16385 mode tunnel

net-next-2.6 host is at 1.1.1.136 and 192.168.136.1. 2.6.35.10 host is 
at 1.1.1.137 and 192.168.137.1. From that host:

ping -I 192.168.137.1 192.168.136.1 -> success
ping -I 192.168.137.1 192.168.136.2 -> silent failure

Thanks,
Mike
