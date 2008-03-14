From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: netconsole still hangs
Date: Sat, 15 Mar 2008 00:47:49 +0100
Message-ID: <20080314234749.GA10606@ami.dom.local>
References: <20080312235205.dcec2d35.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	rjw@sisk.pl
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:15976 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201AbYCNXmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2008 19:42:55 -0400
Received: by fk-out-0910.google.com with SMTP id 19so368355fkr.5
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2008 16:42:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080312235205.dcec2d35.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote, On 03/13/2008 07:52 AM:
...
> I tried it on the t61p and actually got an oops:
> 
> general protection fault: 0000 [1] SMP 
> last sysfs file: /sys/class/net/wlan0/address
> CPU 0 
> Modules linked in: autofs4 sunrpc nf_conntrack_ipv4 ipt_REJECT iptable_filter
> ip_tables nf_conntrack_ipv6 xt_state nf_conntrack xt_tcpudp ip6t_ipv6header
> ip6t_REJECT ip6table_filter ip6_tables x_tables ipv6 cpufreq_ondemand
> acpi_cpufreq dm_mirror dm_log dm_multipath dm_mod snd_hda_intel snd_seq_dummy
> snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss button arc4
> ecb crypto_blkcipher snd_mixer_oss iwl4965 joydev snd_pcm mac80211
> firewire_ohci battery ac thinkpad_acpi hwmon cfg80211 snd_timer snd_page_alloc
> snd_hwdep i2c_i801 i2c_core pcspkr firewire_core crc_itu_t snd soundcore
> sr_mod sg cdrom ata_piix ahci libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd
> ohci_hcd ehci_hcd [last unloaded: microcode]
> Pid: 2916, comm: zsh Not tainted 2.6.25-rc5-mm1 #9
> RIP: 0010:[<ffffffff8123a8ee>]  [<ffffffff8123a8ee>] zap_completion_queue+0x54/0x85
> RSP: 0018:ffff810072c35938  EFLAGS: 00010002
> RAX: 0000000000000000 RBX: 6b6b6b6b6b6b6b6b RCX: 0000000000000001

It looks like POISON_FREE probably while: "while(clist != NULL)". I
haven't found a culprit, but it could be some dev_kfree_skb_irq/_any()
user - not necessarily netpoll to blame. (A card could matter here:
e1000, iwl4965...?).

BTW, here is a patch which isn't supposed to fix this OOPs, but seems
to be needed near this place.

Regards,
Jarek P.

----------->
[NETPOLL] zap_completion_queue: adjust skb->users counter

zap_completion_queue() retrieves skbs from completion_queue where they
have zero skb->users counter. Before dev_kfree_skb_any() it should be
non-zero yet, so it's increased now.


Reported-and-tested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

(not tested)
---

 net/core/netpoll.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index d0c8bf5..b04d643 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -215,10 +215,12 @@ static void zap_completion_queue(void)
 		while (clist != NULL) {
 			struct sk_buff *skb = clist;
 			clist = clist->next;
-			if (skb->destructor)
+			if (skb->destructor) {
+				atomic_inc(&skb->users);
 				dev_kfree_skb_any(skb); /* put this one back */
-			else
+			} else {
 				__kfree_skb(skb);
+			}
 		}
 	}
 
