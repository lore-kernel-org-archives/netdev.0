From: Chris Boot <bootc@bootc.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in ipv6_select_ident
Date: Wed, 21 Dec 2011 20:05:06 +0000
Message-ID: <4EF23BF2.4000601@bootc.net>
References: <4EF200BB.7000209@bootc.net>  <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4EF2117F.6000803@bootc.net>  <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1324490401.2301.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yuna.grokhost.net ([87.117.228.63]:56497 "EHLO
	yuna.grokhost.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752320Ab1LUUFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 15:05:10 -0500
In-Reply-To: <1324490401.2301.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/12/2011 18:00, Eric Dumazet wrote:
> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 18:36 +0100, Eric Dumazet a =
=C3=A9crit :
>
>> Good point, thats a different problem then, since 3.1 is not suppose=
d to
>> have this bug.
>>
>> It seems rt->rt6i_peer points to invalid memory in your crash.
>>
>> (RBX=3D00000000000001f4)
>>
>> 8b 83 a4 00 00 00       mov    0xa4(%rbx),%eax    p->refcnt
>> 1f4+a4 ->  CR2=3D0000000000000298
>>
> It would help if you can confirm latest linux tree can reproduce the
> bug.

Hi Eric,

I just built a v3.2-rc6-140-gb9e26df with the same config as the Debian=
=20
3.1.0 kernel. I can reproduce the bug just as easily with this kernel a=
s=20
with the Debian kernel. Unfortunately I wasn't able to get an entire=20
trace, for some reason it didn't appear to be printed to the serial por=
t=20
and hung after the (long) list of loaded kernel modules. The crash=20
happens at the same offset:

[  356.683420] BUG: unable to handle kernel NULL pointer dereference at=
=20
0000000000000298
[  356.691438] IP: [<ffffffff812ea0da>] ipv6_select_ident+0x31/0xa7
[  356.697633] PGD 425060067 PUD 41de8d067 PMD 0
[  356.702123] Oops: 0000 [#1] SMP
[  356.705451] CPU 4
[  356.707366] Modules linked in: tun sha1_ssse3 sha1_generic hmac=20
sha256_generic dlm configfs ebtable_nat ebtables acpi_cpufreq mperf=20
cpufreq_stats cpufreq_conservative cpufreq_powersave cpufreq_userspace=20
microcode xt_NOTRACK ip_set_hash_net act_police cls_basic cls_flow=20
cls_fw cls_u32 sch_tbf sch_prio sch_htb sch_hfsc sch_ingress sch_sfq=20
xt_realm xt_addrtype xt_connlimit iptable_raw ip_set_hash_ip xt_comment=
=20
ipt_ULOG ipt_REJECT ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN=20
ipt_ecn ipt_CLUSTERIP ipt_ah nf_nat_tftp nf_nat_snmp_basic=20
nf_conntrack_snmp xt_recent nf_nat_sip nf_nat_pptp nf_nat_proto_gre=20
nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda ip6_queue xt_set ip_set=
=20
nf_conntrack_tftp nf_conntrack_sip nf_conntrack_sane=20
nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp=20
nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns=20
nf_conntrack_broadcast nf_conntrack_irc nf_conntrack_h323=20
nf_conntrack_ftp ts_kmp xt_NFLOG nfnetlink_log nf_conntrack_amanda=20
xt_TPROXY nf_tproxy_core xt_time xt_TCPMSS xt_tcpmss xt_sctp xt_policy=20
xt_pkttype xt_physdev xt_owner xt_NFQUEUE xt_multiport xt_mark xt_mac=20
xt_limit xt_length xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp=20
xt_dccp xt_connmark ip6t_LOG xt_CLASSIFY ip6t_REJECT xt_AUDIT=20
nf_conntrack_ipv6

I loaded the kernel in gdb to see where it thought that was:

(gdb) list *ipv6_select_ident+0x31/0xa7
0xffffffff812ea0a9 is in ipv6_select_ident (net/ipv6/ip6_output.c:602).
597
598             return offset;
599     }
600
601     void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *=
rt)
602     {
603             static atomic_t ipv6_fragmentation_id;
604             int old, new;
605
606             if (rt) {

HTH,
Chris

--=20
Chris Boot
bootc@bootc.net
