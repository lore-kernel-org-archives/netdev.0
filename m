From: Laura Abbott <labbott@fedoraproject.org>
Subject: [PATCH] Bluetooth: Make request workqueue freezable
Date: Tue,  5 May 2015 17:06:01 -0700
Message-ID: <1430870761-31720-1-git-send-email-labbott@fedoraproject.org>
References: <5543E097.7000004@redhat.com>
Cc: Laura Abbott <labbott@fedoraproject.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ming Lei <ming.lei@canonical.com>,
	Takashi Iwai <tiwai@suse.de>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
To: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5543E097.7000004@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We've received a number of reports of warnings when coming
out of suspend with certain bluetooth firmware configurations:

WARNING: CPU: 3 PID: 3280 at drivers/base/firmware_class.c:1126
_request_firmware+0x558/0x810()
Modules linked in: ccm ip6t_rpfilter ip6t_REJECT nf_reject_ipv6
xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter
ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6
ip6table_mangle ip6table_security ip6table_raw ip6table_filter
ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4
nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw
binfmt_misc bnep intel_rapl iosf_mbi arc4 x86_pkg_temp_thermal
snd_hda_codec_hdmi coretemp kvm_intel joydev snd_hda_codec_realtek
iwldvm snd_hda_codec_generic kvm iTCO_wdt mac80211 iTCO_vendor_support
snd_hda_intel snd_hda_controller snd_hda_codec crct10dif_pclmul
snd_hwdep crc32_pclmul snd_seq crc32c_intel ghash_clmulni_intel uvcvideo
snd_seq_device iwlwifi btusb videobuf2_vmalloc snd_pcm videobuf2_core
 serio_raw bluetooth cfg80211 videobuf2_memops sdhci_pci v4l2_common
videodev thinkpad_acpi sdhci i2c_i801 lpc_ich mfd_core wacom mmc_core
media snd_timer tpm_tis hid_logitech_hidpp wmi tpm rfkill snd mei_me mei
shpchp soundcore nfsd auth_rpcgss nfs_acl lockd grace sunrpc i915
i2c_algo_bit drm_kms_helper e1000e drm hid_logitech_dj ptp pps_core
video
CPU: 3 PID: 3280 Comm: kworker/u17:0 Not tainted 3.19.3-200.fc21.x86_64
Hardware name: LENOVO 343522U/343522U, BIOS GCET96WW (2.56 ) 10/22/2013
Workqueue: hci0 hci_power_on [bluetooth]
 0000000000000000 0000000089944328 ffff88040acffb78 ffffffff8176e215
 0000000000000000 0000000000000000 ffff88040acffbb8 ffffffff8109bc1a
 0000000000000000 ffff88040acffcd0 00000000fffffff5 ffff8804076bac40
Call Trace:
 [<ffffffff8176e215>] dump_stack+0x45/0x57
 [<ffffffff8109bc1a>] warn_slowpath_common+0x8a/0xc0
 [<ffffffff8109bd4a>] warn_slowpath_null+0x1a/0x20
 [<ffffffff814dbe78>] _request_firmware+0x558/0x810
 [<ffffffff814dc165>] request_firmware+0x35/0x50
 [<ffffffffa03a7886>] btusb_setup_bcm_patchram+0x86/0x590 [btusb]
 [<ffffffff814d40e6>] ? rpm_idle+0xd6/0x230
 [<ffffffffa04d4801>] hci_dev_do_open+0xe1/0xa90 [bluetooth]
 [<ffffffff810c51dd>] ? ttwu_do_activate.constprop.90+0x5d/0x70
 [<ffffffffa04d5980>] hci_power_on+0x40/0x200 [bluetooth]
 [<ffffffff810b487c>] process_one_work+0x14c/0x3f0
 [<ffffffff810b52f3>] worker_thread+0x53/0x470
 [<ffffffff810b52a0>] ? rescuer_thread+0x300/0x300
 [<ffffffff810ba548>] kthread+0xd8/0xf0
 [<ffffffff810ba470>] ? kthread_create_on_node+0x1b0/0x1b0
 [<ffffffff81774958>] ret_from_fork+0x58/0x90
 [<ffffffff810ba470>] ? kthread_create_on_node+0x1b0/0x1b0

This occurs after every resume.

When resuming, the bluetooth stack calls hci_register_dev,
allocates a new workqueue, and immediately schedules the
power_on on the newly created workqueue. Since the new
workqueue is not freezable, the work runs immediately and
triggers the warning since resume is still happening and
usermodehelper has not yet been re-enabled. Fix this by
making the request workqueue freezable. This ensures
the work will not run until unfreezing occurs and usermodehelper
is re-enabled.

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
---
I think this should be fixing the actual root cause.
---
 net/bluetooth/hci_core.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 476709b..87f2e48 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -3131,7 +3131,8 @@ int hci_register_dev(struct hci_dev *hdev)
 	}
 
 	hdev->req_workqueue = alloc_workqueue("%s", WQ_HIGHPRI | WQ_UNBOUND |
-					      WQ_MEM_RECLAIM, 1, hdev->name);
+					      WQ_MEM_RECLAIM | WQ_FREEZABLE,
+					      1, hdev->name);
 	if (!hdev->req_workqueue) {
 		destroy_workqueue(hdev->workqueue);
 		error = -ENOMEM;
-- 
2.1.0
