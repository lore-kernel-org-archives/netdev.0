From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 66691] New: iproute2: macvlan: Wrong root device shown if
 in different netns
Date: Fri, 6 Dec 2013 12:05:43 -0800
Message-ID: <20131206120543.0afaafb5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:39388 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758309Ab3LFUFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 15:05:47 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so1679459pbb.28
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 12:05:46 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id ql10sm5741059pbc.44.2013.12.06.12.05.45
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 06 Dec 2013 12:05:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This isn't a iproute2 bug, it is only reporting what the kernel tells it

Begin forwarded message:

Date: Fri, 6 Dec 2013 00:07:15 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 66691] New: iproute2: macvlan: Wrong root device shown if in different netns


https://bugzilla.kernel.org/show_bug.cgi?id=66691

            Bug ID: 66691
           Summary: iproute2: macvlan: Wrong root device shown if in
                    different netns
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: helmut.schaa@googlemail.com
        Regression: No

In the root net namespace if have the following devices:

> ip link
[...]
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP
mode DEFAULT group default qlen 1000
    link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
3: gre0: <NOARP> mtu 1476 qdisc noop state DOWN mode DEFAULT group default 
    link/gre 0.0.0.0 brd 0.0.0.0
[...]

Let's add a macvlan on top of eth0:

> ip link
[...]
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP
mode DEFAULT group default qlen 1000
    link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
3: gre0: <NOARP> mtu 1476 qdisc noop state DOWN mode DEFAULT group default 
    link/gre 0.0.0.0 brd 0.0.0.0
[...]
17: mac0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
DEFAULT group default 
    link/ether 46:aa:b4:fb:44:a6 brd ff:ff:ff:ff:ff:ff

And now lets move it into its own net namespace and list the devices in the new
namespace.

> ip link set mac0 netns myns
> ip netns exec myns ip link
[...]
2: gre0: <NOARP> mtu 1476 qdisc noop state DOWN mode DEFAULT group default 
    link/gre 0.0.0.0 brd 0.0.0.0
[...]
17: mac0@gre0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode
DEFAULT group default 
    link/ether 46:aa:b4:fb:44:a6 brd ff:ff:ff:ff:ff:ff

mac0 shows gre0 as its base device which is not correct. However gre0 has the
same ifindex in the new namespace as eth0 in the root namespace and the ifindex
is used for finding the base device.

commit aa79e66eee5d525e2fcbd2a5fcb87ae3dd4aa9e9 "net: Make ifindex generation
per-net namespace" changed the ifindex generation to only be unique within a
namespace.

-- 
You are receiving this mail because:
You are the assignee for the bug.
