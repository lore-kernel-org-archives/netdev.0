From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] IB/ipoib: Bound the net device to the ipoib_neigh structue
Date: Thu, 11 Oct 2007 15:01:38 -0700
Message-ID: <32286.1192140098@death>
References: <11916151232222-git-send-email-fubar@us.ibm.com> <470C200D.4010705@pobox.com> <470C2343.1020800@garzik.org> <20071009.181246.41634534.davem@davemloft.net> <706.1191979132@death> <470CF7E1.6060503@voltaire.com> <aday7eaddod.fsf@cisco.com> <470E37AD.3070408@voltaire.com> <ada3awhcsnw.fsf@cisco.com>
Cc: Moni Shoua <monis@voltaire.com>, jeff@garzik.org,
	David Miller <davem@davemloft.net>, ogerlitz@voltaire.com,
	netdev@vger.kernel.org, Moni Levy <monil@voltaire.com>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:36147 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754789AbXJKWBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 18:01:44 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9BM1ecH009375
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 18:01:40 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9BM1eZK481060
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 16:01:40 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9BM1dtJ024144
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 16:01:39 -0600
In-reply-to: <ada3awhcsnw.fsf@cisco.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier <rdreier@cisco.com> wrote:
[...]
>Yes, two napi_disable()s in a row without a matching napi_enable()
>will deadlock.  I guess the question is why the ipoib interface is
>being stopped twice.
>
>If you just take the net-2.6.24 tree (without bonding patches), does
>bonding for ethernet interfaces work OK, or is there a similar problem
>with double napi_disable()?  How about bonding of ethernet after this
>batch of bonding patches?

	I just checked this on an x86 box.  The bonding in stock net-2.6
pulled this morning or last night works ok (I did some basic tests,
including ifconfig down / up, with e100).  This remains true with the
IPoIB bonding patches applied.  I do not have hardware available to test
IPoIB.

	I did get a whammy from tg3, but I think this is unrelated to
bonding (as it happens when tg3 comes up, before bonding is involved):

BUG: unable to handle kernel paging request at virtual address 00004214
 printing eip:
e0828017
*pde = 00000000
Oops: 0002 [#1]
SMP
Modules linked in: thermal processor fan button loop e1000 sg evdev tg3 e100 rtb
CPU:    0
EIP:    0060:[<e0828017>]    Not tainted VLI
EFLAGS: 00010206   (2.6.23-ipv6 #1)
EIP is at tg3_ape_write32+0x7/0x10 [tg3]
eax: de9304c0   ebx: dde8fe18   ecx: 00000000   edx: 00004214
esi: de9304c0   edi: 00000000   ebp: dde8fe28   esp: dde8fdd4
ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
Process ip (pid: 2817, ti=dde8e000 task=dff4e0b0 task.ti=dde8e000)
Stack: e082fb2e 00000000 dde8fdf4 c01ece3e dde8fdf8 000003fe 00000000 00005400
       08000000 00001aa0 e083b340 08001aa0 00000060 e083ce00 08001b20 00000030
       e083ce80 00000101 de9304c0 00000001 dde56800 dde8fe38 e0830178 dff69000
Call Trace:
 [<c010536a>] show_trace_log_lvl+0x1a/0x30
 [<c0105429>] show_stack_log_lvl+0xa9/0xd0
 [<c0105639>] show_registers+0x1e9/0x2f0
 [<c0105851>] die+0x111/0x260
 [<c011c5dc>] do_page_fault+0x18c/0x6a0
 [<c0319bea>] error_code+0x72/0x78
 [<e0830178>] tg3_init_hw+0x38/0x50 [tg3]
 [<e0838886>] tg3_open+0x276/0x5d0 [tg3]
 [<c02aead8>] dev_open+0x38/0x80
 [<c02ad5cd>] dev_change_flags+0x7d/0x1a0
 [<c02f63d8>] devinet_ioctl+0x4c8/0x660
 [<c02f698b>] inet_ioctl+0x6b/0x90
 [<c02a0e5a>] sock_ioctl+0x5a/0x210
 [<c017cd98>] do_ioctl+0x28/0x80
 [<c017ce47>] vfs_ioctl+0x57/0x290
 [<c017d0b9>] sys_ioctl+0x39/0x60
 [<c01042a2>] sysenter_past_esp+0x5f/0x99
 =======================
Code: <89> 0a c3 8d b6 00 00 00 00 55 8b 48 50 89 e5 5d 01 ca 8b 02 c3 8d
EIP: [<e0828017>] tg3_ape_write32+0x7/0x10 [tg3] SS:ESP 0068:dde8fdd4
Kernel panic - not syncing: Fatal exception in interrupt

	I haven't investigated this further.  I'm using a BCM5704 card;
if this isn't a known problem and anyone is curious, I can supply
additional info.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

