From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: dccp: null-pointer dereference on close
Date: Mon, 28 Feb 2011 12:21:40 +0100
Message-ID: <20110228112140.GA3620@gerrit.erg.abdn.ac.uk>
References: <20110226174505.GB3609@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Johan Hovold <jhovold@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:61762 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753344Ab1B1LWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 06:22:03 -0500
Content-Disposition: inline
In-Reply-To: <20110226174505.GB3609@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 32/64 bit x86 problem so far not seen.

Problem seems to be that 

140        tw->tw_tb = icsk->icsk_bind_hash is NULL in __inet_twsk_hashdance()
141        WARN_ON(!icsk->icsk_bind_hash); 

Will be looking at this later on today - any hints how to reproduce would be appreciated.

Gerrit

Quoting Johan Hovold:
| Hi,
| 
| I triggered the null-pointer dereference below when closing a dccp
| socket on 2.6.37 the other day. The receive path is hit during
| close, and the socket has already been unhashed in dccp_set_state from
| dccp_close.
| 
| Thanks,
| Johan
| 
| 
| root@overo:~# [84140.128631] ------------[ cut here ]------------
| [84140.133575] WARNING: at net/ipv4/inet_timewait_sock.c:141 __inet_twsk_hashdance+0x48/0x128()
| [84140.142517] Modules linked in: arc4 ecb carl9170 rt2870sta(C) mac80211 r8712u(C) crc_ccitt ah
| [84140.151794] [<c0038850>] (unwind_backtrace+0x0/0xec) from [<c0055364>] (warn_slowpath_common)
| [84140.161743] [<c0055364>] (warn_slowpath_common+0x4c/0x64) from [<c0055398>] (warn_slowpath_n)
| [84140.171966] [<c0055398>] (warn_slowpath_null+0x1c/0x24) from [<c02b72d0>] (__inet_twsk_hashd)
| [84140.182373] [<c02b72d0>] (__inet_twsk_hashdance+0x48/0x128) from [<c031caa0>] (dccp_time_wai)
| [84140.192413] [<c031caa0>] (dccp_time_wait+0x40/0xc8) from [<c031c15c>] (dccp_rcv_state_proces)
| [84140.202636] [<c031c15c>] (dccp_rcv_state_process+0x120/0x538) from [<c032609c>] (dccp_v4_do_)
| [84140.213043] [<c032609c>] (dccp_v4_do_rcv+0x11c/0x14c) from [<c0286594>] (release_sock+0xac/0)
| [84140.222442] [<c0286594>] (release_sock+0xac/0x110) from [<c031fd34>] (dccp_close+0x28c/0x380)
| [84140.231475] [<c031fd34>] (dccp_close+0x28c/0x380) from [<c02d9a78>] (inet_release+0x64/0x70)
| [84140.240386] [<c02d9a78>] (inet_release+0x64/0x70) from [<c0284ddc>] (sock_release+0x24/0xb8)
| [84140.249328] [<c0284ddc>] (sock_release+0x24/0xb8) from [<c0284e94>] (sock_close+0x24/0x34)
| [84140.258087] [<c0284e94>] (sock_close+0x24/0x34) from [<c00c2e4c>] (fput+0x108/0x1f4)
| [84140.266296] [<c00c2e4c>] (fput+0x108/0x1f4) from [<c00c0104>] (filp_close+0x70/0x7c)
| [84140.274505] [<c00c0104>] (filp_close+0x70/0x7c) from [<c00c01c4>] (sys_close+0xb4/0x10c)
| [84140.283081] [<c00c01c4>] (sys_close+0xb4/0x10c) from [<c0033a80>] (ret_fast_syscall+0x0/0x30)
| [84140.292114] ---[ end trace b8877ec9d542c32e ]---
| [84140.296997] Unable to handle kernel NULL pointer dereference at virtual address 00000010
| [84140.305541] pgd = cedb0000
| [84140.308410] [00000010] *pgd=8ed22031, *pte=00000000, *ppte=00000000
| [84140.315032] Internal error: Oops: 17 [#1] PREEMPT
| [84140.320007] last sysfs file: /sys/kernel/uevent_seqnum
| [84140.325408] Modules linked in: arc4 ecb carl9170 rt2870sta(C) mac80211 r8712u(C) crc_ccitt ah
| [84140.334533] CPU: 0    Tainted: G        WC   (2.6.37+ #47)
| [84140.340332] PC is at __inet_twsk_hashdance+0x4c/0x128
| [84140.345642] LR is at warn_slowpath_null+0x1c/0x24
| [84140.350616] pc : [<c02b72d4>]    lr : [<c0055398>]    psr: 60000013
| [84140.350616] sp : ce975e68  ip : ce975db8  fp : cfbc5c00
| [84140.362701] r10: cfa3e400  r9 : cfbc5c18  r8 : 00000000
| [84140.368225] r7 : 00000006  r6 : cfa96110  r5 : cfa3e400  r4 : cfb54000
| [84140.375091] r3 : 00000002  r2 : 00000006  r1 : 00000000  r0 : 00000000
| [84140.381988] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
| [84140.389495] Control: 10c5387d  Table: 8edb0019  DAC: 00000015
| [84140.395538] Process be2p_ctrl (pid: 2207, stack limit = 0xce9742f0)
| [84140.402160] Stack: (0xce975e68 to 0xce976000)
| [84140.406738] 5e60:                   cfb54000 00000180 cfa3e400 c031caa0 00000007 cfbc5c00
| [84140.415374] 5e80: cfbc9824 00000020 00000007 c031c15c 00000000 00000022 00000000 00000008
| [84140.424011] 5ea0: 00000001 cfbc5c00 cfbc5c00 cfa3e400 cfbc9824 00000000 00000001 c04c11b8
| [84140.432617] 5ec0: be8ffc1c c032609c fa200000 c0033608 cfa3e400 cfa3e7b0 be8ffc1c ce975ee8
| [84140.441253] 5ee0: be8ffc1c cfbc5c00 cfa3e400 ce974000 00000000 c0286594 cfa3e474 cfa3e400
| [84140.449859] 5f00: cfa3e408 00000007 cf487c20 cf805840 cf60ca00 c031fd34 00000000 00000000
| [84140.458496] 5f20: cfb20288 cfa3e400 cf487c00 00000008 00000000 c02d9a78 00000003 00000000
| [84140.467102] 5f40: cf487c00 c0284ddc 00000000 cfb20288 cfb20280 c0284e94 00000000 c00c2e4c
| [84140.475738] 5f60: 00000000 00000000 cfb20280 00000000 cfbc50c0 00000006 c0033c04 ce974000
| [84140.484375] 5f80: 00000000 c00c0104 00000004 cfbc50c0 cfb20280 c00c01c4 400a1000 00000000
| [84140.492980] 5fa0: 0000891c c0033a80 400a1000 00000000 00000004 00000000 403d3014 00000000
| [84140.501617] 5fc0: 400a1000 00000000 0000891c 00000006 00000000 00000000 400a9000 be8ffc1c
| [84140.510223] 5fe0: 00000000 be8ffbe0 00009584 4036320c 60000010 00000004 00005153 bf0fa7d0
| [84140.518859] [<c02b72d4>] (__inet_twsk_hashdance+0x4c/0x128) from [<c031caa0>] (dccp_time_wai)
| [84140.528869] [<c031caa0>] (dccp_time_wait+0x40/0xc8) from [<c031c15c>] (dccp_rcv_state_proces)
| [84140.539062] [<c031c15c>] (dccp_rcv_state_process+0x120/0x538) from [<c032609c>] (dccp_v4_do_)
| [84140.549407] [<c032609c>] (dccp_v4_do_rcv+0x11c/0x14c) from [<c0286594>] (release_sock+0xac/0)
| [84140.558776] [<c0286594>] (release_sock+0xac/0x110) from [<c031fd34>] (dccp_close+0x28c/0x380)
| [84140.567779] [<c031fd34>] (dccp_close+0x28c/0x380) from [<c02d9a78>] (inet_release+0x64/0x70)
| [84140.576660] [<c02d9a78>] (inet_release+0x64/0x70) from [<c0284ddc>] (sock_release+0x24/0xb8)
| [84140.585571] [<c0284ddc>] (sock_release+0x24/0xb8) from [<c0284e94>] (sock_close+0x24/0x34)
| [84140.594299] [<c0284e94>] (sock_close+0x24/0x34) from [<c00c2e4c>] (fput+0x108/0x1f4)
| [84140.602447] [<c00c2e4c>] (fput+0x108/0x1f4) from [<c00c0104>] (filp_close+0x70/0x7c)
| [84140.610626] [<c00c0104>] (filp_close+0x70/0x7c) from [<c00c01c4>] (sys_close+0xb4/0x10c)
| [84140.619171] [<c00c01c4>] (sys_close+0xb4/0x10c) from [<c0033a80>] (ret_fast_syscall+0x0/0x30)
| [84140.628143] Code: e59f00dc e3a0108d ebf6782a e5941044 (e5912010) 
| [84140.634643] ---[ end trace b8877ec9d542c32f ]---
| [84140.639526] Kernel panic - not syncing: Fatal exception in interrupt
| 
| --
| To unsubscribe from this list: send the line "unsubscribe dccp" in
| the body of a message to majordomo@vger.kernel.org
| More majordomo info at  http://vger.kernel.org/majordomo-info.html
| 

-- 
