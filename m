From: Brenden Blanco <bblanco@gmail.com>
Subject: virtnet_xdp_set induces WARNING at drivers/pci/msi.c:1261
 pci_irq_vector+0xd4/0xe0
Date: Wed, 22 Mar 2017 23:31:12 -0700
Message-ID: <CAH9hs-LJfRV4w1htw07uAYeqO5m9c_7_1SqUto8foKHTXWOm2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34350 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751648AbdCWIRv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 04:17:51 -0400
Received: by mail-pg0-f68.google.com with SMTP id w20so9803542pgc.1
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 01:17:50 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi netdev,

I was using the new xdp support in virtio to test some idea that I have,
and am seeing the WARN_ON_ONCE in the end of this email when I add the
first xdp program. After this, the VM seems to operate just fine.

I know that y'all were testing with a particular qemu command line,
which I have adapted to a libvirt xml definition that is close but not
quite exactly like what was suggested. The VM is 4-vCPU, with a single
nic that looks something like:

...
-smp 4,sockets=4,cores=1,threads=1
...
-netdev tap,fds=26:28:29:30:31:32:33:34:35,id=hostnet0,vhost=on,vhostfds=36:37:38:39:40:41:42:43:44 -device virtio-net-pci,guest_tso4=off,guest_tso6=off,guest_ecn=off,guest_ufo=off,mq=on,vectors=20,netdev=hostnet0,id=net0,mac=52:54:00:18:17:f4,bus=pci.0,addr=0x3
...

This comes from a libvirt definition of:

   ...
   <interface type='bridge'>
      <mac address='52:54:00:18:17:f4'/>
      <source bridge='virbr'/>
      <target dev='vnet0'/>
      <model type='virtio'/>
      <driver name='vhost' queues='9'>
        <guest tso4='off' tso6='off' ecn='off' ufo='off'/>
      </driver>
      <alias name='net0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
    ...

I couldn't find an xml parameter to drive qemu's queues=X field as
tested by John, and I believe the vectors=Y parameters comes from a 2N+2
calculation from libvirt's vhost queues setting.

I tested with many different queues settings, and 9 was the only one
that XDP liked enough to allow my program. The resulting ethtool
channels looked like:

Channel parameters for ens3:
Pre-set maximums:
RX:             0
TX:             0
Other:          0
Combined:       9
Current hardware settings:
RX:             0
TX:             0
Other:          0
Combined:       8

Kernel is v4.11-rc2 based.

So, my question would be two-fold:

1. Is there a way to coerce libvirt to create the right command line,
and/or is this some bug in libvirt (and who should I email if so)?

2. Is there anything to fix in the driver side or is this warning
exactly what should be happening with the quirky configuration that I
have?

Thanks,
Brenden


[  131.424391] WARNING: CPU: 2 PID: 3218 at drivers/pci/msi.c:1261 pci_irq_vector+0xd4/0xe0
[  131.424392] Modules linked in: pktgen ipt_MASQUERADE nf_nat_masquerade_ipv4 xfrm_user xfrm_algo iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 xt_addrtype iptable_filter ip_tables xt_conntrack x_tables nf_nat nf_conntrack br_netfilter bridge stp llc dm_thin_pool dm_persistent_data dm_bufio dm_bio_prison binfmt_misc ppdev snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hwdep snd_hda_core snd_pcm snd_timer snd parport_pc intel_rapl_perf soundcore input_leds serio_raw i2c_piix4 parport qemu_fw_cfg mac_hid ib_iser rdma_cm configfs iw_cm ib_cm ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi autofs4 btrfs raid10 raid456 libcrc32c async_raid6_recov async_memcpy async_pq async_xor async_tx xor raid6_pq raid1 raid0 multipath linear crct10dif_pclmul crc32_pclmul ghash
 _clmulni_intel
[  131.424416]  pcbc qxl drm_kms_helper aesni_intel syscopyarea sysfillrect aes_x86_64 sysimgblt crypto_simd fb_sys_fops cryptd ttm psmouse glue_helper drm virtio_net pata_acpi floppy
[  131.424423] CPU: 2 PID: 3218 Comm: PktGen Not tainted 4.11.0-rc2-03152017+ #4
[  131.424424] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-20170228_101828-anatol 04/01/2014
[  131.424424] Call Trace:
[  131.424427]  dump_stack+0x63/0x90
[  131.424430]  __warn+0xcb/0xf0
[  131.424431]  warn_slowpath_null+0x1d/0x20
[  131.424433]  pci_irq_vector+0xd4/0xe0
[  131.424435]  vp_synchronize_vectors+0x46/0x60
[  131.424436]  vp_reset+0x37/0x40
[  131.424438]  virtnet_xdp+0x240/0x3f0 [virtio_net]
[  131.424441]  dev_change_xdp_fd+0x91/0x150
[  131.424443]  do_setlink+0xd34/0xd60
[  131.424445]  ? memcg_kmem_charge_memcg+0x76/0x90
[  131.424448]  ? new_slab+0x31d/0x710
[  131.424449]  ? nla_parse+0xa0/0x100
[  131.424450]  rtnl_setlink+0x100/0x140
[  131.424453]  ? ns_capable_common+0x60/0x80
[  131.424454]  rtnetlink_rcv_msg+0xe6/0x220
[  131.424455]  ? __kmalloc_node_track_caller+0x1ef/0x2c0
[  131.424457]  ? __alloc_skb+0x87/0x1c0
[  131.424458]  ? rtnl_newlink+0x8a0/0x8a0
[  131.424459]  netlink_rcv_skb+0xa4/0xc0
[  131.424460]  rtnetlink_rcv+0x28/0x30
[  131.424461]  netlink_unicast+0x18c/0x240
[  131.424462]  netlink_sendmsg+0x2fb/0x3a0
[  131.424463]  sock_sendmsg+0x38/0x50
[  131.424464]  SYSC_sendto+0x101/0x190
[  131.424467]  ? ____fput+0xe/0x10
[  131.424468]  ? task_work_run+0x83/0xa0
[  131.424469]  SyS_sendto+0xe/0x10
[  131.424472]  entry_SYSCALL_64_fastpath+0x1e/0xad
[  131.424473] RIP: 0033:0x7fbe4ebda99d
[  131.424473] RSP: 002b:00007ffc257d3ef8 EFLAGS: 00000246 ORIG_RAX: 000000000000002c
[  131.424474] RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 00007fbe4ebda99d
[  131.424474] RDX: 000000000000002c RSI: 00007ffc257d3f10 RDI: 0000000000000005
[  131.424475] RBP: 0000000000000005 R08: 0000000000000000 R09: 0000000000000000
[  131.424475] R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffc257d5300
[  131.424476] R13: 00007ffc257d5300 R14: 00007ffc257d5540 R15: 0000000000000000
