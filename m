From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Regression: ixgb warning on MTU change
Date: Wed, 24 Sep 2008 18:23:46 -0300
Message-ID: <48DAAFE2.1050607@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Rafael Lorandi <rafael.lorandi@linux.vnet.ibm.com>
To: e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw1.br.ibm.com ([32.104.18.24]:58876 "EHLO igw1.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751771AbYIXVYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 17:24:24 -0400
Received: from mailhub1.br.ibm.com (mailhub1 [9.18.232.109])
	by igw1.br.ibm.com (Postfix) with ESMTP id B2B3B32C08E
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 17:53:05 -0300 (BRT)
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.18.232.47])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8OLOIgY1736866
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 18:24:24 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8OLOA7r013830
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 18:24:11 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just found an issue related to ixgb that seems to be a regression.
After the interface is up and running (packets already transmitted), if
I try to change the MTU, running "ifconfig ethX mtu 70", for example, 
causes the following warning[1]. 

Bisecting I found that the commit that caused this warning is 
fc2d14e36c69a8d44a2f5230835b54e95025363e. Reverting it solves the
problem, ie, no more warnings. 

Digging further, I found that just removing the following line added
by fc2d14e36c69a8d44a2f5230835b54e95025363e's patch 
"buffer_info->dma = 0;", also solves the problem.

Jay Vosburgh suggested me some tests with barriers, mainly because I 
hit this error on a PPC, but I didn't get any luck adding barriers
around "buffer_info->dma = 0" line. 

[1] 
iommu_free: invalid entry
	entry     = 0x0
	dma_addr  = 0x0
	Table     = 0xc0000000be02b600
	bus#      = 0x0
	size      = 0x38000
	startOff  = 0x48000
	index     = 0x4000004
------------[ cut here ]------------
Badness at arch/powerpc/kernel/iommu.c:258
NIP: c000000000028488 LR: c000000000028484 CTR: 0000000000000001
REGS: c0000000ba10b280 TRAP: 0700   Tainted: G        W  (2.6.27-rc7)
MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24002422  XER: 20000000
TASK = c0000000be5f4c20[23325] 'ifconfig' THREAD: c0000000ba108000 CPU: 2
GPR00: c000000000028484 c0000000ba10b500 c000000000681ae0 000000000000001a 
GPR04: 0000000000000001 0000000000000001 0000000000000000 c0000000005b2f5c 
GPR08: 000000000001ffff c0000000005ea4f8 c0000000007154f4 c0000000007154f0 
GPR12: d00000000047f770 c0000000006f3880 0000000000000000 0000000000000000 
GPR16: 0000000000000000 0000000000000000 0000000000000004 0000000000000000 
GPR20: 0000000010020000 0000000010022860 0000000000000004 0000000000000001 
GPR24: c0000000ba10bca0 0000000000000000 0000000000000000 0000000000000001 
GPR28: fffffffffffb8000 c0000000be02b600 c00000000062b200 0000000000000000 
NIP [c000000000028488] .__iommu_free+0xe8/0x150
LR [c000000000028484] .__iommu_free+0xe4/0x150
Call Trace:
[c0000000ba10b500] [c000000000028484] .__iommu_free+0xe4/0x150 (unreliable)
[c0000000ba10b5a0] [c000000000028548] .iommu_free+0x58/0xc0
[c0000000ba10b640] [c0000000000280cc] .dma_iommu_unmap_single+0x14/0x28
[c0000000ba10b6c0] [d000000000472998] .ixgb_clean_rx_ring+0xa8/0x1e8 [ixgb]
[c0000000ba10b760] [d0000000004763fc] .ixgb_change_mtu+0xa0/0xec [ixgb]
[c0000000ba10b800] [c00000000036df34] .dev_set_mtu+0x68/0xb0
[c0000000ba10b880] [c00000000036f8cc] .dev_ioctl+0x67c/0x780
[c0000000ba10b990] [c00000000035ed44] .sock_ioctl+0x2d8/0x310
[c0000000ba10ba30] [c0000000001095b4] .vfs_ioctl+0x5c/0xf0
[c0000000ba10bad0] [c000000000109a54] .do_vfs_ioctl+0x40c/0x448
[c0000000ba10bb80] [c000000000109b00] .sys_ioctl+0x70/0xb4
[c0000000ba10bc30] [c00000000013eaa4] .dev_ifsioc+0x1b0/0x3e4
[c0000000ba10bd40] [c00000000013e064] .compat_sys_ioctl+0x3d4/0x468
[c0000000ba10be30] [c0000000000086b4] syscall_exit+0x0/0x40
Instruction dump:
e89d0008 e87e8058 4804aec1 60000000 e89d0010 e87e8060 4804aeb1 60000000 
e87e8068 e89d0020 4804aea1 60000000 <0fe00000> 4800003c e93e8070 e9290050 
ixgb: eth4: ixgb_watchdog: NIC Link is Up 10000 Mbps Full Duplex
 
