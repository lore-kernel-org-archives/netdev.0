From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 196093] New: dot1q S-VLAN frame on dot1ad configured
 interface is accepted
Date: Fri, 16 Jun 2017 08:40:01 -0700
Message-ID: <20170616084001.711f687c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35618 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751948AbdFPPkK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 11:40:10 -0400
Received: by mail-pg0-f48.google.com with SMTP id k71so21887127pgd.2
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 08:40:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I suspect that VLAN offload on this Intel NIC is allowing any of the VLAN types.

Begin forwarded message:

Date: Fri, 16 Jun 2017 15:33:35 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 196093] New: dot1q S-VLAN frame on dot1ad configured interface is accepted


https://bugzilla.kernel.org/show_bug.cgi?id=196093

            Bug ID: 196093
           Summary: dot1q S-VLAN frame on dot1ad configured interface is
                    accepted
           Product: Networking
           Version: 2.5
    Kernel Version: 3.16.0 and 4.9.0
          Hardware: Intel
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: jason-kernelbugzilla@lixfeld.ca
        Regression: No

Using the following configuration on an Intel 82599 port.  Tested in Debian 8
with Kernel 3.16.0 and 4.9.0:

ip link set dev eth4 up
ip link add link eth4 eth4.100ad type vlan proto 802.1ad id 100
ip link add link eth4.100ad eth4.100ad.10q type vlan proto 802.1Q id 10
ip link set dev eth4 netns nni-ad
ip link set dev eth4.100ad netns nni-ad
ip link set dev eth4.100ad.10q netns nni-ad
ip netns exec nni-ad ip link set dev eth4 up
ip netns exec nni-ad ip link set dev eth4.100ad up
ip netns exec nni-ad ip link set dev eth4.100ad.10q up
ip netns exec nni-ad ip addr add 10.4.100.10/8 dev eth4.100ad.10q

Ping to 10.4.100.10 while doing tcpdump on eth4 shows the frame has ether type
0x8100 (dot1q) on the S-VLAN, not 0x88a8 (dot1ad), yet the frame is still
accepted, and an echo reply is generated.

The echo reply has the correct ethertype on the S-VLAN (0x88a8).  My
understanding is that if the frame received on the wire does not match the
ether type of the configured interface, the frame should be dropped?

17:44:05.608944 00:0c:bd:08:80:99 > 00:0c:bd:08:80:9a, ethertype 802.1Q
(0x8100), length 106: vlan 100, p 0, ethertype 802.1Q, vlan 10, p 0, ethertype
IPv4, 10.3.1.10 > 10.4.100.10: ICMP echo request, id 8919, seq 1, length 64
17:44:05.608983 00:0c:bd:08:80:9a > 00:0c:bd:08:80:99, ethertype 802.1Q-QinQ
(0x88a8), length 106: vlan 100, p 0, ethertype 802.1Q, vlan 10, p 0, ethertype
IPv4, 10.4.100.10 > 10.3.1.10: ICMP echo reply, id 8919, seq 1, length 64
17:44:06.608085 00:0c:bd:08:80:99 > 00:0c:bd:08:80:9a, ethertype 802.1Q
(0x8100), length 106: vlan 100, p 0, ethertype 802.1Q, vlan 10, p 0, ethertype
IPv4, 10.3.1.10 > 10.4.100.10: ICMP echo request, id 8919, seq 2, length 64
17:44:06.608119 00:0c:bd:08:80:9a > 00:0c:bd:08:80:99, ethertype 802.1Q-QinQ
(0x88a8), length 106: vlan 100, p 0, ethertype 802.1Q, vlan 10, p 0, ethertype
IPv4, 10.4.100.10 > 10.3.1.10: ICMP echo reply, id 8919, seq 2, length 64
17:44:07.608080 00:0c:bd:08:80:99 > 00:0c:bd:08:80:9a, ethertype 802.1Q
(0x8100), length 106: vlan 100, p 0, ethertype 802.1Q, vlan 10, p 0, ethertype
IPv4, 10.3.1.10 > 10.4.100.10: ICMP echo request, id 8919, seq 3, length 64
17:44:07.608102 00:0c:bd:08:80:9a > 00:0c:bd:08:80:99, ethertype 802.1Q-QinQ
(0x88a8), length 106: vlan 100, p 0, ethertype 802.1Q, vlan 10, p 0, ethertype
IPv4, 10.4.100.10 > 10.3.1.10: ICMP echo reply, id 8919, seq 3, length 64
17:44:08.608078 00:0c:bd:08:80:99 > 00:0c:bd:08:80:9a, ethertype 802.1Q
(0x8100), length 106: vlan 100, p 0, ethertype 802.1Q, vlan 10, p 0, ethertype
IPv4, 10.3.1.10 > 10.4.100.10: ICMP echo request, id 8919, seq 4, length 64
17:44:08.608109 00:0c:bd:08:80:9a > 00:0c:bd:08:80:99, ethertype 802.1Q-QinQ
(0x88a8), length 106: vlan 100, p 0, ethertype 802.1Q, vlan 10, p 0, ethertype
IPv4, 10.4.100.10 > 10.3.1.10: ICMP echo reply, id 8919, seq 4, length 64
17:44:09.608090 00:0c:bd:08:80:99 > 00:0c:bd:08:80:9a, ethertype 802.1Q
(0x8100), length 106: vlan 100, p 0, ethertype 802.1Q, vlan 10, p 0, ethertype
IPv4, 10.3.1.10 > 10.4.100.10: ICMP echo request, id 8919, seq 5, length 64
17:44:09.608121 00:0c:bd:08:80:9a > 00:0c:bd:08:80:99, ethertype 802.1Q-QinQ
(0x88a8), length 106: vlan 100, p 0, ethertype 802.1Q, vlan 10, p 0, ethertype
IPv4, 10.4.100.10 > 10.3.1.10: ICMP echo reply, id 8919, seq 5, length 64

-- 
You are receiving this mail because:
You are the assignee for the bug.
