From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next] mlx4: Better use of order-0 pages in RX path
Date: Mon, 20 Mar 2017 06:04:19 -0700
Message-ID: <CANn89iJehuD4m1FghYdcfuZ+WnRR7R04xQjOCmfAqVGKx4COuQ@mail.gmail.com>
References: <20170314151143.16231-1-edumazet@google.com> <60f6dc92-511d-b7be-64d2-2532e112d845@gmail.com>
 <1a1186b1-2b24-8521-9229-cb9bc3d9f3cb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:35617 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753078AbdCTNMm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 09:12:42 -0400
Received: by mail-wr0-f169.google.com with SMTP id g10so92030934wrg.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 06:11:40 -0700 (PDT)
In-Reply-To: <1a1186b1-2b24-8521-9229-cb9bc3d9f3cb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 20, 2017 at 5:59 AM, Tariq Toukan <ttoukan.linux@gmail.com> wrote:

>
> Hi Eric,
>
> While testing XDP scenarios, I noticed a small degradation.
> However, more importantly, I hit a kernel panic, see trace below.
>
> I'll need time to debug this.
> I will update about progress in debug and XDP testing.
>
> If you want, I can do the re-submission myself once both issues are solved.
>
> Thanks,
> Tariq
>
> Trace:
> [  379.069292] BUG: Bad page state in process xdp2  pfn:fd8c04
> [  379.075840] page:ffffea003f630100 count:-1 mapcount:0 mapping:   (null)
> index:0x0
> [  379.085413] flags: 0x2fffff80000000()
> [  379.089816] raw: 002fffff80000000 0000000000000000 0000000000000000
> ffffffffffffffff
> [  379.098994] raw: dead000000000100 dead000000000200 0000000000000000
> 0000000000000000
> [  379.108154] page dumped because: nonzero _refcount
> [  379.113793] Modules linked in: mlx4_en(OE) mlx4_ib ib_core mlx4_core(OE)
> netconsole nfsv3 nfs fscache dm_mirror dm_region_hash dm_log dm_mod sb_edac
> edac_core x86_pkg_temp_thermal coretemp i2c_diolan_u2c kvm iTCO_wdt
> iTCO_vendor_support lpc_ich ipmi_si irqbypass dcdbas ipmi_devintf
> crc32_pclmul mfd_core ghash_clmulni_intel pcspkr ipmi_msghandler sg wmi
> acpi_power_meter shpchp nfsd auth_rpcgss nfs_acl lockd grace sunrpc
> binfmt_misc ip_tables sr_mod cdrom sd_mod mlx5_core i2c_algo_bit
> drm_kms_helper tg3 syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm
> ahci libahci ptp megaraid_sas libata crc32c_intel i2c_core pps_core [last
> unloaded: mlx4_en]
> [  379.179886] CPU: 38 PID: 6243 Comm: xdp2 Tainted: G           OE
> 4.11.0-rc2+ #25
> [  379.188846] Hardware name: Dell Inc. PowerEdge R730/0H21J3, BIOS 1.5.4
> 10/002/2015
> [  379.197814] Call Trace:
> [  379.200838]  dump_stack+0x63/0x8c
> [  379.204833]  bad_page+0xfe/0x11a
> [  379.208728]  free_pages_check_bad+0x76/0x78
> [  379.213688]  free_pcppages_bulk+0x4d5/0x510
> [  379.218647]  free_hot_cold_page+0x258/0x280
> [  379.228911]  __free_pages+0x25/0x30
> [  379.233099]  mlx4_en_free_rx_buf.isra.23+0x79/0x110 [mlx4_en]
> [  379.239811]  mlx4_en_deactivate_rx_ring+0xb2/0xd0 [mlx4_en]
> [  379.246332]  mlx4_en_stop_port+0x4fc/0x7d0 [mlx4_en]
> [  379.252166]  mlx4_xdp+0x373/0x3b0 [mlx4_en]
> [  379.257126]  dev_change_xdp_fd+0x102/0x140
> [  379.261993]  ? nla_parse+0xa3/0x100
> [  379.266176]  do_setlink+0xc9c/0xcc0
> [  379.270363]  ? nla_parse+0xa3/0x100
> [  379.274547]  rtnl_setlink+0xbc/0x100
> [  379.278828]  ? __enqueue_entity+0x60/0x70
> [  379.283595]  rtnetlink_rcv_msg+0x95/0x220
> [  379.288365]  ? __kmalloc_node_track_caller+0x214/0x280
> [  379.294397]  ? __alloc_skb+0x7e/0x260
> [  379.298774]  ? rtnl_newlink+0x830/0x830
> [  379.303349]  netlink_rcv_skb+0xa7/0xc0
> [  379.307825]  rtnetlink_rcv+0x28/0x30
> [  379.312102]  netlink_unicast+0x15f/0x230
> [  379.316771]  netlink_sendmsg+0x319/0x390
> [  379.321441]  sock_sendmsg+0x38/0x50
> [  379.325624]  SYSC_sendto+0xef/0x170
> [  379.329808]  ? SYSC_bind+0xb0/0xe0
> [  379.333895]  ? alloc_file+0x1b/0xc0
> [  379.338077]  ? __fd_install+0x22/0xb0
> [  379.342456]  ? sock_alloc_file+0x91/0x120
> [  379.347314]  ? fd_install+0x25/0x30
> [  379.351518]  SyS_sendto+0xe/0x10
> [  379.355432]  entry_SYSCALL_64_fastpath+0x1a/0xa9
> [  379.360901] RIP: 0033:0x7f824e6d0cad
> [  379.365201] RSP: 002b:00007ffc75259a08 EFLAGS: 00000246 ORIG_RAX:
> 000000000000002c
> [  379.374198] RAX: ffffffffffffffda RBX: 00000000ffffffff RCX:
> 00007f824e6d0cad
> [  379.382481] RDX: 000000000000002c RSI: 00007ffc75259a20 RDI:
> 0000000000000003
> [  379.390746] RBP: 00000000ffffffff R08: 0000000000000000 R09:
> 0000000000000000
> [  379.399010] R10: 0000000000000000 R11: 0000000000000246 R12:
> 0000000000000019
> [  379.407273] R13: 0000000000000030 R14: 00007ffc7525b260 R15:
> 00007ffc75273270
> [  379.415539] Disabling lock debugging due to kernel taint
>
>

Hi Tariq

Thanks for testing.

I wont have time to work on this before one month or so, so I will
appreciate your findings ;)

Thanks !
