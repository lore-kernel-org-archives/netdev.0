From: Karol Lewandowski <kl@jasmine.eu.org>
Subject: [DSCAPE] rate_control needs some form of reference counting
Date: Sat, 29 Jul 2006 23:56:45 +0200
Message-ID: <20060729215645.GE1464@riddly.domek.prywatny>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from arz222.internetdsl.tpnet.pl ([83.17.211.222]:32143 "EHLO
	riddly.domek.prywatny") by vger.kernel.org with ESMTP
	id S932234AbWG2V4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jul 2006 17:56:47 -0400
Received: from karol by riddly.domek.prywatny with local (Exim 4.50)
	id 1G6wnd-0000Pc-Hl
	for netdev@vger.kernel.org; Sat, 29 Jul 2006 23:56:45 +0200
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm getting reproductible oops when removing rt2500pci module
(which uses devicescape ieee802.11 stack):


  # modprobe rt2500pci

Loading module: rt2500pci - CVS (N/A) by http://rt2x00.serialmonkey.com.
ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 21 (level, low) -> IRQ 18
wmaster0: Failed to select rate control algorithm
wmaster0: Failed to initialize rate control algorithm

  # lsmod
Module                  Size  Used by
rt2500pci              29316  0 
80211                 137096  1 rt2500pci
ipv6                  206752  12 

  Note that rate_control isn't loaded.

  # rmmod rt2500pci

Unloading module: rt2500pci - CVS (N/A) by http://rt2x00.serialmonkey.com.
------------[ cut here ]------------
kernel BUG at :46863!
invalid opcode: 0000 [#1]
SMP 
Modules linked in: rt2500pci 80211 ipv6
CPU:    1
EIP:    0060:[netdev_release+15/30]    Not tainted VLI
EFLAGS: 00010297   (2.6.17-riddly7.0 #1) 
EIP is at netdev_release+0xf/0x1e
eax: d600c2e8   ebx: d600c2e8   ecx: c01ffb73   edx: d600c000
esi: c030b5c0   edi: d600c2f0   ebp: c030b5dc   esp: d4e37ea8
ds: 007b   es: 007b   ss: 0068
Process rmmod (pid: 2306, threadinfo=d4e37000 task=c14f95b0)
Stack: c01ffb3b d600c2f0 c03031f0 c0303220 c01b3139 d600c308 c01b3159 d600c000 
       c149f048 c01b377e d600c58c c01b3159 c01b377e d600c574 d600c400 c01b30de 
       d600c2f0 e08e3f4f d600c400 d600c000 e08e3090 d67f9000 d67f989c e08d9e29 
Call Trace:
 <c01ffb3b> class_dev_release+0x2f/0x67  <c01b3139> kobject_cleanup+0x40/0x60
 <c01b3159> kobject_release+0x0/0x8  <c01b377e> kref_put+0x63/0x6d
 <c01b3159> kobject_release+0x0/0x8  <c01b377e> kref_put+0x63/0x6d
 <c01b30de> kobject_unregister+0x14/0x1c  <e08e3f4f> ieee80211_sysfs_remove_netdevice+0x17/0x2e [80211]
 <e08e3090> __ieee80211_if_del+0x2c/0x35 [80211]  <e08d9e29> ieee80211_unregister_hw+0xa3/0x147 [80211]
 <e0875330> rt2500pci_remove+0x32/0x55 [rt2500pci]  <c01bcfbf> pci_device_remove+0x16/0x28
 <c01ff4ad> __device_release_driver+0x5a/0x72  <c01ff549> driver_detach+0x5e/0x8b
 <c01fef49> bus_remove_driver+0x27/0x41  <c01ff801> driver_unregister+0xb/0x13
 <c01bd13b> pci_unregister_driver+0xb/0x13  <c012b11c> sys_delete_module+0x10d/0x132
 <c013cef5> do_munmap+0xda/0xe7  <c010254f> sysenter_past_esp+0x54/0x75
Code: 01 00 00 00 39 f8 7c 07 b8 f4 ff ff ff eb 09 c7 46 04 00 00 00 00 31 c0 5b 5e 5f c3 8d 90 18 fd ff ff 83 ba 94 02 00 00 04 74 02 <0f> 0b 0f b7 42 64 29 c2 89 d0 e9 c1 4a ef ff 05 e8 02 00 00 e9 
EIP: [netdev_release+15/30] netdev_release+0xf/0x1e SS:ESP 0068:d4e37ea8


Loading rate_control before rt2500 pci "fixes" the problem.

It isn't real fix but just hack -- driver uses rate_control module
(indirectly via dscape) but I can unload it (rate_control) while it's
running.

I'm _guessing_ that rate_control needs its own set of kobjects and do
some kobject_put/kobject_get in appropriate places...

thanks
-- 
This signature intentionally says nothing.
