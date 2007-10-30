From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: recent sysfs changes cause lots of network device errors
Date: Tue, 30 Oct 2007 15:00:10 -0700
Message-ID: <20071030150010.79253f01@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>, Tejun Heo <htejun@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40423 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753440AbXJ3WCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 18:02:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It seems that the network device rename done by distro's
interacts badly with the code in device_rename() in 2.6.24
(post -rc1).  Network devices create sysfs entries where the sd->s_name is 
just a pointer over to the actual buffer in the netdevice. 

Prior to calling device_rename, the code in dev_change_name() updates
the network device name field to the new name.  Then when device_rename
is called it sees that the new name already exists, and dumps out a bunch
of sysfs warnings. 

I already fixed the obvious case of rename to same name, so that isn't the
problem.

dev_change_name eth0 -> eth4
[   46.029555] sysfs: duplicate filename 'eth4' can not be created
[   46.029557] WARNING: at fs/sysfs/dir.c:424 sysfs_add_one()
[   46.029559] 
[   46.029560] Call Trace:
[   46.029586]  [<ffffffff802e60ff>] sysfs_add_one+0xaf/0xf0
[   46.029590]  [<ffffffff802e7113>] sysfs_create_link+0xa3/0x140
[   46.029597]  [<ffffffff803b1bb8>] device_rename+0x1d8/0x230
[   46.029603]  [<ffffffff8040af45>] dev_change_name+0xe5/0x280
[   46.029606]  [<ffffffff8040b697>] dev_ioctl+0x2b7/0x540
[   46.029612]  [<ffffffff803fc32d>] sock_ioctl+0x7d/0x250
[   46.029618]  [<ffffffff802ab33f>] do_ioctl+0x2f/0xa0
[   46.029620]  [<ffffffff802ab424>] vfs_ioctl+0x74/0x2d0
[   46.029624]  [<ffffffff8029bde5>] fd_install+0x25/0x60
[   46.029626]  [<ffffffff802ab711>] sys_ioctl+0x91/0xb0
[   46.029631]  [<ffffffff8020bbce>] system_call+0x7e/0x83


What is the proper usage mode for the rename code? 
Should the underlying structure get changed first or later?
Or maybe dev_change_name should just not use device_rename
at all, and just fix the kobject itself?

device_rename() should be smart enough to:
    1. not get confused if sysfs entry is already changed
    2. handle the case of rename to same name correctly.

The device control code needs more regression testing before new patches
are accepted. I understand there is a strong desire to cleanup and eliminate
the class device stuff, but before going there you need to create
regression tests for all usages, and not depend on every subsystem
maintainer to make changes to keep up with your whims.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
