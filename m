From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Tue, 12 May 2015 17:14:04 +0200
Message-ID: <2207F40E-D6B1-4CAD-AC0F-DB64F4641B1C@holtmann.org>
References: <1431391928-30732-1-git-send-email-labbott@fedoraproject.org> <66909EC2-B923-4A1D-8622-4DAB2BB37BC3@holtmann.org> <55515B6B.7000100@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Laura Abbott <labbott@fedoraproject.org>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ming Lei <ming.lei@canonical.com>,
	Takashi Iwai <tiwai@suse.de>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
To: Laura Abbott <labbott@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55515B6B.7000100@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Laura,

>>> We've received a number of reports of warnings when coming
>>> out of suspend with certain bluetooth firmware configurations:
>>> 
>>> WARNING: CPU: 3 PID: 3280 at drivers/base/firmware_class.c:1126
>>> _request_firmware+0x558/0x810()
>>> Modules linked in: ccm ip6t_rpfilter ip6t_REJECT nf_reject_ipv6
>>> xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter
>>> ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6
>>> ip6table_mangle ip6table_security ip6table_raw ip6table_filter
>>> ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4
>>> nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw
>>> binfmt_misc bnep intel_rapl iosf_mbi arc4 x86_pkg_temp_thermal
>>> snd_hda_codec_hdmi coretemp kvm_intel joydev snd_hda_codec_realtek
>>> iwldvm snd_hda_codec_generic kvm iTCO_wdt mac80211 iTCO_vendor_support
>>> snd_hda_intel snd_hda_controller snd_hda_codec crct10dif_pclmul
>>> snd_hwdep crc32_pclmul snd_seq crc32c_intel ghash_clmulni_intel uvcvideo
>>> snd_seq_device iwlwifi btusb videobuf2_vmalloc snd_pcm videobuf2_core
>>> serio_raw bluetooth cfg80211 videobuf2_memops sdhci_pci v4l2_common
>>> videodev thinkpad_acpi sdhci i2c_i801 lpc_ich mfd_core wacom mmc_core
>>> media snd_timer tpm_tis hid_logitech_hidpp wmi tpm rfkill snd mei_me mei
>>> shpchp soundcore nfsd auth_rpcgss nfs_acl lockd grace sunrpc i915
>>> i2c_algo_bit drm_kms_helper e1000e drm hid_logitech_dj ptp pps_core
>>> video
>>> CPU: 3 PID: 3280 Comm: kworker/u17:0 Not tainted 3.19.3-200.fc21.x86_64
>>> Hardware name: LENOVO 343522U/343522U, BIOS GCET96WW (2.56 ) 10/22/2013
>>> Workqueue: hci0 hci_power_on [bluetooth]
>>> 0000000000000000 0000000089944328 ffff88040acffb78 ffffffff8176e215
>>> 0000000000000000 0000000000000000 ffff88040acffbb8 ffffffff8109bc1a
>>> 0000000000000000 ffff88040acffcd0 00000000fffffff5 ffff8804076bac40
>>> Call Trace:
>>> [<ffffffff8176e215>] dump_stack+0x45/0x57
>>> [<ffffffff8109bc1a>] warn_slowpath_common+0x8a/0xc0
>>> [<ffffffff8109bd4a>] warn_slowpath_null+0x1a/0x20
>>> [<ffffffff814dbe78>] _request_firmware+0x558/0x810
>>> [<ffffffff814dc165>] request_firmware+0x35/0x50
>>> [<ffffffffa03a7886>] btusb_setup_bcm_patchram+0x86/0x590 [btusb]
>>> [<ffffffff814d40e6>] ? rpm_idle+0xd6/0x230
>>> [<ffffffffa04d4801>] hci_dev_do_open+0xe1/0xa90 [bluetooth]
>>> [<ffffffff810c51dd>] ? ttwu_do_activate.constprop.90+0x5d/0x70
>>> [<ffffffffa04d5980>] hci_power_on+0x40/0x200 [bluetooth]
>>> [<ffffffff810b487c>] process_one_work+0x14c/0x3f0
>>> [<ffffffff810b52f3>] worker_thread+0x53/0x470
>>> [<ffffffff810b52a0>] ? rescuer_thread+0x300/0x300
>>> [<ffffffff810ba548>] kthread+0xd8/0xf0
>>> [<ffffffff810ba470>] ? kthread_create_on_node+0x1b0/0x1b0
>>> [<ffffffff81774958>] ret_from_fork+0x58/0x90
>>> [<ffffffff810ba470>] ? kthread_create_on_node+0x1b0/0x1b0
>>> 
>>> This occurs after every resume.
>>> 
>>> When resuming, the bluetooth stack calls hci_register_dev,
>>> allocates a new workqueue, and immediately schedules the
>>> power_on on the newly created workqueue. Since the new
>>> workqueue is not freezable, the work runs immediately and
>>> triggers the warning since resume is still happening and
>>> usermodehelper has not yet been re-enabled. Fix this by
>>> making the request workqueue freezable. This ensures
>>> the work will not run until unfreezing occurs and usermodehelper
>>> is re-enabled.
>>> 
>>> Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
>>> ---
>>> Resend because I think this got lost in the thread.
>>> This should be fixing the actual root cause of the warnings.
>> 
>> so I am not convinced that it actually fixes the root cause. This is just papering over it.
>> 
>> The problem is pretty clear, the firmware for some of the Bluetooth controllers is optional and that means during the original hotplug event it will not be found and the controller keeps operating. However for some reason instead of actually suspending and resuming the Bluetooth controller, we see a unplug + replug (since we are going through probe) and that is causing this funny behaviour.
>> 
> 
> Fundamentally the issue is the request_firmware is being called at the
> wrong time. From Documentation/workqueue.txt:
> 
>  WQ_FREEZABLE
> 
>        A freezable wq participates in the freeze phase of the system
>        suspend operations.  Work items on the wq are drained and no
>        new work item starts execution until thawed.
> 
> 
> By making the request workqueue freezable, any work that gets scheduled
> will not run until the time for tasks to unthaw.
> 4320f6b1d9db4ca912c5eb6ecb328b2e090e1586
> ("PM / sleep: Fix request_firmware() error at resume") fixed the resume
> path such that before all tasks are unthawed, calls to
> usermodehelper_read_trylock will block until usermodehelper is fully
> resumed. This means that any task which is frozen and then woken up
> again should have the right sequencing for usermodehelper. The workqueue
> which handled the bluetooth power on was never being frozen properly so
> there was never any guarantee of when it would run. This patch gives
> it the necessary sequence.
> 
>> So how does making one of the core workqueues freezable fixes this the right way. I do not even know how many other side effects that might have. That hdev->req_workqueue is a Bluetooth core internal workqueue that we are using for multiple tasks.
>> 
>> Rather tell me on why we are probing the USB devices that might need firmware without having userspace ready. It sounds to me that the USB driver probe callback should be delayed if we can not guarantee that it can request firmware. As I explained many times, the call path that causes this is going through probe callback of the driver itself.
>> 
> 
> I agree that if the driver probe function was requesting firmware
> directly there would be a problem. The power_on function is already
> being called asynchronously on a workqueue. Making that workqueue freezable does exactly the delay you describe.

I am not convinced. Now we are hacking the Bluetooth core layer (which has nothing to do with the drivers suspend/resume or probe) to do something different so that we do not see this warning.

I can not do anything about the platform in question choosing a unplug/replug for suspend/resume instead of having a proper USB suspend and resume handling. That is pretty much out of our control. I would rather have the USB subsystem delay the probe() callback if we tell it to. Of just have request_firmware() actually sleep until userspace is ready. Seriously, why is request_firmware not just sleeping for us.

> The side effects should be limited to the change in behavior of
> draining all work items at freeze time and then not running
> again until task thaw. Do you know of any limitations where
> draining the workqueue at freeze time could not happen or would
> block indefinitely?

Has anybody actually looked at the hdev->req_workqueue usage? You are touching core code now and unless you convince me that this has no impact, then I am cautious first of all.

Regards

Marcel
