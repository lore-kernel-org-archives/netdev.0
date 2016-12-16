From: Mike Krinkin <krinkin.m.u-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: "rfkill: Add rfkill-any LED trigger" causes deadlock
Date: Fri, 16 Dec 2016 20:09:33 +0300
Message-ID: <20161216170930.GA6368@gmail.com>
References: <20161216163707.GA2629@gmail.com>
 <CACpa5=_chGuU3zVcVR3nkNySwz1cGAQTs39v+BjwcDNSvOqhTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: kernel-ePNcKBjznIDVItvQsEIGlw@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CACpa5=_chGuU3zVcVR3nkNySwz1cGAQTs39v+BjwcDNSvOqhTw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 16, 2016 at 07:46:06PM +0300, Михаил Кринкин wrote:
> Hi,
> 
> with recent i can't load my thinkpad with recent linux-next, bisect points
> at the commit 73f4f76a196d7adb ("rfkill: Add rfkill-any LED trigger").
> 
> Problem occurs because thinkapd_acpi rfkill set_block handler
> tpacpi_rfk_hook_set_block calls rfkill_set_sw_state, which in turn calls
> new rfkill_any_led_trigger_event. So when rfkill_set_block called from
> rfkill_register we have deadlock.
> 
> I added WARN to __rfkill_any_led_trigger_event to see how deadlock occurs,
> here is backtrace:
> 
> [    6.090079] WARNING: CPU: 2 PID: 307 at net/rfkill/core.c:184
> rfkill_any_led_trigger_event+0x2d/0x40
> [    6.090080] reached __rfkill_any_led_trigger_event
> [    6.090081] Modules linked in:
> [    6.090082]  snd_pcm sg thinkpad_acpi(+) mei_me nvram snd_seq mei
> idma64 virt_dma intel_pch_thermal ucsi intel_lpss_pci snd_seq_device
> hci_uart snd_timer snd btbcm soundcore btqca led_class btintel
> bluetooth i8042 rtc_cmos serio evdev intel_lpss_acpi intel_lpss
> acpi_pad tpm_infineon mfd_core kvm_intel kvm irqbypass ipv6 autofs4
> ext4 jbd2 mbcache sd_mod i915 i2c_algo_bit drm_kms_helper syscopyarea
> sysfillrect sysimgblt fb_sys_fops drm ahci libahci video
> pinctrl_sunrisepoint pinctrl_intel
> [    6.090112] CPU: 2 PID: 307 Comm: systemd-udevd Tainted: G        W
>       4.9.0-01741-g73f4f76-dirty #106
> [    6.090113] Hardware name: LENOVO 20GJ004ERT/20GJ004ERT, BIOS
> R0CET21W (1.09 ) 03/07/2016
> [    6.090114]  ffffb199c023f998 ffffffffb4334b6b ffffb199c023f9e8
> 0000000000000000
> [    6.090117]  ffffb199c023f9d8 ffffffffb40658ab 000000b84dd75d28
> 0000000080000006
> [    6.090119]  ffff99ea4dd75d28 0000000000000001 0000000000000001
> 0000000000000000
> [    6.090122] Call Trace:
> [    6.090126]  [<ffffffffb4334b6b>] dump_stack+0x4d/0x72
> [    6.090128]  [<ffffffffb40658ab>] __warn+0xcb/0xf0
> [    6.090130]  [<ffffffffb406592f>] warn_slowpath_fmt+0x5f/0x80
> [    6.090132]  [<ffffffffb4631bfd>] rfkill_any_led_trigger_event+0x2d/0x40
> [    6.090135]  [<ffffffffb46322d9>] rfkill_set_sw_state+0x89/0xd0
> [    6.090142]  [<ffffffffc06c9921>]
> tpacpi_rfk_update_swstate+0x31/0x50 [thinkpad_acpi]
> [    6.090148]  [<ffffffffc06c9972>]
> tpacpi_rfk_hook_set_block+0x32/0x70 [thinkpad_acpi]
> [    6.090150]  [<ffffffffb46327f0>] rfkill_set_block+0x90/0x160
> [    6.090152]  [<ffffffffb4632930>] __rfkill_switch_all+0x70/0xa0
> [    6.090154]  [<ffffffffb4633028>] rfkill_register+0x278/0x2b0
> [    6.090159]  [<ffffffffc06e1f0e>] tpacpi_new_rfkill+0xef/0x15d
> [thinkpad_acpi]
> [    6.090164]  [<ffffffffc06e2407>] bluetooth_init+0x15e/0x1a9 [thinkpad_acpi]
> [    6.090169]  [<ffffffffc06e2fb5>]
> thinkpad_acpi_module_init.part.47+0x5e7/0x996 [thinkpad_acpi]
> [    6.090174]  [<ffffffffc06e3364>] ?
> thinkpad_acpi_module_init.part.47+0x996/0x996 [thinkpad_acpi]
> [    6.090179]  [<ffffffffc06e36af>]
> thinkpad_acpi_module_init+0x34b/0xc9c [thinkpad_acpi]
> [    6.090181]  [<ffffffffb4000450>] do_one_initcall+0x50/0x180
> [    6.090184]  [<ffffffffb4177e12>] ? do_init_module+0x27/0x1ee
> [    6.090186]  [<ffffffffb41cc4b6>] ? kmem_cache_alloc_trace+0x156/0x1a0
> [    6.090188]  [<ffffffffb4177e4a>] do_init_module+0x5f/0x1ee
> [    6.090191]  [<ffffffffb40ed562>] load_module+0x22c2/0x28d0
> [    6.090192]  [<ffffffffb40ea0f0>] ? __symbol_put+0x60/0x60
> [    6.090195]  [<ffffffffb42ee15d>] ? ima_post_read_file+0x7d/0xa0
> [    6.090198]  [<ffffffffb42a809b>] ? security_kernel_post_read_file+0x6b/0x80
> [    6.090200]  [<ffffffffb40eddcf>] SYSC_finit_module+0xdf/0x110
> [    6.090202]  [<ffffffffb40ede1e>] SyS_finit_module+0xe/0x10
> [    6.090204]  [<ffffffffb463d524>] entry_SYSCALL_64_fastpath+0x17/0x98
> [    6.090206] ---[ end trace ea6da61c1ec208d1 ]---
> [    6.090207] rfkill_any_led_trigger unlocked
> [    6.091664] ------------[ cut here ]------------
