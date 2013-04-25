From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.6-rt: inet_sk_rx_dst_set() network splat
Date: Wed, 24 Apr 2013 18:34:55 -0700
Message-ID: <1366853695.8964.120.camel@edumazet-glaptop>
References: <1366786204.5977.10.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: RT <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Mike Galbraith <bitbucket@online.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:64532 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932143Ab3DYBe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 21:34:58 -0400
In-Reply-To: <1366786204.5977.10.camel@marge.simpson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Wed, 2013-04-24 at 08:50 +0200, Mike Galbraith wrote:
> Giving 3.6-rt some routine usage runtime, while updating kernel git
> repositories, the below fell out, but didn't repeat while updating other
> repositories. 
> 
> [  381.481464] ------------[ cut here ]------------
> [  381.486090] WARNING: at include/linux/skbuff.h:536 inet_sk_rx_dst_set+0x8c/0xe0()
> [  381.493566] Hardware name: MS-7502
> [  381.493612] Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables ebtable_nat ebtables x_tables nfsd snd_pcm_oss snd_mixer_oss snd_seq nfs_acl snd_seq_device auth_rpcgss edd nfs fscache lockd sunrpc bridge ipv6 stp cpufreq_conservative cpufreq_ondemand cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf nls_iso8859_1 nls_cp437 vfat fat fuse ext3 jbd arc4 rt2800usb rt2800lib crc_ccitt rt2x00usb rt2x00lib mac80211 iTCO_wdt iTCO_vendor_support cfg80211 hid_generic rfkill usb_storage snd_hda_codec_realtek sr_mod cdrom sg snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_timer e1000e snd firewire_ohci firewire_core coretemp microcode soundcore lpc_ich mfd_core crc_itu_t snd_page_alloc i2c_i801 button ext4 mbcache jbd2 crc16 usbhid hid sd_mod crc_t10dif uhci_hcd ehci_hcd
  rtc_cmos ahci libahci libata thermal fan scsi_mod usbcore usb_common processor
> [  381.493620] Pid: 6170, comm: git Not tainted 3.6.11.1-rt32-smp #52
> [  381.493621] Call Trace:
> [  381.493626]  [<ffffffff8103cddf>] warn_slowpath_common+0x7f/0xc0
> [  381.493629]  [<ffffffff8103ce3a>] warn_slowpath_null+0x1a/0x20
> [  381.493631]  [<ffffffff813f6f0c>] inet_sk_rx_dst_set+0x8c/0xe0
> [  381.493633]  [<ffffffff813ece77>] tcp_rcv_established+0x797/0x7d0
> [  381.493636]  [<ffffffff813f82d4>] tcp_v4_do_rcv+0x134/0x220
> [  381.493638]  [<ffffffff813debc7>] tcp_prequeue_process+0x67/0xb0
> [  381.493641]  [<ffffffff813e373a>] tcp_recvmsg+0xaca/0xd70
> [  381.493645]  [<ffffffff810a627b>] ? __lock_release+0x6b/0xe0
> [  381.493648]  [<ffffffff8140f381>] inet_recvmsg+0x121/0x240
> [  381.493651]  [<ffffffff8140ead0>] ? inet_sock_destruct+0x230/0x230
> [  381.493655]  [<ffffffff8136fd49>] sock_aio_read.part.19+0xf9/0x120
> [  381.493657]  [<ffffffff8136fee0>] ? sock_aio_write+0x90/0xb0
> [  381.493660]  [<ffffffff8136fd96>] sock_aio_read+0x26/0x30
> [  381.493662]  [<ffffffff8116c503>] do_sync_read+0xa3/0xe0
> [  381.493665]  [<ffffffff8116ce9d>] vfs_read+0x14d/0x160
> [  381.493667]  [<ffffffff8116cefd>] sys_read+0x4d/0x90
> [  381.493670]  [<ffffffff81481812>] system_call_fastpath+0x16/0x1b
> [  381.493671] ---[ end trace 0000000000000002 ]---
> 
>  529 static inline struct dst_entry *skb_dst(const struct sk_buff *skb)
>  530 {
>  531         /* If refdst was not refcounted, check we still are in a
>  532          * rcu_read_lock section
>  533          */
>  534         WARN_ON((skb->_skb_refdst & SKB_DST_NOREF) &&
>  535                 !rcu_read_lock_held() &&
>  536                 !rcu_read_lock_bh_held());
>  537         return (struct dst_entry *)(skb->_skb_refdst & SKB_DST_PTRMASK);
>  538 }
> 

Thanks for the report, here is a fix.

It will be a bit of a hassle to merge this one on net-next, as
tcp_prequeue() was moved in commit
b2fb4f54ecd47c42413d54b4666b06cf93c05abf
(tcp: uninline tcp_prequeue() )

David, maybe you prefer to pull into net tree the move, then I respin
the fix ?

[PATCH] tcp: force a dst refcount when prequeue packet

Before escaping RCU protected section and adding packet into
prequeue, make sure the dst is refcounted.

Reported-by: Mike Galbraith <bitbucket@online.de>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index cf0694d..a345480 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1049,6 +1049,7 @@ static inline bool tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 	    skb_queue_len(&tp->ucopy.prequeue) == 0)
 		return false;
 
+	skb_dst_force(skb);
 	__skb_queue_tail(&tp->ucopy.prequeue, skb);
 	tp->ucopy.memory += skb->truesize;
 	if (tp->ucopy.memory > sk->sk_rcvbuf) {
