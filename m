From: Noel Burton-Krahn <noel@pistoncloud.com>
Subject: iproute2 BUG: linux kernel panic after ip netns exec and umount
Date: Mon, 27 Apr 2015 10:03:00 -0700
Message-ID: <CAH6UTCGiGokbRqPMO+hvgz7nX8eV6YCcGQYZ6TWQ2ctAWipyJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:32919 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753028AbbD0RDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 13:03:01 -0400
Received: by igbpi8 with SMTP id pi8so72456848igb.0
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 10:03:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We ran into a kernel panic when we mixed ip netns exec with mounted
nbd devices.  The problem is creating a mount namespace in ip netns
exec is pretty dangerous (details below).  How about we add an option
to ip netns exec to *not* make a new mount namespace?

Details:

The problem is ip netns exec causes the nbd filesystem to
remain open after a umount and qemu-nbd -d

1. qemu-nbd -c creates a nbd device

2. mount nbd device in default namespace

mounting the filesystem creates kernel processes for journalling etc
e.g. jbd2

3. call ip netns exec to run namespaced servers

ip netns exec creates a new mount namespace for each proc so they can
have their own copy of /etc/hosts etc.  The new mount namespace clones
the nbd mount.

4. umount the nbd device

the root namespace does not count references from netns'ed clones, so
umount succeeds.  However, each netns'ed clone has its own copy of the
mounted filesystem, so the filesystem is still open.  The filesystem
will not close until all netns'ed cloned procs quit.

5. qemu-nbd -d to delete the nbd device

6. the last netns'ed child exits, the filesystem flushes its
superblock, tries to write to the deleted block device and panics.


Script to reproduce:

    qemu-img create f.img 1G
    yes | mkfs.ext4 f.img
    modprobe nbd
    qemu-nbd -c /dev/nbd1 f.img
    sleep 1
    mkdir -p /mnt/1
    mount /dev/nbd1 /mnt/1
    date > /mnt/1/date
    ip netns add ns
    ip netns exec ns tail -f /mnt/1/date >/dev/null 2>&1 &   # NOTE1
    #mount -o remount,ro /mnt/1    # NOTE2
    umount /mnt/1
    qemu-nbd -d /dev/nbd1
    sleep 1
    kill %-

NOTE1: umount will fail with device busy is this is not in a netns
NOTE2: remounting readonly masks the bug

Cheers,
Noel Burton-Krahn
Piston Cloud Computing
