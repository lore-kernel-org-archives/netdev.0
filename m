From: Theodore Ts'o <tytso@mit.edu>
Subject: "virtio-net: enable multiqueue by default" in linux-next breaks
 networking on GCE
Date: Mon, 12 Dec 2016 18:33:43 -0500
Message-ID: <20161212233343.q5xlv55rc5npqaqp@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, mst@redhat.com, nhorman@tuxdriver.com,
        davem@davemloft.net
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:46134 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752298AbcLLXdv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 18:33:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was doing a last minute regression test of the ext4 tree before
sending a pull request to Linus, which I do using gce-xfstests[1], and
I found that using networking was broken on GCE on linux-next.  I was
using next-20161209, and after bisecting things, I narrowed down the
commit which causing things to break to commit 449000102901:
"virtio-net: enable multiqueue by default".  Reverting this commit on
top of next-20161209 fixed the problem.

[1] http://thunk.org/gce-xfstests

You can reproduce the problem for building the kernel for Google
Compute Engine --- I use a config such as this [2], and then try to
boot a kernel on a VM.  The way I do this involves booting a test
appliance and then kexec'ing into the kernel to be tested[3], using a
2cpu configuration.  (GCE machine type: n1-standard-2)

[2] https://git.kernel.org/cgit/fs/ext2/xfstests-bld.git/tree/kernel-config=
s/ext4-x86_64-config-4.9
[3] https://github.com/tytso/xfstests-bld/blob/master/Documentation/gce-xfs=
tests.md

You can then take a look at serial console using a command such as
"gcloud compute instances get-serial-port-output <instance-name>", and
you will get something like this (see attached).  The important bit is
that the dhclient command is completely failing to be able to get a
response from the network, from which I deduce that apparently that
either networking send or receive or both seem to be badly affected by
the commit in question.

Please let me know if there's anything I can do to help you debug this
further.

Cheers,

						- Ted

Dec 11 23:53:20 xfstests-201612120451 kernel: [    0.000000] Linux version =
4.9.0-rc8-ext4-06387-g03e5cbd (tytso@tytso-ssd) (gcc version 4.9.2 (Debian =
4.9.2-10) ) #9 SMP Mon Dec 12 04:50:16 UTC 2016
Dec 11 23:53:20 xfstests-201612120451 kernel: [    0.000000] Command line: =
root=3D/dev/sda1 ro console=3DttyS0,38400n8 elevator=3Dnoop console=3DttyS0=
  fstestcfg=3D4k fstestset=3D-g,quick fstestexc=3D fstestopt=3Daex fstestty=
p=3Dext4 fstestapi=3D1.3
Dec 11 23:53:20 xfstests-201612120451 kernel: [    0.000000] x86/fpu: Suppo=
rting XSAVE feature 0x001: 'x87 floating point registers'
Dec 11 23:53:20 xfstests-201612120451 kernel: [    0.000000] x86/fpu: Suppo=
rting XSAVE feature 0x002: 'SSE registers'
Dec 11 23:53:20 xfstests-201612120451 kernel: [    0.000000] x86/fpu: Suppo=
rting XSAVE feature 0x004: 'AVX registers'
Dec 11 23:53:20 xfstests-201612120451 kernel: [    0.000000] x86/fpu: xstat=
e_offset[2]:  576, xstate_sizes[2]:  256
Dec 11 23:53:20 xfstests-201612120451 kernel: [    0.000000] x86/fpu: Enabl=
ed xstate features 0x7, context size is 832 bytes, using 'standard' format.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Load Kernel Modul=
es.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Apply Kernel Var=
iables...
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Mounting Configuration Fi=
le System...
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Mounting FUSE Control Fil=
e System...
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Mounted FUSE Control File=
 System.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Mounted Configuration Fil=
e System.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Apply Kernel Vari=
ables.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Create Static Dev=
ice Nodes in /dev.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting udev Kernel Devi=
ce Manager...
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started udev Kernel Devic=
e Manager.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started udev Coldplug all=
 Devices.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting udev Wait for Co=
mplete Device Initialization...
Dec 11 23:53:20 xfstests-201612120451 systemd-fsck[1659]: xfstests-root: cl=
ean, 56268/655360 files, 357439/2620928 blocks
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started File System Check=
 on Root Device.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Remount Root and=
 Kernel File Systems...
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Remount Root and =
Kernel File Systems.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Various fixups to=
 make systemd work better on Debian.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Load/Save Random=
 Seed...
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Local File Syste=
ms (Pre).
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Reached target Local File=
 Systems (Pre).
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Load/Save Random =
Seed.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started udev Wait for Com=
plete Device Initialization.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Activation of LV=
M2 logical volumes...
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Copy rules gener=
ated while the root was ro...
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Found device /dev/ttyS0.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Found device /dev/ttyS1.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Copy rules genera=
ted while the root was ro.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Found device /dev/ttyS2.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Found device /dev/ttyS3.
Dec 11 23:53:20 xfstests-201612120451 systemd-udevd[2568]: could not open m=
oddep file '/lib/modules/4.9.0-rc8-ext4-06387-g03e5cbd/modules.dep.bin'
Dec 11 23:53:20 xfstests-201612120451 lvm[2579]: No volume groups found
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Activation of LVM=
2 logical volumes.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Encrypted Volume=
s.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Reached target Encrypted =
Volumes.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Activation of LV=
M2 logical volumes...
Dec 11 23:53:20 xfstests-201612120451 lvm[2625]: No volume groups found
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Activation of LVM=
2 logical volumes.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Monitoring of LV=
M2 mirrors, snapshots etc. using dmeventd or progress polling...
Dec 11 23:53:20 xfstests-201612120451 lvm[2627]: No volume groups found
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Monitoring of LVM=
2 mirrors, snapshots etc. using dmeventd or progress polling.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Local File Syste=
ms.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Reached target Local File=
 Systems.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Remote File Syst=
ems.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Reached target Remote Fil=
e Systems.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Trigger Flushing=
 of Journal to Persistent Storage...
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Create Volatile =
Files and Directories...
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting LSB: Generate ss=
h host keys if they do not exist...
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting LSB: Raise netwo=
rk interfaces....
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Trigger Flushing =
of Journal to Persistent Storage.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Create Volatile F=
iles and Directories.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started LSB: Generate ssh=
 host keys if they do not exist.
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Starting Update UTMP abou=
t System Boot/Shutdown...
Dec 11 23:53:20 xfstests-201612120451 systemd[1]: Started Update UTMP about=
 System Boot/Shutdown.
Dec 11 23:53:20 xfstests-201612120451 dhclient: Internet Systems Consortium=
 DHCP Client 4.3.1
Dec 11 23:53:20 xfstests-201612120451 dhclient: Copyright 2004-2014 Interne=
t Systems Consortium.
Dec 11 23:53:20 xfstests-201612120451 dhclient: All rights reserved.
Dec 11 23:53:20 xfstests-201612120451 dhclient: For info, please visit http=
s://www.isc.org/software/dhcp/
Dec 11 23:53:20 xfstests-201612120451 dhclient:=20
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: Configuring network=
 interfaces...Internet Systems Consortium DHCP Client 4.3.1
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: Copyright 2004-2014=
 Internet Systems Consortium.
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: All rights reserved.
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: For info, please vi=
sit https://www.isc.org/software/dhcp/
Dec 11 23:53:20 xfstests-201612120451 dhclient: Listening on LPF/eth0/42:01=
:0a:f0:00:03
Dec 11 23:53:20 xfstests-201612120451 dhclient: Sending on   LPF/eth0/42:01=
:0a:f0:00:03
Dec 11 23:53:20 xfstests-201612120451 dhclient: Sending on   Socket/fallback
Dec 11 23:53:20 xfstests-201612120451 dhclient: DHCPREQUEST on eth0 to 255.=
255.255.255 port 67
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: Listening on LPF/et=
h0/42:01:0a:f0:00:03
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: Sending on   LPF/et=
h0/42:01:0a:f0:00:03
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: Sending on   Socket=
/fallback
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: DHCPREQUEST on eth0=
 to 255.255.255.255 port 67
Dec 11 23:53:20 xfstests-201612120451 dhclient: DHCPREQUEST on eth0 to 255.=
255.255.255 port 67
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: DHCPREQUEST on eth0=
 to 255.255.255.255 port 67
Dec 11 23:53:20 xfstests-201612120451 dhclient: DHCPDISCOVER on eth0 to 255=
=2E255.255.255 port 67 interval 8
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: DHCPDISCOVER on eth=
0 to 255.255.255.255 port 67 interval 8
Dec 11 23:53:20 xfstests-201612120451 dhclient: DHCPDISCOVER on eth0 to 255=
=2E255.255.255 port 67 interval 8
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: DHCP[=1B[32m  OK  =
=1B[0m] DISCOVER on eth0 to 255.255.255.255 port 67 interval 8
Dec 11 23:53:20 xfstests-201612120451 dhclient: DHCPDISCOVER on eth0 to 255=
=2E255.255.255 port 67 interval 13
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: DHCPDISCOVER on eth=
0 to 255.255.255.255 port 67 interval 13
Dec 11 23:53:20 xfstests-201612120451 dhclient: DHCPDISCOVER on eth0 to 255=
=2E255.255.255 port 67 interval 17
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: DHCPDISCOVER on eth=
0 to 255.255.255.255 port 67 interval 17
Dec 11 23:53:20 xfstests-201612120451 dhclient: DHCPDISCOVER on eth0 to 255=
=2E255.255.255 port 67 interval 15
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: DHCPDISCOVER on eth=
0 to 255.255.255.255 port 67 interval 15
Dec 11 23:53:20 xfstests-201612120451 dhclient: No DHCPOFFERS received.
Dec 11 23:53:20 xfstests-201612120451 dhclient: Trying recorded lease 10.24=
0.0.3
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: No DHCPOFFERS recei=
ved.
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: Trying recorded lea=
se 10.240.0.3
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: connect: Network is=
 unreachable
Dec 11 23:53:20 xfstests-201612120451 logger: /etc/dhcp/dhclient-exit-hooks=
 returned non-zero exit status 2
Dec 11 23:53:20 xfstests-201612120451 dhclient: bound: renewal in 38598 sec=
onds.
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: bound: renewal in 3=
8598 seconds.
Dec 11 23:53:20 xfstests-201612120451 networking[2633]: done.
