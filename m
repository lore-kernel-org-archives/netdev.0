From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 74991] New: rp_filter is dropping icmp unreach
Date: Mon, 28 Apr 2014 17:25:08 -0700
Message-ID: <20140428172508.7952555c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:59263 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932702AbaD2AZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 20:25:11 -0400
Received: by mail-pa0-f53.google.com with SMTP id ld10so6387777pab.40
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 17:25:10 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id ss2sm99521351pab.8.2014.04.28.17.25.10
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 17:25:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 28 Apr 2014 06:16:13 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 74991] New: rp_filter is dropping icmp unreach


https://bugzilla.kernel.org/show_bug.cgi?id=74991

            Bug ID: 74991
           Summary: rp_filter is dropping icmp unreach
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.32
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: low
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: cport@openadvice.de
        Regression: No

if rp_filter is enabled some ICMP messages may get dropped by checking the
wrong IP address information.

Setup:
Host - GW1 - GW2 - Server
The host has IP 192.168.1.1/24 and only a single route to 10.1.1.0/24 via its
gateway gw1, there is no default route. rp_filter is set to 1.
GW1 links to GW2 on link 172.16.1.0/24
GW2 has IP address 172.16.1.2 pointing to GW1 and 10.1.1.1 pointing to server,
MTU on link 10.1.1.1 is 1400.
Server has IP 10.1.1.2

Now the host is sending a packet with MTU 1500 to the server:
192.168.1.1 -> 10.1.1.2
GW1 is passing the packet to GW2
GW2 is checking the packet and reject it because of the MTU of the outgoing
link. The generated packet is 172.16.1.2 -> 192.168.1.1 ICMP fragmentation
needed with the original packet header in payload.
GW1 is passing the packet to host.
Host is checking the packet and dropping by rp_filter, because the sender IP
address is not in the routing table. This is a wrong behavior. The rp_filter
routine should in this case check the IP contained in the payload of the ICMP
unreach packet because the packet is related caused by the 192.168.1.1 ->
10.1.1.2 packet and relates to this session. If rp_filter drop this ICMP the
MTU-path-discovery gets broken. There is no need to route all transfer networks
in a provider cloud, but the related ICMP unreachable messages should pass the
filter.

Regards
Christian

-- 
You are receiving this mail because:
You are the assignee for the bug.
