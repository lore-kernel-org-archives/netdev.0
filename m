From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.21-git8+ BUG: NMI Watchdog detected LOCKUP on CPU1
Date: Tue, 8 May 2007 03:07:01 -0700
Message-ID: <20070508030701.d21dc40b.akpm@linux-foundation.org>
References: <46403642.7020501@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934841AbXEHKHQ@vger.kernel.org>
In-Reply-To: <46403642.7020501@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 08 May 2007 10:35:14 +0200 Michal Piotrowski <michal.k.k.piotrowski@gmail.com> wrote:

> Hi,
> 
> / filesystem was full
> 
> [39525.460000] BUG: NMI Watchdog detected LOCKUP on CPU1, eip 08056990, registers:
> [39525.468000] Modules linked in: loop ipt_MASQUERADE iptable_nat nf_nat autofs4 af_packet nf_conntrack_netbios_ns ipt_REJECT nf_conntrack_ipv4 xt_state nf_conntrack nfnetlink iptable_filter ip_tables ip6t_REJECT xt_tcpudp ip6table_filter ip6_tables x_tables ipv6 binfmt_misc thermal processor fan container nvram snd_intel8x0 snd_ac97_codec ac97_bus snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss evdev snd_pcm intel_agp snd_timer snd agpgart soundcore i2c_i801 snd_page_alloc ide_cd cdrom rtc unix
> [39525.518000] CPU:    1
> [39525.518000] EIP:    0073:[<08056990>]    Not tainted VLI
> [39525.518000] EFLAGS: 00000202   (2.6.21-ga989705c #187)
> [39525.529000] EIP is at 0x8056990
> [39525.529000] eax: 6e560d60   ebx: 0000000b   ecx: 00000000   edx: 000dd15e
> [39525.541000] esi: 00000000   edi: 6e560220   ebp: bfeb0a58   esp: bfeb0990
> [39525.547000] ds: 007b   es: 007b   fs: 0000  gs: 0033  ss: 007b
> [39525.553000] Process line (pid: 4277, ti=cf200000 task=f6f560b0 task.ti=cf200000)
> [39525.560000] Kernel panic - not syncing: Aiee, killing interrupt handler!
> 
> http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.21-git8/git-console.log
> http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.21-git8/git-config
> 

I don't know what caused the CPU to jump into hyperspace like that, but Patrick
tells me that this:

> [38773.921000] printk: 15909 messages suppressed.
> [38773.926000] ipt_hook: happy cracking.
> [38778.921000] printk: 16332 messages suppressed.
> [38778.925000] ipt_hook: happy cracking.
> [38783.921000] printk: 16175 messages suppressed.
> [38783.926000] ipt_hook: happy cracking.
> [38788.921000] printk: 16390 messages suppressed.
> [38788.925000] ipt_hook: happy cracking.
> [38793.921000] printk: 16289 messages suppressed.
> [38793.925000] ipt_hook: happy cracking.
> [38798.921000] printk: 16172 messages suppressed.
> [38798.926000] ipt_hook: happy cracking.
> [38803.921000] printk: 15738 messages suppressed.
> [38803.925000] ipt_hook: happy cracking.
> [38808.921000] printk: 14731 messages suppressed.

  happens when a local process sends packets with invalid IP headers
  through raw sockets.

  [ 5225.195000] UDP: short packet: From 37.126.206.54:46544 39671/1182
  to 127.0.0.1:40761

  This seems to indicate something on the local machine (packets are not
  routed to 127.0.0.1) is sending invalid packets, probably with
  incorrectly set up skb pointers.

  I'd suggest to add a WARN_ON(1) in ipt_local_hook().

So can you please add the appropriate WARN_ON?

Whatever happens, that printk should be toned down, shouldn't it?  We
prefer to not let unprivileged apps spam the logs.
