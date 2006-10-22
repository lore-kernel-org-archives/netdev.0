From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 7398] New: Preferred source address selection
 ("src" field) broken with multicast addresses
Date: Sun, 22 Oct 2006 11:40:20 -0700
Message-ID: <20061022114020.3b5a6042.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, linkfanel@yahoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:47082 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750782AbWJVSka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2006 14:40:30 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Sun, 22 Oct 2006 05:28:33 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 7398] New: Preferred source address selection ("src" field) broken with multicast addresses


http://bugzilla.kernel.org/show_bug.cgi?id=7398

           Summary: Preferred source address selection ("src" field) broken
                    with multicast addresses
    Kernel Version: 2.6.18
            Status: NEW
          Severity: low
             Owner: shemminger@osdl.org
         Submitter: linkfanel@yahoo.fr


Most recent kernel where this bug did not occur: unchecked
Distribution: Debian (unstable)
Hardware Environment: Pentium IV/M/MMX
Software Environment: iproute2-ss060323, VLC 0.8.6 Janus

Problem Description:
Output packets to a multicast destination address are not routed properly if 
the matched route features a preferred source address "src" field: packets are 
output through the device corresponding to the "src" field, instead of the 
device that would normally be used.

Steps to reproduce:
(0. Assume eth0 is up and working.)
1. Set up another interface, for instance:
modprobe dummy
ip ad add 10.0.0.1 dummy0
ip link set dummy0 up
2. Set up a route with source address preference:
ip ro add 239.255.1.2 dev eth0 src 10.0.0.1
3. Send packets to multicast address, for instance:
vlc -Irc la_question.mp3 --sout '#std{access=udp,mux=ts,dst=239.255.1.2:1234}'

Packets will go out through dummy0 instead of expected eth0.

Interestingly enough, net/ipv4/route.c contains the following (from line 2419):

        if (oldflp->oif == 0
            && (MULTICAST(oldflp->fl4_dst) || oldflp->fl4_dst == 0xFFFFFFFF)) {
            /* Special hack: user can direct multicasts
               and limited broadcast via necessary interface
               without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
               This hack is not just for fun, it allows
               vic,vat and friends to work.
               They bind socket to loopback, set ttl to zero
               and expect that it will work.
               From the viewpoint of routing cache they are broken,
               because we are not allowed to build multicast path
               with loopback source addr (look, routing cache
               cannot know, that ttl is zero, so that packet
               will not leave this host and route is valid).
               Luckily, this hack is good workaround.
             */

            fl.oif = dev_out->ifindex;
            goto make_route;
        }

Commenting that code out gets the kernel to route packets back in the expected 
way (that is, in the previous example, through eth0 with source address 
10.0.0.1).

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
