From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] bridge: fix gc_timer mod/del race
	condition
Date: Mon, 12 Oct 2015 23:24:16 -0700
Message-ID: <CAE4R7bAUk14WCME8UCBTQp8FKPuP7QfiKyAAjw7e3K0QkRaXwg@mail.gmail.com>
References: <1444665355-28448-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>, Roopa Prabhu <roopa@cumulusnetworks.com>,
	bridge@lists.linux-foundation.org, "David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1444665355-28448-1-git-send-email-razor@blackwall.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 12, 2015 at 8:55 AM, Nikolay Aleksandrov
<razor@blackwall.org> wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
> commit c62987bbd8a1 ("bridge: push bridge setting ageing_time down to
> switchdev") introduced a timer race condition because the gc_timer can
> get rearmed after it's supposedly stopped and flushed in br_dev_delete()
> leading to a use of freed memory. So take rtnl to sync with bridge
> destruction when setting ageing_timer.
> Here's the trace reproduced with these two commands running in parallel:
> while :; do echo 10000 > /sys/class/net/br0/bridge/ageing_timer; done;
> while :; do brctl addbr br0; ip l set br0 up; ip l set br0 down;
> brctl delbr br0; done;
>
> [  300.000029] BUG: unable to handle kernel paging request at
> ffffffff811c59d3
> [  300.000263] IP: [<ffffffff810f168e>] __internal_add_timer+0x2e/0xd0
> [  300.000422] PGD 1a0f067 PUD 1a10063 PMD 10001e1
> [  300.000639] Oops: 0003 [#1] SMP
> [  300.000793] Modules linked in: bridge stp llc nfsd auth_rpcgss
> oid_registry nfs_acl nfs lockd grace fscache sunrpc crct10dif_pclmul
> crc32_pclmul crc32c_intel ghash_clmulni_intel ppdev aesni_intel
> aes_x86_64 glue_helper lrw gf128mul ablk_helper cryptd
> snd_hda_codec_generic qxl drm_kms_helper psmouse pcspkr ttm
> snd_hda_intel 9pnet_virtio evdev serio_raw joydev snd_hda_codec 9pnet
> virtio_balloon drm snd_hwdep virtio_console snd_hda_core pvpanic snd_pcm
> i2c_piix4 snd_timer acpi_cpufreq parport_pc snd parport soundcore button
> processor i2c_core ipv6 autofs4 hid_generic usbhid hid ext4 crc16
> mbcache jbd2 sg sr_mod cdrom ata_generic virtio_blk virtio_net e1000
> ehci_pci uhci_hcd ehci_hcd usbcore usb_common floppy ata_piix libata
> virtio_pci virtio_ring virtio scsi_mod
> [  300.004008] CPU: 1 PID: 1169 Comm: bash Not tainted 4.3.0-rc3+ #46
> [  300.004008] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  300.004008] task: ffff880035be2200 ti: ffff88003795c000 task.ti:
> ffff88003795c000
> [  300.004008] RIP: 0010:[<ffffffff810f168e>]  [<ffffffff810f168e>]
> __internal_add_timer+0x2e/0xd0
> [  300.004008] RSP: 0018:ffff88003fd03e78  EFLAGS: 00010046
> [  300.004008] RAX: ffff88003fd0ef60 RBX: 840fc78949c08548 RCX:
> 00000001ffffffff
> [  300.004008] RDX: 0000000000000000 RSI: ffffffff811c59d3 RDI:
> ffff88003fd0df00
> [  300.004008] RBP: ffff88003fd03e78 R08: 00000000ffffffff R09:
> 0000000000000000
> [  300.004008] R10: 0000000000000000 R11: 0000000000000000 R12:
> ffff88003fd0df00
> [  300.004008] R13: 0000000000000000 R14: 0000000000000001 R15:
> ffffffff816032e0
> [  300.004008] FS:  00007fcbdd609700(0000) GS:ffff88003fd00000(0000)
> knlGS:0000000000000000
> [  300.004008] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  300.004008] CR2: ffffffff811c59d3 CR3: 0000000037879000 CR4:
> 00000000000406e0
> [  300.004008] Stack:
> [  300.004008]  ffff88003fd03ea8 ffffffff810f1775 ffff88003c8cb958
> ffff88003fd0df00
> [  300.004008]  0000000000000000 0000000000000001 ffff88003fd03f18
> ffffffff810f28c4
> [  300.004008]  ffff88003fd0eb68 ffff88003fd0e968 ffff88003fd0e768
> ffff88003fd0df68
> [  300.004008] Call Trace:
> [  300.004008]  <IRQ>
> [  300.004008]  [<ffffffff810f1775>] cascade+0x45/0x70
> [  300.004008]  [<ffffffff810f28c4>] run_timer_softirq+0x2f4/0x340
> [  300.004008]  [<ffffffff8107e380>] __do_softirq+0xd0/0x440
> [  300.004008]  [<ffffffff8107e8a3>] irq_exit+0xb3/0xc0
> [  300.004008]  [<ffffffff815c2032>] smp_apic_timer_interrupt+0x42/0x50
> [  300.004008]  [<ffffffff815bfe37>] apic_timer_interrupt+0x87/0x90
> [  300.004008]  <EOI>
> [  300.004008]  [<ffffffff811fb80c>] ? create_object+0x13c/0x2e0
> [  300.004008]  [<ffffffff8109b23e>] ? __kernel_text_address+0x4e/0x70
> [  300.004008]  [<ffffffff8109b23e>] ? __kernel_text_address+0x4e/0x70
> [  300.004008]  [<ffffffff8101e17f>] print_context_stack+0x7f/0xf0
> [  300.004008]  [<ffffffff8101d55b>] dump_trace+0x11b/0x300
> [  300.004008]  [<ffffffff8102970b>] save_stack_trace+0x2b/0x50
> [  300.004008]  [<ffffffff811fb80c>] create_object+0x13c/0x2e0
> [  300.004008]  [<ffffffff815b2e8e>] kmemleak_alloc+0x4e/0xb0
> [  300.004008]  [<ffffffff811e475d>] kmem_cache_alloc_trace+0x18d/0x2f0
> [  300.004008]  [<ffffffff8128b139>] kernfs_fop_open+0xc9/0x380
> [  300.004008]  [<ffffffff8120214f>] do_dentry_open+0x1ff/0x2f0
> [  300.004008]  [<ffffffff8128b070>] ? kernfs_fop_release+0x70/0x70
> [  300.004008]  [<ffffffff812034f9>] vfs_open+0x59/0x60
> [  300.004008]  [<ffffffff812130de>] path_openat+0x1ce/0x1260
> [  300.004008]  [<ffffffff812154ae>] do_filp_open+0x7e/0xe0
> [  300.004008]  [<ffffffff812251ff>] ? __alloc_fd+0xaf/0x180
> [  300.004008]  [<ffffffff8120387b>] do_sys_open+0x12b/0x210
> [  300.004008]  [<ffffffff8120397e>] SyS_open+0x1e/0x20
> [  300.004008]  [<ffffffff815bf0b6>] entry_SYSCALL_64_fastpath+0x16/0x7a
> [  300.004008] Code: 66 90 48 8b 46 10 48 8b 4f 40 55 48 89 c2 48 89 e5
> 48 29 ca 48 81 fa ff 00 00 00 77 20 0f b6 c0 48 8d 44 c7 68 48 8b 10 48
> 85 d2 <48> 89 16 74 04 48 89 72 08 48 89 30 48 89 46 08 5d c3 48 81 fa
> [  300.004008] RIP  [<ffffffff810f168e>] __internal_add_timer+0x2e/0xd0
> [  300.004008]  RSP <ffff88003fd03e78>
> [  300.004008] CR2: ffffffff811c59d3
>
> Fixes: c62987bbd8a1 ("bridge: push bridge setting ageing_time down to switchdev")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>  net/bridge/br_sysfs_br.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
>
> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
> index 04ef1926ee7e..8365bd53c421 100644
> --- a/net/bridge/br_sysfs_br.c
> +++ b/net/bridge/br_sysfs_br.c
> @@ -102,7 +102,15 @@ static ssize_t ageing_time_show(struct device *d,
>
>  static int set_ageing_time(struct net_bridge *br, unsigned long val)
>  {
> -       return br_set_ageing_time(br, val);
> +       int ret;
> +
> +       if (!rtnl_trylock())
> +               return restart_syscall();
> +
> +       ret = br_set_ageing_time(br, val);
> +       rtnl_unlock();
> +
> +       return ret;
>  }

Looks good, thanks Nikolay.  The other option would have been to
simply not restart gc_timer in br_set_ageing_time(), but this would
make changes to ageing_time "sluggish" in that it might take a while
for the fdb cleanup algo to use the new ageing_time value.  By kicking
the timer when the ageing_time changes, fdb cleanup immediately
switches to the new schedule.  In any case,

Acked-by: Scott Feldman <sfeldma@gmail.com>
