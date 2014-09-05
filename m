From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Thu,  4 Sep 2014 23:37:24 -0700
Message-ID: <1409899047-13045-4-git-send-email-mcgrof@do-not-panic.com>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
Cc: linux-kernel@vger.kernel.org, oleg@redhat.com, hare@suse.com,
	akpm@linux-foundation.org, penguin-kernel@i-love.sakura.ne.jp,
	joseph.salisbury@canonical.com, bpoirier@suse.de,
	santosh@chelsio.com, "Luis R. Rodriguez" <mcgrof@suse.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Casey Leedom <leedom@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	falcon@meizu.com, tiwai@suse.de, tj@kernel.org,
	arjan@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

The new umh kill option has allowed kthreads to receive
kill signals but they are generally accepting all sources
of kill signals while the original motivation was to enable
through the OOM from sending the kill. One particular user
which has been found to send kill signals on kthreads is
systemd, it does this upon a 30 second default timeout on
loading modules. That timeout was in place under the
assumption that some driver's init sequences were taking
long. Since the kernel batches both init and probe together
though its actually been the probe routines which take
long. These should not be penalized, the kill would only
happen if and only if the driver's probe routine ends up
using kthreads somehow. To help with this we now have the
async_probe flag for drivers but before we can amend
drivers with this functionality we need to find them. This
patch addresses that by avoiding the kill from any other
source than the OOM killer -- for now.

Users can provide a log output and it should be clear on
the trace what probe / driver got the kill signal.

This patch is based on Tetsuo's patch [0] to try to address
the timeout issue, which in itself is based on Tetsuo's
original patch to also address this months ago [1]. These
patches just lacked addressing all other callers which
would load modules for us. Although Oleg had rejected a
similar change a while ago [2] its now clear what the
source of the problem. A few solutions have been proposed,
one of them was to allow the default systemd timeout to be
modified, that change by Hannes Reinecke is now merged
upstream on systemd, we still however need a non fatal
way to deal with modules that take long and an easy way
for us to find these modules. At least one proposal has
been made for systemd but discussions on that approach
hasn't gotten much traction [3] so we need to address
this on the kernel, this will also be important for users
of new kernels on old versions of systemd.

[0] https://launchpadlibrarian.net/169657493/kthread-defer-leaving.patch
[1] https://lkml.org/lkml/2014/7/29/284
[2] http://article.gmane.org/gmane.linux.kernel/1669604
[3] http://lists.freedesktop.org/archives/systemd-devel/2014-August/021852.html

An example log output captured by purposely breaking the iwlwifi
driver by using ssleep(33) on probe:

[   43.853997] iwlwifi going to sleep for 33 seconds
[   76.862975] iwlwifi done sleeping for 33 seconds
[   76.863880] iwlwifi 0000:03:00.0: irq 34 for MSI/MSI-X
[   76.863961] ------------[ cut here ]------------
[   76.864648] WARNING: CPU: 0 PID: 479 at kernel/kthread.c:308 kthread_create_on_node+0x1ea/0x200()
[   76.865309] Got SIGKILL but not from OOM, if this issue is on probe use .driver.async_probe
[   76.865974] Modules linked in: xfs libcrc32c x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_hwdep aes_x86_64 uvcvideo glue_helper videobuf2_vmalloc lrw gf128mul snd_pcm ablk_helper iTCO_wdt rtsx_pci_ms videobuf2_memops videobuf2_core rtsx_pci_sdmmc v4l2_common mmc_core videodev snd_timer thinkpad_acpi memstick iTCO_vendor_support snd mei_me rtsx_pci cryptd iwlwifi(+) mei shpchp tpm_tis soundcore pcspkr joydev lpc_ich mfd_core serio_raw tpm btusb wmi i2c_i801 thermal intel_smartconnect ac battery processor dm_mod btrfs xor raid6_pq i915 i2c_algo_bit e1000e drm_kms_helper sr_mod crc32c_intel cdrom xhci
 _hcd drm video
[   76.869197]  button sg
[   76.870035] CPU: 0 PID: 479 Comm: systemd-udevd Not tainted 3.17.0-rc3-25.g1474ea5-desktop+ #12
[   76.870915] Hardware name: LENOVO 20AW000LUS/20AW000LUS, BIOS GLET43WW (1.18 ) 12/04/2013
[   76.871801]  0000000000000009 ffff8802133a3908 ffffffff8173960f ffff8802133a3950
[   76.872771]  ffff8802133a3940 ffffffff81072eed ffff8800c9004480 ffffffff810c8fd0
[   76.873693]  ffffffff81a77845 00000000ffffffff ffff8800c9d2abc0 ffff8802133a39a0
[   76.874620] Call Trace:
[   76.875522]  [<ffffffff8173960f>] dump_stack+0x4d/0x6f
[   76.876379]  [<ffffffff81072eed>] warn_slowpath_common+0x7d/0xa0
[   76.877286]  [<ffffffff810c8fd0>] ? irq_thread_check_affinity+0xb0/0xb0
[   76.878177]  [<ffffffff81072f5c>] warn_slowpath_fmt+0x4c/0x50
[   76.879048]  [<ffffffff810c8fd0>] ? irq_thread_check_affinity+0xb0/0xb0
[   76.879898]  [<ffffffff8108fdea>] kthread_create_on_node+0x1ea/0x200
[   76.880765]  [<ffffffff811bf50e>] ? enable_cpucache+0x4e/0xe0
[   76.881617]  [<ffffffff810c9c55>] __setup_irq+0x165/0x580
[   76.882459]  [<ffffffff8101bca6>] ? dma_generic_alloc_coherent+0x146/0x160
[   76.883314]  [<ffffffffa03cf780>] ? iwl_pcie_disable_ict+0x40/0x40 [iwlwifi]
[   76.884159]  [<ffffffff810ca1cf>] request_threaded_irq+0xcf/0x180
[   76.885010]  [<ffffffffa03d6efa>] iwl_trans_pcie_alloc+0x35a/0x4b1 [iwlwifi]
[   76.885861]  [<ffffffffa03cd3c0>] iwl_pci_probe+0x50/0x260 [iwlwifi]
[   76.886646]  [<ffffffff8146a59d>] ? __pm_runtime_resume+0x4d/0x60
[   76.887404]  [<ffffffff81383595>] local_pci_probe+0x45/0xa0
[   76.888155]  [<ffffffff81384795>] ? pci_match_device+0xe5/0x110
[   76.888899]  [<ffffffff813848d9>] pci_device_probe+0xd9/0x130
[   76.889646]  [<ffffffff8146090d>] driver_probe_device+0x12d/0x3e0
[   76.890391]  [<ffffffff81460c93>] __driver_attach+0x93/0xa0
[   76.891132]  [<ffffffff81460c00>] ? __device_attach+0x40/0x40
[   76.891870]  [<ffffffff8145e713>] bus_for_each_dev+0x63/0xa0
[   76.892763]  [<ffffffff814602de>] driver_attach+0x1e/0x20
[   76.893528]  [<ffffffff8145fe4e>] bus_add_driver+0xfe/0x270
[   76.894292]  [<ffffffffa036d000>] ? 0xffffffffa036d000
[   76.895118]  [<ffffffff814614e4>] driver_register+0x64/0xf0
[   76.895847]  [<ffffffff81382f1c>] __pci_register_driver+0x4c/0x50
[   76.896615]  [<ffffffffa03cd5f4>] iwl_pci_register_driver+0x24/0x40 [iwlwifi]
[   76.896619]  [<ffffffffa036d085>] iwl_drv_init+0x85/0x1000 [iwlwifi]
[   76.896621]  [<ffffffff81002144>] do_one_initcall+0xd4/0x210
[   76.896624]  [<ffffffff811a49e4>] ? __vunmap+0x94/0x100
[   76.896626]  [<ffffffff810f34d5>] load_module+0x1f25/0x2670
[   76.896627]  [<ffffffff810ef170>] ? store_uevent+0x40/0x40
[   76.896630]  [<ffffffff810f3d96>] SyS_finit_module+0x86/0xb0
[   76.896632]  [<ffffffff817413ed>] system_call_fastpath+0x1a/0x1f
[   76.896632] ---[ end trace 9a32581b585745d8 ]---
[   76.982019] iwlwifi 0000:03:00.0: loaded firmware version 23.214.9.0 op_mode iwlmvm
[   77.174150] iwlwifi 0000:03:00.0: Detected Intel(R) Dual Band Wireless AC 7260, REV=0x144
[   77.174952] iwlwifi 0000:03:00.0: L1 Enabled; Disabling L0S
[   77.175955] iwlwifi 0000:03:00.0: L1 Enabled; Disabling L0S

Cc: Tejun Heo <tj@kernel.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Joseph Salisbury <joseph.salisbury@canonical.com>
Cc: Kay Sievers <kay@vrfy.org>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Tim Gardner <tim.gardner@canonical.com>
Cc: Pierre Fersing <pierre-fersing@pierref.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Benjamin Poirier <bpoirier@suse.de>
Cc: Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>
Cc: Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>
Cc: Sreekanth Reddy <sreekanth.reddy@avagotech.com>
Cc: Abhijit Mahajan <abhijit.mahajan@avagotech.com>
Cc: Casey Leedom <leedom@chelsio.com>
Cc: Hariprasad S <hariprasad@chelsio.com>
Cc: Santosh Rastapur <santosh@chelsio.com>
Cc: MPT-FusionLinux.pdl@avagotech.com
Cc: linux-scsi@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 kernel/kmod.c    | 21 +++++++++++++++++++--
 kernel/kthread.c | 19 +++++++++++++++++++
 2 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/kernel/kmod.c b/kernel/kmod.c
index 8637e04..b22228c 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -596,16 +596,33 @@ int call_usermodehelper_exec(struct subprocess_info *sub_info, int wait)
 		goto unlock;
 
 	if (wait & UMH_KILLABLE) {
+		unsigned int i;
+
 		retval = wait_for_completion_killable(&done);
-		if (!retval)
+		if (likely(!retval))
 			goto wait_done;
 
+		/*
+		 * I got SIGKILL, but wait for 60 more seconds for completion
+		 * unless chosen by the OOM killer. This delay is there as a
+		 * workaround for boot failure caused by SIGKILL upon device
+		 * driver initialization timeout.
+		 *
+		 * N.B. this will actually let the thread complete regularly,
+		 * wait_for_completion() will be used eventually, the 60 second
+		 * try here is just to check for the OOM over that time.
+		 */
+		WARN_ONCE(!test_thread_flag(TIF_MEMDIE),
+			  "Got SIGKILL but not from OOM, if this issue is on probe use .driver.async_probe\n");
+		for (i = 0; i < 60 && !test_thread_flag(TIF_MEMDIE); i++)
+			if (wait_for_completion_timeout(&done, HZ))
+				goto wait_done;
+
 		/* umh_complete() will see NULL and free sub_info */
 		if (xchg(&sub_info->complete, NULL))
 			goto unlock;
 		/* fallthrough, umh_complete() was already called */
 	}
-
 	wait_for_completion(&done);
 wait_done:
 	retval = sub_info->retval;
diff --git a/kernel/kthread.c b/kernel/kthread.c
index ef48322..bfb6dbe 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -292,6 +292,24 @@ struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
 	 * new kernel thread.
 	 */
 	if (unlikely(wait_for_completion_killable(&done))) {
+		unsigned int i;
+
+		/*
+		 * I got SIGKILL, but wait for 10 more seconds for completion
+		 * unless chosen by the OOM killer. This delay is there as a
+		 * workaround for boot failure caused by SIGKILL upon device
+		 * driver initialization timeout.
+		 *
+		 * N.B. this will actually let the thread complete regularly,
+		 * wait_for_completion() will be used eventually, the 10 second
+		 * try here is just to check for the OOM over that time.
+		 */
+		WARN_ONCE(!test_thread_flag(TIF_MEMDIE),
+			  "Got SIGKILL but not from OOM, if this issue is on probe use .driver.async_probe\n");
+		for (i = 0; i < 10 && !test_thread_flag(TIF_MEMDIE); i++)
+			if (wait_for_completion_timeout(&done, HZ))
+				goto ready;
+
 		/*
 		 * If I was SIGKILLed before kthreadd (or new kernel thread)
 		 * calls complete(), leave the cleanup of this structure to
@@ -305,6 +323,7 @@ struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
 		 */
 		wait_for_completion(&done);
 	}
+ready:
 	task = create->result;
 	if (!IS_ERR(task)) {
 		static const struct sched_param param = { .sched_priority = 0 };
-- 
2.0.3
