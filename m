From: Daniel Borkmann <dborkman@redhat.com>
Subject: Fwd: [Bug 89161] New: Regression in bonding driver with devices that
 have no MAC address
Date: Tue, 02 Dec 2014 11:56:46 +0100
Message-ID: <547D9AEE.6050102@redhat.com>
References: <bug-89161-65011@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@gmail.com
To: tjc@wintrmute.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52128 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751021AbaLBK4w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2014 05:56:52 -0500
In-Reply-To: <bug-89161-65011@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-------- Original Message --------
Subject: [Bug 89161] New: Regression in bonding driver with devices that have no MAC address
Date: Tue, 02 Dec 2014 10:14:56 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: dborkman@redhat.com

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
You are watching the assignee of the bug.
