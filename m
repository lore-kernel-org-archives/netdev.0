From: Artem Savkov <artem.savkov@gmail.com>
Subject: Re: [PATCH] net: tcp: ipv6_mapped needs sk_rx_dst_set method
Date: Sat, 18 Aug 2012 17:06:43 +0400
Message-ID: <20120818130642.GA10680@thinkpad.lan>
References: <20120809160349.d2880b5a.akpm@linux-foundation.org>
 <1344556733.31104.819.camel@edumazet-glaptop>
 <1344557460.31104.863.camel@edumazet-glaptop>
 <20120809.210600.638327100706973152.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:36375 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432Ab2HRNGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Aug 2012 09:06:50 -0400
Received: by lbbgj3 with SMTP id gj3so2606938lbb.19
        for <netdev@vger.kernel.org>; Sat, 18 Aug 2012 06:06:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120809.210600.638327100706973152.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 09, 2012 at 09:06:00PM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 10 Aug 2012 02:11:00 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > commit 5d299f3d3c8a2fb (net: ipv6: fix TCP early demux) added a
> > regression for ipv6_mapped case.
>  ...
> > Fix this using inet_sk_rx_dst_set(), and export this function in case
> > IPv6 is modular.
> > 
> > Reported-by: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied.

It doesn't seem to fix the problem with mapped ipv6 completely.
I'm still hitting a NULL pointer dereference with mapped ipv6:

[ 1699.191775] BUG: unable to handle kernel NULL pointer dereference at 00000016
[ 1699.192083] IP: [<c15d11d0>] inet6_sk_rx_dst_set+0x40/0xa0
[ 1699.192290] *pde = 00000000 
[ 1699.192455] Oops: 0000 [#1] SMP 
[ 1699.192686] Modules linked in: netconsole fuse iwldvm mac80211 btusb bluetooth kvm_intel iwlwifi cpufreq_ondemand kvm cfg80211 acpi_cpufreq mperf freq_table lpc_ich joydev crc32c_intel r8169 thermal thinkpad_acpi battery ac intel_ips processor
[ 1699.194710] Pid: 9823, comm: ncmpcpp Not tainted 3.6.0-rc1-next-20120810 #96 LENOVO 0578A21/0578A21
[ 1699.194896] EIP: 0060:[<c15d11d0>] EFLAGS: 00210202 CPU: 0
[ 1699.195040] EIP is at inet6_sk_rx_dst_set+0x40/0xa0
[ 1699.195176] EAX: 00000002 EBX: ef880780 ECX: f3264700 EDX: efc18e54
[ 1699.195325] ESI: edb01540 EDI: 00000000 EBP: f540dce8 ESP: f540dce0
[ 1699.195473]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[ 1699.195610] CR0: 8005003b CR2: 00000016 CR3: 2d61a000 CR4: 000007d0
[ 1699.195757] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[ 1699.195904] DR6: ffff0ff0 DR7: 00000400
[ 1699.196025] Process ncmpcpp (pid: 9823, ti=f540c000 task=eca26680 task.ti=e5354000)
[ 1699.196189] Stack:
[ 1699.196280]  ef880780 f3264c80 f540dd04 c15662a1 edb01540 efc18780 efc18780 f3264c80
[ 1699.197242]  efc18780 f540dd2c c1563b54 3401a499 3a200680 34932749 00d00680 edb01540
[ 1699.197933]  efc18780 f3264c80 c16c0de0 f540dd9c c15d162e 00000000 c12691d1 f540dd54
[ 1699.198630] Call Trace:
[ 1699.198736]  [<c15662a1>] tcp_create_openreq_child+0x41/0x4e0
[ 1699.198884]  [<c1563b54>] tcp_v4_syn_recv_sock+0x34/0x330
[ 1699.199032]  [<c15d162e>] tcp_v6_syn_recv_sock+0x3fe/0x660
[ 1699.199178]  [<c12691d1>] ? selinux_sock_rcv_skb_compat+0xb1/0xc0
[ 1699.199332]  [<c106c95d>] ? sched_clock_cpu+0xfd/0x180
[ 1699.199474]  [<c1566b76>] tcp_check_req+0x2b6/0x410
[ 1699.199610]  [<c1564756>] tcp_v4_do_rcv+0x266/0x420
[ 1699.199746]  [<c15659a2>] ? tcp_v4_rcv+0x732/0xb20
[ 1699.199881]  [<c162e25a>] ? _raw_spin_lock_nested+0x6a/0x80
[ 1699.200031]  [<c1565c9d>] tcp_v4_rcv+0xa2d/0xb20
[ 1699.200167]  [<c1541e0a>] ip_local_deliver_finish+0xda/0x370
[ 1699.200312]  [<c1541d6c>] ? ip_local_deliver_finish+0x3c/0x370
[ 1699.200460]  [<c15426cf>] ip_local_deliver+0x7f/0x90
[ 1699.200597]  [<c1541d30>] ? inet_del_protocol+0x40/0x40
[ 1699.200737]  [<c15421c2>] ip_rcv_finish+0x122/0x4a0
[ 1699.200873]  [<c1542965>] ip_rcv+0x285/0x370
[ 1699.201005]  [<c15420a0>] ? ip_local_deliver_finish+0x370/0x370
[ 1699.201156]  [<c1503b30>] __netif_receive_skb+0x540/0x790
[ 1699.201298]  [<c15036e1>] ? __netif_receive_skb+0xf1/0x790
[ 1699.201442]  [<c1503e13>] process_backlog+0x93/0x150
[ 1699.201578]  [<c1504915>] net_rx_action+0x105/0x1d0
[ 1699.201716]  [<c103d72f>] __do_softirq+0x9f/0x1d0
[ 1699.201854]  [<c103d690>] ? local_bh_enable_ip+0x90/0x90
[ 1699.202260]  <IRQ> 
[ 1699.202397] [<c103d679>] ? local_bh_enable_ip+0x79/0x90
[ 1699.202682]  [<c162ec35>] ? _raw_spin_unlock_bh+0x35/0x40
[ 1699.202826]  [<c14f3cbc>] ? release_sock+0x14c/0x1c0
[ 1699.205792]  [<c157537f>] ? inet_stream_connect+0x3f/0x50
[ 1699.208723]  [<c14f07c2>] ? sys_connect+0xb2/0xd0
[ 1699.211642]  [<c1125b9c>] ? fd_install+0x4c/0x60
[ 1699.214583]  [<c162ecf2>] ? _raw_spin_unlock+0x22/0x30
[ 1699.217400]  [<c1125b9c>] ? fd_install+0x4c/0x60
[ 1699.220080]  [<c14ee794>] ? sock_map_fd+0x24/0x30
[ 1699.222690]  [<c12b33e2>] ? _copy_from_user+0x52/0x70
[ 1699.225259]  [<c14f134f>] ? sys_socketcall+0xef/0x2d0
[ 1699.227803]  [<c105eceb>] ? up_write+0x1b/0x30
[ 1699.230325]  [<c16355cc>] ? sysenter_do_call+0x12/0x2d
[ 1699.232835] Code: c3 89 d6 f6 c1 01 75 33 83 e1 fe f0 ff 41 40 89 8b 10 01 00 00 8b 46 74 89 83 fc 02 00 00 8b 41 58 85 c0 74 0c 8b 93 d0 02 00 00 <8b> 40 14 89 42 68 8b 5d f8 8b 75 fc 89 ec 5d c3 e8 cb 21 a8 ff 
[ 1699.242913] EIP: [<c15d11d0>] inet6_sk_rx_dst_set+0x40/0xa0 SS:ESP 0068:f540dce0
[ 1699.245945] CR2: 0000000000000016
[ 1699.280708] ---[ end trace 3fb05aeec95e7238 ]---
[ 1699.280806] Kernel panic - not syncing: Fatal exception in interrupt
[ 1699.284674] panic occurred, switching back to text console

After some debugging I found out that rt->rt6i_node in inet6_sk_rx_dst_set
is 0x02 when this happens.

I've been able to fix this with:
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4d63dff..a10a436 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1198,6 +1198,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
                 *      v6 mapped
                 */
 
+               inet_csk(sk)->icsk_af_ops = &ipv6_mapped;
                newsk = tcp_v4_syn_recv_sock(sk, skb, req, dst);
 
                if (newsk == NULL)
@@ -1218,7 +1219,6 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
                newnp->rcv_saddr = newnp->saddr;
 
-               inet_csk(newsk)->icsk_af_ops = &ipv6_mapped;
                newsk->sk_backlog_rcv = tcp_v4_do_rcv;
 #ifdef CONFIG_TCP_MD5SIG
                newtp->af_specific = &tcp_sock_ipv6_mapped_specific;

But not sure if this is safe. Is it better to add some kind of
additional check to inet6_sk_rx_dst_set?


-- 
Kind regards,
Artem
