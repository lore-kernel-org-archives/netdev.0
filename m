From: Chris Friesen <chris.friesen@genband.com>
Subject: [BUG] problems with "ip xfrm" on 32-bit userspace with 64-bit kernel
Date: Wed, 20 Oct 2010 17:18:14 -0600
Message-ID: <4CBF78B6.90002@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We've run into a 32/64 compatibility problem with iproute2.  The "ip
xfrm monitor acquire" command doesn't work properly due to struct size
mismatches between kernel and userspace.

If I modify include/linux/xfrm.h to pack all the structures and rebuild
the kernel and userspace, this message is displayed properly.  However,
this shouldn't be necessary and might not work on all architectures.

Anyone got any ideas that are less drastic?

Thanks,
Chris



Details:

iproute2-2.6.35.tar.bz2 package (the "ip" binary reports a version of
iproute2-ss100804)

2.6.27.18 kernel, ARCH is x86, kernel is 64-bit, userspace is 32-bit.



To reproduce:

1.  Find a src and dst IP address that normally passes a ping test

ping -I 172.25.0.4 172.25.132.1


2.  Setup a single outgoing IPsec policy that will require an IPsec SA
on the next ping packet.

setkey -c << EOF
spdadd 172.24.132.4/32[any] 172.24.136.0/32[any] any -P out ipsec
esp/transport//unique:1;
EOF


3.  In a separate window/terminal, launch the following command to
monitor Netlink messages from the kernel

ip xfrm monitor acquire


4.  Send a ping packet (this command will block, or fail depending on
your kernel config)

ping -I 172.25.0.4 172.25.132.1


5.  The "ip xfrm monitor acquire" command displays something similar to
this:

!!!Deficit 72, rta_len=1
acquire proto esp
  sel src 172.25.0.4/32 dst 172.25.132.1/32 proto udp sport 44136 dport 1025
  policy src 172.25.0.4/32 dst 172.25.132.1/32
        dir out priority 2147483648 ptype main

6.  The "!!!Deficit 72, rta_len=1" string at the beginning of the
message is complaining about mismatches between the total reported
length of the Netlink message and the useable length detected.   Also,
the ACQUIRE message is incomplete as shown--there are attributes such as
the reqId value that are not displayed.

7. Now clean up after yourself and take down the ipsec policy:

setkey -c << EOF
spddelete 172.24.132.4/32[any] 172.24.136.0/32[any] any -P out ipsec
esp/transport//unique:1;
EOF



-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
