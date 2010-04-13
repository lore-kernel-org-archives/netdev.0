From: Richard Zidlicky <rz@linux-m68k.org>
Subject: usb-sound circular locking again?
Date: Tue, 13 Apr 2010 22:30:39 +0200
Message-ID: <20100413203039.GC8468@linux-m68k.org>
References: <20091206141419.GA6195@linux-m68k.org> <20091207143057.53c6a362.akpm@linux-foundation.org> <20091208002353.GA30011@linux-m68k.org> <20091207164826.eb2bbc48.akpm@linux-foundation.org> <s5hocm9som6.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Takashi Iwai <tiwai@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:48305 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753812Ab0DMU3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 16:29:02 -0400
Content-Disposition: inline
In-Reply-To: <s5hocm9som6.wl%tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

is this the same old issue? Any way to fix it? Seeing it triggered in a sync
syscall does not make me comfortable.

Apr 13 02:01:36 localhost kernel: [ 8569.449882] PM: Syncing filesystems ... 
Apr 13 02:01:36 localhost kernel: [ 8569.449998] =======================================================
Apr 13 02:01:36 localhost kernel: [ 8569.450049] [ INFO: possible circular locking dependency detected ]
Apr 13 02:01:36 localhost kernel: [ 8569.450078] 2.6.33.2v2 #4
Apr 13 02:01:36 localhost kernel: [ 8569.450101] -------------------------------------------------------
Apr 13 02:01:36 localhost kernel: [ 8569.450130] pm-hibernate/17348 is trying to acquire lock:
Apr 13 02:01:36 localhost kernel: [ 8569.450158]  (mutex){+.+...}, at: [<c04e6670>] sync_filesystems+0x14/0xd6
Apr 13 02:01:36 localhost kernel: [ 8569.450252] 
Apr 13 02:01:36 localhost kernel: [ 8569.450253] but task is already holding lock:
Apr 13 02:01:36 localhost kernel: [ 8569.450266]  (pm_mutex){+.+.+.}, at: [<c0466658>] hibernate+0x13/0x18d
Apr 13 02:01:36 localhost kernel: [ 8569.450266] 
Apr 13 02:01:36 localhost kernel: [ 8569.450266] which lock already depends on the new lock.
Apr 13 02:01:36 localhost kernel: [ 8569.450266] 
Apr 13 02:01:36 localhost kernel: [ 8569.450266] 
Apr 13 02:01:36 localhost kernel: [ 8569.450266] the existing dependency chain (in reverse order) is:
Apr 13 02:01:36 localhost kernel: [ 8569.450266] 
Apr 13 02:01:36 localhost kernel: [ 8569.450266] -> #6 (pm_mutex){+.+.+.}:
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c045b60a>] __lock_acquire+0xa2d/0xbb7
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c045b828>] lock_acquire+0x94/0xb1
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c0736d84>] __mutex_lock_common+0x35/0x2f3
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c07370e0>] mutex_lock_nested+0x30/0x38
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c0466658>] hibernate+0x13/0x18d
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c046551c>] state_store+0x56/0xa8
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c05acb19>] kobj_attr_store+0x1a/0x22
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c050f306>] sysfs_write_file+0xb9/0xe4
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c04cc821>] vfs_write+0x84/0xdf
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c04cc915>] sys_write+0x3b/0x60
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c0738295>] syscall_call+0x7/0xb
Apr 13 02:01:36 localhost kernel: [ 8569.450266] 
Apr 13 02:01:36 localhost kernel: [ 8569.450266] -> #5 (s_active){++++.+}:
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c045b60a>] __lock_acquire+0xa2d/0xbb7
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c045b828>] lock_acquire+0x94/0xb1
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c05102f8>] sysfs_addrm_finish+0x89/0xde
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c050eaf7>] sysfs_hash_and_remove+0x3d/0x4f
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c0511100>] sysfs_remove_group+0x74/0xa3
Apr 13 02:01:36 localhost kernel: [ 8569.450266]        [<c062e16c>] dpm_sysfs_remove+0x10/0x12
Apr 13 09:39:32 localhost kernel: [ 8569.450266]        [<c062933f>] device_del+0x33/0x154
Apr 13 09:39:34 localhost kernel: [ 8569.450266]        [<c0629488>] device_unregister+0x28/0x4b
Apr 13 09:39:34 localhost kernel: [ 8569.450266]        [<c067b7c5>] usb_remove_ep_devs+0x15/0x1f
Apr 13 09:39:34 localhost kernel: [ 8569.450266]        [<c0675c92>] remove_intf_ep_devs+0x21/0x32
Apr 13 09:39:34 localhost kernel: [ 8569.450266]        [<c0676d53>] usb_set_interface+0x18c/0x22c
Apr 13 09:39:34 localhost kernel: [ 8569.450266]        [<f8302c46>] snd_usb_capture_close+0x26/0x3f [snd_usb_audio]
Apr 13 09:39:34 localhost kernel: [ 8569.450266]        [<f80fbb08>] snd_pcm_release_substream+0x3d/0x66 [snd_pcm]
Apr 13 09:39:34 localhost kernel: [ 8569.450266]        [<f80fbb8d>] snd_pcm_release+0x5c/0x9e [snd_pcm]
Apr 13 09:39:34 localhost kernel: [ 8569.450266]        [<c04cd12a>] __fput+0xf0/0x187
Apr 13 09:39:34 localhost kernel: [ 8569.450266]        [<c04cd1da>] fput+0x19/0x1b
Apr 13 09:39:34 localhost kernel: [ 8569.450266]        [<c04b2e9f>] remove_vma+0x3e/0x5d
Apr 13 09:39:34 localhost kernel: [ 8569.450266]        [<c04b3b2a>] do_munmap+0x23c/0x259
Apr 13 09:39:34 localhost kernel: [ 8569.450266]        [<c04b3b77>] sys_munmap+0x30/0x3f
Apr 13 09:39:34 localhost kernel: [ 8569.450266]        [<c0738295>] syscall_call+0x7/0xb
Apr 13 09:39:34 localhost kernel: [ 8569.450266] 
Apr 13 09:39:34 localhost kernel: [ 8569.450266] -> #4 (&pcm->open_mutex){+.+.+.}:
Apr 13 09:39:34 localhost kernel: [ 8569.454127]        [<c045b60a>] __lock_acquire+0xa2d/0xbb7
Apr 13 09:39:34 localhost kernel: [ 8569.454127]        [<c045b828>] lock_acquire+0x94/0xb1
Apr 13 09:39:34 localhost kernel: [ 8569.454127]        [<c0736d84>] __mutex_lock_common+0x35/0x2f3
Apr 13 09:39:34 localhost kernel: [ 8569.454127]        [<c07370e0>] mutex_lock_nested+0x30/0x38
Apr 13 09:39:34 localhost kernel: [ 8569.454127]        [<f80fbb86>] snd_pcm_release+0x55/0x9e [snd_pcm]
Apr 13 09:39:34 localhost kernel: [ 8569.454127]        [<c04cd12a>] __fput+0xf0/0x187
Apr 13 09:39:34 localhost kernel: [ 8569.454127]        [<c04cd1da>] fput+0x19/0x1b
Apr 13 09:39:34 localhost kernel: [ 8569.454127]        [<c04b2e9f>] remove_vma+0x3e/0x5d
Apr 13 09:39:34 localhost kernel: [ 8569.454127]        [<c04b3b2a>] do_munmap+0x23c/0x259
Apr 13 09:39:34 localhost kernel: [ 8569.454127]        [<c04b3b77>] sys_munmap+0x30/0x3f
Apr 13 09:39:34 localhost kernel: [ 8569.455127]        [<c0738295>] syscall_call+0x7/0xb
Apr 13 09:39:34 localhost kernel: [ 8569.455127] 
Apr 13 09:39:34 localhost kernel: [ 8569.455127] -> #3 (&mm->mmap_sem){++++++}:
Apr 13 09:39:34 localhost kernel: [ 8569.455127]        [<c045b60a>] __lock_acquire+0xa2d/0xbb7
Apr 13 09:39:34 localhost kernel: [ 8569.455127]        [<c045b828>] lock_acquire+0x94/0xb1
Apr 13 09:39:34 localhost kernel: [ 8569.455127]        [<c04add1a>] might_fault+0x64/0x81
Apr 13 09:39:34 localhost kernel: [ 8569.455127]        [<c05b3828>] copy_to_user+0x2c/0xfc
Apr 13 09:39:34 localhost kernel: [ 8569.455127]        [<c04d784b>] filldir64+0x97/0xcd
Apr 13 09:39:34 localhost kernel: [ 8569.455127]        [<c04e299c>] dcache_readdir+0x5a/0x1af
Apr 13 09:39:34 localhost kernel: [ 8569.456129]        [<c04d7a5d>] vfs_readdir+0x68/0x94
Apr 13 09:39:34 localhost kernel: [ 8569.456129]        [<c04d7aec>] sys_getdents64+0x63/0xa0
Apr 13 09:39:34 localhost kernel: [ 8569.456129]        [<c0738295>] syscall_call+0x7/0xb
Apr 13 09:39:34 localhost kernel: [ 8569.456129] 
Apr 13 09:39:34 localhost kernel: [ 8569.456129] -> #2 (&sb->s_type->i_mutex_key#3){+.+.+.}:
Apr 13 09:39:34 localhost kernel: [ 8569.456129]        [<c045b60a>] __lock_acquire+0xa2d/0xbb7
Apr 13 09:39:34 localhost kernel: [ 8569.456129]        [<c045b828>] lock_acquire+0x94/0xb1
Apr 13 09:39:34 localhost kernel: [ 8569.456129]        [<c0736d84>] __mutex_lock_common+0x35/0x2f3
Apr 13 09:39:34 localhost kernel: [ 8569.456129]        [<c07370e0>] mutex_lock_nested+0x30/0x38
Apr 13 09:39:34 localhost kernel: [ 8569.456129]        [<c051164f>] devpts_get_sb+0x1c0/0x29f
Apr 13 09:39:34 localhost kernel: [ 8569.456129]        [<c04ce0db>] vfs_kern_mount+0x86/0x11f
Apr 13 09:39:34 localhost kernel: [ 8569.456129]        [<c04ce1b8>] do_kern_mount+0x32/0xbe
Apr 13 09:39:34 localhost kernel: [ 8569.456129]        [<c04e02c2>] do_mount+0x671/0x6d0
Apr 13 09:39:34 localhost kernel: [ 8569.456129]        [<c04e0382>] sys_mount+0x61/0x8f
Apr 13 09:39:34 localhost kernel: [ 8569.456129]        [<c0738295>] syscall_call+0x7/0xb
Apr 13 09:39:34 localhost kernel: [ 8569.456129] 
Apr 13 09:39:34 localhost kernel: [ 8569.456129] -> #1 (&type->s_umount_key#19){++++..}:
Apr 13 09:39:34 localhost kernel: [ 8569.458127]        [<c045b60a>] __lock_acquire+0xa2d/0xbb7
Apr 13 09:39:34 localhost kernel: [ 8569.458127]        [<c045b828>] lock_acquire+0x94/0xb1
Apr 13 09:39:34 localhost kernel: [ 8569.458127]        [<c0737310>] down_read+0x31/0x45
Apr 13 09:39:34 localhost kernel: [ 8569.458127]        [<c04e66cf>] sync_filesystems+0x73/0xd6
Apr 13 09:39:34 localhost kernel: [ 8569.458127]        [<c04e676e>] sys_sync+0x11/0x2d
Apr 13 09:39:34 localhost kernel: [ 8569.458127]        [<c0738295>] syscall_call+0x7/0xb
Apr 13 09:39:34 localhost kernel: [ 8569.458127] 
Apr 13 09:39:34 localhost kernel: [ 8569.458127] -> #0 (mutex){+.+...}:
Apr 13 09:39:34 localhost kernel: [ 8569.458127]        [<c045b517>] __lock_acquire+0x93a/0xbb7
Apr 13 09:39:34 localhost kernel: [ 8569.458127]        [<c045b828>] lock_acquire+0x94/0xb1
Apr 13 09:39:34 localhost kernel: [ 8569.458127]        [<c0736d84>] __mutex_lock_common+0x35/0x2f3
Apr 13 09:39:34 localhost kernel: [ 8569.458127]        [<c07370e0>] mutex_lock_nested+0x30/0x38
Apr 13 09:39:34 localhost kernel: [ 8569.458127]        [<c04e6670>] sync_filesystems+0x14/0xd6
Apr 13 09:39:34 localhost kernel: [ 8569.458127]        [<c04e676e>] sys_sync+0x11/0x2d
Apr 13 09:39:34 localhost kernel: [ 8569.458127]        [<c04666c2>] hibernate+0x7d/0x18d
Apr 13 09:39:34 localhost kernel: [ 8569.459761]        [<c046551c>] state_store+0x56/0xa8
Apr 13 09:39:34 localhost kernel: [ 8569.459761]        [<c05acb19>] kobj_attr_store+0x1a/0x22
Apr 13 09:39:34 localhost kernel: [ 8569.459761]        [<c050f306>] sysfs_write_file+0xb9/0xe4
Apr 13 09:39:34 localhost kernel: [ 8569.459761]        [<c04cc821>] vfs_write+0x84/0xdf
Apr 13 09:39:34 localhost kernel: [ 8569.460128]        [<c04cc915>] sys_write+0x3b/0x60
Apr 13 09:39:34 localhost kernel: [ 8569.460128]        [<c0738295>] syscall_call+0x7/0xb
Apr 13 09:39:34 localhost kernel: [ 8569.460128] 
Apr 13 09:39:34 localhost kernel: [ 8569.460128] other info that might help us debug this:
Apr 13 09:39:34 localhost kernel: [ 8569.460128] 
Apr 13 09:39:34 localhost kernel: [ 8569.460128] 4 locks held by pm-hibernate/17348:
Apr 13 09:39:34 localhost kernel: [ 8569.460128]  #0:  (&buffer->mutex){+.+.+.}, at: [<c050f272>] sysfs_write_file+0x25/0xe4
Apr 13 09:39:34 localhost kernel: [ 8569.460128]  #1:  (s_active){++++.+}, at: [<c0510544>] sysfs_get_active_two+0x16/0x36
Apr 13 09:39:34 localhost kernel: [ 8569.461127]  #2:  (s_active){++++.+}, at: [<c051054f>] sysfs_get_active_two+0x21/0x36
Apr 13 09:39:34 localhost kernel: [ 8569.461127]  #3:  (pm_mutex){+.+.+.}, at: [<c0466658>] hibernate+0x13/0x18d
Apr 13 09:39:34 localhost kernel: [ 8569.461127] 
Apr 13 09:39:34 localhost kernel: [ 8569.461127] stack backtrace:
Apr 13 09:39:34 localhost kernel: [ 8569.461127] Pid: 17348, comm: pm-hibernate Not tainted 2.6.33.2v2 #4
Apr 13 09:39:34 localhost kernel: [ 8569.461127] Call Trace:
Apr 13 09:39:34 localhost kernel: [ 8569.461127]  [<c0735b79>] ? printk+0xf/0x16
Apr 13 09:39:34 localhost kernel: [ 8569.461127]  [<c045a8a0>] print_circular_bug+0x90/0x9c
Apr 13 09:39:34 localhost kernel: [ 8569.462128]  [<c045b517>] __lock_acquire+0x93a/0xbb7
Apr 13 09:39:34 localhost kernel: [ 8569.462128]  [<c042730d>] ? update_curr+0x177/0x17f
Apr 13 09:39:34 localhost kernel: [ 8569.462128]  [<c0459bf5>] ? mark_lock+0x1e/0x1ea
Apr 13 09:39:34 localhost kernel: [ 8569.462128]  [<c045b828>] lock_acquire+0x94/0xb1
Apr 13 09:39:34 localhost kernel: [ 8569.462128]  [<c04e6670>] ? sync_filesystems+0x14/0xd6
Apr 13 09:39:34 localhost kernel: [ 8569.462128]  [<c0736d84>] __mutex_lock_common+0x35/0x2f3
Apr 13 09:39:34 localhost kernel: [ 8569.462128]  [<c04e6670>] ? sync_filesystems+0x14/0xd6
Apr 13 09:39:34 localhost kernel: [ 8569.462128]  [<c04e3423>] ? bdi_alloc_queue_work+0x84/0xa0
Apr 13 09:39:34 localhost kernel: [ 8569.462128]  [<c07370e0>] mutex_lock_nested+0x30/0x38
Apr 13 09:39:34 localhost kernel: [ 8569.462128]  [<c04e6670>] ? sync_filesystems+0x14/0xd6
Apr 13 09:39:34 localhost kernel: [ 8569.462128]  [<c04e6670>] sync_filesystems+0x14/0xd6
Apr 13 09:39:34 localhost kernel: [ 8569.462128]  [<c04e676e>] sys_sync+0x11/0x2d
Apr 13 09:39:34 localhost kernel: [ 8569.463127]  [<c04666c2>] hibernate+0x7d/0x18d
Apr 13 09:39:34 localhost kernel: [ 8569.463127]  [<c04654c6>] ? state_store+0x0/0xa8
Apr 13 09:39:34 localhost kernel: [ 8569.463127]  [<c046551c>] state_store+0x56/0xa8
Apr 13 09:39:34 localhost kernel: [ 8569.463127]  [<c04654c6>] ? state_store+0x0/0xa8
Apr 13 09:39:34 localhost kernel: [ 8569.463127]  [<c05acb19>] kobj_attr_store+0x1a/0x22
Apr 13 09:39:34 localhost kernel: [ 8569.463127]  [<c050f306>] sysfs_write_file+0xb9/0xe4
Apr 13 09:39:34 localhost kernel: [ 8569.463127]  [<c050f24d>] ? sysfs_write_file+0x0/0xe4
Apr 13 09:39:34 localhost kernel: [ 8569.463127]  [<c04cc821>] vfs_write+0x84/0xdf
Apr 13 09:39:34 localhost kernel: [ 8569.463127]  [<c04cc915>] sys_write+0x3b/0x60
Apr 13 09:39:34 localhost kernel: [ 8569.463127]  [<c0738295>] syscall_call+0x7/0xb
Apr 13 09:39:34 localhost kernel: [ 8569.484133] done.

Apr 13 09:39:34 localhost kernel: [ 8569.484223] Freezing user space processes ... (elapsed 0.04 seconds) done.
Apr 13 09:39:34 localhost kernel: [ 8569.528142] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
Apr 13 09:39:34 localhost kernel: [ 8569.539272] PM: Preallocating image memory... done (allocated 349210 pages)
Apr 13 09:39:34 localhost kernel: [ 8583.627118] PM: Allocated 1396840 kbytes in 14.08 seconds (99.20 MB/s)

Regards,
Richard

