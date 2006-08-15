From: Max <netdev@tralhalla.dyndns.org>
Subject: BUG at kernel/workqueue.c:149 using linux-2.6.18-rc4 with zd1211rw
Date: Mon, 14 Aug 2006 17:52:10 -0700
Message-ID: <20060815005210.GB6397@tralhalla.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rwcrmhc14.comcast.net ([216.148.227.154]:35015 "EHLO
	rwcrmhc14.comcast.net") by vger.kernel.org with ESMTP
	id S932739AbWHOAwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 20:52:12 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hit this when connecting a computer to an access point with a zydas usb
dongle using the zd1211rw driver. This seems entirely reproducible
(2/2).  The system hit the BUG over night. I already sent this to
zd1211-devs and Ulrich Kunitz suggested that it might be a bug in
softmac, so resending to a wider audience.

Max
--
kernel BUG at kernel/workqueue.c:149!
invalid opcode: 0000 [#1]
Modules linked in: michael_mic arc4 zd1211rw ieee80211_crypt_wep ieee80211_crypt_tkip ieee80211_crypt_ccmp firmware_class ieee80211softmac ieee80211 ieee80211_crypt snd_mixer_oss rfcomm l2cap bluetooth 8250 serial_core snd_cmipci snd_pcm snd_page_alloc snd_opl3_lib snd_timer snd_hwdep snd_mpu401_uart snd_rawmidi snd ehci_hcd uhci_hcd ohci_hcd ohci1394 ieee1394
CPU:    0
EIP:    0060:[<c01289f1>]    Not tainted VLI
EFLAGS: 00010082   (2.6.18-rc4 #1)
EIP is at queue_delayed_work+0x71/0x90
eax: 00000000   ebx: e0f024ec   ecx: f7146780   edx: e0f024d4
esi: c1ab63c0   edi: 00000bb8   ebp: f6084a38   esp: c1ac7efc
ds: 007b   es: 007b   ss: 0068
Process events/0 (pid: 4, ti=c1ac6000 task=c1ab8ab0 task.ti=c1ac6000)
Stack: 02000112 e0f024d4 00000292 e0f024c0 f68cd600 fa9c9a47 f6084d5c 00000006
       00000000 00000086 00000296 c1ac7f40 00000086 00000000 e0f024d4 c1a94420
       00000296 e0f024c0 c01285b1 e0f024c0 c1ab8bc0 0000021c c1a94428 c1a94438
Call Trace:
 [<fa9c9a47>] ieee80211softmac_auth_queue+0x57/0x170 [ieee80211softmac]
 [<c01285b1>] run_workqueue+0x61/0xd0
 [<fa9c99f0>] ieee80211softmac_auth_queue+0x0/0x170 [ieee80211softmac]
 [<c0128be7>] worker_thread+0x147/0x170
 [<c0115980>] default_wake_function+0x0/0x20
 [<c0128aa0>] worker_thread+0x0/0x170
 [<c012b77d>] kthread+0xfd/0x110
 [<c012b680>] kthread+0x0/0x110
 [<c0101005>] kernel_thread_helper+0x5/0x10
Code: a1 80 b3 45 c0 89 53 10 c7 43 0c a0 83 12 c0 01 f8 85 c9 89 43 08 75 27 89 44 24 04 89 1c 24 e8 d6 8c ff ff b9 01 00 00 00 eb b1 <0f> 0b 95 00 34 b7 3f c0 eb c0 0f 0b 96 00 34 b7 3f c0 eb be 0f
EIP: [<c01289f1>] queue_delayed_work+0x71/0x90 SS:ESP 0068:c1ac7efc
 <7>SoftMAC: Authentication response received from 00:13:10:36:43:0b but no queue item exists.
SoftMAC: Authentication response received from 00:13:10:36:43:0b but no queue item exists.
--
int fastcall queue_delayed_work(struct workqueue_struct *wq,
                        struct work_struct *work, unsigned long delay)
{
        int ret = 0;
        struct timer_list *timer = &work->timer;

        if (!test_and_set_bit(0, &work->pending)) {
                BUG_ON(timer_pending(timer));      <--- XXX
                BUG_ON(!list_empty(&work->entry));

                /* This stores wq for the moment, for the timer_fn */
                work->wq_data = wq;
                timer->expires = jiffies + delay;
                timer->data = (unsigned long)work;
                timer->function = delayed_work_timer_fn;
                add_timer(timer);
                ret = 1;
        }
        return ret;
}
--
[...]
SoftMAC: Received deauthentication packet from 00:13:10:36:43:0b, but that network is unknown.
SoftMAC: Received deauthentication packet from 00:13:10:36:43:0b, but that network is unknown.
SoftMAC: Received deauthentication packet from 00:13:10:36:43:0b, but that network is unknown.
SoftMAC: Received deauthentication packet from 00:13:10:36:43:0b, but that network is unknown.
SoftMAC: Open Authentication completed with 00:13:10:36:43:0b
SoftMAC: Authentication response received from 00:13:10:36:43:0b but no queue item exists.
TKIP: replay detected: STA=00:13:10:36:43:0b previous TSC 000000000001 received TSC 000000000001
TKIP: replay detected: STA=00:13:10:36:43:0b previous TSC 000000000001 received TSC 000000000001
SoftMAC: Received deauthentication packet from 00:13:10:36:43:0b, but that network is unknown.
SoftMAC: Received deauthentication packet from 00:13:10:36:43:0b, but that network is unknown.
SoftMAC: Received deauthentication packet from 00:13:10:36:43:0b, but that network is unknown.
SoftMAC: Received deauthentication packet from 00:13:10:36:43:0b, but that network is unknown.
SoftMAC: Open Authentication completed with 00:13:10:36:43:0b
SoftMAC: Authentication response received from 00:13:10:36:43:0b but no queue item exists.
TKIP: replay detected: STA=00:13:10:36:43:0b previous TSC 000000000001 received TSC 000000000001
TKIP: replay detected: STA=00:13:10:36:43:0b previous TSC 000000000001 received TSC 000000000001
TKIP: replay detected: STA=00:13:10:36:43:0b previous TSC 000000000001 received TSC 000000000001
SoftMAC: Received deauthentication packet from 00:13:10:36:43:0b, but that network is unknown.
SoftMAC: Authentication timed out with 00:13:10:36:43:0b
SoftMAC: Authentication timed out with 00:13:10:36:43:0b
SoftMAC: Authentication timed out with 00:13:10:36:43:0b
SoftMAC: Authentication timed out with 00:13:10:36:43:0b
SoftMAC: Authentication timed out with 00:13:10:36:43:0b
SoftMAC: Open Authentication completed with 00:13:10:36:43:0b
SoftMAC: Open Authentication completed with 00:13:10:36:43:0b
SoftMAC: Authentication response received from 00:13:10:36:43:0b but no queue item exists.
SoftMAC: Authentication response received from 00:13:10:36:43:0b but no queue item exists.
------------[ cut here ]------------
kernel BUG at ...
