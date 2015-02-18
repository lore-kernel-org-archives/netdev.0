From: Shachar Raindel <raindel@mellanox.com>
Subject: Use-after-free oops in next-20150204 - probably nelink related
Date: Wed, 18 Feb 2015 15:52:25 +0000
Message-ID: <AM3PR05MB093578F143B8C4C1BC18D5F6DC2C0@AM3PR05MB0935.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0061.outbound.protection.outlook.com ([157.55.234.61]:34879
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751568AbbBRPw4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 10:52:56 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm running trinity inside a VM running linux-next tagged next-20150204.

The kernel debugging infrastructure detected a use-after-free situation, probably in netlink:

[25041.653858] =============================================================================
[25041.654502] BUG kmalloc-2048 (Not tainted): Poison overwritten
[25041.654502] -----------------------------------------------------------------------------
[25041.654502] 
[25041.654502] Disabling lock debugging due to kernel taint
[25041.654502] INFO: 0xffff88007a213f88-0xffff88007a213f8f. First byte 0x19 instead of 0x6b
[25041.654502] INFO: Allocated in sk_prot_alloc+0xcb/0x1b0 age=4824 cpu=0 pid=950
[25041.654502] 	__slab_alloc+0x4dc/0x586
[25041.654502] 	__kmalloc+0x3f8/0x480
[25041.654502] 	sk_prot_alloc+0xcb/0x1b0
[25041.654502] 	sk_alloc+0x30/0x2e0
[25041.654502] 	__netlink_create+0x37/0xe0
[25041.654502] 	netlink_create+0xea/0x250
[25041.654502] 	__sock_create+0x2a3/0x3c0
[25041.654502] 	SyS_socket+0x61/0xf0
[25041.654502] 	tracesys_phase2+0xd8/0xdd
[25041.654502] INFO: Freed in __sk_free+0x178/0x1c0 age=4687 cpu=0 pid=9
[25041.654502] 	__slab_free+0x55/0x242
[25041.654502] 	kfree+0x369/0x380
[25041.654502] 	__sk_free+0x178/0x1c0
[25041.654502] 	sk_free+0x19/0x20
[25041.654502] 	deferred_put_nlk_sk+0x20/0x30
[25041.654502] 	rcu_nocb_kthread+0x24b/0x630
[25041.654502] 	kthread+0x10d/0x130
[25041.654502] 	ret_from_fork+0x7c/0xb0
[25041.654502] INFO: Slab 0xffffea0001e88400 objects=13 used=13 fp=0x          (null) flags=0x1fffff80004080
[25041.654502] INFO: Object 0xffff88007a2137b0 @offset=14256 fp=0xffff88007a210000
[25041.654502] 
[25041.654502] Bytes b4 ffff88007a2137a0: d8 ee aa 00 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
[25041.654502] Object ffff88007a2137b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2137c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2137d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2137e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2137f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213800: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213810: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213820: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213830: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213840: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213850: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213860: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213870: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213880: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213890: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2138a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2138b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2138c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2138d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2138e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2138f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213900: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213910: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213920: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213930: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213940: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213950: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213960: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213970: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213980: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213990: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2139a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2139b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2139c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2139d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2139e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a2139f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213a00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213a10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213a20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213a30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213a40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213a50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213a60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213a70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213a80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213a90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213aa0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213ab0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213ac0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213ad0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213ae0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213af0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213b00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213b10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213b20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213b30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213b40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213b50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213b60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213b70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213b80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213b90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213ba0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213bb0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213bc0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213bd0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213be0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213bf0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213c00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213c10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213c20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213c30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213c40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213c50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213c60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213c70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213c80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213c90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213ca0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213cb0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213cc0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213cd0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213ce0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213cf0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213d00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213d10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213d20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213d30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213d40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213d50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213d60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213d70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213d80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213d90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213da0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213db0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213dc0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213dd0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213de0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213df0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213e00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213e10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213e20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213e30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213e40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213e50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213e60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213e70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213e80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213e90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213ea0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213eb0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213ec0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213ed0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213ee0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213ef0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213f00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213f10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213f20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213f30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213f40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213f50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213f60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213f70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213f80: 6b 6b 6b 6b 6b 6b 6b 6b 19 00 00 00 00 00 00 00  kkkkkkkk........
[25041.654502] Object ffff88007a213f90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[25041.654502] Object ffff88007a213fa0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[25041.654502] Redzone ffff88007a213fb0: bb bb bb bb bb bb bb bb                          ........
[25041.654502] Padding ffff88007a2140f0: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
[25041.654502] CPU: 2 PID: 16599 Comm: top Tainted: G    B           3.19.0-rc7-next-20150204+ #28
[25041.654502] Hardware name: Red Hat KVM, BIOS Bochs 01/01/2007
[25041.654502]  0000000000000000 000000007af2d0f6 ffff8800048ab448 ffffffff8175d68e
[25041.654502]  0000000000000000 ffff88007ec04f00 ffff8800048ab488 ffffffff812287ad
[25041.654502]  0000000000000008 ffff880000000001 ffff88007a213f90 ffff88007ec04f00
[25041.654502] Call Trace:
[25041.654502]  [<ffffffff8175d68e>] dump_stack+0x4c/0x65
[25041.654502]  [<ffffffff812287ad>] print_trailer+0x14d/0x200
[25041.654502]  [<ffffffff8122892f>] check_bytes_and_report+0xcf/0x110
[25041.654502]  [<ffffffff81229ba7>] check_object+0x1d7/0x250
[25041.654502]  [<ffffffffa004e770>] ? alloc_indirect.isra.10+0x20/0x60 [virtio_ring]
[25041.654502]  [<ffffffff8175a830>] alloc_debug_processing+0x76/0x118
[25041.654502]  [<ffffffff8175b54d>] __slab_alloc+0x4dc/0x586
[25041.654502]  [<ffffffffa004e770>] ? alloc_indirect.isra.10+0x20/0x60 [virtio_ring]
[25041.654502]  [<ffffffff8122de28>] __kmalloc+0x3f8/0x480
[25041.654502]  [<ffffffffa004e770>] ? alloc_indirect.isra.10+0x20/0x60 [virtio_ring]
[25041.654502]  [<ffffffffa004e770>] alloc_indirect.isra.10+0x20/0x60 [virtio_ring]
[25041.654502]  [<ffffffff8122b889>] ? deactivate_slab+0x5a9/0x640
[25041.654502]  [<ffffffffa004e87e>] virtqueue_add_sgs+0xce/0x420 [virtio_ring]
[25041.654502]  [<ffffffffa0066492>] __virtblk_add_req+0xc2/0x1d0 [virtio_blk]
[25041.654502]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[25041.654502]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[25041.654502]  [<ffffffffa00666a7>] ? virtio_queue_rq+0x107/0x290 [virtio_blk]
[25041.654502]  [<ffffffffa00666a7>] ? virtio_queue_rq+0x107/0x290 [virtio_blk]
[25041.654502]  [<ffffffffa00666cb>] virtio_queue_rq+0x12b/0x290 [virtio_blk]
[25041.654502]  [<ffffffff8136661d>] __blk_mq_run_hw_queue+0x1fd/0x3c0
[25041.654502]  [<ffffffff81368e01>] ? blk_sq_make_request+0x231/0x5a0
[25041.654502]  [<ffffffff81367a20>] blk_mq_run_hw_queue+0xd0/0x110
[25041.654502]  [<ffffffff81368e20>] blk_sq_make_request+0x250/0x5a0
[25041.654502]  [<ffffffff81356990>] generic_make_request+0xe0/0x130
[25041.654502]  [<ffffffff81356a57>] submit_bio+0x77/0x150
[25041.654502]  [<ffffffff811f4a4a>] ? workingset_refault+0x5a/0xb0
[25041.654502]  [<ffffffff8129937a>] mpage_bio_submit+0x2a/0x40
[25041.654502]  [<ffffffff8129a539>] mpage_readpages+0x119/0x150
[25041.654502]  [<ffffffffa01984f0>] ? _ext4_get_block+0x220/0x220 [ext4]
[25041.654502]  [<ffffffffa01984f0>] ? _ext4_get_block+0x220/0x220 [ext4]
[25041.654502]  [<ffffffff8121ff97>] ? alloc_pages_current+0x107/0x1a0
[25041.654502]  [<ffffffffa0194bf4>] ext4_readpages+0x44/0x50 [ext4]
[25041.654502]  [<ffffffff811d16df>] __do_page_cache_readahead+0x2cf/0x350
[25041.654502]  [<ffffffff811d159b>] ? __do_page_cache_readahead+0x18b/0x350
[25041.654502]  [<ffffffff811c41e7>] filemap_fault+0x3b7/0x460
[25041.654502]  [<ffffffff811fd7e5>] ? handle_mm_fault+0xcd5/0x1700
[25041.654502]  [<ffffffff811f908c>] __do_fault+0x4c/0xd0
[25041.654502]  [<ffffffff811fd800>] handle_mm_fault+0xcf0/0x1700
[25041.654502]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[25041.654502]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[25041.654502]  [<ffffffff81071681>] do_page_fault+0x31/0x70
[25041.654502]  [<ffffffff8176a4d8>] page_fault+0x28/0x30
[25041.654502] FIX kmalloc-2048: Restoring 0xffff88007a213f88-0xffff88007a213f8f=0x6b
[25041.654502] 
[25041.654502] FIX kmalloc-2048: Marking all objects used
[25044.404089] ------------[ cut here ]------------
[25044.404792] WARNING: CPU: 0 PID: 5418 at fs/locks.c:243 locks_free_lock_context+0x64/0xc0()
[25044.406736] Modules linked in: 8021q garp mrp stp llc fuse cmtp kernelcapi bnep tun hidp crypto_user af_key rfcomm bluetooth vmw_vsock_vmci_transport vmw_vmci vsock l2tp_ppp l2tp_netlink l2tp_core ip6_udp_tunnel udp_tunnel pppoe pppox ppp_generic slhc scsi_transport_iscsi nfnetlink sctp libcrc32c ieee802154_socket ieee802154 atm nfsv3 rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache cfg80211 rfkill sg snd_hda_codec_generic snd_hda_intel snd_hda_controller dm_mirror snd_hda_codec dm_region_hash dm_log dm_mod snd_hwdep snd_seq snd_seq_device ppdev snd_pcm snd_timer snd virtio_balloon serio_raw pcspkr parport_pc parport soundcore 8250_fintek i2c_piix4 nfsd acpi_cpufreq auth_rpcgss nfs_acl lockd grace sunrpc uinput ext4 mbcache jbd2 cirrus syscopyarea sysfillrect sysimgblt drm_kms_helper virt
 io_blk ttm ata_generic pata_acpi drm 8139too ata_piix libata virtio_pci virtio_ring 8139cp i2c_core virtio mii floppy
[25044.422972] CPU: 0 PID: 5418 Comm: trinity-main Tainted: G    B           3.19.0-rc7-next-20150204+ #28
[25044.424649] Hardware name: Red Hat KVM, BIOS Bochs 01/01/2007
[25044.425889]  0000000000000000 00000000450cf6e2 ffff88007b90bca8 ffffffff8175d68e
[25044.427475]  0000000000000000 0000000000000000 ffff88007b90bce8 ffffffff8108930a
[25044.428739]  ffff88007b90bd08 ffff88007bc8d220 ffff880058fd0b70 ffffffff8183af80
[25044.430236] Call Trace:
[25044.430605]  [<ffffffff8175d68e>] dump_stack+0x4c/0x65
[25044.431548]  [<ffffffff8108930a>] warn_slowpath_common+0x8a/0xc0
[25044.432674]  [<ffffffff8108943a>] warn_slowpath_null+0x1a/0x20
[25044.433574]  [<ffffffff812af604>] locks_free_lock_context+0x64/0xc0
[25044.434821]  [<ffffffff8127139a>] __destroy_inode+0x3a/0x100
[25044.435761]  [<ffffffff81271486>] destroy_inode+0x26/0x70
[25044.436586]  [<ffffffff812715da>] evict+0x10a/0x180
[25044.437418]  [<ffffffff8127203e>] iput+0x1ce/0x390
[25044.438264]  [<ffffffff8126b320>] __dentry_kill+0x190/0x200
[25044.439310]  [<ffffffff8126c68e>] ? dput+0x26e/0x330
[25044.440411]  [<ffffffff8126c69d>] dput+0x27d/0x330
[25044.441173]  [<ffffffff8126c440>] ? dput+0x20/0x330
[25044.442248]  [<ffffffff81253417>] __fput+0x1a7/0x240
[25044.443138]  [<ffffffff812534fe>] ____fput+0xe/0x10
[25044.443880]  [<ffffffff810ae9fc>] task_work_run+0xbc/0xf0
[25044.444950]  [<ffffffff8108cbe9>] do_exit+0x389/0xcc0
[25044.445871]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[25044.446956]  [<ffffffff8102d7cc>] ? do_audit_syscall_entry+0x6c/0x70
[25044.448171]  [<ffffffff8108d5bc>] do_group_exit+0x4c/0xc0
[25044.449171]  [<ffffffff8108d644>] SyS_exit_group+0x14/0x20
[25044.449991]  [<ffffffff817685ba>] tracesys_phase2+0xd8/0xdd
[25044.450808] ---[ end trace 840289003955b5ec ]---


Thanks,
--Shachar
