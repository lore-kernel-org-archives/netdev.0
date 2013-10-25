From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: vxlan gso is broken by stackable gso_segment()
Date: Thu, 24 Oct 2013 18:59:20 -0700
Message-ID: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
References: <CAMEtUuxRhENE+OCFgdVASyVAaLo8AOdazUZdT+YHrcEzWA8Dow@mail.gmail.com>
	<1382661707.7572.73.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <edumazet@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:48775 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754056Ab3JYB7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 21:59:21 -0400
Received: by mail-we0-f180.google.com with SMTP id q59so3202763wes.11
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 18:59:20 -0700 (PDT)
In-Reply-To: <1382661707.7572.73.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gre seems to be fine.
packets seem to be segmented with wrong length and being dropped.
After client iperf is finished, in few seconds I see the warning:

[  329.669685] WARNING: CPU: 3 PID: 3817 at net/core/skbuff.c:3474
skb_try_coalesce+0x3a0/0x3f0()
[  329.669688] Modules linked in: vxlan ip_tunnel veth ip6table_filter
ip6_tables ebtable_nat ebtables nf_conntrack_ipv4 nf_defrag_ipv4
xt_state nf_conntrack xt_CHECKSUM iptable_mangle ipt_REJECT xt_tcpudp
iptable_filter ip_tables x_tables bridge stp llc vhost_net macvtap
macvlan vhost kvm_intel kvm iscsi_tcp libiscsi_tcp libiscsi
scsi_transport_iscsi dm_crypt hid_generic eeepc_wmi asus_wmi
sparse_keymap mxm_wmi dm_multipath psmouse serio_raw usbhid hid
parport_pc ppdev firewire_ohci e1000e firewire_core lpc_ich crc_itu_t
binfmt_misc igb dca ptp pps_core mac_hid wmi lp parport i2o_config
i2o_block video
[  329.669746] CPU: 3 PID: 3817 Comm: iperf Not tainted 3.12.0-rc6+ #81
[  329.669748] Hardware name: System manufacturer System Product
Name/P8Z77 WS, BIOS 3007 07/26/2012
[  329.669750]  0000000000000009 ffff88082fb839d8 ffffffff8175427a
0000000000000002
[  329.669756]  0000000000000000 ffff88082fb83a18 ffffffff8105206c
ffff880808f926f8
[  329.669760]  ffff8807ef122b00 ffff8807ef122a00 0000000000000576
ffff88082fb83a94
[  329.669765] Call Trace:
[  329.669767]  <IRQ>  [<ffffffff8175427a>] dump_stack+0x55/0x76
[  329.669779]  [<ffffffff8105206c>] warn_slowpath_common+0x8c/0xc0
[  329.669783]  [<ffffffff810520ba>] warn_slowpath_null+0x1a/0x20
[  329.669787]  [<ffffffff816150f0>] skb_try_coalesce+0x3a0/0x3f0
[  329.669793]  [<ffffffff8167bce4>] tcp_try_coalesce.part.44+0x34/0xa0
[  329.669797]  [<ffffffff8167d168>] tcp_queue_rcv+0x108/0x150
[  329.669801]  [<ffffffff8167f129>] tcp_data_queue+0x299/0xd00
[  329.669806]  [<ffffffff816822f4>] tcp_rcv_established+0x2d4/0x8f0
[  329.669809]  [<ffffffff8168d8b5>] tcp_v4_do_rcv+0x295/0x520
[  329.669813]  [<ffffffff8168fb08>] tcp_v4_rcv+0x888/0xc30
[  329.669818]  [<ffffffff816651d3>] ? ip_local_deliver_finish+0x43/0x480
[  329.669823]  [<ffffffff810cae04>] ? __lock_is_held+0x54/0x80
[  329.669827]  [<ffffffff816652fb>] ip_local_deliver_finish+0x16b/0x480
[  329.669831]  [<ffffffff816651d3>] ? ip_local_deliver_finish+0x43/0x480
[  329.669836]  [<ffffffff81666018>] ip_local_deliver+0x48/0x80
[  329.669840]  [<ffffffff81665770>] ip_rcv_finish+0x160/0x770
[  329.669845]  [<ffffffff816662f8>] ip_rcv+0x2a8/0x3e0
[  329.669849]  [<ffffffff81623d13>] __netif_receive_skb_core+0xa63/0xdb0
[  329.669853]  [<ffffffff816233b8>] ? __netif_receive_skb_core+0x108/0xdb0
[  329.669858]  [<ffffffff8175d37f>] ? _raw_spin_unlock_irqrestore+0x3f/0x70
[  329.669862]  [<ffffffff8162417b>] ? process_backlog+0xab/0x180
[  329.669866]  [<ffffffff81624081>] __netif_receive_skb+0x21/0x70
[  329.669869]  [<ffffffff81624184>] process_backlog+0xb4/0x180
[  329.669873]  [<ffffffff81626d08>] ? net_rx_action+0x98/0x350
[  329.669876]  [<ffffffff81626dca>] net_rx_action+0x15a/0x350
[  329.669882]  [<ffffffff81057f97>] __do_softirq+0xf7/0x3f0
[  329.669886]  [<ffffffff8176820c>] call_softirq+0x1c/0x30
[  329.669887]  <EOI>  [<ffffffff81004bed>] do_softirq+0x8d/0xc0
[  329.669896]  [<ffffffff8160de03>] ? release_sock+0x193/0x1f0
[  329.669901]  [<ffffffff81057a5b>] local_bh_enable_ip+0xdb/0xf0
[  329.669906]  [<ffffffff8175d2e4>] _raw_spin_unlock_bh+0x44/0x50
[  329.669910]  [<ffffffff8160de03>] release_sock+0x193/0x1f0
[  329.669914]  [<ffffffff81679237>] tcp_recvmsg+0x467/0x1030
[  329.669919]  [<ffffffff816ab424>] inet_recvmsg+0x134/0x230
[  329.669923]  [<ffffffff8160a17d>] sock_recvmsg+0xad/0xe0

to reproduce do:
$ sudo brctl addbr br0
$ sudo ifconfig br0 up
$ cat foo1.conf
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = br0
lxc.network.ipv4 = 10.2.3.5/24
$sudo lxc-start -n foo1 -f ./foo1.conf bash
#ip li add vxlan0 type vxlan id 42 group 239.1.1.1 dev eth0
#ip addr add 192.168.99.1/24 dev vxlan0
#ip link set up dev vxlan0
#iperf -s

similar for another lxc with different IP
$sudo lxc-start -n foo2 -f ./foo2.conf bash
#ip li add vxlan0 type vxlan id 42 group 239.1.1.1 dev eth0
#ip addr add 192.168.99.2/24 dev vxlan0
#ip link set up dev vxlan0
# iperf -c 192.168.99.1

I keep hitting it all the time.


On Thu, Oct 24, 2013 at 5:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-10-24 at 16:37 -0700, Alexei Starovoitov wrote:
>> Hi Eric, Stephen,
>>
>> it seems commit 3347c960 "ipv4: gso: make inet_gso_segment() stackable"
>> broke vxlan gso
>>
>> the way to reproduce:
>> start two lxc with veth and bridge between them
>> create vxlan dev in both containers
>> do iperf
>>
>> this setup on net-next does ~80 Mbps and a lot of tcp retransmits.
>> reverting 3347c960 and d3e5e006 gets performance back to ~230 Mbps
>>
>> I guess vxlan driver suppose to set encap_level ? Some other way?
>
> Hi Alexei
>
> Are the GRE tunnels broken as well for you ?
>
> In my testings, GRE was working, and it looks GRE and vxlan has quite
> similar gso implementation.
>
> Maybe you can capture some of the broken frames with tcpdump ?
>
>
>
