From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 89161] New: Regression in bonding driver with devices that
 have no MAC address
Date: Tue, 2 Dec 2014 09:34:53 -0800
Message-ID: <20141202093453.42e7af86@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:49133 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976AbaLBRfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 12:35:05 -0500
Received: by mail-pa0-f45.google.com with SMTP id lj1so13817135pab.18
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 09:35:05 -0800 (PST)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id b1sm20962594pat.2.2014.12.02.09.35.03
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Dec 2014 09:35:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 2 Dec 2014 02:15:05 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 89161] New: Regression in bonding driver with devices that have no MAC address


https://bugzilla.kernel.org/show_bug.cgi?id=89161

            Bug ID: 89161
           Summary: Regression in bonding driver with devices that have no
                    MAC address
           Product: Networking
           Version: 2.5
    Kernel Version: 3.17.4
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: tjc@wintrmute.net
        Regression: No

In kernel 3.13 and earlier, a user could use the "bonding" network module to
enslave devices without MAC addresses, such as ppp devices, in certain modes
(such as balance-rr).

At some point between 3.13 and 3.17, this ability was removed -- even though
apparently a commit was made to specifically ALLOW this to happen:
https://github.com/torvalds/linux/commit/f54424412b6b2f64cae4d7c39d981ca14ce0052c


On kernel 3.13, this was printed to syslog upon enslaving ppp0:
bonding: bond0: Warning: The first slave device specified does not support
setting the MAC address. Setting fail_over_mac to active.
bonding: bond0: enslaving ppp0 as an active interface with an up link.

On kernel 3.17.2 and 3.17.4 (and probably others) instead this error comes up:
bond0: Adding slave ppp0
bond0: The slave device specified does not support setting the MAC address

And the slave is not added.


In case it was relevant, I resorted to manually creating the bond0 with
appropriate options (including fail_over_mac) preset, and yet the problem
persists.

To replicate the problem, setup at least one ppp connection, and then follow
these instructions:

    modprobe bonding
    echo '+bond0' > /sys/class/net/bonding_masters
    echo 'active' > /sys/class/net/bond0/bonding/fail_over_mac
    ifconfig bond0 down
    echo 'balance-rr' > /sys/class/net/bond0/bonding/mode
    ifconfig bond0 202.xx.xx.xx netmask 255.255.255.255 mtu 1492 up
    echo '500' > /sys/class/net/bond0/bonding/miimon

    ifconfig ppp0 down
    echo '+ppp0' > /sys/class/net/bond0/bonding/slaves


Under earlier kernel versions, that would work -- but current stable kernels
fail.

-- 
You are receiving this mail because:
You are the assignee for the bug.
