From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: Is it normal to have cross namespace symlinks?
Date: Thu, 21 Aug 2014 14:12:05 +0200
Message-ID: <20140821121205.GR9476@redhat.com>
References: <20140821143816.48c5ad08@mad-cat.int.e5.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org
To: "Alexander Y. Fomichev" <git.user@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19138 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754479AbaHUMPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Aug 2014 08:15:06 -0400
Content-Disposition: inline
In-Reply-To: <20140821143816.48c5ad08@mad-cat.int.e5.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2014 at 02:38:16PM +0400, Alexander Y. Fomichev wrote:
>Hello guys!
>
>Recently i switched to 3.14.x stable branch and i've got a bunch of
>warnings:
>
>[   44.717746] ------------[ cut here ]------------
>[   44.717750] WARNING: CPU: 1 PID: 7007 at fs/sysfs/dir.c:52
>sysfs_warn_dup+0x86/0xa0() [   44.717751] sysfs: cannot create
>duplicate filename
>'/devices/pci0000:00/0000:00:1c.4/0000:05:00.0/net/eth1/upper_eth1'
>
>[   37.759856] ------------[ cut here ]------------
>[   37.759863] WARNING: CPU: 1 PID: 3822 at fs/sysfs/dir.c:52
>sysfs_warn_dup+0x86/0xa0() [   37.759864] sysfs: cannot create
>duplicate filename '/devices/virtual/net/bond0/upper_eth0'
>....
>
>It was triggered by renaming of macvlan interfaces in a freshly created
>network namespaces. Just start two lxc containers one by one with
>macvlans on the same lowerdev and rename devices inside containers (with
>the same name) and voila.
>v
>I investigated problem a bit and i see that code in net/core/dev.c
>which working with sysfs symlinks upper_dev / lower_dev is absolutely
>unaware of namespaces. I mean code which uses functions
>netdev_adjacent_sysfs_del,netdev_adjacent_sysfs_add
>netdev_adjacent_rename_links,dev_change_name
>just not takes into account that dev and adj_dev could be in a
>different namespaces.

That's indeed so. When I've implemented it, I indeed didn't take into
account net_ns, my bad.

Before the code, though, I'm not sure on how exactly to fix this. The only
idea which comes to mind is to prohibit inter-net_ns symlinks (which can be
done without much hassle) - i.e. to remove/add them on net_ns change, and
to prohibit creating them on adding an inter-ns upper links.

However, as I definitely lack experience using net_ns, maybe there are
other, better way, to fix this?
