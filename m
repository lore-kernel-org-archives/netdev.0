From: Simon Horman <simon.horman@netronome.com>
Subject: Decreasing xmit RECURSION_LIMIT
Date: Wed, 27 May 2015 17:04:51 +0900
Message-ID: <20150527080450.GA16782@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pravin Shelar <pshelar@nicira.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:36508 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562AbbE0IE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 04:04:58 -0400
Received: by pdfh10 with SMTP id h10so3948278pdf.3
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 01:04:58 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, Hi All,

I am wondering about your feelings about reducing the xmit RECURSION_LIMIT
in net/core/dev.c.

It was last changed, from 3 to 10, by you by
11a766ce915fc ("net: Increase xmit RECURSION_LIMIT to 10.")
where you described 3 as "definitely too low".
I believe this occurred in v3.6.37; about 5 years ago.

The reason that I ask is that when a loop occurs using VXLAN with
Open vSwitch I see my stack exhausted before hitting the current limit.
Empirically it appears that reducing the limit to 5 mitigates
the problem in my test environment.

>From my reading of the code that means the code will bail-out
in the 6th loop after the first one. Or in other words the recursion
limit only kicks in once hitting the check the (RECURSION_LIMIT + 2)th time.

An alternate solution I thought of would be for Open vSwitch to
implement its own (lower) recursion limit. I have not investigated the
practicality of this idea.

I observed this on x86_64. I was able to use ftrace to
show the stack usage when hitting the recursion limit with
RECURSION_LIMIT set to 5.

The stack usage seem very high to me. It wasn't immediately
obvious to me where any savings might be made by putting the
code on a diet or tweaking kernel configuration options.

        Depth    Size   Location    (140 entries)
        -----    ----   --------
  0)    14760     208   wait_for_xmitr+0x3b/0xa0
  1)    14552      64   io_serial_in+0x5/0x20
  2)    14488      72   wait_for_xmitr+0x3b/0xa0
  3)    14416      32   serial8250_console_putchar+0x1c/0x30
  4)    14384      48   uart_console_write+0x3c/0x70
  5)    14336     144   univ8250_console_write+0xfe/0x2c0
  6)    14192      48   call_console_drivers.constprop.26+0xb2/0x100
  7)    14144      80   console_unlock+0x2ce/0x430
  8)    14064     128   vprintk_emit+0x2ec/0x500
  9)    13936      16   vprintk_default+0x1f/0x30
 10)    13920      96   printk+0x46/0x48
 11)    13824      96   __netdev_printk+0x1fa/0x2c0
 12)    13728     112   netdev_info+0x53/0x60
 13)    13616      96   __dev_queue_xmit+0x45/0x500
 14)    13520      16   dev_queue_xmit_sk+0x13/0x20
 15)    13504      96   ip_finish_output+0x252/0x8b0
 16)    13408      80   ip_output+0xab/0xc0
 17)    13328      32   ip_local_out_sk+0x31/0x40
 18)    13296      96   iptunnel_xmit+0x102/0x120
 19)    13200     128   udp_tunnel_xmit_skb+0xe8/0x100
 20)    13072     176   vxlan_xmit_skb+0x230/0x4f0
 21)    12896     192   vxlan_tnl_send+0x1ab/0x2e0 [vport_vxlan]
 22)    12704       8   ovs_vport_send+0x18/0x60 [openvswitch]
 23)    12696      32   do_output+0x29/0x40 [openvswitch]
 24)    12664     168   do_execute_actions+0xe19/0x11d0 [openvswitch]
 25)    12496      48   ovs_execute_actions+0x3f/0xf0 [openvswitch]
 26)    12448     112   ovs_dp_process_packet+0x75/0xf0 [openvswitch]
 27)    12336     136   ovs_vport_receive+0x6c/0xa0 [openvswitch]
 28)    12200     312   internal_dev_xmit+0x1d/0x30 [openvswitch]
 29)    11888     128   dev_hard_start_xmit+0x24f/0x3c0
 30)    11760      96   __dev_queue_xmit+0x353/0x500
 31)    11664      16   dev_queue_xmit_sk+0x13/0x20
 32)    11648      96   ip_finish_output+0x252/0x8b0
 33)    11552      80   ip_output+0xab/0xc0
 34)    11472      32   ip_local_out_sk+0x31/0x40
 35)    11440      96   iptunnel_xmit+0x102/0x120
 36)    11344     128   udp_tunnel_xmit_skb+0xe8/0x100
 37)    11216     176   vxlan_xmit_skb+0x230/0x4f0
 38)    11040     192   vxlan_tnl_send+0x1ab/0x2e0 [vport_vxlan]
 39)    10848       8   ovs_vport_send+0x18/0x60 [openvswitch]
 40)    10840      32   do_output+0x29/0x40 [openvswitch]
 41)    10808     168   do_execute_actions+0xe19/0x11d0 [openvswitch]
 42)    10640      48   ovs_execute_actions+0x3f/0xf0 [openvswitch]
 43)    10592     112   ovs_dp_process_packet+0x75/0xf0 [openvswitch]
 44)    10480     136   ovs_vport_receive+0x6c/0xa0 [openvswitch]
 45)    10344     312   internal_dev_xmit+0x1d/0x30 [openvswitch]
 46)    10032     128   dev_hard_start_xmit+0x24f/0x3c0
 47)     9904      96   __dev_queue_xmit+0x353/0x500
 48)     9808      16   dev_queue_xmit_sk+0x13/0x20
 49)     9792      96   ip_finish_output+0x252/0x8b0
 50)     9696      80   ip_output+0xab/0xc0
 51)     9616      32   ip_local_out_sk+0x31/0x40
 52)     9584      96   iptunnel_xmit+0x102/0x120
 53)     9488     128   udp_tunnel_xmit_skb+0xe8/0x100
 54)     9360     176   vxlan_xmit_skb+0x230/0x4f0
 55)     9184     192   vxlan_tnl_send+0x1ab/0x2e0 [vport_vxlan]
 56)     8992       8   ovs_vport_send+0x18/0x60 [openvswitch]
 57)     8984      32   do_output+0x29/0x40 [openvswitch]
 58)     8952     168   do_execute_actions+0xe19/0x11d0 [openvswitch]
 59)     8784      48   ovs_execute_actions+0x3f/0xf0 [openvswitch]
 60)     8736     112   ovs_dp_process_packet+0x75/0xf0 [openvswitch]
 61)     8624     136   ovs_vport_receive+0x6c/0xa0 [openvswitch]
 62)     8488     312   internal_dev_xmit+0x1d/0x30 [openvswitch]
 63)     8176     128   dev_hard_start_xmit+0x24f/0x3c0
 64)     8048      96   __dev_queue_xmit+0x353/0x500
 65)     7952      16   dev_queue_xmit_sk+0x13/0x20
 66)     7936      96   ip_finish_output+0x252/0x8b0
 67)     7840      80   ip_output+0xab/0xc0
 68)     7760      32   ip_local_out_sk+0x31/0x40
 69)     7728      96   iptunnel_xmit+0x102/0x120
 70)     7632     128   udp_tunnel_xmit_skb+0xe8/0x100
 71)     7504     176   vxlan_xmit_skb+0x230/0x4f0
 72)     7328     192   vxlan_tnl_send+0x1ab/0x2e0 [vport_vxlan]
 73)     7136       8   ovs_vport_send+0x18/0x60 [openvswitch]
 74)     7128      32   do_output+0x29/0x40 [openvswitch]
 75)     7096     168   do_execute_actions+0xe19/0x11d0 [openvswitch]
 76)     6928      48   ovs_execute_actions+0x3f/0xf0 [openvswitch]
 77)     6880     112   ovs_dp_process_packet+0x75/0xf0 [openvswitch]
 78)     6768     136   ovs_vport_receive+0x6c/0xa0 [openvswitch]
 79)     6632     312   internal_dev_xmit+0x1d/0x30 [openvswitch]
 80)     6320     128   dev_hard_start_xmit+0x24f/0x3c0
 81)     6192      96   __dev_queue_xmit+0x353/0x500
 82)     6096      16   dev_queue_xmit_sk+0x13/0x20
 83)     6080      96   ip_finish_output+0x252/0x8b0
 84)     5984      80   ip_output+0xab/0xc0
 85)     5904      32   ip_local_out_sk+0x31/0x40
 86)     5872      96   iptunnel_xmit+0x102/0x120
 87)     5776     128   udp_tunnel_xmit_skb+0xe8/0x100
 88)     5648     176   vxlan_xmit_skb+0x230/0x4f0
 89)     5472     192   vxlan_tnl_send+0x1ab/0x2e0 [vport_vxlan]
 90)     5280       8   ovs_vport_send+0x18/0x60 [openvswitch]
 91)     5272      32   do_output+0x29/0x40 [openvswitch]
 92)     5240     168   do_execute_actions+0xe19/0x11d0 [openvswitch]
 93)     5072      48   ovs_execute_actions+0x3f/0xf0 [openvswitch]
 94)     5024     112   ovs_dp_process_packet+0x75/0xf0 [openvswitch]
 95)     4912     136   ovs_vport_receive+0x6c/0xa0 [openvswitch]
 96)     4776     312   internal_dev_xmit+0x1d/0x30 [openvswitch]
 97)     4464     128   dev_hard_start_xmit+0x24f/0x3c0
 98)     4336      96   __dev_queue_xmit+0x353/0x500
 99)     4240      16   dev_queue_xmit_sk+0x13/0x20
100)     4224      96   ip_finish_output+0x252/0x8b0
101)     4128      80   ip_output+0xab/0xc0
102)     4048      32   ip_local_out_sk+0x31/0x40
103)     4016      96   iptunnel_xmit+0x102/0x120
104)     3920     128   udp_tunnel_xmit_skb+0xe8/0x100
105)     3792     176   vxlan_xmit_skb+0x230/0x4f0
106)     3616     192   vxlan_tnl_send+0x1ab/0x2e0 [vport_vxlan]
107)     3424       8   ovs_vport_send+0x18/0x60 [openvswitch]
108)     3416      32   do_output+0x29/0x40 [openvswitch]
109)     3384     168   do_execute_actions+0xe19/0x11d0 [openvswitch]
110)     3216      48   ovs_execute_actions+0x3f/0xf0 [openvswitch]
111)     3168     112   ovs_dp_process_packet+0x75/0xf0 [openvswitch]
112)     3056     136   ovs_vport_receive+0x6c/0xa0 [openvswitch]
113)     2920     312   internal_dev_xmit+0x1d/0x30 [openvswitch]
114)     2608     128   dev_hard_start_xmit+0x24f/0x3c0
115)     2480      96   __dev_queue_xmit+0x353/0x500
116)     2384      16   dev_queue_xmit_sk+0x13/0x20
117)     2368      96   ip_finish_output+0x252/0x8b0
118)     2272      80   ip_output+0xab/0xc0
119)     2192      32   ip_local_out_sk+0x31/0x40
120)     2160      96   iptunnel_xmit+0x102/0x120
121)     2064     128   udp_tunnel_xmit_skb+0xe8/0x100
122)     1936     176   vxlan_xmit_skb+0x230/0x4f0
123)     1760     192   vxlan_tnl_send+0x1ab/0x2e0 [vport_vxlan]
124)     1568       8   ovs_vport_send+0x18/0x60 [openvswitch]
125)     1560      32   do_output+0x29/0x40 [openvswitch]
126)     1528     168   do_execute_actions+0xe19/0x11d0 [openvswitch]
127)     1360      48   ovs_execute_actions+0x3f/0xf0 [openvswitch]
128)     1312      96   ovs_packet_cmd_execute+0x1f8/0x260 [openvswitch]
129)     1216     144   genl_family_rcv_msg+0x19b/0x330
130)     1072      24   genl_rcv_msg+0x79/0xc0
131)     1048      72   netlink_rcv_skb+0xb9/0xe0
132)      976       8   genl_rcv+0x2c/0x40
133)      968      88   netlink_unicast+0x162/0x210
134)      880     144   netlink_sendmsg+0x366/0x3d0
135)      736      16   sock_sendmsg+0x14/0x30
136)      720     384   ___sys_sendmsg+0x223/0x230
137)      336     144   __sys_sendmsg+0x42/0x80
138)      192      16   SyS_sendmsg+0xe/0x10
139)      176     176   system_call_fastpath+0x12/0x6a
