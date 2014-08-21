From: "Alexander Y. Fomichev" <git.user@gmail.com>
Subject: Is it normal to have cross namespace symlinks?
Date: Thu, 21 Aug 2014 14:38:16 +0400
Message-ID: <20140821143816.48c5ad08@mad-cat.int.e5.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:42091 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754379AbaHUKi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 06:38:29 -0400
Received: by mail-lb0-f181.google.com with SMTP id 10so7778802lbg.26
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 03:38:28 -0700 (PDT)
Received: from mad-cat.int.e5.ru ([109.238.246.114])
        by mx.google.com with ESMTPSA id lm8sm16081661lac.36.2014.08.21.03.38.27
        for <netdev@vger.kernel.org>
        (version=SSLv3 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Aug 2014 03:38:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello guys!

Recently i switched to 3.14.x stable branch and i've got a bunch of
warnings:

[   44.717746] ------------[ cut here ]------------
[   44.717750] WARNING: CPU: 1 PID: 7007 at fs/sysfs/dir.c:52
sysfs_warn_dup+0x86/0xa0() [   44.717751] sysfs: cannot create
duplicate filename
'/devices/pci0000:00/0000:00:1c.4/0000:05:00.0/net/eth1/upper_eth1'

[   37.759856] ------------[ cut here ]------------
[   37.759863] WARNING: CPU: 1 PID: 3822 at fs/sysfs/dir.c:52
sysfs_warn_dup+0x86/0xa0() [   37.759864] sysfs: cannot create
duplicate filename '/devices/virtual/net/bond0/upper_eth0'
....

It was triggered by renaming of macvlan interfaces in a freshly created
network namespaces. Just start two lxc containers one by one with
macvlans on the same lowerdev and rename devices inside containers (with
the same name) and voila.

I investigated problem a bit and i see that code in net/core/dev.c
which working with sysfs symlinks upper_dev / lower_dev is absolutely
unaware of namespaces. I mean code which uses functions
netdev_adjacent_sysfs_del,netdev_adjacent_sysfs_add
netdev_adjacent_rename_links,dev_change_name
just not takes into account that dev and adj_dev could be in a
different namespaces. If userland asks to rename interface in a
new namespace this code renames an upper_dev link
in a parent namespace accordingly. I hadn't tried but i'll
bet it works vice-versa as well. It leads to warnings i've wrote above
and also creation inside namespaces a pretty meaningless links:
/sys/devices/virtual/net/eth1/lower_eth1
-> ../../../pci0000:00/0000:00:1c.4/0000:05:00.0/net/eth1
or probably deletion of symlinks of a perfectly valid devices. 

At the same time this issue is not affecting most of current
functionality and seems like nobody cares about that. I suspect that
there's (almost) no real users of sysfs uppder_dev/lower_dev simlinks,
am i right?

-- 

Best regards.
        Alexander Y. Fomichev <Aleksandr.Fomichev@x5.ru>
	        +7-495-662-88-88 ext. 11346
