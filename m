From: Veaceslav Falico <vfalico@redhat.com>
Subject: [RFC] sysfs_rename_link() and its usage
Date: Tue, 14 Jan 2014 18:17:40 +0100
Message-ID: <20140114171740.GB1867@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	ebiederm@xmission.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12900 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367AbaANRUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 12:20:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm hitting a strange issue and/or I'm completely lost in sysfs internals.

Consider having two net_device *a, *b; which are registered normally.
Now, to create a link from /sys/class/net/a->name/linkname to b, one should
use:

sysfs_create_link(&(a->dev.kobj), &(b->dev.kobj), linkname);

To remove it, even simpler:

sysfs_remove_link(&(a->dev.kobj), linkname);

This works like a charm. However, if I want to use (obviously, with the
symlink present):

sysfs_rename_link(&(a->dev.kobj), &(b->dev.kobj), oldname, newname);

this fails with:

"sysfs: ns invalid in 'a->name' for 'oldname'"

in

  608 struct sysfs_dirent *sysfs_find_dirent(struct sysfs_dirent *parent_sd,
...
  615         if (!!sysfs_ns_type(parent_sd) != !!ns) {
  616                 WARN(1, KERN_WARNING "sysfs: ns %s in '%s' for '%s'\n",
  617                         sysfs_ns_type(parent_sd) ? "required" : "invalid",
  618                         parent_sd->s_name, name);
  619                 return NULL;
  620         }

Code path:
warn_slowpath_fmt+0x46/0x50
sysfs_get_dirent_ns+0x30/0x80
sysfs_find_dirent+0x84/0x110
sysfs_get_dirent_ns+0x3e/0x80
sysfs_rename_link_ns+0x54/0xd0

I have no idea what this code means. Is there any reason for it to
fail (i.e. am I doing something wrong?) or I've hit a bug?

I've tested the only user of it (bridge) - and it works fine, however it's
not using its own net_device's kobject but rather its own dir.

Thank you!
