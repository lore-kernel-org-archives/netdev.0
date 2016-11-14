From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: BUG: unable to handle kernel NULL pointer
 dereference in __sk_mem_raise_allocated()
Date: Mon, 14 Nov 2016 15:35:01 -0800
Message-ID: <1479166501.8455.91.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CANaxB-yCk8hhP68L4Q2nFOJht8sqgXGGQO2AftpHs0u1xyGG5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Paolo Abeni <pabeni@redhat.com>
To: Andrei Vagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34903 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932174AbcKNXfD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 18:35:03 -0500
Received: by mail-pf0-f177.google.com with SMTP id i88so31889927pfk.2
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 15:35:02 -0800 (PST)
In-Reply-To: <CANaxB-yCk8hhP68L4Q2nFOJht8sqgXGGQO2AftpHs0u1xyGG5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-14 at 15:24 -0800, Andrei Vagin wrote:
> Hi Paolo,
> 
> Our test system detected a kernel oops. Looks like a problem in the
> "udp: refactor memory accounting" series.
> 
> # good: [f970bd9e3a06f06df8d8ecf1f8ad2c8615cc17eb] udp: implement
> memory accounting helpers
> git bisect good f970bd9e3a06f06df8d8ecf1f8ad2c8615cc17eb
> # bad: [2d0e30c30f84d08dc16f0f2af41f1b8a85f0755e] bpf: add helper for
> retrieving current numa node id
> git bisect bad 2d0e30c30f84d08dc16f0f2af41f1b8a85f0755e
> # bad: [a10b91b8b81c29b87ff5a6d58c1402898337b956] Merge branch 'udpmem'
> git bisect bad a10b91b8b81c29b87ff5a6d58c1402898337b956
> # good: [850cbaddb52dfd4e0c7cabe2c168dd34b44ae0b9] udp: use it's own
> memory accounting schema
> git bisect good 850cbaddb52dfd4e0c7cabe2c168dd34b44ae0b9
> # first bad commit: [a10b91b8b81c29b87ff5a6d58c1402898337b956] Merge
> branch 'udpmem'
> 
> 
> [  112.472363] BUG: unable to handle kernel NULL pointer dereference
> at           (null)
> [  112.473360] IP: [<ffffffffb76f8031>] __sk_mem_raise_allocated+0x31/0x3f0
> [  112.474156] PGD 62a08067 [  112.474455] PUD 2b8bf067
> PMD 0 [  112.474856]
> [  112.475054] Oops: 0002 [#1] SMP
> [  112.475431] Modules linked in: nf_conntrack_netlink udp_diag
> tcp_diag inet_diag netlink_diag af_packet_diag unix_diag binfmt_misc
> nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4
> xt_conntrack nf_conntrack nfnetlink ip6table_filter ip6_tables ppdev
> sunrpc crc32c_intel joydev virtio_balloon virtio_net i2c_piix4
> parport_pc parport acpi_cpufreq tpm_tis tpm_tis_core tpm virtio_blk
> serio_raw virtio_pci virtio_ring virtio ata_generic pata_acpi
> [  112.480594] CPU: 1 PID: 7405 Comm: socket_udplite Not tainted 4.8.0+ #84
> [  112.481377] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS 1.9.1-1.fc24 04/01/2014
> [  112.482375] task: ffff928a5b5fa540 task.stack: ffffb3b484a0c000
> [  112.483059] RIP: 0010:[<ffffffffb76f8031>]  [<ffffffffb76f8031>]
> __sk_mem_raise_allocated+0x31/0x3f0
> [  112.484135] RSP: 0018:ffff928abfd03b18  EFLAGS: 00010296
> [  112.484758] RAX: 0000000000000001 RBX: ffff928aa293cfc0 RCX: 0000000000000001
> [  112.485585] RDX: 0000000000000000 RSI: 0000000000001000 RDI: ffff928aa293cfc0
> [  112.486414] RBP: ffff928abfd03b48 R08: 0de4c53600000000 R09: 0000000000000000
> [  112.487241] R10: 000000006226b971 R11: 0000000000000000 R12: ffff928aa293cfc0
> [  112.488064] R13: 0000000000000001 R14: ffffffffb7f0d5a0 R15: 0000000000001000
> [  112.488893] FS:  00007f058067a700(0000) GS:ffff928abfd00000(0000)
> knlGS:0000000000000000
> [  112.489807] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  112.490447] CR2: 0000000000000000 CR3: 000000002b8f5000 CR4: 00000000000006e0
> [  112.491248] DR0: 00000000000100a0 DR1: 0000000000000000 DR2: 0000000000000000
> [  112.492025] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> [  112.492808] Stack:
> [  112.493038]  0000000100000300 ffff928aa293cfc0 ffff928a651b9c00
> 0000000000000300
> [  112.493912]  ffff928aa293d108 0000000000001000 ffff928abfd03b88
> ffffffffb779e094
> [  112.494782]  ffff928abfd03b70 ffff928a651b9c00 ffff928aa293cfc0
> 0000000000000000

Thanks for the report.

I guess following patch would be needed ?

diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index af817158d830c0da080935ba29e012dffbb89112..12604c0371c451efcc9aad278bb86be9ac4bb813 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -54,6 +54,7 @@ struct proto 	udplite_prot = {
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
+	.memory_allocated  = &udp_memory_allocated,
 	.obj_size	   = sizeof(struct udp_sock),
 	.h.udp_table	   = &udplite_table,
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 47d0d2b87106558fece3496479198005c55b99e7..946025c888cc9519fb3523edbbe8afbb18273326 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -49,6 +49,7 @@ struct proto udplitev6_prot = {
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v6_get_port,
+	.memory_allocated  = &udp_memory_allocated,
 	.obj_size	   = sizeof(struct udp6_sock),
 	.h.udp_table	   = &udplite_table,
 #ifdef CONFIG_COMPAT
