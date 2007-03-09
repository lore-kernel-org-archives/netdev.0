From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [Bugme-new] [Bug 8132] New: pptp server lockup in   ppp_asynctty_receive()
Date: Fri, 9 Mar 2007 14:10:32 +0100
Message-ID: <20070309131031.GE1662@ff.dom.local>
References: <20070308084539.GA2423@ff.dom.local> <01a001c76226$c956b290$9b01a8c0@Empty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@bugzilla.kernel.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-ppp@vger.kernel.org
To: "Yuriy N\. Shkandybin" <jura@netams.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:60794 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1767261AbXCINGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 08:06:30 -0500
Content-Disposition: inline
In-Reply-To: <01a001c76226$c956b290$9b01a8c0@Empty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 09, 2007 at 11:40:04AM +0300, Yuriy N. Shkandybin wrote:
...
> .config is at
> http://bugzilla.kernel.org/attachment.cgi?id=10660&action=view
> Also all information i've provied was recieved by serial console and it's 
> not hand writing.
> 
> I've checked logs and right before lockup there is oops in syslog
> Mar  5 21:50:44 vpn2 skb_under_panic: text:c02248a2 len:207 put:1 
> head:db96e22c data:db96e22b tail:db96e2fa end:db96e82c dev:<NULL>

This looks like a real problem with skb and maybe with
dev->hard_header_len. I see you are using vlan module,
so maybe there is some interaction? I don't know ppp
enough, so I CC this message to the ppp list.
I'm not sure HZ change will cure this forever (maybe
some packets are going to the wrong dev?).

If you're willing to experiment, you can try to edit
"include/linux/ppp_defs.h" and change it like this:

#define PPP_HDRLEN	8
#define PPP_MRU		1496

and "include/linux/if_ppp.h":

#define PPP_MTU		1496

plus mru/mtu in your pppd config (and recompile).

But I hope ppp people will propose something better.

Cheers,
Jarek P.

> Mar  5 21:50:44 vpn2 ------------[ cut here ]------------
> Mar  5 21:50:44 vpn2 kernel BUG at net/core/skbuff.c:112!
> Mar  5 21:50:44 vpn2 invalid opcode: 0000 [#1]
> Mar  5 21:50:44 vpn2 SMP
> Mar  5 21:50:44 vpn2 Modules linked in: 8021q ipt_TCPMSS xt_tcpudp 
> xt_pkttype iptable_filter ip_tables x_tables i2c_i801 i2c_core
> Mar  5 21:50:44 vpn2 CPU:    1
> Mar  5 21:50:44 vpn2 EIP:    0060:[<c024d1e4>]    Not tainted VLI
> Mar  5 21:50:44 vpn2 EFLAGS: 00010092   (2.6.20-gentoo #10)
> Mar  5 21:50:44 vpn2 EIP is at skb_under_panic+0x59/0x5d
> Mar  5 21:50:44 vpn2 eax: 00000072   ebx: db96e22c   ecx: 00000001   edx: 
> de20d4d0
> Mar  5 21:50:44 vpn2 esi: 00000000   edi: db96e2fc   ebp: dc5ab2e8   esp: 
> dcaf5e84
> Mar  5 21:50:44 vpn2 ds: 007b   es: 007b   ss: 0068
> Mar  5 21:50:44 vpn2 Process pptpctrl (pid: 5203, ti=dcaf4000 task=de20d4d0 
> task.ti=dcaf4000)
> Mar  5 21:50:44 vpn2 Stack: c0315e34 c02248a2 000000cf 00000001 db96e22c 
> db96e22b db96e2fa db96e82c
> Mar  5 21:50:44 vpn2 c0301eef 00000004 00000000 c02248b0 de20d4d0 de20da04 
> de20d4d0 00000000
> Mar  5 21:50:44 vpn2 db96e22b 000000cf de3e28f0 de3e2884 00000000 ddae82ac 
> de3e2854 00000296
> Mar  5 21:50:44 vpn2 Call Trace:
> Mar  5 21:50:44 vpn2 [<c02248a2>] ppp_asynctty_receive+0x6d2/0x710
> Mar  5 21:50:44 vpn2 [<c02248b0>] ppp_asynctty_receive+0x6e0/0x710
> Mar  5 21:50:44 vpn2 [<c01d5a09>] pty_write+0x39/0x41
> Mar  5 21:50:44 vpn2 [<c01d37e1>] write_chan+0x212/0x320
> Mar  5 21:50:44 vpn2 [<c0116209>] default_wake_function+0x0/0xc
> Mar  5 21:50:44 vpn2 [<c01d1028>] tty_write+0x11c/0x1d0
> Mar  5 21:50:44 vpn2 [<c01d35cf>] write_chan+0x0/0x320
> Mar  5 21:50:44 vpn2 [<c015d502>] vfs_write+0x87/0xf0
> Mar  5 21:50:44 vpn2 [<c01d0f0c>] tty_write+0x0/0x1d0
> Mar  5 21:50:44 vpn2 [<c015daa9>] sys_write+0x41/0x6a
> Mar  5 21:50:44 vpn2 [<c0102dae>] sysenter_past_esp+0x5f/0x99
> Mar  5 21:50:44 vpn2 =======================
> Mar  5 21:50:44 vpn2 Code: 00 00 89 5c 24 14 8b 98 8c 00 00 00 89 5c 24 10 
> 89 54 24 0c 8b 40 60 89 44 24 08 89 4c 24 04 c7 04 24 34 5e 31 c0 e8 8e e4 
> ec ff <0
> f> 0b eb fe 56 53 83 ec 24 8b 70 14 bb ef 1e 30 c0 85 f6 0f 45
> Mar  5 21:50:44 vpn2 EIP: [<c024d1e4>] skb_under_panic+0x59/0x5d SS:ESP 
> 0068:dcaf5e84
> 
> Another thing - when i`ve changed HZ from 100 too 300 there is no such 
> lockups for few days.
> 
> Jura
> 
