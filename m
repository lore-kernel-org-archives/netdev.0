From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.32 regression, hard lock
Date: Mon, 7 Dec 2009 16:48:26 -0800
Message-ID: <20091207164826.eb2bbc48.akpm@linux-foundation.org>
References: <20091206141419.GA6195@linux-m68k.org>
	<20091207143057.53c6a362.akpm@linux-foundation.org>
	<20091208002353.GA30011@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Takashi Iwai <tiwai@suse.de>
To: Richard Zidlicky <rz@linux-m68k.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965297AbZLHAtM@vger.kernel.org>
In-Reply-To: <20091208002353.GA30011@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Dec 2009 01:23:53 +0100
Richard Zidlicky <rz@linux-m68k.org> wrote:

> 
> > > first visible symptom is that ppp over UMTS connection "stops working", connection
> > > did not die. Trying to restart the connection fails and the related processes hang.
> > > 
> > > After that one after another everything stops working, "telinit 6" does not do its
> > > job and SysRQ sync-umount-reboot is logged in messages but has no visible effect.
> > > 
> > > Attaching messages and .config.
> > > 
> > 
> > I uploaded your dmesg output to
> > http://userweb.kernel.org/~akpm/stuff/messages.txt
> 
> > 
> > I'm looking at those traces and am not able to develop a theory to
> > explain it :(
> 
> thanks for looking at it. 
> 
> I did revert to 2.31.5 and to my big surprise found a similar thing happened
> so it is not a regression, at least not from 2.6.31.

This trace is different.  It's a lock ranking warning and is surely
unrelated to the IRQs-off lockup which you earlier experienced.

> No idea why it did not occur anytime sooner while running earlier kernels, however
> the most recently plugged in device is an USB webcam with micro which I am suspecting
> to play a role in this message (posted more details about it earlier):
> 
> Dec  6 10:31:39 localhost kernel: [  162.087836] =======================================================
> Dec  6 10:31:39 localhost kernel: [  162.087839] [ INFO: possible circular locking dependency detected ]
> Dec  6 10:31:39 localhost kernel: [  162.087842] 2.6.32v0 #1
> Dec  6 10:31:39 localhost kernel: [  162.087844] -------------------------------------------------------
> Dec  6 10:31:39 localhost kernel: [  162.087846] pulseaudio/4506 is trying to acquire lock:
> Dec  6 10:31:39 localhost kernel: [  162.087848]  (sysfs_mutex){+.+.+.}, at: [<c050c99d>] sysfs_get_dirent+0x15/0x35
> Dec  6 10:31:39 localhost kernel: [  162.087857]
> Dec  6 10:31:39 localhost kernel: [  162.087858] but task is already holding lock:
> Dec  6 10:31:39 localhost kernel: [  162.087860]  (&pcm->open_mutex){+.+.+.}, at: [<f80f4b2a>] snd_pcm_release+0x55/0x9e [snd_pcm]
> Dec  6 10:31:39 localhost kernel: [  162.087873]
> Dec  6 10:31:39 localhost kernel: [  162.087874] which lock already depends on the new lock.
> Dec  6 10:31:39 localhost kernel: [  162.087875]
> Dec  6 10:31:39 localhost kernel: [  162.087876]
> Dec  6 10:31:39 localhost kernel: [  162.087877] the existing dependency chain (in reverse order) is:
> Dec  6 10:31:39 localhost kernel: [  162.087879]
> Dec  6 10:31:39 localhost kernel: [  162.087880] -> #2 (&pcm->open_mutex){+.+.+.}:
> Dec  6 10:31:39 localhost kernel: [  162.087884]        [<c045a703>] __lock_acquire+0xa2a/0xbb5
> 
> Dec  6 10:31:39 localhost kernel: [  162.087890]        [<c045a922>] lock_acquire+0x94/0xb1
> Dec  6 10:31:39 localhost kernel: [  162.087893]        [<c07324a6>] __mutex_lock_common+0x35/0x2dc
> Dec  6 10:31:39 localhost kernel: [  162.087898]        [<c07327eb>] mutex_lock_nested+0x30/0x38
> Dec  6 10:31:39 localhost kernel: [  162.087901]        [<f80f4b2a>] snd_pcm_release+0x55/0x9e [snd_pcm]
> Dec  6 10:31:39 localhost kernel: [  162.087913]        [<c04ca0b5>] __fput+0xf0/0x187
> Dec  6 10:31:39 localhost kernel: [  162.087918]        [<c04ca165>] fput+0x19/0x1b
> Dec  6 10:31:39 localhost kernel: [  162.087921]        [<c04b0d6b>] remove_vma+0x3e/0x5d
> Dec  6 10:31:39 localhost kernel: [  162.087926]        [<c04b19f0>] do_munmap+0x21c/0x237
> Dec  6 10:31:39 localhost kernel: [  162.087929]        [<c04b1a3b>] sys_munmap+0x30/0x3f
> Dec  6 10:31:39 localhost kernel: [  162.087932]        [<c040321d>] syscall_call+0x7/0xb
> Dec  6 10:31:39 localhost kernel: [  162.087937]
> Dec  6 10:31:39 localhost kernel: [  162.087938] -> #1 (&mm->mmap_sem){++++++}:
> Dec  6 10:31:39 localhost kernel: [  162.087942]        [<c045a703>] __lock_acquire+0xa2a/0xbb5
> Dec  6 10:31:39 localhost kernel: [  162.087946]        [<c045a922>] lock_acquire+0x94/0xb1
> Dec  6 10:31:39 localhost kernel: [  162.087949]        [<c04aba42>] might_fault+0x64/0x81
> Dec  6 10:31:39 localhost kernel: [  162.087952]        [<c05b34cc>] copy_to_user+0x2c/0xfc
> Dec  6 10:31:39 localhost kernel: [  162.087957]        [<c04d4879>] filldir+0x78/0xb7
> Dec  6 10:31:39 localhost kernel: [  162.087961]        [<c050c88d>] sysfs_readdir+0x117/0x14b
> Dec  6 10:31:39 localhost kernel: [  162.087964]        [<c04d49dd>] vfs_readdir+0x68/0x94
> Dec  6 10:31:39 localhost kernel: [  162.087968]        [<c04d4b0b>] sys_getdents+0x62/0xa1
> Dec  6 10:31:39 localhost kernel: [  162.087971]        [<c040321d>] syscall_call+0x7/0xb
> Dec  6 10:31:39 localhost kernel: [  162.087975]
> Dec  6 10:31:39 localhost kernel: [  162.087975] -> #0 (sysfs_mutex){+.+.+.}:
> Dec  6 10:31:39 localhost kernel: [  162.087979]        [<c045a610>] __lock_acquire+0x937/0xbb5
> Dec  6 10:31:39 localhost kernel: [  162.087983]        [<c045a922>] lock_acquire+0x94/0xb1
> Dec  6 10:31:39 localhost kernel: [  162.087986]        [<c07324a6>] __mutex_lock_common+0x35/0x2dc
> Dec  6 10:31:39 localhost kernel: [  162.087990]        [<c07327eb>] mutex_lock_nested+0x30/0x38
> Dec  6 10:31:39 localhost kernel: [  162.087993]        [<c050c99d>] sysfs_get_dirent+0x15/0x35
> Dec  6 10:31:39 localhost kernel: [  162.087996]        [<c050e03e>] sysfs_remove_group+0x1e/0xa3
> Dec  6 10:31:39 localhost kernel: [  162.088000]        [<c062bf50>] dpm_sysfs_remove+0x10/0x12
> Dec  6 10:31:39 localhost kernel: [  162.088006]        [<c0627108>] device_del+0x33/0x154
> Dec  6 10:31:39 localhost kernel: [  162.088010]        [<c0627251>] device_unregister+0x28/0x4b
> Dec  6 10:31:39 localhost kernel: [  162.088014]        [<c0678499>] usb_remove_ep_devs+0x15/0x1f
> Dec  6 10:31:39 localhost kernel: [  162.088018]        [<c0672ba2>] remove_intf_ep_devs+0x21/0x32
> Dec  6 10:31:39 localhost kernel: [  162.088023]        [<c0673b3a>] usb_set_interface+0x10c/0x19f
> Dec  6 10:31:39 localhost kernel: [  162.088027]        [<f832dce6>] snd_usb_capture_close+0x1e/0x37 [snd_usb_audio]
> Dec  6 10:31:39 localhost kernel: [  162.088040]        [<f80f4aac>] snd_pcm_release_substream+0x3d/0x66 [snd_pcm]
> Dec  6 10:31:39 localhost kernel: [  162.088050]        [<f80f4b31>] snd_pcm_release+0x5c/0x9e [snd_pcm]
> Dec  6 10:31:39 localhost kernel: [  162.088058]        [<c04ca0b5>] __fput+0xf0/0x187
> Dec  6 10:31:39 localhost kernel: [  162.088062]        [<c04ca165>] fput+0x19/0x1b
> Dec  6 10:31:39 localhost kernel: [  162.088065]        [<c04b0d6b>] remove_vma+0x3e/0x5d
> Dec  6 10:31:39 localhost kernel: [  162.088069]        [<c04b19f0>] do_munmap+0x21c/0x237
> Dec  6 10:31:39 localhost kernel: [  162.088072]        [<c04b1a3b>] sys_munmap+0x30/0x3f
> Dec  6 10:31:39 localhost kernel: [  162.088076]        [<c040321d>] syscall_call+0x7/0xb
> Dec  6 10:31:39 localhost kernel: [  162.088079]
> Dec  6 10:31:39 localhost kernel: [  162.088080] other info that might help us debug this:
> Dec  6 10:31:39 localhost kernel: [  162.088080]
> Dec  6 10:31:39 localhost kernel: [  162.088083] 2 locks held by pulseaudio/4506:
> Dec  6 10:31:39 localhost kernel: [  162.088085]  #0:  (&mm->mmap_sem){++++++}, at: [<c04b1a2e>] sys_munmap+0x23/0x3f
> Dec  6 10:31:39 localhost kernel: [  162.088090]  #1:  (&pcm->open_mutex){+.+.+.}, at: [<f80f4b2a>] snd_pcm_release+0x55/0x9e [snd_pcm]
> Dec  6 10:31:39 localhost kernel: [  162.088104]
> Dec  6 10:31:39 localhost kernel: [  162.088105] stack backtrace:
> Dec  6 10:31:39 localhost kernel: [  162.088108] Pid: 4506, comm: pulseaudio Not tainted 2.6.32v0 #1
> Dec  6 10:31:39 localhost kernel: [  162.088110] Call Trace:
> Dec  6 10:31:39 localhost kernel: [  162.088113]  [<c07312cc>] ? printk+0xf/0x13
> Dec  6 10:31:39 localhost kernel: [  162.088117]  [<c045999b>] print_circular_bug+0x91/0x9d
> Dec  6 10:31:39 localhost kernel: [  162.088121]  [<c045a610>] __lock_acquire+0x937/0xbb5
> Dec  6 10:31:39 localhost kernel: [  162.088124]  [<c04584f5>] ? save_trace+0x37/0xa3
> Dec  6 10:31:39 localhost kernel: [  162.088128]  [<c045a922>] lock_acquire+0x94/0xb1
> Dec  6 10:31:39 localhost kernel: [  162.088131]  [<c050c99d>] ? sysfs_get_dirent+0x15/0x35
> Dec  6 10:31:39 localhost kernel: [  162.088135]  [<c07324a6>] __mutex_lock_common+0x35/0x2dc
> Dec  6 10:31:39 localhost kernel: [  162.088138]  [<c050c99d>] ? sysfs_get_dirent+0x15/0x35
> Dec  6 10:31:39 localhost kernel: [  162.088141]  [<c0458f23>] ? mark_held_locks+0x43/0x5b
> Dec  6 10:31:39 localhost kernel: [  162.088145]  [<c04591bf>] ? trace_hardirqs_on+0xb/0xd
> Dec  6 10:31:39 localhost kernel: [  162.088148]  [<c07327eb>] mutex_lock_nested+0x30/0x38
> Dec  6 10:31:39 localhost kernel: [  162.088151]  [<c050c99d>] ? sysfs_get_dirent+0x15/0x35
> Dec  6 10:31:39 localhost kernel: [  162.088154]  [<c050c99d>] sysfs_get_dirent+0x15/0x35
> Dec  6 10:31:39 localhost kernel: [  162.088157]  [<c050e03e>] sysfs_remove_group+0x1e/0xa3
> Dec  6 10:31:39 localhost kernel: [  162.088161]  [<c062bf50>] dpm_sysfs_remove+0x10/0x12
> Dec  6 10:31:39 localhost kernel: [  162.088164]  [<c0627108>] device_del+0x33/0x154
> Dec  6 10:31:39 localhost kernel: [  162.088168]  [<c0627251>] device_unregister+0x28/0x4b
> Dec  6 10:31:39 localhost kernel: [  162.088171]  [<c0678499>] usb_remove_ep_devs+0x15/0x1f
> Dec  6 10:31:39 localhost kernel: [  162.088174]  [<c0672ba2>] remove_intf_ep_devs+0x21/0x32
> Dec  6 10:31:39 localhost kernel: [  162.088178]  [<c0673b3a>] usb_set_interface+0x10c/0x19f
> Dec  6 10:31:39 localhost kernel: [  162.088190]  [<f832dce6>] snd_usb_capture_close+0x1e/0x37 [snd_usb_audio]
> Dec  6 10:31:39 localhost kernel: [  162.088199]  [<f80f4aac>] snd_pcm_release_substream+0x3d/0x66 [snd_pcm]
> Dec  6 10:31:39 localhost kernel: [  162.088208]  [<f80f4b31>] snd_pcm_release+0x5c/0x9e [snd_pcm]
> Dec  6 10:31:39 localhost kernel: [  162.088211]  [<c04ca0b5>] __fput+0xf0/0x187
> Dec  6 10:31:39 localhost kernel: [  162.088215]  [<c04ca165>] fput+0x19/0x1b
> Dec  6 10:31:39 localhost kernel: [  162.088218]  [<c04b0d6b>] remove_vma+0x3e/0x5d
> Dec  6 10:31:39 localhost kernel: [  162.088221]  [<c04b19f0>] do_munmap+0x21c/0x237
> Dec  6 10:31:39 localhost kernel: [  162.088225]  [<c04b1a3b>] sys_munmap+0x30/0x3f
> Dec  6 10:31:39 localhost kernel: [  162.088228]  [<c040321d>] syscall_call+0x7/0xb

And fortunately I know who to cc on this one ;)
