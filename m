From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 70151] New: redundant GRE tunnel on same interface not
 brought down when gre link is downed
Date: Fri, 7 Feb 2014 17:21:30 -0700
Message-ID: <20140207172130.54cf1f7d@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:56454 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbaBHAVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 19:21:34 -0500
Received: by mail-pa0-f47.google.com with SMTP id kp14so3844039pab.34
        for <netdev@vger.kernel.org>; Fri, 07 Feb 2014 16:21:34 -0800 (PST)
Received: from samsung-9 (ip01.wsr-guests.simplybits.net. [64.119.35.90])
        by mx.google.com with ESMTPSA id it4sm17634477pbc.39.2014.02.07.16.21.33
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Feb 2014 16:21:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 6 Feb 2014 07:19:48 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 70151] New: redundant GRE tunnel on same interface not brought down when gre link is downed


https://bugzilla.kernel.org/show_bug.cgi?id=70151

            Bug ID: 70151
           Summary: redundant GRE tunnel on same interface not brought
                    down when gre link is downed
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10.0+
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: tbeadle@gmail.com
        Regression: No

Say I have two IP's assigned to an interface (either a physical interface or an
802.1q sub-interface) and I create two gre interface, using each of the IP
addresses assigned above as the local endpoint.  I can send GRE keepalives to
either gre interface and a response is received.

Now if I bring one of the gre interfaces down and then send a keepalive to it,
a response is still received.  Not until I bring down the other interface also
do I stop getting responses.

Prior to the GRE/tunnel refactoring introduced in 3.10.0 (commit c5441932), the
keepalives to the downed gre interface would not elicit a response.  I have
tested kernels from 3.10.0 up through 3.13.0.

Steps to reproduce:
- Assign 192.168.56.1/24 to eth0 on a machine to be used to send the keepalives
(SENDER).

- Assign 192.168.56.3/24 and 192.168.56.4/24 to eth0 on the device under test
(DUT).
ip addr add 192.168.56.3/24 dev eth0
ip addr add 192.168.56.4/24 dev eth0

- Bring up the 2 GRE interfaces on DUT.
ip tunnel add gre1 mode gre remote 192.168.56.1 local 192.168.56.3 ttl 255
ip link set gre1 up
sysctl -w net.ipv4.conf.gre1.accept_local=1
sysctl -w net.ipv4.conf.gre1.forwarding=1
sysctl -w net.ipv6.conf.gre1.forwarding=1
ip tunnel add gre2 mode gre remote 192.168.56.1 local 192.168.56.4 ttl 255
ip link set gre2 up
sysctl -w net.ipv4.conf.gre2.accept_local=1
sysctl -w net.ipv4.conf.gre2.forwarding=1
sysctl -w net.ipv6.conf.gre2.forwarding=1

- I used scapy on SENDER to generate a GRE keepalive packet to 192.168.56.3
(08:00:27:53:aa:c1 is the MAC address of eth0 on DUT):
>>> ip = IP(src='192.168.56.1', dst='192.168.56.3')
>>> pkt = Ether(dst='08:00:27:53:aa:c1')/ip/GRE()/IP(src=ip.dst, dst=ip.src)/GRE()
>>> sendp(pkt, iface='eth0')

- When issuing the sendp command, run "tcpdump -nvi eth0 proto gre" on SENDER. 
You should see the following request and reply:

22:24:09.608401 IP (tos 0x0, ttl 64, id 1, offset 0, flags [none], proto GRE
(47), length 48)
    192.168.56.1 > 192.168.56.3: GREv0, Flags [none], length 28
        IP (tos 0x0, ttl 64, id 1, offset 0, flags [none], proto GRE (47),
length 24)
    192.168.56.3 > 192.168.56.1: GREv0, Flags [none], length 4
        gre-proto-0x0
22:24:09.608879 IP (tos 0x0, ttl 63, id 1, offset 0, flags [none], proto GRE
(47), length 24)
    192.168.56.3 > 192.168.56.1: GREv0, Flags [none], length 4
        gre-proto-0x0

- On DUT, run "ip link set gre1 down" and do the sendp command again from
SENDER, watching the tcpdump output as well.  With kernels 3.10.0+, you'll
still see a response packet.  With earlier kernels, no response is sent, which
is the appropriate behavior.

Note that, with 3.10.0+, if you now run "ip link set gre2 down" and do the
sendp again, no response is sent.

-- 
You are receiving this mail because:
You are the assignee for the bug.
