From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: WARN trace - skb_warn_bad_offload - vxlan - large udp packet - udp
 checksum disabled
Date: Tue, 15 Dec 2015 01:35:27 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFD00B5@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Tom Herbert <tom@herbertland.com>, Jesse Gross <jesse@nicira.com>,
	"Jiri Benc" <jbenc@redhat.com>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:58708 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932859AbbLOBf3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 20:35:29 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using a slightly modified version of udpspam (see diff below - hopefull=
y not mangled by corporate email servers), where I set the SO_NO_CHECK =
socket option and can specify a large buffer size, I can reliably get t=
he following WARN trace.  I have reproduced this on both ixgbe and i40e=
 drivers using "udpspam-no-check <target-ip> 6000".

It looks to me like this is in the Tx path before we get to the actual =
NIC drivers, but I may be wrong.


[ 1757.644324] ------------[ cut here ]------------
[ 1757.644333] WARNING: CPU: 22 PID: 5537 at net/core/dev.c:2423 skb_wa=
rn_bad_offload+0x104/0x111()
[ 1757.644340] ixgbe: caps=3D(0x0000080660314bb3, 0x0000000000000000) l=
en=3D6092 data_len=3D6000 gso_size=3D1528 gso_type=3D1026 ip_summed=3D0
[ 1757.644343] Modules linked in: nfnetlink_queue nfnetlink_log nfnetli=
nk vxlan ip6_udp_tunnel udp_tunnel rfcomm xt_CHECKSUM bnep bluetooth rf=
kill tun fuse ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv=
6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_connt=
rack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables =
ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tabl=
es iptable_mangle iptable_security iptable_raw x86_pkg_temp_thermal cor=
etemp kvm_intel kvm joydev iTCO_wdt ipmi_devintf iTCO_vendor_support ir=
qbypass crct10dif_pclmul ixgbe igb crc32_pclmul ipmi_si ptp pps_core sb=
_edac lpc_ich crc32c_intel pcspkr edac_core i2c_i801 mfd_core mdio ipmi=
_msghandler mei_me shpchp tpm_tis ioatdma mei dca wmi tpm binfmt_misc u=
input mgag200 i2c_algo_bit drm_kms_helper
[ 1757.644443]  ttm drm isci libsas firewire_ohci firewire_core i2c_cor=
e scsi_transport_sas crc_itu_t
[ 1757.644475] CPU: 22 PID: 5537 Comm: udpspam-no-chec Tainted: G      =
  W       4.4.0-rc3+ #1
[ 1757.644480] Hardware name: Intel Corporation S2600CO/S2600CO, BIOS S=
E5C600.86B.02.03.0003.041920141333 04/19/2014
[ 1757.644482]  0000000000000000 00000000c92b03e4 ffff88081907b410 ffff=
ffff8138f918
[ 1757.644488]  ffff88081907b458 ffff88081907b448 ffffffff8109c036 ffff=
8808196e9500
[ 1757.644494]  ffff880816f60000 0000000000000402 0000000000000000 ffff=
88080e8eb2ac
[ 1757.644499] Call Trace:
[ 1757.644509]  [<ffffffff8138f918>] dump_stack+0x44/0x5c
[ 1757.644514]  [<ffffffff8109c036>] warn_slowpath_common+0x86/0xc0
[ 1757.644518]  [<ffffffff8109c0cc>] warn_slowpath_fmt+0x5c/0x80
[ 1757.644523]  [<ffffffff813958cc>] ? ___ratelimit+0x8c/0xf0
[ 1757.644539]  [<ffffffff8174c77c>] skb_warn_bad_offload+0x104/0x111
[ 1757.644549]  [<ffffffff81649d1f>] __skb_gso_segment+0x7f/0xd0
[ 1757.644563]  [<ffffffff8164a08f>] validate_xmit_skb.isra.104.part.10=
5+0x11f/0x2a0
[ 1757.644572]  [<ffffffff8164a5fb>] validate_xmit_skb_list+0x3b/0x60
[ 1757.644579]  [<ffffffff8166e591>] sch_direct_xmit+0xc1/0x1f0
[ 1757.644585]  [<ffffffff8164a92b>] __dev_queue_xmit+0x21b/0x510
[ 1757.644589]  [<ffffffff8164ac30>] dev_queue_xmit+0x10/0x20
[ 1757.644593]  [<ffffffff8168b66f>] ip_finish_output2+0x23f/0x310
[ 1757.644598]  [<ffffffff8168c179>] ip_finish_output+0x139/0x1f0
[ 1757.644605]  [<ffffffff8167e9d6>] ? nf_hook_slow+0x76/0xd0
[ 1757.644610]  [<ffffffff8168d64e>] ip_output+0x6e/0xe0
[ 1757.644615]  [<ffffffff8168cd02>] ? __ip_local_out+0x42/0x100
[ 1757.644620]  [<ffffffff8168c040>] ? ip_fragment.constprop.49+0x80/0x=
80
[ 1757.644627]  [<ffffffff8168cdf5>] ip_local_out+0x35/0x40
[ 1757.644634]  [<ffffffff816d195d>] iptunnel_xmit+0x12d/0x150
[ 1757.644640]  [<ffffffffa036326a>] udp_tunnel_xmit_skb+0xea/0x100 [ud=
p_tunnel]
[ 1757.644648]  [<ffffffffa038a506>] vxlan_xmit_one+0xac6/0x1280 [vxlan=
]
[ 1757.644659]  [<ffffffff810ef332>] ? vprintk_emit+0x2f2/0x4f0
[ 1757.644675]  [<ffffffff81193772>] ? printk+0x5d/0x74
[ 1757.644681]  [<ffffffff8109c045>] ? warn_slowpath_common+0x95/0xc0
[ 1757.644688]  [<ffffffffa038bf32>] vxlan_xmit+0x172/0xd44 [vxlan]
[ 1757.644694]  [<ffffffff816c26a3>] ? inet_gso_segment+0x163/0x360
[ 1757.644711]  [<ffffffff8164a43e>] dev_hard_start_xmit+0x22e/0x3b0
[ 1757.644721]  [<ffffffff8164ab24>] __dev_queue_xmit+0x414/0x510
[ 1757.644734]  [<ffffffff8164ac30>] dev_queue_xmit+0x10/0x20
[ 1757.644747]  [<ffffffff8168b66f>] ip_finish_output2+0x23f/0x310
[ 1757.644758]  [<ffffffff8168c179>] ip_finish_output+0x139/0x1f0
[ 1757.644763]  [<ffffffff8167e9d6>] ? nf_hook_slow+0x76/0xd0
[ 1757.644768]  [<ffffffff8168d64e>] ip_output+0x6e/0xe0
[ 1757.644775]  [<ffffffff8168cd02>] ? __ip_local_out+0x42/0x100
[ 1757.644780]  [<ffffffff8168c040>] ? ip_fragment.constprop.49+0x80/0x=
80
[ 1757.644785]  [<ffffffff8168cdf5>] ip_local_out+0x35/0x40
[ 1757.644793]  [<ffffffff8168e0c9>] ip_send_skb+0x19/0x40
[ 1757.644800]  [<ffffffff816b41cd>] udp_send_skb+0x16d/0x270
[ 1757.644807]  [<ffffffff816b50f8>] udp_sendmsg+0x2c8/0x9a0
[ 1757.644812]  [<ffffffff8168b1b0>] ? ip_reply_glue_bits+0x60/0x60
[ 1757.644825]  [<ffffffff816c2387>] inet_sendmsg+0x67/0xa0
[ 1757.644838]  [<ffffffff8162bf88>] sock_sendmsg+0x38/0x50
[ 1757.644852]  [<ffffffff8162c442>] SYSC_sendto+0x102/0x190
[ 1757.644860]  [<ffffffff8113842f>] ? __audit_syscall_entry+0xaf/0x100
[ 1757.644867]  [<ffffffff81003176>] ? do_audit_syscall_entry+0x66/0x70
[ 1757.644873]  [<ffffffff810037ef>] ? syscall_trace_enter_phase1+0x11f=
/0x140
[ 1757.644879]  [<ffffffff81096c6d>] ? syscall_slow_exit_work+0x3f/0x9f
[ 1757.644883]  [<ffffffff8162cf5e>] SyS_sendto+0xe/0x10
[ 1757.644890]  [<ffffffff8175946e>] entry_SYSCALL_64_fastpath+0x12/0x7=
1
[ 1757.644895] ---[ end trace ec9dfd887c59f41f ]---


Here are the udpspam.c diffs from the original that I found at
http://oss.sgi.com/archives/netdev/2001-10/txtmtEDzF63p0.txt


--- udpspam.c	2015-12-14 16:56:18.287053786 -0800
+++ udpspam-no-check.c	2015-12-14 17:02:21.979047972 -0800
@@ -42,8 +42,8 @@ typedef unsigned long dword;
=20
 /* Globals */
=20
-#define PAYLOAD_SIZE 4
-static char payload[PAYLOAD_SIZE];
+static int payload_size =3D 4;
+static char *payload;
=20
 /* Socket functions */
=20
@@ -85,6 +85,8 @@ static int get_udp_socket(){
=20
 	option =3D 0;
 	setsockopt(fd,SOL_SOCKET,SO_BROADCAST,(void *)&option,sizeof(option))=
;
+	option =3D 1;
+	setsockopt(fd,SOL_SOCKET,SO_NO_CHECK,(void *)&option,sizeof(option));
=20
 	udp.sin_addr.s_addr =3D htonl(INADDR_ANY);
 	udp.sin_port =3D htons(0);
@@ -123,9 +125,19 @@ int main(int argc,char *argv[]){
 		exit(-1);
=20
 	socket_connect_address(fd,&remote);
-	memset(payload,0,PAYLOAD_SIZE);
+
+	if (argc =3D=3D 3) {
+		errno =3D 0;
+		payload_size =3D strtol(argv[2], NULL, 0);
+		if (errno) {
+			fprintf(stderr, "bad payload size '%s'\n", argv[2]);
+			exit(1);
+		}
+	}
+	payload =3D malloc(payload_size);
+	memset(payload,0,payload_size);
 	while (1)
-		sendto(fd,payload,PAYLOAD_SIZE,0,(struct sockaddr *)&remote,sizeof(r=
emote));
+		sendto(fd,payload,payload_size,0,(struct sockaddr *)&remote,sizeof(r=
emote));
=20
 	exit(0);
 }


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Mr. Shannon Nelson=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0       =A0=
 Network Division, Intel Corp.
Shannon.Nelson@intel.com=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 I=
 don't speak for Intel
(503) 712-7659=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 Parents can't afford to be squeamish
