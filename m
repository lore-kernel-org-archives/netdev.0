From: Brad Campbell <lists2009@fnarfbargle.com>
Subject: commit : ppp: add rtnetlink device creation support - breaks netcf on
 my machine.
Date: Mon, 5 Dec 2016 17:06:31 +0800
Message-ID: <32208f70-4165-e79b-89ee-543eefaf40ef@fnarfbargle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: g.nault@alphalink.fr
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns3.fnarfbargle.com ([43.245.164.105]:47896 "EHLO
        ns3.fnarfbargle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751233AbcLEKFX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 05:05:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

G'day All,

I've been chasing an issue on and off for a couple of months now, and 
I've managed to finally find a way to reproduce and bisect it.

Machine is an old Debian (7.11) box with a recent compile of netcf. Any 
kernel later than 4.6.7 prevents ncftool from running if the ppp 
interface is up.

I'm using netcf-0.2.8, and this commit breaks it :

96d934c70db6e1bc135600c57da1285eaf7efb26 is the first bad commit
commit 96d934c70db6e1bc135600c57da1285eaf7efb26
Author: Guillaume Nault <g.nault@alphalink.fr>
Date:   Thu Apr 28 17:55:30 2016 +0200

     ppp: add rtnetlink device creation support

     Define PPP device handler for use with rtnetlink.
     The only PPP specific attribute is IFLA_PPP_DEV_FD. It is mandatory and
     contains the file descriptor of the associated /dev/ppp instance (the
     file descriptor which would have been used for ioctl(PPPIOCNEWUNIT) in
     the ioctl-based API). The PPP device is removed when this file
     descriptor is released (same behaviour as with ioctl based PPP
     devices).

     PPP devices created with the rtnetlink API behave like the ones created
     with ioctl(PPPIOCNEWUNIT). In particular existing ioctls work the same
     way, no matter how the PPP device was created.
     The rtnl callbacks are also assigned to ioctl based PPP devices. This
     way, rtnl messages have the same effect on any PPP devices.
     The immediate effect is that all PPP devices, even ioctl-based
     ones, can now be removed with "ip link del".

     A minor difference still exists between ioctl and rtnl based PPP
     interfaces: in the device name, the number following the "ppp" prefix
     corresponds to the PPP unit number for ioctl based devices, while it is
     just an unrelated incrementing index for rtnl ones.

     Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
     Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 b26929a9fd7becd3652583d2f56579b8420fc522 
dd9e74c76a02cff8387a98821c05509518ca2f48 M    drivers
:040000 040000 82eacf2954c38d78ec4ccb7b8bdec2675e96e2e8 
7d4b666b5a61b0a23738943b39a984b47bcde3ae M    include

The issue is netcf dies if the ppp interface is up with the informative 
message "Failed to initialize netcf". No debug output. Enabling 
debugging in libnl shows it dies when the data for the ppp interface is 
returned.

Take ppp down and ncftool comes up ok.

libnl appears to be version 3.2.24 (Debian libnl-3)

This has been manifesting on a production machine with a pppoe link to 
the world, but I managed to reproduce it on a test box using a pppoe 
server and a client on the test box which enabled me to bisect it.

I don't know anything about netlink, nor the networking subsystem so I'm 
asking for a belt with a cluebat please. I'm using the latest *released* 
netcf, and a quick check of the git tree does not seem to indicate 
anything that might be related. Have I missed a kernel config option, or 
made some catastrophic blunder in setting this up? It works fine on 
4.6.4, but anything 4.7 or later just dies if the ppp interface is up.


Regards,
Brad
