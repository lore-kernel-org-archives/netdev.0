From: Richard Gregory <R.Gregory@liverpool.ac.uk>
Subject: r8169+NAPI soft lockup
Date: Tue, 09 May 2006 16:44:28 +0100
Message-ID: <4460B8DC.9080105@liv.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.liv.ac.uk ([138.253.100.181]:13270 "EHLO mx3.liv.ac.uk")
	by vger.kernel.org with ESMTP id S1750773AbWEIPoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 May 2006 11:44:30 -0400
Received: from mailhubb.liv.ac.uk ([138.253.100.37])
	by mx3.liv.ac.uk with esmtp (Exim 4.54)
	id 1FdUNx-0006ei-CA
	for netdev@vger.kernel.org; Tue, 09 May 2006 16:44:29 +0100
Received: from localhost ([127.0.0.1] helo=mailhubb.liv.ac.uk)
	by mailhubb.liv.ac.uk with esmtp (Exim 4.54)
	id 1FdUNx-0008OC-Av
	for netdev@vger.kernel.org; Tue, 09 May 2006 16:44:29 +0100
Received: from greg.csc.liv.ac.uk ([138.253.184.37] helo=[172.20.34.2])
	by mailhubb.liv.ac.uk with esmtp (Exim 4.54)
	id 1FdUNx-0008O9-9x
	for netdev@vger.kernel.org; Tue, 09 May 2006 16:44:29 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm seeing the crash below using 2.6.16.11 custom based on RedHat FC2. 
The main culprit being the r8169+NAPI module, although the it821x module 
(with noraid=1) seems to bring out the bug, maybe because it uses the 
same interrupt.

The machine is an Athlon 2200+ with 1.5G of ram, NForce2 chipset. Two 40 
gig drives create an ext3 software raid1 OS partition and eight 160 gig 
drives form a software raid5 partition, 1.1TB in size using reiserfs. 
The eight drives raid5 use four ITE8182 PCI cards, the r8169 gigabit 
card is in the middle of 5 PCI slots. The two raid1 boot drives use the 
onboard IDE.

BUG: soft lockup detected on CPU#0!

Pid: 11413, comm:                 cpio
EIP: 0060:[<c027d551>] CPU: 0
EIP is at ide_intr+0x41/0xe0
  EFLAGS: 00000286    Not tainted  (2.6.16.11 #1)
EAX: 00000050 EBX: f6f81d80 ECX: e81a9b1c EDX: 0000d007
ESI: 04000000 EDI: 00000286 EBP: c04a8740 DS: 007b ES: 007b
CR0: 8005003b CR2: b7fa5000 CR3: 2a319000 CR4: 000006d0
  [<c012c5c0>] handle_IRQ_event+0x21/0x4a
  [<c012c63c>] __do_IRQ+0x53/0x8f
  [<c0103fab>] do_IRQ+0x19/0x24
  [<c0102b6e>] common_interrupt+0x1a/0x20
  [<c030fb30>] netif_receive_skb+0x108/0x1a9
  [<f883017e>] rtl8169_rx_interrupt+0x287/0x31e [r8169]
  [<f8830798>] pci_unmap_single+0x0/0x10 [r8169]
  [<f88303ad>] rtl8169_poll+0x37/0xb5 [r8169]
  [<c030fd18>] net_rx_action+0x75/0x10a
  [<c0117be1>] __do_softirq+0x35/0x7d
  [<c0117c4b>] do_softirq+0x22/0x26
  [<c0103fb0>] do_IRQ+0x1e/0x24
  [<c0102b6e>] common_interrupt+0x1a/0x20
  [<c0187b38>] is_internal+0x37/0x6f
  [<c018832c>] search_by_key+0x713/0xb06
  [<c0177a4d>] make_cpu_key+0x2a/0x2f
  [<c01799a8>] reiserfs_update_sd_size+0x77/0x17b
  [<c01220d2>] autoremove_wake_function+0x0/0x2d
  [<c017d8ba>] reiserfs_prepare_file_region_for_write+0x47f/0x749
  [<c018ec49>] journal_begin+0x8c/0xcd
  [<c01819c4>] reiserfs_dirty_inode+0x47/0x61
  [<c015e1b7>] __mark_inode_dirty+0x27/0x14b
  [<c017d246>] reiserfs_submit_file_region_for_write+0x150/0x1d2
  [<c017e02e>] reiserfs_file_write+0x4aa/0x58e
  [<c03364e2>] tcp_v4_do_rcv+0x1b/0xb6
  [<c033699f>] tcp_v4_rcv+0x422/0x66e
  [<c01220df>] autoremove_wake_function+0xd/0x2d
  [<c01179a2>] current_fs_time+0x3a/0x50
  [<c0157c9d>] touch_atime+0x65/0xa6
  [<c014d82d>] pipe_readv+0x242/0x24e
  [<c01444b1>] vfs_write+0x87/0x123
  [<c01445eb>] sys_write+0x3c/0x62
  [<c0102947>] sysenter_past_esp+0x54/0x75

(a full trace is available, 
http://www.csc.liv.ac.uk/~greg/r8169bug.tar.gz , bug1.txt)


A similar lockup (with no info, sysreq wasn't enabled) has been seen 
with 2.6.14, in fact, when using the r8169+NAPI driver, the lockup would 
occur any time the it821x driver was used instead of ITE's own driver. 
With the ITE driver, the system has seen 400 days uptime with r8169+NAPI.

Without NAPI, the r8169 driver is stable with it821x. Can transfer at 
~35meg/second for hours with only a single unexplained 10 second pause 
(and link down/link up in dmesg).

The lockup requires r8169 io and it821x based disk io, onboard IDE disk 
io with r8169 io does not crash the system. A raid5 sync or slocate has 
never yet lead to a lockup yet is 89% full. The crash above used cpio to 
backup another machine via rsh, the machine froze an hour or so into 
this operation, having been up and running for at least a day with the 
raid5 partition mounted read/write but mostly unaccessed. Other tests 
showed this wasn't a reiserfs issue, reading the block device also 
crashed the machine.

Rebooting, a raid5 resync was required, which completed without 
problems. raid5 was mounted read only for all these tests, if it was 
mounted at all. linuxbox is another machine, also with an r8169 card, 
without the NAPI option. The discard daemon was running on port 9.

# locked up after 63 mins. Output in bug2.txt
$ find raid5 -xdev | cpio -oHnewc > /dev/tcp/linuxbox/9

# was fine for 180 mins, rebooted and did next test.
$ find raid5 -xdev | cpio -oHnewc > /dev/tcp/localhost/9

# locked up in ~30 mins. Output in bug3.txt
$ find raid5 -xdev | cpio -oHnewc > /dev/tcp/linuxbox/9

# locked up in 15 mins. md0 is the raid5 drive. Output in bug4.txt
# This showed raid5 module and reiserfs were not part of the problem.
$ cat /dev/md0 > /dev/tcp/linuxbox/9

# ran to the end, md0 wasn't enabled. md1 is the onboard IDE based raid1
# `seq 0 26` is enough to tranfer 1.1TB of data.
$ for i in `seq 0 26` ; do cat /dev/md1 > /dev/tcp/linuxbox/9 ; done

# locked in 1 min. Output in bug5.txt
$ for i in `seq 0 26` ; do cat /dev/md1 > /dev/tcp/linuxbox/9 &
$ cat /dev/md0 > /dev/tcp/localhost/9

# locked in 150 mins. no raid5 module. Output in bug6.txt
$ for i in e g i k m o q s ; do cat /dev/hd${i}1 > /dev/tcp/linuxbox/9 ; 
done
# locked in 7 hours. no raid5 module. Output in bug7.txt
$ for i in e g i k m o q s ; do cat /dev/hd${i}1 > /dev/udp/linuxbox/9 ; 
done

# test onboard LAN, 100meg forcedeth module. Fine for 8 hours (approx 
320gig transfered)
$ for i in g i k m o q s e ; do cat /dev/hd${i}1 > /dev/tcp/linuxbox/9 ; 
done &
$ for i in e g i k m o q s ; do cat /dev/hd${i}1 > /dev/tcp/linuxbox/9 ; 
done

# test r8169+NAPI at 100 meg. Locked in 110 mins. Output in bug8.txt
$ for i in g i k m o q s e ; do cat /dev/hd${i}1 > /dev/tcp/linuxbox/9 ; 
done &
$ for i in e g i k m o q s ; do cat /dev/hd${i}1 > /dev/tcp/linuxbox/9 ; 
done

# test r8169 at gigabit, with RX polling option disabled.
# Ran for 9 hours, so we have the winner. But why the NAPI interaction 
problem with it821x and not ITE?
$ for i in g i k m o q s e ; do cat /dev/hd${i}1 > /dev/tcp/linuxbox/9 ; 
done &
$ for i in e g i k m o q s ; do cat /dev/hd${i}1 > /dev/tcp/linuxbox/9 ; 
done &

# Again without NAPI. Ran to the end.
$ cat /dev/md0 > /dev/tcp/linuxbox/9

These tests were done a few days ago, the system has been stable with 
r8169(without NAPI) and it821x.


Am willing to test patches,

Richard
