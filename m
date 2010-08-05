From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free (after using openvpn)
Date: Thu, 05 Aug 2010 02:51:29 -0700
Message-ID: <m1y6clz8ta.fsf_-_@fess.ebiederm.org>
References: <loom.20100708T183152-326@post.gmane.org>
	<20100709235744.GA12752@kroah.com>
	<20100710101540.2799c9ef@xenia.leun.net>
	<20100710140800.GA20424@kroah.com>
	<20100710165208.59272ae6@xenia.leun.net>
	<20100710235323.5336f627@xenia.leun.net>
	<20100711192939.1c25dcaf@xenia.leun.net>
	<20100804153543.56f6ecad@xenia.leun.net>
	<20100804214618.GA6289@kroah.com>
	<20100805001105.5a3453ed@xenia.leun.net>
	<m1lj8l29zm.fsf@fess.ebiederm.org>
	<20100805112538.60a46cb1@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Michael Leun <lkml20100708@newton.leun.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47841 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755581Ab0HEJvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 05:51:35 -0400
In-Reply-To: <20100805112538.60a46cb1@xenia.leun.net> (Michael Leun's message of "Thu\, 5 Aug 2010 11\:25\:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Leun <lkml20100708@newton.leun.net> writes:

> Hi,
>
> On Wed, 04 Aug 2010 17:12:29 -0700
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
> First, thank you very much for picking that up (and, of course, for
> your work at linux in general).
>
>
>> > # > unshare -n /bin/bash
>> > # > # how to setup veth device pair to get connectivity into
>> > namespace not shown here # > openvpn --config some.config
>> > [ running some traffic over vpn device not shown here ]
>> > ^c # stopping openvpn
>> > # > lsof -i
>> > # > netstat -an
>> > Active Internet connections (servers and established)
>> > Proto Recv-Q Send-Q Local Address           Foreign Address
>> > State Active UNIX domain sockets (servers and established)
>> > Proto RefCnt Flags       Type       State         I-Node Path
>> > # > ps ax|grep openvpn|grep -v grep
>> > # > # cannot find anything that suggests there is anything left
>> > from that openvpn session # > exit # logging out from shell in
>> > network namespace
>> >
>> > Now I get
>> >
>> > Jul 10 20:02:36 doris kernel: unregister_netdevice: waiting for lo
>> > to become free. Usage count = 3 [repeated]
>> 
>> How many times?
>
> Unfortunately looks like indefinitely. Never watched longer so far
> (rebooted soon), but I'm seeing this message now repeated every 10 secs
> for ~10 minutes on a idle system.

Ugh.  A real bug then.  These can be a pain to track down and fix. I
think the last one of these I tracked down took a couple of weeks.  I
will start digging in when I get back from vacation.

> Additionally when testing this I found another one (by accident started
> my firewall script in that namespace...) - using netfilter RECENT
> makes it barf. Stripped down to the essentials it looks like this:

Micheal this is on 2.6.35?

Alexey can you look at this BUG_ON?  It looks like there has been a regression
or you missed something when you did the netns conversion of xt_recent.


>> # unshare -n /bin/bash
>> # iptables -I INPUT -d 1.2.3.4 -m recent --name BLA --set
>> # exit
>
> Aug  5 11:19:47 doris kernel: [  218.420238] ------------[ cut here ]------------
> Aug  5 11:19:47 doris kernel: [  218.420256] kernel BUG at net/netfilter/xt_recent.c:609!
> Aug  5 11:19:47 doris kernel: [  218.420268] invalid opcode: 0000 [#1] PREEMPT SMP 
> Aug  5 11:19:47 doris kernel: [  218.420284] last sysfs file: /sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0A:00/power_supply/BAT0/charge_full
> Aug  5 11:19:47 doris kernel: [  218.420295] Modules linked in: snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device edd cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf ipt_REJECT ipt_LOG xt_limit xt_recent iptable_mangle iptable_nat iptable_filter nf_conntrack_ipv6 xt_state xt_tcpudp ip6table_filter ip6_tables nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack ip_tables x_tables fuse nls_utf8 loop arc4 ecb iwlagn iwlcore mac80211 snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm cfg80211 snd_timer snd usb_storage iTCO_wdt soundcore tg3 sg iTCO_vendor_support snd_page_alloc rfkill i2c_i801 pcspkr battery ac ext4 jbd2 crc16 sha256_generic aes_generic cbc dm_crypt linear i915 drm_kms_helper drm i2c_algo_bit sd_mod vide
 o intel_agp button dm_snapshot dm_mod fan processor ata_piix ahci libahci libata scsi_mod thermal thermal_sys
> Aug  5 11:19:47 doris kernel: [  218.420529] 
> Aug  5 11:19:47 doris kernel: [  218.420542] Pid: 13, comm: netns Not tainted 2.6.35 #2 Kuril                           /40684JG         
> Aug  5 11:19:47 doris kernel: [  218.420557] EIP: 0060:[<fc886a15>] EFLAGS: 00010206 CPU: 0
> Aug  5 11:19:47 doris kernel: [  218.420578] EIP is at recent_net_exit+0x55/0x70 [xt_recent]
> Aug  5 11:19:47 doris kernel: [  218.420589] EAX: f2218000 EBX: f5b79290 ECX: f2f27b40 EDX: f5cd4000
> Aug  5 11:19:47 doris kernel: [  218.420601] ESI: f2218000 EDI: f5cd5f44 EBP: f5cd5f28 ESP: f5cd5f20
> Aug  5 11:19:47 doris kernel: [  218.420612]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Aug  5 11:19:47 doris kernel: [  218.420626] Process netns (pid: 13, ti=f5cd4000 task=f5cc9920 task.ti=f5cd4000)
> Aug  5 11:19:47 doris kernel: [  218.420635] Stack:
> Aug  5 11:19:47 doris kernel: [  218.420641]  f5cd5f30 fc887618 f5cd5f3c c130867d fc887618 f5cd5f44 c1308850 f5cd5f60
> Aug  5 11:19:47 doris kernel: [  218.420667] <0> c1308919 f2218014 f2218014 f221800c f221800c c15915a0 c3bb4f40 c1308850
> Aug  5 11:19:47 doris kernel: [  218.420695] <0> f5cd5fbc c105a230 c13d1658 00000001 00000000 f7048000 c160f500 f5cc9c00
> Aug  5 11:19:47 doris kernel: [  218.420724] Call Trace:
> Aug  5 11:19:47 doris kernel: [  218.420749]  [<c130867d>] ? ops_exit_list+0x1d/0x50
> Aug  5 11:19:47 doris kernel: [  218.420766]  [<c1308850>] ? cleanup_net+0x0/0x160
> Aug  5 11:19:47 doris kernel: [  218.420782]  [<c1308919>] ? cleanup_net+0xc9/0x160
> Aug  5 11:19:47 doris kernel: [  218.420797]  [<c1308850>] ? cleanup_net+0x0/0x160
> Aug  5 11:19:47 doris kernel: [  218.420815]  [<c105a230>] ? worker_thread+0x110/0x250
> Aug  5 11:19:47 doris kernel: [  218.420832]  [<c13d1658>] ? schedule+0x748/0x7a0
> Aug  5 11:19:47 doris kernel: [  218.420849]  [<c105d5f0>] ? autoremove_wake_function+0x0/0x40
> Aug  5 11:19:47 doris kernel: [  218.420864]  [<c105a120>] ? worker_thread+0x0/0x250
> Aug  5 11:19:47 doris kernel: [  218.420879]  [<c105d1bc>] ? kthread+0x6c/0x80
> Aug  5 11:19:47 doris kernel: [  218.420895]  [<c105d150>] ? kthread+0x0/0x80
> Aug  5 11:19:47 doris kernel: [  218.420910]  [<c1003336>] ? kernel_thread_helper+0x6/0x10
> Aug  5 11:19:47 doris kernel: [  218.420919] Code: 91 08 89 e2 81 e2 00 e0 ff ff 83 6a 14 01 f6 42 08 08 75 19 3b 1b 75 13 ba fa 72 88 fc e8 94 3e 8c c4 8d 64 24 04 5b 5d c3 0f 0b <0f> 0b 89 45 f8 e8 a1 ad b4 c4 8b 45 f8 eb da 8d b6 00 00 00 00 
> Aug  5 11:19:47 doris kernel: [  218.421063] EIP: [<fc886a15>] recent_net_exit+0x55/0x70 [xt_recent] SS:ESP 0068:f5cd5f20
> Aug  5 11:19:47 doris kernel: [  218.421136] ---[ end trace f57524f15f4df616 ]---
>


Eric
