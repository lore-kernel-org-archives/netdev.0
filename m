From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: sky2 hangs
Date: Thu, 1 Feb 2007 19:55:32 +0100
Message-ID: <20070201185532.GL13130@cip.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui03.informatik.uni-erlangen.de ([131.188.30.103]:57405 "EHLO
	faui03.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422963AbXBATWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 14:22:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
I have a sky2 network card in my intel mac mini. It stops working when I
do havy network load like watching a divx over http/sshfs. However if I
remove the driver module and load it again it works and even the tcp
connection doesn't get shutdown. I automated the above procedure using
a userland watchdog which basically does the same thing and is written
entirely by me, because the traditional watchdog wasn't that reliable
and did a lot of false positives:

        * Look every ten seconds if my default router is pingable (3
          pings, one has to get back).
                If it isn't the case I call network_fix script (it calls the
                script only once after a ping gets lost. To run the script again at least one
                ping has to arrive again)

                (mini) [~] cat /usr/local/sbin/fix_network
                #!/bin/bash

                export PATH=/bin:/usr/bin:/usr/sbin:/sbin

                rmmod sky2
                modprobe sky2
                ifdown eth0
                ifup eth0

                If after that no ping is received from the default
                router for another 90 seconds I tell init to reboot and
                stop feeding the kernel software watchdog.

        * My watchdog also checks if sshd process is running. If it is
          down for more than 100 seconds it reboots the machine, too.

Jan 27 22:35:35 mini watchdog-tg[4146]: No PONG received from 192.168.0.3 (failure 1 of 10)
Jan 27 22:35:35 mini watchdog-tg[4146]: Running fix_network script.
Jan 27 22:38:46 mini watchdog-tg[4146]: No PONG received from 192.168.0.3 (failure 1 of 10)
Jan 27 22:38:46 mini watchdog-tg[4146]: Running fix_network script.
Jan 27 22:44:17 mini watchdog-tg[4146]: No PONG received from 192.168.0.3 (failure 1 of 10)
Jan 27 22:44:17 mini watchdog-tg[4146]: Running fix_network script.
Jan 29 12:00:13 mini watchdog-tg[4146]: No PONG received from 192.168.0.3 (failure 1 of 10)
Jan 29 12:00:13 mini watchdog-tg[4146]: Running fix_network script.
Jan 29 19:18:59 mini watchdog-tg[4146]: No PONG received from 192.168.0.3 (failure 1 of 10)
Jan 29 19:18:59 mini watchdog-tg[4146]: Running fix_network script.
Jan 31 15:56:29 mini watchdog-tg[4146]: No PONG received from 192.168.0.3 (failure 1 of 10)
Jan 31 15:56:29 mini watchdog-tg[4146]: Running fix_network script.
Feb  1 08:56:57 mini watchdog-tg[4146]: No PONG received from 192.168.0.3 (failure 1 of 10)
Feb  1 08:56:57 mini watchdog-tg[4146]: Running fix_network script.

I have a question to this: I wonder why the Linux Kernel (no longer?)
increments the use counter of an ethernet driver (I saw it on sky2 and
e1000) when the interface is up, running and configured? I can unload
the sky2 driver without doing a 'ifconfig eth0 down' beforehand. Could
somone provide me with background on this fact?

With that everything works. If somone is interested in my userland
watchdog, just send me an E-Mail.

@Sam: I can provide you access to my hardware including root access via
the wifi driver so that you can debug this network driver lockup, if you
want to.

        Thomas
