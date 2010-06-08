From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: 2.6.32: Frequent Call Traces with Ethernet Bonding
Date: Tue, 08 Jun 2010 12:03:05 -0700
Message-ID: <12524.1276023785@death.nxdomain.ibm.com>
References: <AANLkTikdj-WjtcjnNH0SiD9qHDeSW4e7N3jMCOwzYsY5@mail.gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: John Livingston <jlivings@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:36342 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752038Ab0FHTDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jun 2010 15:03:36 -0400
In-reply-to: <AANLkTikdj-WjtcjnNH0SiD9qHDeSW4e7N3jMCOwzYsY5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Livingston <jlivings@gmail.com> wrote:
>I've recently set up an internal gateway that's used to forward high
>bandwidth traffic among ~10 VLANs.  The system is connected using a
>6-port Ethernet bond (4 ports e1000e, 2 ports bnx2) in balance-alb
>mode, with tagged VLANs running on top of the bond.  A few minutes
>after the box came online I began seeing a massive number of call
>traces.  The box is still functioning for the moment, though its logs
>are filling up quite fast.  I have a number of other machines with
>combination e1000e/bnx2/sky2 NICs that I'd like to try to use in a
>similar fashion, but I'm hoping to track down the cause of this issue
>first.
>
>The machine is an HP Proliant DL 365 G1 running Debian testing, with
>the stock 2.6.32-3 Debian kernel.  The call traces and output of lspci
>-v are below.  Please let me know if any further information would be
>helpful.  Thank you.

	It looks like the GSO code is complaining that an skb is coming
in without ip_summed == CHECKSUM_PARTIAL.  Assuming that this doesn't
happen without bonding, my first guess as to why bonding could be
involved would be that the feature flags aren't correct, and are
confusing the GSO logic.

	Can you include the features for the bonding device itself, one
of the VLANs stacked on it, and one each of the e1000e and bnx2 devices
(I'm assuming the e1000es and bnx2s are all the same)?  These can be
found via, e.g.,

cat /sys/class/net/bond0/features

	-J

>
>===== call traces =====
>
>Jun  8 14:07:59 gateway kernel: [ 5655.000130] ------------[ cut here
>]------------
>Jun  8 14:07:59 gateway kernel: [ 5655.000173] WARNING: at
>/build/mattems-linux-2.6_2.6.32-9-amd64-NYTFdD/linux-2.6-2.6.32-9/debian/build/source_amd64_none/net/core/dev.c:1582
>skb_gso_segment+0x109/0x263()
>Jun  8 14:07:59 gateway kernel: [ 5655.000259] Hardware name: ProLiant DL365 G1
>Jun  8 14:07:59 gateway kernel: [ 5655.000288] 802.1Q VLAN Support:
>caps=(0x190803, 0x19080b) len=2928 data_len=2856 ip_summed=0
>Jun  8 14:07:59 gateway kernel: [ 5655.000324] Modules linked in: tun
>sch_hfsc ip6_queue act_police cls_flow cls_fw cls_u32 sch_htb
>sch_ingress sch_sfq bridge xt_realm ip6t_LOG iptable_raw xt_connlimit
>ip6table_raw xt_comment ip6t_REJECT xt_recent ipt_ULOG ipt_REJECT
>ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_ecn ipt_CLUSTERIP
>ipt_ah ipt_addrtype nf_nat_tftp nf_nat_snmp_basic nf_nat_sip
>nf_nat_pptp nf_nat_proto_gre ip6table_mangle nf_nat_irc
>nf_conntrack_ipv6 nf_nat_h323 nf_nat_ftp nf_nat_amanda
>nf_conntrack_tftp nf_conntrack_sane nf_conntrack_sip
>nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp
>nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns
>nf_conntrack_irc ts_kmp nf_conntrack_amanda nf_conntrack_h323 xt_time
>xt_TCPMSS nf_conntrack_ftp xt_TPROXY xt_sctp nf_tproxy_core xt_policy
>xt_tcpmss xt_pkttype xt_physdev xt_owner xt_NFLOG xt_NFQUEUE
>nfnetlink_log xt_multiport xt_MARK xt_mark xt_mac xt_limit xt_length
>xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp x
>Jun  8 14:07:59 gateway kernel: t_CONNMARK xt_connmark xt_CLASSIFY
>ipt_LOG xt_tcpudp iptable_nat nf_nat xt_state nf_conntrack_ipv4
>nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_mangle nfnetlink
>iptable_filter ip_tables ip6table_filter ip6_tables x_tables
>rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss
>sunrpc 8021q garp stp bonding loop amd64_edac_mod psmouse edac_core
>snd_pcm i2c_piix4 ipmi_si ipmi_msghandler serio_raw edac_mce_amd
>snd_timer snd soundcore snd_page_alloc i2c_core hpwdt evdev pcspkr
>k8temp container hpilo button shpchp pci_hotplug processor ext4
>mbcache jbd2 crc16 dm_mod ide_cd_mod cdrom ide_pci_generic ata_generic
>libata usbhid hid uhci_hcd ohci_hcd cciss serverworks scsi_mod bnx2
>sky2 ehci_hcd ide_core usbcore e1000e nls_base thermal thermal_sys
>[last unloaded: scsi_wait_scan]
>Jun  8 14:07:59 gateway kernel: [ 5655.001381] Pid: 5545, comm: sshd
>Tainted: G        W  2.6.32-3-amd64 #1
>Jun  8 14:07:59 gateway kernel: [ 5655.001415] Call Trace:
>Jun  8 14:07:59 gateway kernel: [ 5655.001444]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:07:59 gateway kernel: [ 5655.001477]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:07:59 gateway kernel: [ 5655.001514]  [<ffffffff8104dbf0>] ?
>warn_slowpath_common+0x77/0xa3
>Jun  8 14:07:59 gateway kernel: [ 5655.001548]  [<ffffffff8104dc78>] ?
>warn_slowpath_fmt+0x51/0x59
>Jun  8 14:07:59 gateway kernel: [ 5655.001588]  [<ffffffffa03b5e6d>] ?
>ip6t_do_table+0x65f/0x69a [ip6_tables]
>Jun  8 14:07:59 gateway kernel: [ 5655.001628]  [<ffffffffa0226f29>] ?
>vlan_ethtool_get_drvinfo+0x24/0x35 [8021q]
>Jun  8 14:07:59 gateway kernel: [ 5655.001680]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:07:59 gateway kernel: [ 5655.001714]  [<ffffffff81243c4f>] ?
>dev_hard_start_xmit+0x1b0/0x2b8
>Jun  8 14:07:59 gateway kernel: [ 5655.001749]  [<ffffffff81244135>] ?
>dev_queue_xmit+0x2dd/0x38d
>Jun  8 14:07:59 gateway kernel: [ 5655.001783]  [<ffffffff812ad79c>] ?
>ip6_output+0xd5c/0xd74
>Jun  8 14:07:59 gateway kernel: [ 5655.001816]  [<ffffffff81260076>] ?
>nf_iterate+0x41/0x7d
>Jun  8 14:07:59 gateway kernel: [ 5655.001848]  [<ffffffff812aa0e8>] ?
>dst_output+0x0/0xb
>Jun  8 14:07:59 gateway kernel: [ 5655.001879]  [<ffffffff81260114>] ?
>nf_hook_slow+0x62/0xc3
>Jun  8 14:07:59 gateway kernel: [ 5655.001911]  [<ffffffff812aa0e8>] ?
>dst_output+0x0/0xb
>Jun  8 14:07:59 gateway kernel: [ 5655.001942]  [<ffffffff812ac4f6>] ?
>ip6_xmit+0x3b9/0x4a0
>Jun  8 14:07:59 gateway kernel: [ 5655.001975]  [<ffffffff812cefb1>] ?
>inet6_csk_xmit+0x249/0x274
>Jun  8 14:07:59 gateway kernel: [ 5655.002012]  [<ffffffff8127b4cf>] ?
>tcp_transmit_skb+0x648/0x687
>Jun  8 14:07:59 gateway kernel: [ 5655.002045]  [<ffffffff8127d944>] ?
>tcp_write_xmit+0x874/0x96c
>Jun  8 14:07:59 gateway kernel: [ 5655.002083]  [<ffffffff8123c641>] ?
>__alloc_skb+0x69/0x15a
>Jun  8 14:07:59 gateway kernel: [ 5655.002116]  [<ffffffff8127da89>] ?
>__tcp_push_pending_frames+0x22/0x53
>Jun  8 14:07:59 gateway kernel: [ 5655.002152]  [<ffffffff81272c6b>] ?
>tcp_sendmsg+0x77c/0x878
>Jun  8 14:07:59 gateway kernel: [ 5655.002186]  [<ffffffff812348ac>] ?
>sock_aio_write+0xb1/0xbc
>Jun  8 14:07:59 gateway kernel: [ 5655.002220]  [<ffffffff810ed27a>] ?
>do_sync_write+0xce/0x113
>Jun  8 14:07:59 gateway kernel: [ 5655.002254]  [<ffffffff81064a56>] ?
>autoremove_wake_function+0x0/0x2e
>Jun  8 14:07:59 gateway kernel: [ 5655.002291]  [<ffffffff8104a1a6>] ?
>default_wake_function+0x0/0x9
>Jun  8 14:07:59 gateway kernel: [ 5655.002324]  [<ffffffff810edc05>] ?
>vfs_write+0xbc/0x102
>Jun  8 14:07:59 gateway kernel: [ 5655.002356]  [<ffffffff810edd07>] ?
>sys_write+0x45/0x6e
>Jun  8 14:07:59 gateway kernel: [ 5655.002390]  [<ffffffff81010b42>] ?
>system_call_fastpath+0x16/0x1b
>Jun  8 14:07:59 gateway kernel: [ 5655.002423] ---[ end trace
>d52ed80ad3c42ed5 ]---
>Jun  8 14:07:59 gateway kernel: [ 5655.002456] ------------[ cut here
>]------------
>Jun  8 14:07:59 gateway kernel: [ 5655.002487] WARNING: at
>/build/mattems-linux-2.6_2.6.32-9-amd64-NYTFdD/linux-2.6-2.6.32-9/debian/build/source_amd64_none/net/core/dev.c:1582
>skb_gso_segment+0x109/0x263()
>Jun  8 14:07:59 gateway kernel: [ 5655.002571] Hardware name: ProLiant DL365 G1
>Jun  8 14:07:59 gateway kernel: [ 5655.002600] bonding:
>caps=(0x1913a3, 0x19080b) len=2928 data_len=2856 ip_summed=0
>Jun  8 14:07:59 gateway kernel: [ 5655.002634] Modules linked in: tun
>sch_hfsc ip6_queue act_police cls_flow cls_fw cls_u32 sch_htb
>sch_ingress sch_sfq bridge xt_realm ip6t_LOG iptable_raw xt_connlimit
>ip6table_raw xt_comment ip6t_REJECT xt_recent ipt_ULOG ipt_REJECT
>ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_ecn ipt_CLUSTERIP
>ipt_ah ipt_addrtype nf_nat_tftp nf_nat_snmp_basic nf_nat_sip
>nf_nat_pptp nf_nat_proto_gre ip6table_mangle nf_nat_irc
>nf_conntrack_ipv6 nf_nat_h323 nf_nat_ftp nf_nat_amanda
>nf_conntrack_tftp nf_conntrack_sane nf_conntrack_sip
>nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp
>nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns
>nf_conntrack_irc ts_kmp nf_conntrack_amanda nf_conntrack_h323 xt_time
>xt_TCPMSS nf_conntrack_ftp xt_TPROXY xt_sctp nf_tproxy_core xt_policy
>xt_tcpmss xt_pkttype xt_physdev xt_owner xt_NFLOG xt_NFQUEUE
>nfnetlink_log xt_multiport xt_MARK xt_mark xt_mac xt_limit xt_length
>xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp x
>Jun  8 14:07:59 gateway kernel: t_CONNMARK xt_connmark xt_CLASSIFY
>ipt_LOG xt_tcpudp iptable_nat nf_nat xt_state nf_conntrack_ipv4
>nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_mangle nfnetlink
>iptable_filter ip_tables ip6table_filter ip6_tables x_tables
>rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss
>sunrpc 8021q garp stp bonding loop amd64_edac_mod psmouse edac_core
>snd_pcm i2c_piix4 ipmi_si ipmi_msghandler serio_raw edac_mce_amd
>snd_timer snd soundcore snd_page_alloc i2c_core hpwdt evdev pcspkr
>k8temp container hpilo button shpchp pci_hotplug processor ext4
>mbcache jbd2 crc16 dm_mod ide_cd_mod cdrom ide_pci_generic ata_generic
>libata usbhid hid uhci_hcd ohci_hcd cciss serverworks scsi_mod bnx2
>sky2 ehci_hcd ide_core usbcore e1000e nls_base thermal thermal_sys
>[last unloaded: scsi_wait_scan]
>Jun  8 14:07:59 gateway kernel: [ 5655.009854] Pid: 5545, comm: sshd
>Tainted: G        W  2.6.32-3-amd64 #1
>Jun  8 14:07:59 gateway kernel: [ 5655.009891] Call Trace:
>Jun  8 14:07:59 gateway kernel: [ 5655.009921]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:07:59 gateway kernel: [ 5655.009959]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:07:59 gateway kernel: [ 5655.009997]  [<ffffffff8104dbf0>] ?
>warn_slowpath_common+0x77/0xa3
>Jun  8 14:07:59 gateway kernel: [ 5655.010036]  [<ffffffff8104dc78>] ?
>warn_slowpath_fmt+0x51/0x59
>Jun  8 14:07:59 gateway kernel: [ 5655.010075]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:07:59 gateway kernel: [ 5655.010111]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:07:59 gateway kernel: [ 5655.010146]  [<ffffffff8104dc0a>] ?
>warn_slowpath_common+0x91/0xa3
>Jun  8 14:07:59 gateway kernel: [ 5655.010185]  [<ffffffff8104dc78>] ?
>warn_slowpath_fmt+0x51/0x59
>Jun  8 14:07:59 gateway kernel: [ 5655.010229]  [<ffffffffa02880ce>] ?
>bond_ethtool_get_drvinfo+0x2e/0x4b [bonding]
>Jun  8 14:07:59 gateway kernel: [ 5655.010285]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:07:59 gateway kernel: [ 5655.010320]  [<ffffffff81243c4f>] ?
>dev_hard_start_xmit+0x1b0/0x2b8
>Jun  8 14:07:59 gateway kernel: [ 5655.010357]  [<ffffffff81244135>] ?
>dev_queue_xmit+0x2dd/0x38d
>Jun  8 14:07:59 gateway kernel: [ 5655.010397]  [<ffffffffa02271c2>] ?
>vlan_dev_hwaccel_hard_start_xmit+0x63/0x7d [8021q]
>Jun  8 14:07:59 gateway kernel: [ 5655.010455]  [<ffffffff81243cb0>] ?
>dev_hard_start_xmit+0x211/0x2b8
>Jun  8 14:07:59 gateway kernel: [ 5655.010491]  [<ffffffff81244135>] ?
>dev_queue_xmit+0x2dd/0x38d
>Jun  8 14:07:59 gateway kernel: [ 5655.010525]  [<ffffffff812ad79c>] ?
>ip6_output+0xd5c/0xd74
>Jun  8 14:07:59 gateway kernel: [ 5655.010560]  [<ffffffff81260076>] ?
>nf_iterate+0x41/0x7d
>Jun  8 14:07:59 gateway kernel: [ 5655.010593]  [<ffffffff812aa0e8>] ?
>dst_output+0x0/0xb
>Jun  8 14:07:59 gateway kernel: [ 5655.010627]  [<ffffffff81260114>] ?
>nf_hook_slow+0x62/0xc3
>Jun  8 14:07:59 gateway kernel: [ 5655.010660]  [<ffffffff812aa0e8>] ?
>dst_output+0x0/0xb
>Jun  8 14:07:59 gateway kernel: [ 5655.010693]  [<ffffffff812ac4f6>] ?
>ip6_xmit+0x3b9/0x4a0
>Jun  8 14:07:59 gateway kernel: [ 5655.010732]  [<ffffffff812cefb1>] ?
>inet6_csk_xmit+0x249/0x274
>Jun  8 14:07:59 gateway kernel: [ 5655.010769]  [<ffffffff8127b4cf>] ?
>tcp_transmit_skb+0x648/0x687
>Jun  8 14:07:59 gateway kernel: [ 5655.010806]  [<ffffffff8127d944>] ?
>tcp_write_xmit+0x874/0x96c
>Jun  8 14:07:59 gateway kernel: [ 5655.010842]  [<ffffffff8123c641>] ?
>__alloc_skb+0x69/0x15a
>Jun  8 14:07:59 gateway kernel: [ 5655.010877]  [<ffffffff8127da89>] ?
>__tcp_push_pending_frames+0x22/0x53
>Jun  8 14:07:59 gateway kernel: [ 5655.010914]  [<ffffffff81272c6b>] ?
>tcp_sendmsg+0x77c/0x878
>Jun  8 14:07:59 gateway kernel: [ 5655.010948]  [<ffffffff812348ac>] ?
>sock_aio_write+0xb1/0xbc
>Jun  8 14:07:59 gateway kernel: [ 5655.010983]  [<ffffffff810ed27a>] ?
>do_sync_write+0xce/0x113
>Jun  8 14:07:59 gateway kernel: [ 5655.011019]  [<ffffffff81064a56>] ?
>autoremove_wake_function+0x0/0x2e
>Jun  8 14:07:59 gateway kernel: [ 5655.011055]  [<ffffffff8104a1a6>] ?
>default_wake_function+0x0/0x9
>Jun  8 14:07:59 gateway kernel: [ 5655.011092]  [<ffffffff810edc05>] ?
>vfs_write+0xbc/0x102
>Jun  8 14:07:59 gateway kernel: [ 5655.011125]  [<ffffffff810edd07>] ?
>sys_write+0x45/0x6e
>Jun  8 14:07:59 gateway kernel: [ 5655.011158]  [<ffffffff81010b42>] ?
>system_call_fastpath+0x16/0x1b
>Jun  8 14:07:59 gateway kernel: [ 5655.011192] ---[ end trace
>d52ed80ad3c42ed6 ]---
>Jun  8 14:08:01 gateway kernel: [ 5656.277637] ------------[ cut here
>]------------
>Jun  8 14:08:01 gateway kernel: [ 5656.277673] WARNING: at
>/build/mattems-linux-2.6_2.6.32-9-amd64-NYTFdD/linux-2.6-2.6.32-9/debian/build/source_amd64_none/net/core/dev.c:1582
>skb_gso_segment+0x109/0x263()
>Jun  8 14:08:01 gateway kernel: [ 5656.277768] Hardware name: ProLiant DL365 G1
>Jun  8 14:08:01 gateway kernel: [ 5656.277797] 802.1Q VLAN Support:
>caps=(0x190803, 0x19080b) len=2928 data_len=2856 ip_summed=0
>Jun  8 14:08:01 gateway kernel: [ 5656.277832] Modules linked in: tun
>sch_hfsc ip6_queue act_police cls_flow cls_fw cls_u32 sch_htb
>sch_ingress sch_sfq bridge xt_realm ip6t_LOG iptable_raw xt_connlimit
>ip6table_raw xt_comment ip6t_REJECT xt_recent ipt_ULOG ipt_REJECT
>ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_ecn ipt_CLUSTERIP
>ipt_ah ipt_addrtype nf_nat_tftp nf_nat_snmp_basic nf_nat_sip
>nf_nat_pptp nf_nat_proto_gre ip6table_mangle nf_nat_irc
>nf_conntrack_ipv6 nf_nat_h323 nf_nat_ftp nf_nat_amanda
>nf_conntrack_tftp nf_conntrack_sane nf_conntrack_sip
>nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp
>nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns
>nf_conntrack_irc ts_kmp nf_conntrack_amanda nf_conntrack_h323 xt_time
>xt_TCPMSS nf_conntrack_ftp xt_TPROXY xt_sctp nf_tproxy_core xt_policy
>xt_tcpmss xt_pkttype xt_physdev xt_owner xt_NFLOG xt_NFQUEUE
>nfnetlink_log xt_multiport xt_MARK xt_mark xt_mac xt_limit xt_length
>xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp x
>Jun  8 14:08:01 gateway kernel: t_CONNMARK xt_connmark xt_CLASSIFY
>ipt_LOG xt_tcpudp iptable_nat nf_nat xt_state nf_conntrack_ipv4
>nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_mangle nfnetlink
>iptable_filter ip_tables ip6table_filter ip6_tables x_tables
>rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss
>sunrpc 8021q garp stp bonding loop amd64_edac_mod psmouse edac_core
>snd_pcm i2c_piix4 ipmi_si ipmi_msghandler serio_raw edac_mce_amd
>snd_timer snd soundcore snd_page_alloc i2c_core hpwdt evdev pcspkr
>k8temp container hpilo button shpchp pci_hotplug processor ext4
>mbcache jbd2 crc16 dm_mod ide_cd_mod cdrom ide_pci_generic ata_generic
>libata usbhid hid uhci_hcd ohci_hcd cciss serverworks scsi_mod bnx2
>sky2 ehci_hcd ide_core usbcore e1000e nls_base thermal thermal_sys
>[last unloaded: scsi_wait_scan]
>Jun  8 14:08:01 gateway kernel: [ 5656.278845] Pid: 5545, comm: sshd
>Tainted: G        W  2.6.32-3-amd64 #1
>Jun  8 14:08:01 gateway kernel: [ 5656.278878] Call Trace:
>Jun  8 14:08:01 gateway kernel: [ 5656.278905]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.278938]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.278972]  [<ffffffff8104dbf0>] ?
>warn_slowpath_common+0x77/0xa3
>Jun  8 14:08:01 gateway kernel: [ 5656.279005]  [<ffffffff8104dc78>] ?
>warn_slowpath_fmt+0x51/0x59
>Jun  8 14:08:01 gateway kernel: [ 5656.279042]  [<ffffffffa03b5e6d>] ?
>ip6t_do_table+0x65f/0x69a [ip6_tables]
>Jun  8 14:08:01 gateway kernel: [ 5656.279082]  [<ffffffffa0226f29>] ?
>vlan_ethtool_get_drvinfo+0x24/0x35 [8021q]
>Jun  8 14:08:01 gateway kernel: [ 5656.279134]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.279168]  [<ffffffff81243c4f>] ?
>dev_hard_start_xmit+0x1b0/0x2b8
>Jun  8 14:08:01 gateway kernel: [ 5656.279202]  [<ffffffff81244135>] ?
>dev_queue_xmit+0x2dd/0x38d
>Jun  8 14:08:01 gateway kernel: [ 5656.279236]  [<ffffffff812ad79c>] ?
>ip6_output+0xd5c/0xd74
>Jun  8 14:08:01 gateway kernel: [ 5656.279268]  [<ffffffff81260076>] ?
>nf_iterate+0x41/0x7d
>Jun  8 14:08:01 gateway kernel: [ 5656.279300]  [<ffffffff812aa0e8>] ?
>dst_output+0x0/0xb
>Jun  8 14:08:01 gateway kernel: [ 5656.279331]  [<ffffffff81260114>] ?
>nf_hook_slow+0x62/0xc3
>Jun  8 14:08:01 gateway kernel: [ 5656.279363]  [<ffffffff812aa0e8>] ?
>dst_output+0x0/0xb
>Jun  8 14:08:01 gateway kernel: [ 5656.279394]  [<ffffffff812ac4f6>] ?
>ip6_xmit+0x3b9/0x4a0
>Jun  8 14:08:01 gateway kernel: [ 5656.279425]  [<ffffffff812cefb1>] ?
>inet6_csk_xmit+0x249/0x274
>Jun  8 14:08:01 gateway kernel: [ 5656.279460]  [<ffffffff8127b4cf>] ?
>tcp_transmit_skb+0x648/0x687
>Jun  8 14:08:01 gateway kernel: [ 5656.279493]  [<ffffffff8127d944>] ?
>tcp_write_xmit+0x874/0x96c
>Jun  8 14:08:01 gateway kernel: [ 5656.279526]  [<ffffffff8123c641>] ?
>__alloc_skb+0x69/0x15a
>Jun  8 14:08:01 gateway kernel: [ 5656.279559]  [<ffffffff8127da89>] ?
>__tcp_push_pending_frames+0x22/0x53
>Jun  8 14:08:01 gateway kernel: [ 5656.279594]  [<ffffffff81272c6b>] ?
>tcp_sendmsg+0x77c/0x878
>Jun  8 14:08:01 gateway kernel: [ 5656.279627]  [<ffffffff812348ac>] ?
>sock_aio_write+0xb1/0xbc
>Jun  8 14:08:01 gateway kernel: [ 5656.279663]  [<ffffffff811f44c8>] ?
>n_tty_read+0x692/0x774
>Jun  8 14:08:01 gateway kernel: [ 5656.279695]  [<ffffffff810ed27a>] ?
>do_sync_write+0xce/0x113
>Jun  8 14:08:01 gateway kernel: [ 5656.279728]  [<ffffffff81064a56>] ?
>autoremove_wake_function+0x0/0x2e
>Jun  8 14:08:01 gateway kernel: [ 5656.279763]  [<ffffffff8104a1a6>] ?
>default_wake_function+0x0/0x9
>Jun  8 14:08:01 gateway kernel: [ 5656.279797]  [<ffffffff810edc05>] ?
>vfs_write+0xbc/0x102
>Jun  8 14:08:01 gateway kernel: [ 5656.279829]  [<ffffffff810edd07>] ?
>sys_write+0x45/0x6e
>Jun  8 14:08:01 gateway kernel: [ 5656.279866]  [<ffffffff81010b42>] ?
>system_call_fastpath+0x16/0x1b
>Jun  8 14:08:01 gateway kernel: [ 5656.279903] ---[ end trace
>d52ed80ad3c42ed7 ]---
>Jun  8 14:08:01 gateway kernel: [ 5656.279934] ------------[ cut here
>]------------
>Jun  8 14:08:01 gateway kernel: [ 5656.279965] WARNING: at
>/build/mattems-linux-2.6_2.6.32-9-amd64-NYTFdD/linux-2.6-2.6.32-9/debian/build/source_amd64_none/net/core/dev.c:1582
>skb_gso_segment+0x109/0x263()
>Jun  8 14:08:01 gateway kernel: [ 5656.280053] Hardware name: ProLiant DL365 G1
>Jun  8 14:08:01 gateway kernel: [ 5656.280082] bonding:
>caps=(0x1913a3, 0x19080b) len=2928 data_len=2856 ip_summed=0
>Jun  8 14:08:01 gateway kernel: [ 5656.280116] Modules linked in: tun
>sch_hfsc ip6_queue act_police cls_flow cls_fw cls_u32 sch_htb
>sch_ingress sch_sfq bridge xt_realm ip6t_LOG iptable_raw xt_connlimit
>ip6table_raw xt_comment ip6t_REJECT xt_recent ipt_ULOG ipt_REJECT
>ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_ecn ipt_CLUSTERIP
>ipt_ah ipt_addrtype nf_nat_tftp nf_nat_snmp_basic nf_nat_sip
>nf_nat_pptp nf_nat_proto_gre ip6table_mangle nf_nat_irc
>nf_conntrack_ipv6 nf_nat_h323 nf_nat_ftp nf_nat_amanda
>nf_conntrack_tftp nf_conntrack_sane nf_conntrack_sip
>nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp
>nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns
>nf_conntrack_irc ts_kmp nf_conntrack_amanda nf_conntrack_h323 xt_time
>xt_TCPMSS nf_conntrack_ftp xt_TPROXY xt_sctp nf_tproxy_core xt_policy
>xt_tcpmss xt_pkttype xt_physdev xt_owner xt_NFLOG xt_NFQUEUE
>nfnetlink_log xt_multiport xt_MARK xt_mark xt_mac xt_limit xt_length
>xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp x
>Jun  8 14:08:01 gateway kernel: t_CONNMARK xt_connmark xt_CLASSIFY
>ipt_LOG xt_tcpudp iptable_nat nf_nat xt_state nf_conntrack_ipv4
>nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_mangle nfnetlink
>iptable_filter ip_tables ip6table_filter ip6_tables x_tables
>rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss
>sunrpc 8021q garp stp bonding loop amd64_edac_mod psmouse edac_core
>snd_pcm i2c_piix4 ipmi_si ipmi_msghandler serio_raw edac_mce_amd
>snd_timer snd soundcore snd_page_alloc i2c_core hpwdt evdev pcspkr
>k8temp container hpilo button shpchp pci_hotplug processor ext4
>mbcache jbd2 crc16 dm_mod ide_cd_mod cdrom ide_pci_generic ata_generic
>libata usbhid hid uhci_hcd ohci_hcd cciss serverworks scsi_mod bnx2
>sky2 ehci_hcd ide_core usbcore e1000e nls_base thermal thermal_sys
>[last unloaded: scsi_wait_scan]
>Jun  8 14:08:01 gateway kernel: [ 5656.281133] Pid: 5545, comm: sshd
>Tainted: G        W  2.6.32-3-amd64 #1
>Jun  8 14:08:01 gateway kernel: [ 5656.281166] Call Trace:
>Jun  8 14:08:01 gateway kernel: [ 5656.281193]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.281227]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.281260]  [<ffffffff8104dbf0>] ?
>warn_slowpath_common+0x77/0xa3
>Jun  8 14:08:01 gateway kernel: [ 5656.281293]  [<ffffffff8104dc78>] ?
>warn_slowpath_fmt+0x51/0x59
>Jun  8 14:08:01 gateway kernel: [ 5656.281328]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.281361]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.281394]  [<ffffffff8104dc0a>] ?
>warn_slowpath_common+0x91/0xa3
>Jun  8 14:08:01 gateway kernel: [ 5656.281427]  [<ffffffff8104dc78>] ?
>warn_slowpath_fmt+0x51/0x59
>Jun  8 14:08:01 gateway kernel: [ 5656.281465]  [<ffffffffa02880ce>] ?
>bond_ethtool_get_drvinfo+0x2e/0x4b [bonding]
>Jun  8 14:08:01 gateway kernel: [ 5656.281521]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.281557]  [<ffffffff81243c4f>] ?
>dev_hard_start_xmit+0x1b0/0x2b8
>Jun  8 14:08:01 gateway kernel: [ 5656.281595]  [<ffffffff81244135>] ?
>dev_queue_xmit+0x2dd/0x38d
>Jun  8 14:08:01 gateway kernel: [ 5656.281634]  [<ffffffffa02271c2>] ?
>vlan_dev_hwaccel_hard_start_xmit+0x63/0x7d [8021q]
>Jun  8 14:08:01 gateway kernel: [ 5656.281690]  [<ffffffff81243cb0>] ?
>dev_hard_start_xmit+0x211/0x2b8
>Jun  8 14:08:01 gateway kernel: [ 5656.281725]  [<ffffffff81244135>] ?
>dev_queue_xmit+0x2dd/0x38d
>Jun  8 14:08:01 gateway kernel: [ 5656.281760]  [<ffffffff812ad79c>] ?
>ip6_output+0xd5c/0xd74
>Jun  8 14:08:01 gateway kernel: [ 5656.281794]  [<ffffffff81260076>] ?
>nf_iterate+0x41/0x7d
>Jun  8 14:08:01 gateway kernel: [ 5656.281829]  [<ffffffff812aa0e8>] ?
>dst_output+0x0/0xb
>Jun  8 14:08:01 gateway kernel: [ 5656.281865]  [<ffffffff81260114>] ?
>nf_hook_slow+0x62/0xc3
>Jun  8 14:08:01 gateway kernel: [ 5656.281901]  [<ffffffff812aa0e8>] ?
>dst_output+0x0/0xb
>Jun  8 14:08:01 gateway kernel: [ 5656.281936]  [<ffffffff812ac4f6>] ?
>ip6_xmit+0x3b9/0x4a0
>Jun  8 14:08:01 gateway kernel: [ 5656.281971]  [<ffffffff812cefb1>] ?
>inet6_csk_xmit+0x249/0x274
>Jun  8 14:08:01 gateway kernel: [ 5656.282010]  [<ffffffff8127b4cf>] ?
>tcp_transmit_skb+0x648/0x687
>Jun  8 14:08:01 gateway kernel: [ 5656.282052]  [<ffffffff8127d944>] ?
>tcp_write_xmit+0x874/0x96c
>Jun  8 14:08:01 gateway kernel: [ 5656.282089]  [<ffffffff8123c641>] ?
>__alloc_skb+0x69/0x15a
>Jun  8 14:08:01 gateway kernel: [ 5656.282127]  [<ffffffff8127da89>] ?
>__tcp_push_pending_frames+0x22/0x53
>Jun  8 14:08:01 gateway kernel: [ 5656.282166]  [<ffffffff81272c6b>] ?
>tcp_sendmsg+0x77c/0x878
>Jun  8 14:08:01 gateway kernel: [ 5656.282205]  [<ffffffff812348ac>] ?
>sock_aio_write+0xb1/0xbc
>Jun  8 14:08:01 gateway kernel: [ 5656.282241]  [<ffffffff811f44c8>] ?
>n_tty_read+0x692/0x774
>Jun  8 14:08:01 gateway kernel: [ 5656.282276]  [<ffffffff810ed27a>] ?
>do_sync_write+0xce/0x113
>Jun  8 14:08:01 gateway kernel: [ 5656.282312]  [<ffffffff81064a56>] ?
>autoremove_wake_function+0x0/0x2e
>Jun  8 14:08:01 gateway kernel: [ 5656.282351]  [<ffffffff8104a1a6>] ?
>default_wake_function+0x0/0x9
>Jun  8 14:08:01 gateway kernel: [ 5656.282388]  [<ffffffff810edc05>] ?
>vfs_write+0xbc/0x102
>Jun  8 14:08:01 gateway kernel: [ 5656.282425]  [<ffffffff810edd07>] ?
>sys_write+0x45/0x6e
>Jun  8 14:08:01 gateway kernel: [ 5656.282460]  [<ffffffff81010b42>] ?
>system_call_fastpath+0x16/0x1b
>Jun  8 14:08:01 gateway kernel: [ 5656.282497] ---[ end trace
>d52ed80ad3c42ed8 ]---
>Jun  8 14:08:01 gateway kernel: [ 5656.469615] ------------[ cut here
>]------------
>Jun  8 14:08:01 gateway kernel: [ 5656.469648] WARNING: at
>/build/mattems-linux-2.6_2.6.32-9-amd64-NYTFdD/linux-2.6-2.6.32-9/debian/build/source_amd64_none/net/core/dev.c:1582
>skb_gso_segment+0x109/0x263()
>Jun  8 14:08:01 gateway kernel: [ 5656.475890] Hardware name: ProLiant DL365 G1
>Jun  8 14:08:01 gateway kernel: [ 5656.475919] 802.1Q VLAN Support:
>caps=(0x190803, 0x19080b) len=2928 data_len=2856 ip_summed=0
>Jun  8 14:08:01 gateway kernel: [ 5656.475960] Modules linked in: tun
>sch_hfsc ip6_queue act_police cls_flow cls_fw cls_u32 sch_htb
>sch_ingress sch_sfq bridge xt_realm ip6t_LOG iptable_raw xt_connlimit
>ip6table_raw xt_comment ip6t_REJECT xt_recent ipt_ULOG ipt_REJECT
>ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_ecn ipt_CLUSTERIP
>ipt_ah ipt_addrtype nf_nat_tftp nf_nat_snmp_basic nf_nat_sip
>nf_nat_pptp nf_nat_proto_gre ip6table_mangle nf_nat_irc
>nf_conntrack_ipv6 nf_nat_h323 nf_nat_ftp nf_nat_amanda
>nf_conntrack_tftp nf_conntrack_sane nf_conntrack_sip
>nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp
>nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns
>nf_conntrack_irc ts_kmp nf_conntrack_amanda nf_conntrack_h323 xt_time
>xt_TCPMSS nf_conntrack_ftp xt_TPROXY xt_sctp nf_tproxy_core xt_policy
>xt_tcpmss xt_pkttype xt_physdev xt_owner xt_NFLOG xt_NFQUEUE
>nfnetlink_log xt_multiport xt_MARK xt_mark xt_mac xt_limit xt_length
>xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp x
>Jun  8 14:08:01 gateway kernel: t_CONNMARK xt_connmark xt_CLASSIFY
>ipt_LOG xt_tcpudp iptable_nat nf_nat xt_state nf_conntrack_ipv4
>nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_mangle nfnetlink
>iptable_filter ip_tables ip6table_filter ip6_tables x_tables
>rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss
>sunrpc 8021q garp stp bonding loop amd64_edac_mod psmouse edac_core
>snd_pcm i2c_piix4 ipmi_si ipmi_msghandler serio_raw edac_mce_amd
>snd_timer snd soundcore snd_page_alloc i2c_core hpwdt evdev pcspkr
>k8temp container hpilo button shpchp pci_hotplug processor ext4
>mbcache jbd2 crc16 dm_mod ide_cd_mod cdrom ide_pci_generic ata_generic
>libata usbhid hid uhci_hcd ohci_hcd cciss serverworks scsi_mod bnx2
>sky2 ehci_hcd ide_core usbcore e1000e nls_base thermal thermal_sys
>[last unloaded: scsi_wait_scan]
>Jun  8 14:08:01 gateway kernel: [ 5656.477031] Pid: 5545, comm: sshd
>Tainted: G        W  2.6.32-3-amd64 #1
>Jun  8 14:08:01 gateway kernel: [ 5656.477064] Call Trace:
>Jun  8 14:08:01 gateway kernel: [ 5656.477092]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.477125]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.477158]  [<ffffffff8104dbf0>] ?
>warn_slowpath_common+0x77/0xa3
>Jun  8 14:08:01 gateway kernel: [ 5656.477192]  [<ffffffff8104dc78>] ?
>warn_slowpath_fmt+0x51/0x59
>Jun  8 14:08:01 gateway kernel: [ 5656.477232]  [<ffffffffa03b5e6d>] ?
>ip6t_do_table+0x65f/0x69a [ip6_tables]
>Jun  8 14:08:01 gateway kernel: [ 5656.477270]  [<ffffffffa0226f29>] ?
>vlan_ethtool_get_drvinfo+0x24/0x35 [8021q]
>Jun  8 14:08:01 gateway kernel: [ 5656.477323]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.477357]  [<ffffffff81243c4f>] ?
>dev_hard_start_xmit+0x1b0/0x2b8
>Jun  8 14:08:01 gateway kernel: [ 5656.477391]  [<ffffffff81244135>] ?
>dev_queue_xmit+0x2dd/0x38d
>Jun  8 14:08:01 gateway kernel: [ 5656.477424]  [<ffffffff812ad79c>] ?
>ip6_output+0xd5c/0xd74
>Jun  8 14:08:01 gateway kernel: [ 5656.477459]  [<ffffffff81260076>] ?
>nf_iterate+0x41/0x7d
>Jun  8 14:08:01 gateway kernel: [ 5656.477490]  [<ffffffff812aa0e8>] ?
>dst_output+0x0/0xb
>Jun  8 14:08:01 gateway kernel: [ 5656.477522]  [<ffffffff81260114>] ?
>nf_hook_slow+0x62/0xc3
>Jun  8 14:08:01 gateway kernel: [ 5656.477554]  [<ffffffff812aa0e8>] ?
>dst_output+0x0/0xb
>Jun  8 14:08:01 gateway kernel: [ 5656.477588]  [<ffffffff812ac4f6>] ?
>ip6_xmit+0x3b9/0x4a0
>Jun  8 14:08:01 gateway kernel: [ 5656.477620]  [<ffffffff812cefb1>] ?
>inet6_csk_xmit+0x249/0x274
>Jun  8 14:08:01 gateway kernel: [ 5656.477654]  [<ffffffff8127b4cf>] ?
>tcp_transmit_skb+0x648/0x687
>Jun  8 14:08:01 gateway kernel: [ 5656.477690]  [<ffffffff8127d944>] ?
>tcp_write_xmit+0x874/0x96c
>Jun  8 14:08:01 gateway kernel: [ 5656.477731]  [<ffffffff8123c641>] ?
>__alloc_skb+0x69/0x15a
>Jun  8 14:08:01 gateway kernel: [ 5656.477764]  [<ffffffff8127da89>] ?
>__tcp_push_pending_frames+0x22/0x53
>Jun  8 14:08:01 gateway kernel: [ 5656.477799]  [<ffffffff81272c6b>] ?
>tcp_sendmsg+0x77c/0x878
>Jun  8 14:08:01 gateway kernel: [ 5656.477835]  [<ffffffff812348ac>] ?
>sock_aio_write+0xb1/0xbc
>Jun  8 14:08:01 gateway kernel: [ 5656.477867]  [<ffffffff810ed27a>] ?
>do_sync_write+0xce/0x113
>Jun  8 14:08:01 gateway kernel: [ 5656.477900]  [<ffffffff81064a56>] ?
>autoremove_wake_function+0x0/0x2e
>Jun  8 14:08:01 gateway kernel: [ 5656.477935]  [<ffffffff8104a1a6>] ?
>default_wake_function+0x0/0x9
>Jun  8 14:08:01 gateway kernel: [ 5656.477972]  [<ffffffff810edc05>] ?
>vfs_write+0xbc/0x102
>Jun  8 14:08:01 gateway kernel: [ 5656.478004]  [<ffffffff810edd07>] ?
>sys_write+0x45/0x6e
>Jun  8 14:08:01 gateway kernel: [ 5656.478036]  [<ffffffff81010b42>] ?
>system_call_fastpath+0x16/0x1b
>Jun  8 14:08:01 gateway kernel: [ 5656.478069] ---[ end trace
>d52ed80ad3c42ed9 ]---
>Jun  8 14:08:01 gateway kernel: [ 5656.478101] ------------[ cut here
>]------------
>Jun  8 14:08:01 gateway kernel: [ 5656.478132] WARNING: at
>/build/mattems-linux-2.6_2.6.32-9-amd64-NYTFdD/linux-2.6-2.6.32-9/debian/build/source_amd64_none/net/core/dev.c:1582
>skb_gso_segment+0x109/0x263()
>Jun  8 14:08:01 gateway kernel: [ 5656.478217] Hardware name: ProLiant DL365 G1
>Jun  8 14:08:01 gateway kernel: [ 5656.478245] bonding:
>caps=(0x1913a3, 0x19080b) len=2928 data_len=2856 ip_summed=0
>Jun  8 14:08:01 gateway kernel: [ 5656.478279] Modules linked in: tun
>sch_hfsc ip6_queue act_police cls_flow cls_fw cls_u32 sch_htb
>sch_ingress sch_sfq bridge xt_realm ip6t_LOG iptable_raw xt_connlimit
>ip6table_raw xt_comment ip6t_REJECT xt_recent ipt_ULOG ipt_REJECT
>ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_ecn ipt_CLUSTERIP
>ipt_ah ipt_addrtype nf_nat_tftp nf_nat_snmp_basic nf_nat_sip
>nf_nat_pptp nf_nat_proto_gre ip6table_mangle nf_nat_irc
>nf_conntrack_ipv6 nf_nat_h323 nf_nat_ftp nf_nat_amanda
>nf_conntrack_tftp nf_conntrack_sane nf_conntrack_sip
>nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp
>nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns
>nf_conntrack_irc ts_kmp nf_conntrack_amanda nf_conntrack_h323 xt_time
>xt_TCPMSS nf_conntrack_ftp xt_TPROXY xt_sctp nf_tproxy_core xt_policy
>xt_tcpmss xt_pkttype xt_physdev xt_owner xt_NFLOG xt_NFQUEUE
>nfnetlink_log xt_multiport xt_MARK xt_mark xt_mac xt_limit xt_length
>xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp x
>Jun  8 14:08:01 gateway kernel: t_CONNMARK xt_connmark xt_CLASSIFY
>ipt_LOG xt_tcpudp iptable_nat nf_nat xt_state nf_conntrack_ipv4
>nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_mangle nfnetlink
>iptable_filter ip_tables ip6table_filter ip6_tables x_tables
>rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss
>sunrpc 8021q garp stp bonding loop amd64_edac_mod psmouse edac_core
>snd_pcm i2c_piix4 ipmi_si ipmi_msghandler serio_raw edac_mce_amd
>snd_timer snd soundcore snd_page_alloc i2c_core hpwdt evdev pcspkr
>k8temp container hpilo button shpchp pci_hotplug processor ext4
>mbcache jbd2 crc16 dm_mod ide_cd_mod cdrom ide_pci_generic ata_generic
>libata usbhid hid uhci_hcd ohci_hcd cciss serverworks scsi_mod bnx2
>sky2 ehci_hcd ide_core usbcore e1000e nls_base thermal thermal_sys
>[last unloaded: scsi_wait_scan]
>Jun  8 14:08:01 gateway kernel: [ 5656.479283] Pid: 5545, comm: sshd
>Tainted: G        W  2.6.32-3-amd64 #1
>Jun  8 14:08:01 gateway kernel: [ 5656.479316] Call Trace:
>Jun  8 14:08:01 gateway kernel: [ 5656.479341]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.479375]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.479407]  [<ffffffff8104dbf0>] ?
>warn_slowpath_common+0x77/0xa3
>Jun  8 14:08:01 gateway kernel: [ 5656.479441]  [<ffffffff8104dc78>] ?
>warn_slowpath_fmt+0x51/0x59
>Jun  8 14:08:01 gateway kernel: [ 5656.479475]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.479509]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.479542]  [<ffffffff8104dc0a>] ?
>warn_slowpath_common+0x91/0xa3
>Jun  8 14:08:01 gateway kernel: [ 5656.479575]  [<ffffffff8104dc78>] ?
>warn_slowpath_fmt+0x51/0x59
>Jun  8 14:08:01 gateway kernel: [ 5656.479613]  [<ffffffffa02880ce>] ?
>bond_ethtool_get_drvinfo+0x2e/0x4b [bonding]
>Jun  8 14:08:01 gateway kernel: [ 5656.479665]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.479699]  [<ffffffff81243c4f>] ?
>dev_hard_start_xmit+0x1b0/0x2b8
>Jun  8 14:08:01 gateway kernel: [ 5656.479733]  [<ffffffff81244135>] ?
>dev_queue_xmit+0x2dd/0x38d
>Jun  8 14:08:01 gateway kernel: [ 5656.479770]  [<ffffffffa02271c2>] ?
>vlan_dev_hwaccel_hard_start_xmit+0x63/0x7d [8021q]
>Jun  8 14:08:01 gateway kernel: [ 5656.479824]  [<ffffffff81243cb0>] ?
>dev_hard_start_xmit+0x211/0x2b8
>Jun  8 14:08:01 gateway kernel: [ 5656.479862]  [<ffffffff81244135>] ?
>dev_queue_xmit+0x2dd/0x38d
>Jun  8 14:08:01 gateway kernel: [ 5656.479900]  [<ffffffff812ad79c>] ?
>ip6_output+0xd5c/0xd74
>Jun  8 14:08:01 gateway kernel: [ 5656.479933]  [<ffffffff81260076>] ?
>nf_iterate+0x41/0x7d
>Jun  8 14:08:01 gateway kernel: [ 5656.479964]  [<ffffffff812aa0e8>] ?
>dst_output+0x0/0xb
>Jun  8 14:08:01 gateway kernel: [ 5656.479995]  [<ffffffff81260114>] ?
>nf_hook_slow+0x62/0xc3
>Jun  8 14:08:01 gateway kernel: [ 5656.480031]  [<ffffffff812aa0e8>] ?
>dst_output+0x0/0xb
>Jun  8 14:08:01 gateway kernel: [ 5656.480062]  [<ffffffff812ac4f6>] ?
>ip6_xmit+0x3b9/0x4a0
>Jun  8 14:08:01 gateway kernel: [ 5656.480094]  [<ffffffff812cefb1>] ?
>inet6_csk_xmit+0x249/0x274
>Jun  8 14:08:01 gateway kernel: [ 5656.480127]  [<ffffffff8127b4cf>] ?
>tcp_transmit_skb+0x648/0x687
>Jun  8 14:08:01 gateway kernel: [ 5656.480161]  [<ffffffff8127d944>] ?
>tcp_write_xmit+0x874/0x96c
>Jun  8 14:08:01 gateway kernel: [ 5656.480193]  [<ffffffff8123c641>] ?
>__alloc_skb+0x69/0x15a
>Jun  8 14:08:01 gateway kernel: [ 5656.480226]  [<ffffffff8127da89>] ?
>__tcp_push_pending_frames+0x22/0x53
>Jun  8 14:08:01 gateway kernel: [ 5656.480260]  [<ffffffff81272c6b>] ?
>tcp_sendmsg+0x77c/0x878
>Jun  8 14:08:01 gateway kernel: [ 5656.480293]  [<ffffffff812348ac>] ?
>sock_aio_write+0xb1/0xbc
>Jun  8 14:08:01 gateway kernel: [ 5656.480326]  [<ffffffff810ed27a>] ?
>do_sync_write+0xce/0x113
>Jun  8 14:08:01 gateway kernel: [ 5656.480358]  [<ffffffff81064a56>] ?
>autoremove_wake_function+0x0/0x2e
>Jun  8 14:08:01 gateway kernel: [ 5656.480393]  [<ffffffff8104a1a6>] ?
>default_wake_function+0x0/0x9
>Jun  8 14:08:01 gateway kernel: [ 5656.480426]  [<ffffffff810edc05>] ?
>vfs_write+0xbc/0x102
>Jun  8 14:08:01 gateway kernel: [ 5656.480458]  [<ffffffff810edd07>] ?
>sys_write+0x45/0x6e
>Jun  8 14:08:01 gateway kernel: [ 5656.480490]  [<ffffffff81010b42>] ?
>system_call_fastpath+0x16/0x1b
>Jun  8 14:08:01 gateway kernel: [ 5656.480537] ---[ end trace
>d52ed80ad3c42eda ]---
>Jun  8 14:08:01 gateway kernel: [ 5656.949629] ------------[ cut here
>]------------
>Jun  8 14:08:01 gateway kernel: [ 5656.949665] WARNING: at
>/build/mattems-linux-2.6_2.6.32-9-amd64-NYTFdD/linux-2.6-2.6.32-9/debian/build/source_amd64_none/net/core/dev.c:1582
>skb_gso_segment+0x109/0x263()
>Jun  8 14:08:01 gateway kernel: [ 5656.949750] Hardware name: ProLiant DL365 G1
>Jun  8 14:08:01 gateway kernel: [ 5656.949782] 802.1Q VLAN Support:
>caps=(0x190803, 0x19080b) len=2928 data_len=2856 ip_summed=0
>Jun  8 14:08:01 gateway kernel: [ 5656.949817] Modules linked in: tun
>sch_hfsc ip6_queue act_police cls_flow cls_fw cls_u32 sch_htb
>sch_ingress sch_sfq bridge xt_realm ip6t_LOG iptable_raw xt_connlimit
>ip6table_raw xt_comment ip6t_REJECT xt_recent ipt_ULOG ipt_REJECT
>ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_ecn ipt_CLUSTERIP
>ipt_ah ipt_addrtype nf_nat_tftp nf_nat_snmp_basic nf_nat_sip
>nf_nat_pptp nf_nat_proto_gre ip6table_mangle nf_nat_irc
>nf_conntrack_ipv6 nf_nat_h323 nf_nat_ftp nf_nat_amanda
>nf_conntrack_tftp nf_conntrack_sane nf_conntrack_sip
>nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp
>nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns
>nf_conntrack_irc ts_kmp nf_conntrack_amanda nf_conntrack_h323 xt_time
>xt_TCPMSS nf_conntrack_ftp xt_TPROXY xt_sctp nf_tproxy_core xt_policy
>xt_tcpmss xt_pkttype xt_physdev xt_owner xt_NFLOG xt_NFQUEUE
>nfnetlink_log xt_multiport xt_MARK xt_mark xt_mac xt_limit xt_length
>xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp x
>Jun  8 14:08:01 gateway kernel: t_CONNMARK xt_connmark xt_CLASSIFY
>ipt_LOG xt_tcpudp iptable_nat nf_nat xt_state nf_conntrack_ipv4
>nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_mangle nfnetlink
>iptable_filter ip_tables ip6table_filter ip6_tables x_tables
>rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss
>sunrpc 8021q garp stp bonding loop amd64_edac_mod psmouse edac_core
>snd_pcm i2c_piix4 ipmi_si ipmi_msghandler serio_raw edac_mce_amd
>snd_timer snd soundcore snd_page_alloc i2c_core hpwdt evdev pcspkr
>k8temp container hpilo button shpchp pci_hotplug processor ext4
>mbcache jbd2 crc16 dm_mod ide_cd_mod cdrom ide_pci_generic ata_generic
>libata usbhid hid uhci_hcd ohci_hcd cciss serverworks scsi_mod bnx2
>sky2 ehci_hcd ide_core usbcore e1000e nls_base thermal thermal_sys
>[last unloaded: scsi_wait_scan]
>Jun  8 14:08:01 gateway kernel: [ 5656.950828] Pid: 5545, comm: sshd
>Tainted: G        W  2.6.32-3-amd64 #1
>Jun  8 14:08:01 gateway kernel: [ 5656.950862] Call Trace:
>Jun  8 14:08:01 gateway kernel: [ 5656.950888]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.950921]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.950954]  [<ffffffff8104dbf0>] ?
>warn_slowpath_common+0x77/0xa3
>Jun  8 14:08:01 gateway kernel: [ 5656.950988]  [<ffffffff8104dc78>] ?
>warn_slowpath_fmt+0x51/0x59
>Jun  8 14:08:01 gateway kernel: [ 5656.951026]  [<ffffffffa03b5e6d>] ?
>ip6t_do_table+0x65f/0x69a [ip6_tables]
>Jun  8 14:08:01 gateway kernel: [ 5656.951065]  [<ffffffffa0226f29>] ?
>vlan_ethtool_get_drvinfo+0x24/0x35 [8021q]
>Jun  8 14:08:01 gateway kernel: [ 5656.951118]  [<ffffffff81243945>] ?
>skb_gso_segment+0x109/0x263
>Jun  8 14:08:01 gateway kernel: [ 5656.951151]  [<ffffffff81243c4f>] ?
>dev_hard_start_xmit+0x1b0/0x2b8
>Jun  8 14:08:01 gateway kernel: [ 5656.951187]  [<ffffffff81244135>] ?
>dev_queue_xmit+0x2dd/0x38d
>Jun  8 14:08:01 gateway kernel: [ 5656.951223]  [<ffffffff812ad79c>] ?
>ip6_output+0xd5c/0xd74
>Jun  8 14:08:01 gateway kernel: [ 5656.951256]  [<ffffffff81260076>] ?
>nf_iterate+0x41/0x7d
>Jun  8 14:08:01 gateway kernel: [ 5656.951288]  [<ffffffff812aa0e8>] ?
>dst_output+0x0/0xb
>Jun  8 14:08:01 gateway kernel: [ 5656.951319]  [<ffffffff81260114>] ?
>nf_hook_slow+0x62/0xc3
>Jun  8 14:08:01 gateway kernel: [ 5656.951350]  [<ffffffff812aa0e8>] ?
>dst_output+0x0/0xb
>Jun  8 14:08:01 gateway kernel: [ 5656.951381]  [<ffffffff812ac4f6>] ?
>ip6_xmit+0x3b9/0x4a0
>Jun  8 14:08:01 gateway kernel: [ 5656.951413]  [<ffffffff812cefb1>] ?
>inet6_csk_xmit+0x249/0x274
>Jun  8 14:08:01 gateway kernel: [ 5656.951446]  [<ffffffff8127b4cf>] ?
>tcp_transmit_skb+0x648/0x687
>Jun  8 14:08:01 gateway kernel: [ 5656.951480]  [<ffffffff8127d944>] ?
>tcp_write_xmit+0x874/0x96c
>Jun  8 14:08:01 gateway kernel: [ 5656.951512]  [<ffffffff8123c641>] ?
>__alloc_skb+0x69/0x15a
>Jun  8 14:08:01 gateway kernel: [ 5656.957763]  [<ffffffff8127da89>] ?
>__tcp_push_pending_frames+0x22/0x53
>Jun  8 14:08:01 gateway kernel: [ 5656.957805]  [<ffffffff81272c6b>] ?
>tcp_sendmsg+0x77c/0x878
>Jun  8 14:08:01 gateway kernel: [ 5656.957840]  [<ffffffff812348ac>] ?
>sock_aio_write+0xb1/0xbc
>Jun  8 14:08:01 gateway kernel: [ 5656.957877]  [<ffffffff811f44c8>] ?
>n_tty_read+0x692/0x774
>Jun  8 14:08:01 gateway kernel: [ 5656.957913]  [<ffffffff810ed27a>] ?
>do_sync_write+0xce/0x113
>Jun  8 14:08:01 gateway kernel: [ 5656.957946]  [<ffffffff81064a56>] ?
>autoremove_wake_function+0x0/0x2e
>Jun  8 14:08:01 gateway kernel: [ 5656.957984]  [<ffffffff8104a1a6>] ?
>default_wake_function+0x0/0x9
>Jun  8 14:08:01 gateway kernel: [ 5656.958021]  [<ffffffff810edc05>] ?
>vfs_write+0xbc/0x102
>Jun  8 14:08:01 gateway kernel: [ 5656.958056]  [<ffffffff810edd07>] ?
>sys_write+0x45/0x6e
>Jun  8 14:08:01 gateway kernel: [ 5656.958092]  [<ffffffff81010b42>] ?
>system_call_fastpath+0x16/0x1b
>Jun  8 14:08:01 gateway kernel: [ 5656.958129] ---[ end trace
>d52ed80ad3c42edb ]---
>
>===== end call traces =====
>
>===== lspci -v =====
>
>00:03.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev
>02) (prog-if 00 [VGA controller])
>	Subsystem: Hewlett-Packard Company Device 31fb
>	Flags: bus master, stepping, medium devsel, latency 64, IRQ 10
>	Memory at e8000000 (32-bit, prefetchable) [size=128M]
>	I/O ports at 1000 [size=256]
>	Memory at f7ff0000 (32-bit, non-prefetchable) [size=64K]
>	[virtual] Expansion ROM at e0000000 [disabled] [size=128K]
>	Capabilities: [50] Power Management version 2
>
>00:04.0 System peripheral: Compaq Computer Corporation Integrated
>Lights Out Controller (rev 03)
>	Subsystem: Hewlett-Packard Company Device 3305
>	Flags: medium devsel, IRQ 25
>	I/O ports at 2800 [size=256]
>	Memory at f7fe0000 (32-bit, non-prefetchable) [size=512]
>	Capabilities: [f0] Power Management version 3
>	Kernel driver in use: hpwdt
>
>00:04.2 System peripheral: Compaq Computer Corporation Integrated
>Lights Out  Processor (rev 03)
>	Subsystem: Hewlett-Packard Company Device 3305
>	Flags: bus master, medium devsel, latency 64, IRQ 26
>	I/O ports at 1400 [size=256]
>	Memory at f7fd0000 (32-bit, non-prefetchable) [size=2K]
>	Memory at f7fc0000 (32-bit, non-prefetchable) [size=8K]
>	Memory at f7f00000 (32-bit, non-prefetchable) [size=512K]
>	[virtual] Expansion ROM at e0020000 [disabled] [size=64K]
>	Capabilities: [f0] Power Management version 3
>	Kernel driver in use: hpilo
>
>00:04.4 USB Controller: Hewlett-Packard Company Proliant iLO2/iLO3
>virtual USB controller (prog-if 00 [UHCI])
>	Subsystem: Hewlett-Packard Company Device 3305
>	Flags: bus master, medium devsel, latency 64, IRQ 26
>	I/O ports at 1800 [size=32]
>	Capabilities: [f0] Power Management version 3
>	Kernel driver in use: uhci_hcd
>
>00:04.6 IPMI SMIC interface: Hewlett-Packard Company Proliant iLO2
>virtual UART (prog-if 01)
>	Subsystem: Hewlett-Packard Company Device 3305
>	Flags: medium devsel, IRQ 25
>	Memory at f7ef0000 (32-bit, non-prefetchable) [size=256]
>	Capabilities: [f0] Power Management version 3
>	Kernel driver in use: ipmi_si
>
>00:05.0 PCI bridge: Broadcom BCM5785 [HT1000] PCI/PCI-X Bridge
>(prog-if 00 [Normal decode])
>	Flags: bus master, fast devsel, latency 64
>	Bus: primary=00, secondary=01, subordinate=04, sec-latency=64
>	Capabilities: [90] PCI-X bridge device
>	Capabilities: [a0] HyperTransport: MSI Mapping Enable+ Fixed-
>	Capabilities: [b0] HyperTransport: Slave or Primary Interface
>	Capabilities: [d8] Subsystem: Gammagraphx, Inc. (or missing ID) Device 0000
>
>00:06.0 Host bridge: Broadcom BCM5785 [HT1000] Legacy South Bridge
>	Subsystem: Broadcom Device 0201
>	Flags: bus master, medium devsel, latency 64
>	Kernel driver in use: piix4_smbus
>
>00:06.1 IDE interface: Broadcom BCM5785 [HT1000] IDE (prog-if 8a
>[Master SecP PriP])
>	Subsystem: Hewlett-Packard Company Device 320b
>	Flags: bus master, medium devsel, latency 64
>	I/O ports at 01f0 [size=8]
>	I/O ports at 03f4 [size=1]
>	I/O ports at 0170 [size=8]
>	I/O ports at 0374 [size=1]
>	I/O ports at 1840 [size=16]
>	Capabilities: [b0] #00 [0002]
>	Kernel driver in use: Serverworks_IDE
>
>00:06.2 ISA bridge: Broadcom BCM5785 [HT1000] LPC
>	Subsystem: Broadcom Device 0230
>	Flags: bus master, medium devsel, latency 0
>
>00:07.0 USB Controller: Broadcom BCM5785 [HT1000] USB (rev 01)
>(prog-if 10 [OHCI])
>	Subsystem: Hewlett-Packard Company Device 320c
>	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 5
>	Memory at f7ee0000 (32-bit, non-prefetchable) [size=4K]
>	I/O ports at 1c00 [size=256]
>	Capabilities: [dc] Power Management version 2
>	Kernel driver in use: ohci_hcd
>
>00:07.1 USB Controller: Broadcom BCM5785 [HT1000] USB (rev 01)
>(prog-if 10 [OHCI])
>	Subsystem: Hewlett-Packard Company Device 320c
>	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 5
>	Memory at f7ed0000 (32-bit, non-prefetchable) [size=4K]
>	I/O ports at 3000 [size=256]
>	Capabilities: [dc] Power Management version 2
>	Kernel driver in use: ohci_hcd
>
>00:07.2 USB Controller: Broadcom BCM5785 [HT1000] USB (rev 01)
>(prog-if 20 [EHCI])
>	Subsystem: Hewlett-Packard Company Device 320d
>	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 5
>	Memory at f7ec0000 (32-bit, non-prefetchable) [size=4K]
>	I/O ports at 3400 [size=256]
>	Capabilities: [dc] Power Management version 2
>	Kernel driver in use: ehci_hcd
>
>00:18.0 Host bridge: Advanced Micro Devices [AMD] K8
>[Athlon64/Opteron] HyperTransport Technology Configuration
>	Flags: fast devsel
>	Capabilities: [80] HyperTransport: Host or Secondary Interface
>	Capabilities: [a0] HyperTransport: Host or Secondary Interface
>	Capabilities: [c0] HyperTransport: Host or Secondary Interface
>
>00:18.1 Host bridge: Advanced Micro Devices [AMD] K8
>[Athlon64/Opteron] Address Map
>	Flags: fast devsel
>
>00:18.2 Host bridge: Advanced Micro Devices [AMD] K8
>[Athlon64/Opteron] DRAM Controller
>	Flags: fast devsel
>	Kernel driver in use: amd64_edac
>
>00:18.3 Host bridge: Advanced Micro Devices [AMD] K8
>[Athlon64/Opteron] Miscellaneous Control
>	Flags: fast devsel
>	Capabilities: [f0] Secure device <?>
>	Kernel driver in use: k8temp
>
>00:19.0 Host bridge: Advanced Micro Devices [AMD] K8
>[Athlon64/Opteron] HyperTransport Technology Configuration
>	Flags: fast devsel
>	Capabilities: [80] HyperTransport: Host or Secondary Interface
>	Capabilities: [a0] HyperTransport: Host or Secondary Interface
>	Capabilities: [c0] HyperTransport: Host or Secondary Interface
>
>00:19.1 Host bridge: Advanced Micro Devices [AMD] K8
>[Athlon64/Opteron] Address Map
>	Flags: fast devsel
>
>00:19.2 Host bridge: Advanced Micro Devices [AMD] K8
>[Athlon64/Opteron] DRAM Controller
>	Flags: fast devsel
>	Kernel driver in use: amd64_edac
>
>00:19.3 Host bridge: Advanced Micro Devices [AMD] K8
>[Athlon64/Opteron] Miscellaneous Control
>	Flags: fast devsel
>	Capabilities: [f0] Secure device <?>
>	Kernel driver in use: k8temp
>
>01:0d.0 PCI bridge: Broadcom BCM5785 [HT1000] PCI/PCI-X Bridge (rev
>c0) (prog-if 00 [Normal decode])
>	Flags: bus master, 66MHz, medium devsel, latency 64
>	Bus: primary=01, secondary=02, subordinate=04, sec-latency=64
>	Capabilities: [90] PCI-X bridge device
>	Capabilities: [88] Subsystem: Device 814f:0000
>
>08:0f.0 PCI bridge: Broadcom HT2100 PCI-Express Bridge (rev a2)
>(prog-if 00 [Normal decode])
>	Flags: bus master, fast devsel, latency 0
>	Bus: primary=08, secondary=13, subordinate=16, sec-latency=0
>	I/O behind bridge: 00006000-00007fff
>	Memory behind bridge: fde00000-fdffffff
>	Prefetchable memory behind bridge: 00000000fc000000-00000000fc1fffff
>	Capabilities: [a0] HyperTransport: MSI Mapping Enable+ Fixed-
>	Capabilities: [b0] Express Root Port (Slot-), MSI 00
>	Capabilities: [98] Power Management version 3
>	Capabilities: [80] MSI: Enable+ Count=1/2 Maskable- 64bit+
>	Capabilities: [78] Subsystem: Gammagraphx, Inc. (or missing ID) Device 0000
>	Capabilities: [50] HyperTransport: Slave or Primary Interface
>	Capabilities: [100] Advanced Error Reporting
>	Capabilities: [200] Vendor Specific Information: ID=0001 Rev=1 Len=100 <?>
>	Kernel driver in use: pcieport
>
>08:10.0 PCI bridge: Broadcom HT2100 PCI-Express Bridge (rev a2)
>(prog-if 00 [Normal decode])
>	Flags: bus master, fast devsel, latency 0
>	Bus: primary=08, secondary=10, subordinate=12, sec-latency=0
>	I/O behind bridge: 00005000-00005fff
>	Memory behind bridge: fdd00000-fddfffff
>	Prefetchable memory behind bridge: 00000000fc200000-00000000fc2fffff
>	Capabilities: [a0] HyperTransport: MSI Mapping Enable+ Fixed-
>	Capabilities: [b0] Express Root Port (Slot-), MSI 00
>	Capabilities: [98] Power Management version 3
>	Capabilities: [80] MSI: Enable+ Count=1/2 Maskable- 64bit+
>	Capabilities: [78] Subsystem: Gammagraphx, Inc. (or missing ID) Device 0000
>	Capabilities: [100] Advanced Error Reporting
>	Capabilities: [200] Vendor Specific Information: ID=0001 Rev=1 Len=100 <?>
>	Kernel driver in use: pcieport
>
>08:11.0 PCI bridge: Broadcom HT2100 PCI-Express Bridge (rev a2)
>(prog-if 00 [Normal decode])
>	Flags: bus master, fast devsel, latency 0
>	Bus: primary=08, secondary=09, subordinate=0a, sec-latency=0
>	Memory behind bridge: f8000000-f9ffffff
>	Prefetchable memory behind bridge: 00000000fc300000-00000000fc3fffff
>	Capabilities: [a0] HyperTransport: MSI Mapping Enable+ Fixed-
>	Capabilities: [b0] Express Root Port (Slot-), MSI 00
>	Capabilities: [98] Power Management version 3
>	Capabilities: [80] MSI: Enable+ Count=1/2 Maskable- 64bit+
>	Capabilities: [78] Subsystem: Gammagraphx, Inc. (or missing ID) Device 0000
>	Capabilities: [100] Advanced Error Reporting
>	Capabilities: [200] Vendor Specific Information: ID=0001 Rev=1 Len=100 <?>
>	Kernel driver in use: pcieport
>
>08:12.0 PCI bridge: Broadcom HT2100 PCI-Express Bridge (rev a2)
>(prog-if 00 [Normal decode])
>	Flags: bus master, fast devsel, latency 0
>	Bus: primary=08, secondary=0b, subordinate=0c, sec-latency=0
>	Memory behind bridge: fa000000-fbffffff
>	Prefetchable memory behind bridge: 00000000fc400000-00000000fc4fffff
>	Capabilities: [a0] HyperTransport: MSI Mapping Enable+ Fixed-
>	Capabilities: [b0] Express Root Port (Slot-), MSI 00
>	Capabilities: [98] Power Management version 3
>	Capabilities: [80] MSI: Enable+ Count=1/2 Maskable- 64bit+
>	Capabilities: [78] Subsystem: Gammagraphx, Inc. (or missing ID) Device 0000
>	Capabilities: [100] Advanced Error Reporting
>	Capabilities: [200] Vendor Specific Information: ID=0001 Rev=1 Len=100 <?>
>	Kernel driver in use: pcieport
>
>08:13.0 PCI bridge: Broadcom HT2100 PCI-Express Bridge (rev a2)
>(prog-if 00 [Normal decode])
>	Flags: bus master, fast devsel, latency 0
>	Bus: primary=08, secondary=0d, subordinate=0f, sec-latency=0
>	I/O behind bridge: 00004000-00004fff
>	Memory behind bridge: fdb00000-fdcfffff
>	Prefetchable memory behind bridge: 00000000fc500000-00000000fc5fffff
>	Capabilities: [a0] HyperTransport: MSI Mapping Enable+ Fixed-
>	Capabilities: [b0] Express Root Port (Slot-), MSI 00
>	Capabilities: [98] Power Management version 3
>	Capabilities: [80] MSI: Enable+ Count=1/2 Maskable- 64bit+
>	Capabilities: [78] Subsystem: Gammagraphx, Inc. (or missing ID) Device 0000
>	Capabilities: [100] Advanced Error Reporting
>	Capabilities: [200] Vendor Specific Information: ID=0001 Rev=1 Len=100 <?>
>	Kernel driver in use: pcieport
>
>09:00.0 PCI bridge: Broadcom EPB PCI-Express to PCI-X Bridge (rev c2)
>(prog-if 00 [Normal decode])
>	Flags: bus master, fast devsel, latency 0
>	Bus: primary=09, secondary=0a, subordinate=0a, sec-latency=64
>	Memory behind bridge: f8000000-f9ffffff
>	Prefetchable memory behind bridge: 00000000fc300000-00000000fc3fffff
>	Capabilities: [60] Express PCI/PCI-X Bridge, MSI 00
>	Capabilities: [90] PCI-X bridge device
>	Capabilities: [b0] Power Management version 2
>	Capabilities: [100] Advanced Error Reporting
>	Capabilities: [14c] Power Budgeting <?>
>	Capabilities: [160] Device Serial Number 00-18-fe-ff-fe-34-d9-22
>
>0a:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708
>Gigabit Ethernet (rev 11)
>	Subsystem: Hewlett-Packard Company NC373i Integrated Multifunction
>Gigabit Server Adapter
>	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 48
>	Memory at f8000000 (64-bit, non-prefetchable) [size=32M]
>	[virtual] Expansion ROM at fc300000 [disabled] [size=2K]
>	Capabilities: [40] PCI-X non-bridge device
>	Capabilities: [48] Power Management version 2
>	Capabilities: [50] Vital Product Data
>	Capabilities: [58] MSI: Enable+ Count=1/1 Maskable- 64bit+
>	Kernel driver in use: bnx2
>
>0b:00.0 PCI bridge: Broadcom EPB PCI-Express to PCI-X Bridge (rev c2)
>(prog-if 00 [Normal decode])
>	Flags: bus master, fast devsel, latency 0
>	Bus: primary=0b, secondary=0c, subordinate=0c, sec-latency=64
>	Memory behind bridge: fa000000-fbffffff
>	Prefetchable memory behind bridge: 00000000fc400000-00000000fc4fffff
>	Capabilities: [60] Express PCI/PCI-X Bridge, MSI 00
>	Capabilities: [90] PCI-X bridge device
>	Capabilities: [b0] Power Management version 2
>	Capabilities: [100] Advanced Error Reporting
>	Capabilities: [14c] Power Budgeting <?>
>	Capabilities: [160] Device Serial Number 00-18-fe-ff-fe-34-d9-26
>
>0c:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708
>Gigabit Ethernet (rev 11)
>	Subsystem: Hewlett-Packard Company NC373i Integrated Multifunction
>Gigabit Server Adapter
>	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 49
>	Memory at fa000000 (64-bit, non-prefetchable) [size=32M]
>	[virtual] Expansion ROM at fc400000 [disabled] [size=2K]
>	Capabilities: [40] PCI-X non-bridge device
>	Capabilities: [48] Power Management version 2
>	Capabilities: [50] Vital Product Data
>	Capabilities: [58] MSI: Enable+ Count=1/1 Maskable- 64bit+
>	Kernel driver in use: bnx2
>
>0d:00.0 RAID bus controller: Hewlett-Packard Company Smart Array
>Controller (rev 01)
>	Subsystem: Hewlett-Packard Company P400i SAS Controller
>	Flags: bus master, fast devsel, latency 0, IRQ 17
>	Memory at fdc00000 (64-bit, non-prefetchable) [size=1M]
>	I/O ports at 4000 [size=256]
>	Memory at fdbf0000 (64-bit, non-prefetchable) [size=4K]
>	[virtual] Expansion ROM at fc500000 [disabled] [size=256K]
>	Capabilities: [b0] Express Endpoint, MSI 00
>	Capabilities: [d4] MSI-X: Enable+ Count=4 Masked-
>	Capabilities: [e0] Power Management version 2
>	Capabilities: [ec] Vital Product Data
>	Capabilities: [100] Power Budgeting <?>
>	Kernel driver in use: cciss
>
>10:00.0 Ethernet controller: SysKonnect SK-9E21D 10/100/1000Base-T
>Adapter, Copper RJ-45 (rev 14)
>	Subsystem: SysKonnect SK-9E22 Server Adapter
>	Flags: bus master, fast devsel, latency 0, IRQ 40
>	Memory at fddf0000 (64-bit, non-prefetchable) [size=16K]
>	I/O ports at 5000 [size=256]
>	[virtual] Expansion ROM at fc200000 [disabled] [size=128K]
>	Capabilities: [48] Power Management version 2
>	Capabilities: [50] Vital Product Data
>	Capabilities: [5c] MSI: Enable+ Count=1/2 Maskable- 64bit+
>	Capabilities: [e0] Express Legacy Endpoint, MSI 00
>	Capabilities: [100] Advanced Error Reporting
>	Kernel driver in use: sky2
>
>13:00.0 PCI bridge: Integrated Device Technology, Inc. PES12N3A PCI
>Express Switch (rev 04) (prog-if 00 [Normal decode])
>	Flags: bus master, fast devsel, latency 0
>	Bus: primary=13, secondary=14, subordinate=16, sec-latency=0
>	I/O behind bridge: 00006000-00007fff
>	Memory behind bridge: fde00000-fdffffff
>	Prefetchable memory behind bridge: 00000000fc000000-00000000fc1fffff
>	Capabilities: [40] Express Upstream Port, MSI 00
>	Capabilities: [70] Power Management version 2
>	Capabilities: [100] Virtual Channel
>	Kernel driver in use: pcieport
>
>14:00.0 PCI bridge: Integrated Device Technology, Inc. PES12N3A PCI
>Express Switch (rev 04) (prog-if 00 [Normal decode])
>	Flags: bus master, fast devsel, latency 0
>	Bus: primary=14, secondary=15, subordinate=15, sec-latency=0
>	I/O behind bridge: 00006000-00006fff
>	Memory behind bridge: fde00000-fdefffff
>	Prefetchable memory behind bridge: 00000000fc000000-00000000fc0fffff
>	Capabilities: [40] Express Downstream Port (Slot-), MSI 00
>	Capabilities: [70] Power Management version 2
>	Capabilities: [7c] MSI: Enable+ Count=1/1 Maskable- 64bit+
>	Capabilities: [100] Virtual Channel
>	Kernel driver in use: pcieport
>
>14:01.0 PCI bridge: Integrated Device Technology, Inc. PES12N3A PCI
>Express Switch (rev 04) (prog-if 00 [Normal decode])
>	Flags: bus master, fast devsel, latency 0
>	Bus: primary=14, secondary=16, subordinate=16, sec-latency=0
>	I/O behind bridge: 00007000-00007fff
>	Memory behind bridge: fdf00000-fdffffff
>	Prefetchable memory behind bridge: 00000000fc100000-00000000fc1fffff
>	Capabilities: [40] Express Downstream Port (Slot-), MSI 00
>	Capabilities: [70] Power Management version 2
>	Capabilities: [7c] MSI: Enable+ Count=1/1 Maskable- 64bit+
>	Capabilities: [100] Virtual Channel
>	Kernel driver in use: pcieport
>
>15:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit
>Ethernet Controller (rev 06)
>	Subsystem: Intel Corporation PRO/1000 PT Quad Port Server Adapter
>	Flags: bus master, fast devsel, latency 0, IRQ 39
>	Memory at fdee0000 (32-bit, non-prefetchable) [size=128K]
>	Memory at fdec0000 (32-bit, non-prefetchable) [size=128K]
>	I/O ports at 6000 [size=32]
>	[virtual] Expansion ROM at fc000000 [disabled] [size=128K]
>	Capabilities: [c8] Power Management version 2
>	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
>	Capabilities: [e0] Express Endpoint, MSI 00
>	Capabilities: [100] Advanced Error Reporting
>	Capabilities: [140] Device Serial Number 00-15-17-ff-ff-92-1e-fc
>	Kernel driver in use: e1000e
>
>15:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit
>Ethernet Controller (rev 06)
>	Subsystem: Intel Corporation PRO/1000 PT Quad Port Server Adapter
>	Flags: bus master, fast devsel, latency 0, IRQ 45
>	Memory at fdea0000 (32-bit, non-prefetchable) [size=128K]
>	Memory at fde80000 (32-bit, non-prefetchable) [size=128K]
>	I/O ports at 6020 [size=32]
>	[virtual] Expansion ROM at fc020000 [disabled] [size=128K]
>	Capabilities: [c8] Power Management version 2
>	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
>	Capabilities: [e0] Express Endpoint, MSI 00
>	Capabilities: [100] Advanced Error Reporting
>	Capabilities: [140] Device Serial Number 00-15-17-ff-ff-92-1e-fc
>	Kernel driver in use: e1000e
>
>16:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit
>Ethernet Controller (rev 06)
>	Subsystem: Intel Corporation PRO/1000 PT Quad Port Server Adapter
>	Flags: bus master, fast devsel, latency 0, IRQ 46
>	Memory at fdfe0000 (32-bit, non-prefetchable) [size=128K]
>	Memory at fdfc0000 (32-bit, non-prefetchable) [size=128K]
>	I/O ports at 7000 [size=32]
>	[virtual] Expansion ROM at fc100000 [disabled] [size=128K]
>	Capabilities: [c8] Power Management version 2
>	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
>	Capabilities: [e0] Express Endpoint, MSI 00
>	Capabilities: [100] Advanced Error Reporting
>	Capabilities: [140] Device Serial Number 00-15-17-ff-ff-92-1e-fe
>	Kernel driver in use: e1000e
>
>16:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit
>Ethernet Controller (rev 06)
>	Subsystem: Intel Corporation PRO/1000 PT Quad Port Server Adapter
>	Flags: bus master, fast devsel, latency 0, IRQ 47
>	Memory at fdfa0000 (32-bit, non-prefetchable) [size=128K]
>	Memory at fdf80000 (32-bit, non-prefetchable) [size=128K]
>	I/O ports at 7020 [size=32]
>	[virtual] Expansion ROM at fc120000 [disabled] [size=128K]
>	Capabilities: [c8] Power Management version 2
>	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
>	Capabilities: [e0] Express Endpoint, MSI 00
>	Capabilities: [100] Advanced Error Reporting
>	Capabilities: [140] Device Serial Number 00-15-17-ff-ff-92-1e-fe
>	Kernel driver in use: e1000e
>
>===== end lspci =====

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

