From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: fix for 2.9.20-rc2 null pointer dereference in SoftMAC? was Re:
 [PATCH] softmac: Fix for work struct changes
Date: Tue, 26 Dec 2006 10:26:57 -0600
Message-ID: <45914D51.10205@lwfinger.net>
References: <457C7E17.mail8SI11YW8G@lwfinger.net> <20061226144533.GA12583@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:45554 "EHLO
	mtiwmhc11.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932700AbWLZQ1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Dec 2006 11:27:36 -0500
To: bert hubert <bert.hubert@netherlabs.nl>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>
In-Reply-To: <20061226144533.GA12583@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bert hubert wrote:
> On Sun, Dec 10, 2006 at 03:37:27PM -0600, Larry Finger wrote:
>> casted to (void*). This compiled correctly but resulted in a
>> softlock, because mutex_lock was called with the wrong memory
>> address. The patch fixes the problem. Another issue was a wrong
> 
> (quickly, between christmas dinner preparations)
> Does this explain the following, which happens reliably in stock 2.6.20-rc2 (in-kernel zd1211rw):
> 
> Dec 24 22:07:25 localhost kernel: [  120.238914] SoftMAC: Open Authentication completed with 00:0e:a6:16:28:a9
> Dec 24 22:07:25 localhost kernel: [  120.239005] BUG: unable to handle kernel NULL pointer dereference at virtual address 00000006
> Dec 24 22:07:25 localhost kernel: [  120.239132]  printing eip:
> Dec 24 22:07:25 localhost kernel: [  120.239191] c04cf8c5
> Dec 24 22:07:25 localhost kernel: [  120.239249] *pde = 00000000
> Dec 24 22:07:25 localhost kernel: [  120.239308] Oops: 0002 [#1]
> Dec 24 22:07:25 localhost kernel: [  120.239367] Modules linked in: capability commoncap cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_ondemand freq_table cpufreq_conservative zd1211rw ieee80211softmac usbhid ieee80211 ieee80211_crypt psmouse
> Dec 24 22:07:25 localhost kernel: [  120.239850] CPU:    0
> Dec 24 22:07:25 localhost kernel: [  120.239851] EIP:    0060:[__mutex_lock_slowpath+30/89]    Not tainted VLI
> Dec 24 22:07:25 localhost kernel: [  120.239853] EFLAGS: 00010286   (2.6.20-rc2 #7)
> Dec 24 22:07:25 localhost kernel: [  120.240043] EIP is at __mutex_lock_slowpath+0x1e/0x59
> Dec 24 22:07:25 localhost kernel: [  120.240106] eax: f5b449e0   ebx: f5b449dc   ecx: 00000006   edx: 00000004
> Dec 24 22:07:25 localhost kernel: [  120.240173] esi: c19005a0   edi: f5b44a40   ebp: f8862ce8   esp: c1909ec0
> Dec 24 22:07:25 localhost kernel: [  120.240241] ds: 007b   es: 007b   ss: 0068
> Dec 24 22:07:25 localhost kernel: [  120.240305] Process events/0 (pid: 4, ti=c1908000 task=c19005a0 task.ti=c1908000)
> Dec 24 22:07:25 localhost kernel: [  120.240372] Stack: f5b449e0 00000006 00000020 f5b449a0 f5b44a40 c04cf7d8 f8862943 f72b8500
> Dec 24 22:07:25 localhost kernel: [  120.240676]        00000286 f5b44314 f5b449dc f5b44a40 00000001 00000000 f5e6c9c0 f5e6c9c0
> Dec 24 22:07:25 localhost kernel: [  120.240981]        00000000 f5b44a40 f8862ce8 f8862d50 00000004 00100100 00200200 00000004
> Dec 24 22:07:25 localhost kernel: [  120.241284] Call Trace:
> Dec 24 22:07:25 localhost kernel: [  120.241399]  [mutex_lock+9/10] mutex_lock+0x9/0xa
> Dec 24 22:07:25 localhost kernel: [  120.241485]  [<f8862943>] ieee80211softmac_assoc_work+0x1b/0x3c0 [ieee80211softmac]
> Dec 24 22:07:25 localhost kernel: [  120.241614]  [<f8862ce8>] ieee80211softmac_assoc_notify_auth+0x0/0x1e [ieee80211softmac]
> Dec 24 22:07:25 localhost kernel: [  120.241741]  [<f8862d50>] ieee80211softmac_notify_callback+0x40/0x48 [ieee80211softmac]
> Dec 24 22:07:25 localhost kernel: [  120.241866]  [<f8862d10>] ieee80211softmac_notify_callback+0x0/0x48 [ieee80211softmac]
> Dec 24 22:07:25 localhost kernel: [  120.241992]  [<f8862ce8>] ieee80211softmac_assoc_notify_auth+0x0/0x1e [ieee80211softmac]
> Dec 24 22:07:25 localhost kernel: [  120.242118]  [<f8862d10>] ieee80211softmac_notify_callback+0x0/0x48 [ieee80211softmac]
> Dec 24 22:07:25 localhost kernel: [  120.242243]  [run_workqueue+139/311] run_workqueue+0x8b/0x137
> Dec 24 22:07:25 localhost kernel: [  120.242336]  [worker_thread+0/302] worker_thread+0x0/0x12e
> Dec 24 22:07:25 localhost kernel: [  120.242422]  [worker_thread+261/302] worker_thread+0x105/0x12e
> Dec 24 22:07:25 localhost kernel: [  120.242509]  [default_wake_function+0/12] default_wake_function+0x0/0xc
> Dec 24 22:07:25 localhost kernel: [  120.242596]  [kthread+155/191] kthread+0x9b/0xbf
> Dec 24 22:07:25 localhost kernel: [  120.242682]  [kthread+0/191] kthread+0x0/0xbf
> Dec 24 22:07:25 localhost kernel: [  120.242767]  [kernel_thread_helper+7/16] kernel_thread_helper+0x7/0x10
> Dec 24 22:07:25 localhost kernel: [  120.242856]  =======================
> Dec 24 22:07:25 localhost kernel: [  120.242915] Code: 00 00 00 31 d2 89 d0 83 c4 0c 5b 5e c3 56 53 83 ec 0c 89 c3 65 8b 35 08 00 00 00 8d 40 04 8b 48 04 89
> 60 04 89 04 24 89 4c 24 04 <89> 21 89 74 24 08 83 c8 ff 87 03 48 74 0d c7 06 02 00 00 00 e8
> Dec 24 22:07:25 localhost kernel: [  120.244531] EIP: [__mutex_lock_slowpath+30/89] __mutex_lock_slowpath+0x1e/0x59 SS:ESP 0068:c1909ec0
> 
> This happens after starting wpa_supplicant on a zd1211rw device.

Yes, this error applies to any interface using softmac, not just bcm43xx.

Larry

