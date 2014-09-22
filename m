From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 84961] New: Kernel crash at __xfrm_state_lookup
Date: Mon, 22 Sep 2014 09:03:09 -0700
Message-ID: <20140922090309.63538960@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:39653 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671AbaIVQDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 12:03:17 -0400
Received: by mail-pd0-f171.google.com with SMTP id y13so4634795pdi.16
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 09:03:17 -0700 (PDT)
Received: from urahara (static-50-53-65-80.bvtn.or.frontiernet.net. [50.53.65.80])
        by mx.google.com with ESMTPSA id t16sm9756365pdl.32.2014.09.22.09.03.15
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 09:03:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 21 Sep 2014 12:13:05 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 84961] New: Kernel crash at __xfrm_state_lookup


https://bugzilla.kernel.org/show_bug.cgi?id=84961

            Bug ID: 84961
           Summary: Kernel crash at __xfrm_state_lookup
           Product: Networking
           Version: 2.5
    Kernel Version: 3.14.13
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: jiri.horky@gmail.com
        Regression: No

Hi,

we have a rather specific setup of 102hosts (cluster1) having p2p IPsec tunnels
to 102 hosts to cluster2, so each host from cluster1 is connected to each host
in cluster2. We use strongswan-5.2.0-2 with configuration as follows:

# cat /etc/strongswan/ipsec.conf
config setup
        uniqueids=no

conn %default
        ikelifetime=180m
        keylife=90m
        rekeymargin=5m
        keyingtries=%forever
        keyexchange=ikev2
        mobike=no
        reauth=no
        dpdaction=restart
        closeaction=restart

include /etc/strongswan/ipsec.d/*.conf

One of the connection file looks like this:
conn tch017
        left=5.45.X.Y
        right=5.45.Z.W
        authby=secret
        type=transport
        auto=route

On each of the hosts, we run periodical ping to all hosts on the other
side of the tunnels so we keep the tunnels up.

e experience relatively frequent kernel crash (~2 a day out of 102
nodes). I enclose a stack trace:

[17243.492008] general protection fault: 0000 [#1] SMP
[17243.492038] Modules linked in: nfsv3 nfs_acl ipmi_si vfat fat
usb_storage mpt3sas mpt2sas scsi_transport_sas raid_class mptctl mptbase
ipmi_devintf dell_rbu authenc xfrm4_mode_transport cbc xfrm4_tunnel
tunnel4 ipcomp xfrm_ipcomp esp4 ah4 af_key rpcsec_gss_krb5 auth_rpcgss
nfsv4 nfs fscache lockd sunrpc cls_u32 sch_prio 8021q garp stp llc
bonding xt_comment iptable_filter iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 nf_nat xt_DSCP iptable_mangle xt_CT xt_set
iptable_raw ip_tables ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6
xt_state nf_conntrack ip6table_filter ip6_tables ipv6 ip_set_hash_net
ip_set nfnetlink fuse dm_mirror dm_region_hash dm_log dm_mod gpio_ich
iTCO_wdt iTCO_vendor_support dcdbas microcode pcspkr sb_edac edac_core
mgag200 ttm drm_kms_helper sysimgblt sysfillrect syscopyarea
[17243.492370]  ipmi_msghandler acpi_pad lpc_ich shpchp joydev sg tg3
ptp pps_core wmi acpi_power_meter hwmon ext4 jbd2 mbcache sd_mod
crc_t10dif crct10dif_common megaraid_sas [last unloaded: ipmi_si]
[17243.492449] CPU: 12 PID: 16085 Comm: charon Not tainted
3.14.13.ffdebug2 #8
[17243.492473] Hardware name: Dell Inc. PowerEdge R720xd/0X3D66, BIOS
2.2.2 01/16/2014
[17243.492499] task: ffff883fe0948e30 ti: ffff883fdd728000 task.ti:
ffff883fdd728000
[17243.492525] RIP: 0010:[<ffffffff81601b18>]  [<ffffffff81601b18>]
__xfrm_state_lookup+0x78/0x100
[17243.492559] RSP: 0018:ffff883fdd7299f0  EFLAGS: 00010202
[17243.492577] RAX: 0060000000000804 RBX: 000000000000012e RCX:
0000000017cd52c6
[17243.492605] RDX: ffff880063f05810 RSI: 0000000000000000 RDI:
ffff880a2552c028
[17243.492629] RBP: ffff883fdd7299f8 R08: 0000000000000032 R09:
0000000000000002
[17243.492654] R10: ffff880a2552c000 R11: 000000000007ffff R12:
ffffffff81d0ef40
[17243.492678] R13: 0000000000000000 R14: ffff880063f05810 R15:
0000000017cd52c6
[17243.492702] FS:  00007f4e61c89700(0000) GS:ffff88207fac0000(0000)
knlGS:0000000000000000
[17243.492729] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[17243.492748] CR2: ffffffffff600400 CR3: 0000003fdf1c8000 CR4:
00000000001407e0
[17243.492772] Stack:
[17243.492780]  ffffffff81d0ff80 ffff883fdd729a48 ffffffff81601c06
ffff880900000002
[17243.492812]  ffff883fdd729a32 ffff883f87759bc0 ffff883fdd729a94
ffff881e520368c0
[17243.492842]  ffffffff81d0ef40 ffff880063f05800 ffff883fdd729c60
ffff883fdd729a78
[17243.492872] Call Trace:
[17243.492885]  [<ffffffff81601c06>] xfrm_state_lookup+0x66/0x90
[17243.492907]  [<ffffffff8160796e>] xfrm_user_state_lookup+0x6e/0xe0
[17243.492930]  [<ffffffff81255078>] ? security_capable+0x18/0x20
[17243.492952]  [<ffffffff81608912>] xfrm_get_sa+0x42/0xc0
[17243.492971]  [<ffffffff816078db>] xfrm_user_rcv_msg+0x12b/0x150
[17243.493919]  [<ffffffff816077b0>] ? attach_auth+0xf0/0xf0
[17243.495228]  [<ffffffff815979ec>] netlink_rcv_skb+0x6c/0xd0
[17243.496520]  [<ffffffff81606e6f>] xfrm_netlink_rcv+0x3f/0x60
[17243.497813]  [<ffffffff8159779f>] netlink_unicast+0x12f/0x1e0
[17243.499162]  [<ffffffff815989b8>] netlink_sendmsg+0x348/0x3a0
[17243.500436]  [<ffffffff81551670>] sock_sendmsg+0x90/0xc0
[17243.501685]  [<ffffffff810def29>] ? futex_wait+0x1b9/0x290
[17243.502945]  [<ffffffff8154ee49>] ? copy_from_user+0x9/0x10
[17243.504203]  [<ffffffff815517a4>] SYSC_sendto+0x104/0x140
[17243.505466]  [<ffffffff811bdc73>] ? __sb_end_write+0x33/0x70
[17243.506713]  [<ffffffff815517ee>] SyS_sendto+0xe/0x10
[17243.507951]  [<ffffffff8163c8e9>] system_call_fastpath+0x16/0x1b
[17243.509368] Code: 14 41 31 da 41 31 c2 48 8b 87 20 0d 00 00 45 21 da
4a 8b 3c d0 31 c0 4c 8d 57 d8 48 85 ff 49 0f 45 c2 eb 74 0f 1f 80 00 00
00 00 <66> 44 39 88 c2 00 00 00 75 56 39 48 50 75 51 44 38 40 54 75 4b
[17243.512127] RIP  [<ffffffff81601b18>] __xfrm_state_lookup+0x78/0x100
[17243.513445]  RSP <ffff883fdd7299f0>


The objdump of the function:


00000000000030f0 <__xfrm_state_lookup>:
__xfrm_state_lookup():
.....
    3144:       48 8b 87 20 0d 00 00    mov    0xd20(%rdi),%rax
    314b:       45 21 da                and    %r11d,%r10d
    314e:       4a 8b 3c d0             mov    (%rax,%r10,8),%rdi
    3152:       31 c0                   xor    %eax,%eax
    3154:       4c 8d 57 d8             lea    -0x28(%rdi),%r10
    3158:       48 85 ff                test   %rdi,%rdi
    315b:       49 0f 45 c2             cmovne %r10,%rax
    315f:       eb 74                   jmp    31d5
<__xfrm_state_lookup+0xe5>
    3161:       0f 1f 80 00 00 00 00    nopl   0x0(%rax)
/root/zach/kernel/linux-3.14.13/net/xfrm/xfrm_state.c:676
    3168:       66 44 39 88 c2 00 00    cmp    %r9w,0xc2(%rax)
    316f:       00
    3170:       75 56                   jne    31c8
<__xfrm_state_lookup+0xd8>
    3172:       39 48 50                cmp    %ecx,0x50(%rax)
    3175:       75 51                   jne    31c8
<__xfrm_state_lookup+0xd8>
    3177:       44 38 40 54             cmp    %r8b,0x54(%rax)
    317b:       75 4b                   jne    31c8
<__xfrm_state_lookup+0xd8>


The failing offset is 0x3168, which is on line 676:

 667  static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32
mark,
   668                                                const
xfrm_address_t *daddr,
   669                                                __be32 spi, u8 proto,
   670                                                unsigned short family)
   671  {
   672          unsigned int h = xfrm_spi_hash(net, daddr, spi, proto,
family);
   673          struct xfrm_state *x;
   674
   675          hlist_for_each_entry(x, net->xfrm.state_byspi+h, byspi) {
   676                  if (x->props.family != family ||
   677                      x->id.spi       != spi ||
   678                      x->id.proto     != proto ||
   679                      !xfrm_addr_equal(&x->id.daddr, daddr, family))
   680                          continue;
   681
   682                  if ((mark & x->mark.m) != x->mark.v)
   683                          continue;
   684                  xfrm_state_hold(x);
   685                  return x;
   686          }
   687
   688          return NULL;
   689  }


This might be related to the fact that we see unexpected high number of SPIs in
ip xfrm state:

ip xfrm state | grep -c ^src
7857

Instead of expected ~ 102*2=204 SPIs. Some of the SPIs are in a stale state, on
the affected nodes, we see this in charon.log:


Sep 18 10:15:57 13[KNL] <tch059|49961> querying SAD entry with SPI c663d950
failed: No such process (3)
Sep 18 10:15:57 13[KNL] <tch059|49961> querying SAD entry with SPI c5265bed
failed: No such process (3)
Sep 18 10:15:57 13[KNL] <tch059|49961> querying SAD entry with SPI cea44e84
failed: No such process (3)
Sep 18 10:15:57 05[KNL] <tch059|49972> querying SAD entry with SPI c218d962
failed: No such process (3)
Sep 18 10:15:57 07[KNL] <tch059|50015> querying SAD entry with SPI c08f7af3
failed: No such process (3)
Sep 18 10:15:57 13[KNL] <tch059|49961> querying SAD entry with SPI ca3eb959
failed: No such process (3)
Sep 18 10:15:57 05[KNL] <tch059|49972> querying SAD entry with SPI ccd82ddf
failed: No such process (3)
Sep 18 10:15:57 07[KNL] <tch059|50015> querying SAD entry with SPI c5e8e50d
failed: No such process (3)
Sep 18 10:15:57 13[KNL] <tch059|49961> querying SAD entry with SPI c7c6f94f
failed: No such process (3)


Some of the point to point assosiations are there multiple times:

# ip xfrm state  | grep ^src | sort | uniq -c | sort -rn | head -n10
   3528 src 5.45.A.B dst 5.45.C.D
   3528 src 5.45.C.D dst 5.45.A.B
     88 src 5.45.A.B dst 5.45.E.F
     88 src 5.45.E.F dst 5.45.A.B

I am happy to provide more information, if necessary.

Jiri Horky

--
You are receiving this mail because:
You are the assignee for the bug.
