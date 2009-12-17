From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH]ipv6:fix an oops when force unload ipv6 module
Date: Thu, 17 Dec 2009 13:17:01 +0800
Message-ID: <4B29BECD.1040004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61836 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751197AbZLQFO1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2009 00:14:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I do an ipv6 module force unload,I got the following oops:
#rmmod -f ipv6
------------[ cut here ]------------
kernel BUG at mm/slub.c:2969!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/devices/pci0000:00/0000:00:11.0/0000:02:03.0/net/eth2/ifindex
Modules linked in: ipv6(-) dm_multipath uinput ppdev tpm_tis tpm tpm_bios pcspkr pcnet32 mii parport_pc i2c_piix4 parport i2c_core floppy mptspi mptscsih mptbase scsi_transport_spi

Pid: 2530, comm: rmmod Tainted: G  R        2.6.32 #2 440BX Desktop Reference Platform/VMware Virtual Platform
EIP: 0060:[<c04b73f2>] EFLAGS: 00010246 CPU: 0
EIP is at kfree+0x6a/0xdd
EAX: 00000000 EBX: c09e86bc ECX: c043e4dd EDX: c14293e0
ESI: e141f1d8 EDI: e140fc31 EBP: dec58ef0 ESP: dec58ed0
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process rmmod (pid: 2530, ti=dec58000 task=decb1940 task.ti=dec58000)
Stack:
 c14293e0 00000282 df624240 c0897d08 c09e86bc c09e86bc e141f1d8 dec58f1c
<0> dec58f00 e140fc31 c09e84c4 e141f1bc dec58f14 c0689d21 dec58f1c e141f1bc
<0> 00000000 dec58f2c c0689eff c09e84d8 c09e84d8 e141f1bc bff33a90 dec58f38
Call Trace:
 [<e140fc31>] ? ipv6_frags_exit_net+0x22/0x32 [ipv6]
 [<c0689d21>] ? ops_exit_list+0x19/0x3d
 [<c0689eff>] ? unregister_pernet_operations+0x2a/0x51
 [<c0689f70>] ? unregister_pernet_subsys+0x17/0x24
 [<e140fbfe>] ? ipv6_frag_exit+0x21/0x32 [ipv6]
 [<e141a361>] ? inet6_exit+0x47/0x122 [ipv6]
 [<c045f5de>] ? sys_delete_module+0x198/0x1f6
 [<c04a8acf>] ? remove_vma+0x57/0x5d
 [<c070f63f>] ? do_page_fault+0x2e7/0x315
 [<c0403218>] ? sysenter_do_call+0x12/0x28
Code: 86 00 00 00 40 c1 e8 0c c1 e0 05 01 d0 89 45 e0 66 83 38 00 79 06 8b 40 0c 89 45 e0 8b 55 e0 8b 02 84 c0 78 14 66 a9 00 c0 75 04 <0f> 0b eb fe 8b 45 e0 e8 35 15 fe ff eb 5d 8b 45 04 8b 55 e0 89
EIP: [<c04b73f2>] kfree+0x6a/0xdd SS:ESP 0068:dec58ed0
---[ end trace 4475d1a5b0afa7e5 ]---

It's because in ip6_frags_ns_sysctl_register,
"table" only alloced when "net" is not equals
to "init_net".So when we free "table" in 
ip6_frags_ns_sysctl_unregister,we should check
this first.

This patch fix the problem.

Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com>

---
 net/ipv6/reassembly.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 4d98549..e4113bd 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -705,7 +705,8 @@ static void ip6_frags_ns_sysctl_unregister(struct net *net)
 
 	table = net->ipv6.sysctl.frags_hdr->ctl_table_arg;
 	unregister_net_sysctl_table(net->ipv6.sysctl.frags_hdr);
-	kfree(table);
+	if (!net_eq(net, &init_net))
+		kfree(table);
 }
 
 static struct ctl_table_header *ip6_ctl_header;
-- 
1.6.0.3

-- 
Regards
Yang Hongyang
