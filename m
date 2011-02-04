From: Chuck Ebbert <cebbert@redhat.com>
Subject: Oops in tcp_output.c, kernel 2.6.38-rc3
Date: Fri, 4 Feb 2011 15:32:54 -0500
Message-ID: <20110204153254.5c37c6f2@katamari>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ilpo =?UTF-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752180Ab1BDUfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Feb 2011 15:35:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Analysis is below. (From https://bugzilla.redhat.com/show_bug.cgi?id=674622)

 BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
 IP: [<ffffffff81407b16>] tcp_write_xmit+0x694/0x7af
 PGD 0 
 Oops: 0002 [#1] SMP 
 last sysfs file: /sys/devices/system/cpu/cpu1/cache/index2/shared_cpu_map
 CPU 0 
 Modules linked in: nls_utf8 hfsplus hfs vfat fat ext2 usb_storage uas cpufreq_ondemand acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel e1000e btusb i2c_i801 snd_hda_codec serio_raw snd_hwdep atl1e snd_seq snd_seq_device snd_pcm iTCO_wdt iTCO_vendor_support snd_timer asus_atk0110 bluetooth rfkill snd microcode soundcore snd_page_alloc ipv6 firewire_ohci firewire_core crc_itu_t radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: scsi_wait_scan]
 Pid: 1411, comm: ssh Not tainted 2.6.38-0.rc3.git0.1.fc15.x86_64 #1 P5Q-PRO/P5Q-PRO
 RIP: 0010:[<ffffffff81407b16>]  [<ffffffff81407b16>] tcp_write_xmit+0x694/0x7af
 RSP: 0018:ffff88022373db88  EFLAGS: 00010202
 RAX: ffff88022644aa00 RBX: ffff880224178d00 RCX: 0000000000000001
 RDX: 0000000000000000 RSI: ffff88022644aa00 RDI: ffff88022644aa00
 RBP: ffff88022373dc08 R08: 0000000000000140 R09: ffff880223129000
 R10: 0000000000001c48 R11: 0000000000000005 R12: ffff88022644aa00
 R13: 0000000000000b50 R14: 00000000000005a8 R15: 0000000000000000
 FS:  00007fc81ed797e0(0000) GS:ffff8800cfc00000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 CR2: 0000000000000008 CR3: 0000000223093000 CR4: 00000000000406f0
 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
 Process ssh (pid: 1411, threadinfo ffff88022373c000, task ffff8802237f4560)
 Stack:
  ffff880200003a00 0000000200000c90 0000000000000140 ffff88022644aa00
  0000000000000001 0000000100000140 000000202373dc08 ffffffff813b5197
  ffff880200000000 ffff880224178e08 ffff88022373dbe8 ffff880224178d00
 Call Trace:
  [<ffffffff813b5197>] ? __alloc_skb+0x8d/0x133
  [<ffffffff81407c88>] __tcp_push_pending_frames+0x23/0x51
  [<ffffffff813faa61>] tcp_push+0x8c/0x8e
  [<ffffffff813fcb30>] tcp_sendmsg+0x732/0x826
  [<ffffffff81418969>] inet_sendmsg+0x66/0x6f
  [<ffffffff813af53b>] __sock_sendmsg+0x69/0x76
  [<ffffffff813af601>] sock_aio_write+0xb9/0xc9
  [<ffffffff8112f627>] ? set_fd_set+0x3c/0x46
  [<ffffffff81120c57>] do_sync_write+0xbf/0xff
  [<ffffffff811e7967>] ? security_file_permission+0x2e/0x33
  [<ffffffff81121042>] ? rw_verify_area+0xb0/0xcd
  [<ffffffff811212d4>] vfs_write+0xb3/0xf3
  [<ffffffff811214bc>] sys_write+0x4a/0x6e
  [<ffffffff81009bc2>] system_call_fastpath+0x16/0x1b
 Code: f2 48 89 df 48 89 c6 e8 83 e4 ff ff 48 8b 45 98 48 89 c7 e8 df e5 ff ff 49 8b 14 24 48 8b 45 98 48 89 10 4c 89 60 08 49 89 04 24 <48> 89 42 08 ff 83 18 01 00 00 48 8b 05 59 9d 73 00 8b 4d b4 ba 
 RIP  [<ffffffff81407b16>] tcp_write_xmit+0x694/0x7af
  RSP <ffff88022373db88>
  CR2: 0000000000000008


OOPS is at include/linux/skbuff.h:895:
static inline void __skb_insert(struct sk_buff *newsk,
                                struct sk_buff *prev, struct sk_buff *next,
                                struct sk_buff_head *list)
{
        newsk->next = next;
        newsk->prev = prev;
==>     next->prev  = prev->next = newsk;
        list->qlen++;
}

  next is NULL here


Called from include/linux/skbuff.h:991:
static inline void __skb_queue_after(struct sk_buff_head *list,
                                     struct sk_buff *prev,
                                     struct sk_buff *newsk)
{
        __skb_insert(newsk, prev, prev->next, list);
}

Called from include/net/tcp.h:1294:
static inline void tcp_insert_write_queue_after(struct sk_buff *skb,
                                                struct sk_buff *buff,
                                                struct sock *sk)
{
        __skb_queue_after(&sk->sk_write_queue, skb, buff);
}

Called from net/ipv4/tcp_output.c:tso_fragment:1515:
        /* Link BUFF into the send queue. */
        skb_header_release(buff);
==>     tcp_insert_write_queue_after(skb, buff, sk);


Called from net/ipv4/tcp_output.c:tcp_write_xmit:1784:
                if (skb->len > limit &&
==>                 unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
                        break;
