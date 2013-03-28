From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Deleting a network namespace
Date: Thu, 28 Mar 2013 07:00:52 -0700
Message-ID: <87hajvhbe3.fsf@xmission.com>
References: <CAJJAcodGG6nmRNcF_rC+AUUpCp1MWjU3faGLfRTm9FNc6LT_Yw@mail.gmail.com>
	<87y5d7lr73.fsf@xmission.com>
	<CAJJAcof98k+GDt88MORMz6sS-JFODeuyqYSwP6dk-ZYqFMGTWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46938 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028Ab3C1OBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 10:01:04 -0400
In-Reply-To: <CAJJAcof98k+GDt88MORMz6sS-JFODeuyqYSwP6dk-ZYqFMGTWg@mail.gmail.com>
	(David Shwatrz's message of "Thu, 28 Mar 2013 15:41:25 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Shwatrz <dshwatrz@gmail.com> writes:

> Hello,
> I checked and indeed physical hardware are moved to init_net.
> I wonder how it is done, as in netns_delete() there is only
> umount2() and unlink() syscalls (might these syscalls trigger this
> movement to init_net)?

The mount holds a refcount to the network namespace, the unmount drops
that refcount.

> I really could not figure how this is
> implemented and where in code do we differentiate between physical and
> non physical devices.

When the refcount drops to zero put_net calls __put_net in
net/core/net_namespace.c which wiggles around and arranges
for cleanup_net to be called.

As for what happens to the network devices look at default_device_exit
and default_device_exit_batch in net/core/dev.c

As for the rest having software based network devices vanish is by
design and I can't think of a single reason why it would make sense to
do anything differently.  Depending on your configuration the initial
network namespace really isn't where you would want network devices to
be moved.   Think about what happens when you run your use can in a lxc
based container for example.

Eric
