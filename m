From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: tun: add tun_flags, owner, group attributes in sysfs
Date: Sat, 09 May 2009 23:55:45 +0100
Message-ID: <1241909745.24436.49.camel@macbook.infradead.org>
References: <1241433136.6126.70.camel@macbook.infradead.org>
	 <20090509.132733.213857911.davem@davemloft.net>
	 <1241908073.24436.27.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49330 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970AbZEIWzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 18:55:47 -0400
In-Reply-To: <1241908073.24436.27.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-05-09 at 23:27 +0100, David Woodhouse wrote:
> On Sat, 2009-05-09 at 13:27 -0700, David Miller wrote:
> > From: David Woodhouse <dwmw2@infradead.org>
> > Date: Mon, 04 May 2009 11:32:16 +0100
> > 
> > > I don't have to explicitly remove the files, do I? They go away
> > > naturally when the device is unregistered?
> > 
> > I'm not so sure about this.  I can't see anything in the
> > drivers/base/core.c code that automatically deletes anything
> > other than device groups and attributes.
> 
> Hm, I really do think the attributes go away automatically when the
> parent device does.
> 
> If not, gianfar_sysfs.c and niu.c want fixing too -- and we should
> probably have a WARN_ON() in the sysfs code when it happens, if
> possible.
> 
> I'll experiment (since I'm getting lost when I try to work it out by
> inspection).

I added a WARN_ON(!strcmp(sd->s_name, "tun_flags")) into
release_sysfs_dirent() to see when (and if) it gets called.

It does.

Looking at the backtrace, I see it's __sysfs_remove_dir() which iterates
over all the children of the device's directory and kills them:

[   98.024138]  [<ffffffff810f2e4e>] release_sysfs_dirent+0x49/0xc8
[   98.030178]  [<ffffffff810f2eff>] __sysfs_put+0x32/0x36
[   98.035432]  [<ffffffff810f3133>] sysfs_addrm_finish+0x20c/0x239
[   98.041470]  [<ffffffff810f2870>] ? sysfs_ilookup_test+0x0/0x14
[   98.047417]  [<ffffffff810f3214>] sysfs_remove_dir+0x6f/0x82
[   98.053107]  [<ffffffff8118fce4>] kobject_del+0x16/0x37
[   98.058367]  [<ffffffff8123953f>] device_del+0x16b/0x17b
[   98.063769]  [<ffffffff813b2d8f>] netdev_unregister_kobject+0x24/0x29
[   98.070241]  [<ffffffff813a7f0f>] rollback_registered+0x1d2/0x1e3
[   98.076364]  [<ffffffff813a7f5a>] unregister_netdevice+0x3a/0x69
[   98.082402]  [<ffffffffa0006458>] tun_chr_close+0x3d/0x66 [tun]

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

