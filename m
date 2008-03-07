From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH] [XFRM] Beet: Fix output for ipv6
Date: Fri, 7 Mar 2008 19:22:23 +0200
Message-ID: <200803071922.23513.joakim.koskela@hiit.fi>
References: <200802081812.18985.joakim.koskela@hiit.fi> <200802252231.01021.joakim.koskela@hiit.fi> <20080306110835.GA6802@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:51112 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751254AbYCGRW3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 12:22:29 -0500
In-Reply-To: <20080306110835.GA6802@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 06 March 2008 13:08, Herbert Xu wrote:
> After a quick a look I have to say that I don't think this is
> right.  BEET is supposed to wrap around all extension headers
> so we shouldn't call hdr_offset.  In fact the packet could be
> IPv4 for all we know.
>
> So why don't you show us the crash that you're experiencing?
>
> Thanks,


Thanks for checking this out. I didn't actually think about
interfamily in this patch at all as it didn't work for me without any
patching either, this was only for fixing the 6-6 case.  We've been
using another patch (which sort of builds on this one) for
interfamily, I could actually send it (as a rfc) in just a minute
(it's sort of ugly, follows the old model of handling ipv4/6
differently in x_beet_output), was sort of waiting to get feedback for
the 6-6 case before introducing interfamily.

But anyway - here's the trace from the crash I get. I just do a manual
key setup and try to get a ping through.


------------[ cut here ]------------
invalid opcode: 0000 [#5] PREEMPT
Process ping6 (pid: 5445, ti=dc3ac000 task=dc3940b0 task.ti=dc3ac000)
Stack: df9dea40 00000004 dbb14494 dc3adc1c db87f000 dbb9d880 dbb45540 c0457290
       0000008c df9dea40 00000001 c04726b2 00000000 00000000 dbb9d880 dbb45560
       dbd16248 dbb45540 c03d16a4 0000007c dbd16240 c0475aaf 0000007c dbb14400
Call Trace:
 [<c0457290>] ip6_pol_route_output+0x0/0x20
 [<c04726b2>] xfrm6_dst_lookup+0x32/0x80
 [<c03d16a4>] skb_to_sgvec+0x14/0x30
 [<c0475aaf>] esp6_output+0x1bf/0x290
 [<c04412df>] xfrm_output_resume+0x2bf/0x360
 [<c044d4a1>] ip6_append_data+0xa41/0xc10
 [<c044aa35>] ip6_local_out+0x15/0x20
 [<c044c781>] ip6_push_pending_frames+0x2a1/0x3f0
 [<c046250b>] rawv6_sendmsg+0x99b/0xcf0
 [<c03d45c8>] memcpy_toiovec+0x38/0x50
 [<c03eb40c>] netlink_recvmsg+0x1ec/0x2c0
 [<c011d2f0>] update_curr+0x70/0x110
 [<c041dfd7>] inet_sendmsg+0x37/0x70
 [<c03cc85d>] sock_sendmsg+0xcd/0x100
 [<c01368d0>] autoremove_wake_function+0x0/0x50
 [<c03ccc14>] sys_sendto+0x114/0x160
 [<c015af71>] __do_fault+0x171/0x3b0
 [<c0150a00>] filemap_fault+0x0/0x460
 [<c015cde2>] handle_mm_fault+0xf2/0x5e0
 [<c03cdd58>] sys_socketcall+0x198/0x280
 [<c0104082>] sysenter_past_esp+0x5f/0x85
 [<c04c0000>] quirk_piix4_acpi+0x30/0x170
 =======================

Code: ff ff c7 44 24 0c 16 09 00 00 c7 44 24 08 27 98 59 c0 c7 44 24 04 39 98 59 c0 c7 04 24 30 ce 59 c0 e8 c5 35 d5 ff e9 02 ff ff ff <0f> 0b eb fe 0f 0b eb fe 90 8d b4 26 00 00 00 00 53 89 d3 83 ec

EIP: [<c03d1680>] __skb_to_sgvec+0x280/0x290 SS:ESP 0068:dc3adbc0

Modules linked in: radeon drm rfcomm l2cap binfmt_misc ppdev lp cpufreq_userspace cpufreq_conservative cpufreq_powersave cpufreq_ondemand ipt_TTL ipt_ttl ipt_REDIRECT ipt_recent ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_ecn ipt_addrtype nf_nat_tftp nf_nat_snmp_basic nf_nat_sip nf_nat_pptp nf_nat_proto_gre nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda ts_kmp nf_conntrack_amanda nf_conntrack_tftp nf_conntrack_sip nf_conntrack_proto_sctp nf_conntrack_pptp nf_conntrack_proto_gre nf_conntrack_netbios_ns nf_conntrack_irc nf_conntrack_h323 nf_conntrack_ftp xt_tcpmss xt_pkttype xt_mark xt_mac xt_limit xt_length xt_helper xt_hashlimit xt_dccp xt_conntrack xt_CONNMARK xt_connmark xt_state iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nls_cp437 loop 8250_pci hci_usb bluetooth snd_intel8x0 snd_intel
 8x0m snd_ac97_codec ac97_bus snd_pcm_oss snd_mixer_oss irtty_sir snd_pcm sir_dev snd_timer 8250_pnp irda snd 8250 serial_core crc_ccitt parport_pc parport ipw2100 floppy soundcore ide_cd_mod i2c_
801 snd_page_alloc cdrom ieee80211 ieee80211_crypt e1000 ehci_hcd uhci_hcd usbcore evdev

Pid: 5445, comm: ping6 Tainted: G      D  (2.6.25-rc3-00135-g1ff82fe #1)
EIP: 0060:[<c03d1680>] EFLAGS: 00010206 CPU: 0
EIP is at __skb_to_sgvec+0x280/0x290
EAX: dbb9d880 EBX: 00000250 ECX: dbb45540 EDX: dbd16300
ESI: 00000000 EDI: 00000028 EBP: 0000008c ESP: dc3adbc0
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
---[ end trace 778e504de7e3b1e3 ]---
 
