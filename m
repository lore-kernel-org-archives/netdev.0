From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: "virtio-net: enable multiqueue by default" in linux-next breaks
 networking on GCE
Date: Tue, 13 Dec 2016 04:28:17 +0200
Message-ID: <20161213042057-mutt-send-email-mst@kernel.org>
References: <20161212233343.q5xlv55rc5npqaqp@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: jasowang@redhat.com, netdev@vger.kernel.org, nhorman@tuxdriver.com,
        davem@davemloft.net
To: "Theodore Ts'o" <tytso@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35522 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752544AbcLMC2U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 21:28:20 -0500
Content-Disposition: inline
In-Reply-To: <20161212233343.q5xlv55rc5npqaqp@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2016 at 06:33:43PM -0500, Theodore Ts'o wrote:
> Hi,
> 
> I was doing a last minute regression test of the ext4 tree before
> sending a pull request to Linus, which I do using gce-xfstests[1], and
> I found that using networking was broken on GCE on linux-next.  I was
> using next-20161209, and after bisecting things, I narrowed down the
> commit which causing things to break to commit 449000102901:
> "virtio-net: enable multiqueue by default".  Reverting this commit on
> top of next-20161209 fixed the problem.
> 
> [1] http://thunk.org/gce-xfstests
> 
> You can reproduce the problem for building the kernel for Google
> Compute Engine --- I use a config such as this [2], and then try to
> boot a kernel on a VM.  The way I do this involves booting a test
> appliance and then kexec'ing into the kernel to be tested[3], using a
> 2cpu configuration.  (GCE machine type: n1-standard-2)
> 
> [2] https://git.kernel.org/cgit/fs/ext2/xfstests-bld.git/tree/kernel-configs/ext4-x86_64-config-4.9
> [3] https://github.com/tytso/xfstests-bld/blob/master/Documentation/gce-xfstests.md
> 
> You can then take a look at serial console using a command such as
> "gcloud compute instances get-serial-port-output <instance-name>", and
> you will get something like this (see attached).  The important bit is
> that the dhclient command is completely failing to be able to get a
> response from the network, from which I deduce that apparently that
> either networking send or receive or both seem to be badly affected by
> the commit in question.
> 
> Please let me know if there's anything I can do to help you debug this
> further.
> 
> Cheers,
> 
> 						- Ted

That's unfortunate, of course. It could be a hypervisor or
a guest kernel bug. ideas:
- does host have mq capability? how many queues?
- how about # of msix vectors?
- after you send something on tx queues,
  are interrupts arriving on rx queues?
- is problem rx or tx?
  set ip and arp manually and send a packet to known MAC,
  does it get there?

> Dec 11 23:53:20 xfstests-201612120451 kernel: [    0.000000] Linux version 4.9.0-rc8-ext4-06387-g03e5cbd (tytso@tytso-ssd) (gcc version 4.9.2 (Debian 4.9.2-10) ) #9 SMP Mon Dec 12 04:50:16 UTC 2016
> Dec 11 23:53:20 xfstests-201612120451 kernel: [    0.000000] Command line: root=/dev/sda1 ro console=ttyS0,38400n8 elevator=noop console=ttyS0  fstestcfg=4k fstestset=-g,quick fstestexc= fstestopt=aex fstesttyp=ext4 fstestapi=1.3
> Dec 11 23:53:20 xfstests-201612120451 kernel: [    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
> Dec 11 23:53:20 xfstests-201612120451 kernel: [    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
> Dec 11 23:53:20 xfstests-201612120451 kernel: [    0.000000] x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
> Dec 11 23:53:20 xfstests-201612120451 kernel: [    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
> Dec 11 23:53:20 xfstests-201612120451 kernel: [    0.000000] x86/fpu: Enabled xstate features 0x7, context size is 832 bytes, using 'standard' format.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Load Kernel Modules.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Apply Kernel Variables...
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Mounting Configuration File System...
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Mounting FUSE Control File System...
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Mounted FUSE Control File System.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Mounted Configuration File System.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Apply Kernel Variables.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Create Static Device Nodes in /dev.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting udev Kernel Device Manager...
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started udev Kernel Device Manager.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started udev Coldplug all Devices.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting udev Wait for Complete Device Initialization...
> Dec 11 23:53:20 xfstests-201612120451 systemd-fsck[1659]: xfstests-root: clean, 56268/655360 files, 357439/2620928 blocks
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started File System Check on Root Device.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Remount Root and Kernel File Systems...
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Remount Root and Kernel File Systems.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Various fixups to make systemd work better on Debian.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Load/Save Random Seed...
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Local File Systems (Pre).
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Reached target Local File Systems (Pre).
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Load/Save Random Seed.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started udev Wait for Complete Device Initialization.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Activation of LVM2 logical volumes...
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Copy rules generated while the root was ro...
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Found device /dev/ttyS0.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Found device /dev/ttyS1.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Copy rules generated while the root was ro.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Found device /dev/ttyS2.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Found device /dev/ttyS3.
> Dec 11 23:53:20 xfstests-201612120451 systemd-udevd[2568]: could not open moddep file '/lib/modules/4.9.0-rc8-ext4-06387-g03e5cbd/modules.dep.bin'
> Dec 11 23:53:20 xfstests-201612120451 lvm[2579]: No volume groups found
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Activation of LVM2 logical volumes.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Encrypted Volumes.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Reached target Encrypted Volumes.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Activation of LVM2 logical volumes...
> Dec 11 23:53:20 xfstests-201612120451 lvm[2625]: No volume groups found
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Activation of LVM2 logical volumes.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling...
> Dec 11 23:53:20 xfstests-201612120451 lvm[2627]: No volume groups found
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Local File Systems.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Reached target Local File Systems.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Remote File Systems.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Reached target Remote File Systems.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Trigger Flushing of Journal to Persistent Storage...
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Create Volatile Files and Directories...
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting LSB: Generate ssh host keys if they do not exist...
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting LSB: Raise network interfaces....
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Trigger Flushing of Journal to Persistent Storage.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Create Volatile Files and Directories.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started LSB: Generate ssh host keys if they do not exist.
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Update UTMP about System Boot/Shutdown...
> Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Update UTMP about System Boot/Shutdown.
> Dec 11 23:53:20 xfstests-201612120451 dhclient: Internet Systems Consortium DHCP Client 4.3.1
> Dec 11 23:53:20 xfstests-201612120451 dhclient: Copyright 2004-2014 Internet Systems Consortium.
> Dec 11 23:53:20 xfstests-201612120451 dhclient: All rights reserved.
> Dec 11 23:53:20 xfstests-201612120451 dhclient: For info, please visit https://www.isc.org/software/dhcp/
> Dec 11 23:53:20 xfstests-201612120451 dhclient: 
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: Configuring network interfaces...Internet Systems Consortium DHCP Client 4.3.1
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: Copyright 2004-2014 Internet Systems Consortium.
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: All rights reserved.
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: For info, please visit https://www.isc.org/software/dhcp/
> Dec 11 23:53:20 xfstests-201612120451 dhclient: Listening on LPF/eth0/42:01:0a:f0:00:03
> Dec 11 23:53:20 xfstests-201612120451 dhclient: Sending on   LPF/eth0/42:01:0a:f0:00:03
> Dec 11 23:53:20 xfstests-201612120451 dhclient: Sending on   Socket/fallback
> Dec 11 23:53:20 xfstests-201612120451 dhclient: DHCPREQUEST on eth0 to 255.255.255.255 port 67
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: Listening on LPF/eth0/42:01:0a:f0:00:03
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: Sending on   LPF/eth0/42:01:0a:f0:00:03
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: Sending on   Socket/fallback
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: DHCPREQUEST on eth0 to 255.255.255.255 port 67
> Dec 11 23:53:20 xfstests-201612120451 dhclient: DHCPREQUEST on eth0 to 255.255.255.255 port 67
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: DHCPREQUEST on eth0 to 255.255.255.255 port 67
> Dec 11 23:53:20 xfstests-201612120451 dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 8
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 8
> Dec 11 23:53:20 xfstests-201612120451 dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 8
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: DHCP[[32m  OK  [0m] DISCOVER on eth0 to 255.255.255.255 port 67 interval 8
> Dec 11 23:53:20 xfstests-201612120451 dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 13
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 13
> Dec 11 23:53:20 xfstests-201612120451 dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 17
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 17
> Dec 11 23:53:20 xfstests-201612120451 dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 15
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 15
> Dec 11 23:53:20 xfstests-201612120451 dhclient: No DHCPOFFERS received.
> Dec 11 23:53:20 xfstests-201612120451 dhclient: Trying recorded lease 10.240.0.3
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: No DHCPOFFERS received.
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: Trying recorded lease 10.240.0.3
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: connect: Network is unreachable
> Dec 11 23:53:20 xfstests-201612120451 logger: /etc/dhcp/dhclient-exit-hooks returned non-zero exit status 2
> Dec 11 23:53:20 xfstests-201612120451 dhclient: bound: renewal in 38598 seconds.
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: bound: renewal in 38598 seconds.
> Dec 11 23:53:20 xfstests-201612120451 networking[2633]: done.
