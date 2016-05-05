From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: mlx5 core/en oops in 4.6-rc6+
Date: Thu, 5 May 2016 23:51:25 +0300
Message-ID: <CALzJLG8ho88yJStHbPg+XFtEJHDQf3s20gjnsEdRdh4mGye7FQ@mail.gmail.com>
References: <56df9c0a-39dd-6e07-9466-23195dc60860@redhat.com>
 <CALzJLG9_PLzU=Qwvv=_3aEd0KQr1c9rZyfcrfuLPo8wF=F_B0A@mail.gmail.com> <b4a8c4ca-74c5-b9b4-f9a5-4386cf6857fe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34260 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503AbcEEUvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 16:51:45 -0400
Received: by mail-yw0-f195.google.com with SMTP id i22so13336583ywc.1
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 13:51:45 -0700 (PDT)
In-Reply-To: <b4a8c4ca-74c5-b9b4-f9a5-4386cf6857fe@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 5, 2016 at 8:16 PM, Doug Ledford <dledford@redhat.com> wrote:
>
> That depends on which interface actually generated the oops.  If it was
> the base interface, then I don't manually set any special params on it.
> If it's one of the vlan interfaces, then there is a NetworkManager
> dispatcher script that is intended to set the tc count on interface up:
>
> [root@rdma-virt-03 ~]$ more /etc/NetworkManager/dispatcher.d/98-mlx5_roce.4*
> ::::::::::::::
> /etc/NetworkManager/dispatcher.d/98-mlx5_roce.43-egress.conf
> ::::::::::::::
> #!/bin/sh
> interface=$1
> status=$2
> [ "$interface" = mlx5_roce.43 ] || exit 0
> case $status in
> up)
>         tc qdisc add dev mlx5_roce root mqprio num_tc 8 map 5 5 5 5 5 5 5 5 5 5
> 5 5 5 5 5 5

Well, here you are configuring 8 TCs on the base mlx5 interface, so
the answer to my question is yes.

It appears that we have a bug in mlx5e_slelect_queue

int channel_ix = fallback(dev, skb);
return priv->channeltc_to_txq_map[channel_ix][tc];

When num_tc > 1 the fallback can return any value between [0..
num_channles * num_tc ]

while channeltc_to_txq_map is an array of the size num_channels.

so there is a good chance that channel_ix exceeds the array limits and
resulting OOPs.

>         # tc_wrap.py -i mlx5_roce -u 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
>         ;;
> esac
> --More--(Next file:
> /etc/NetworkManager/dispatcher.d/98-mlx5_roce.45-egress.conf::::::::::::::
> /etc/NetworkManager/dispatcher.d/98-mlx5_roce.45-egress.conf
> ::::::::::::::
> #!/bin/sh
> interface=$1
> status=$2
> [ "$interface" = mlx5_roce.45 ] || exit 0
> case $status in
> up)
>         tc qdisc add dev mlx5_roce root mqprio num_tc 8 map 5 5 5 5 5 5 5 5 5 5
> 5 5 5 5 5 5

will, here you map all user skb prios (skb->priority) to HW tc 5.
BTW skprio or user prio in this example is never the vlan prio it is
the ipv4 (ToS).

please see http://lartc.org/manpages/tc-prio.html

So to achieve a vlan prio to HW tc mapping, you will need to map the
skprios to vlan prios using vlan egress mapping
which i see you already do down below.

But, our select queue implementation will extract the vlan priority
and use the corresponding TC from our own
priv->channeltc_to_txq_map[channel_ix][up] mapping
where up is vlan user priority.  but this only applies to kernel
traffic, i don't see why it is needed for RoCE.

Currently this code is buggy and I will need to dig more into how to
provide a full working solution that fits our hardware requirements
and complies with the kernel QoS APIs.


[...]

> [root@rdma-virt-02 vlan]$ for i in *; do echo "$i:"; cat $i; echo; done
> config:
> VLAN Dev name    | VLAN ID
> Name-Type: VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD
> mlx5_roce.45   | 45  | mlx5_roce
> mlx5_roce.43   | 43  | mlx5_roce
>
> mlx5_roce.43:
> mlx5_roce.43  VID: 43    REORDER_HDR: 1  dev->priv_flags: 1001
>          total frames received           57
>           total bytes received         5010
>       Broadcast/Multicast Rcvd            0
>
>       total frames transmitted           20
>        total bytes transmitted         2525
> Device: mlx5_roce
> INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
>  EGRESS priority mappings: 0:3 1:3 2:3 3:3 4:3 5:3 6:3 7:3
>

Here you map every SKB prio (0..7) to vlan priorty 3.

>
> mlx5_roce.45:
> mlx5_roce.45  VID: 45    REORDER_HDR: 1  dev->priv_flags: 1001
>          total frames received           57
>           total bytes received         5010
>       Broadcast/Multicast Rcvd            0
>
>       total frames transmitted           21
>        total bytes transmitted         2603
> Device: mlx5_roce
> INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
>  EGRESS priority mappings: 0:5 1:5 2:5 3:5 4:5 5:5 6:5 7:5
>
> OK, so the vlans have egress mappings, but they don't match what the
> mlx5_roce.43 egress.conf file should have enabled.  Digging a little
> further on this machine:
>
> [root@rdma-virt-03 vlan]$ more
> /etc/sysconfig/network-scripts/ifcfg-mlx5_roce.4?
> ::::::::::::::
> /etc/sysconfig/network-scripts/ifcfg-mlx5_roce.43
> ::::::::::::::
> DEVICE=mlx5_roce.43
> VLAN=yes
> VLAN_ID=43
> VLAN_EGRESS_PRIORITY_MAP=0:3,1:3,2:3,3:3,4:3,5:3,6:3,7:3
> TYPE=Vlan
> ONBOOT=yes
> BOOTPROTO=dhcp
> DEFROUTE=no
> PEERDNS=no
> PEERROUTES=yes
> IPV4_FAILURE_FATAL=yes
> IPV6INIT=yes
> IPV6_AUTOCONF=yes
> IPV6_DEFROUTE=no
> IPV6_PEERDNS=no
> IPV6_PEERROUTES=yes
> IPV6_FAILURE_FATAL=no
> NAME=mlx5_roce.43
> ::::::::::::::
> /etc/sysconfig/network-scripts/ifcfg-mlx5_roce.45
> ::::::::::::::
> DEVICE=mlx5_roce.45
> VLAN=yes
> VLAN_ID=45
> VLAN_EGRESS_PRIORITY_MAP=0:5,1:5,2:5,3:5,4:5,5:5,6:5,7:5
> TYPE=Vlan
> ONBOOT=yes
> BOOTPROTO=dhcp
> DEFROUTE=no
> PEERDNS=no
> PEERROUTES=yes
> IPV4_FAILURE_FATAL=yes
> IPV6INIT=yes
> IPV6_AUTOCONF=yes
> IPV6_DEFROUTE=no
> IPV6_PEERDNS=no
> IPV6_PEERROUTES=yes
> IPV6_FAILURE_FATAL=no
> NAME=mlx5_roce.45
> [root@rdma-virt-03 vlan]$
>
> This is a Fedora rawhide machine, using NetworkManager to handle the
> network interfaces.  So, the egress priority mappings are being set by
> NM.  I don't know if they are overriding the egress mapping dispatchers
> or if the egress mapping dispatchers are failing to work/run properly.
> It might be the latter.  Let me double check the command...
>
> OK, re-reading the egress dispatchers above, they work on the base
> interface, not on the vlan interface that triggers them.  That's why
> they both use the same command (mapping to egress 5) instead of being
> like the ifcfg files, which map the 43 vlan to egress priority 3, and
> the 45 vlan to egress priority 5.  Running tc qdisc | grep mlx5_roce
> shows that the egress mapping is being applied (although I'm not sure it
> should be...I made that mapping many kernels ago when that was the right
> thing to do, the modern mlx5 ethernet drivers create their own mappings
> that are drastically different).
>
> So, to answer your question, yes, num_tc > 1, num_tc == 8, and I
> probably need to reconfigure that egress dispatcher to do what I want it
> to do (which is merely to make sure that all packets from specific
> interfaces are tagged with specific vlan priorities so per-priority flow
> control between the card and switch works properly, the base interface
> is supposed to have no priority tag, the 43 vlan is supposed to have
> priority tag 3, and vlan 45 is supposed to have priority tag 5) on
> modern kernels.
>

As i said above configuring any num_tc > 1 might cause the panic you saw.

Regarding the proper mapping to do for 45 => priority 5, 43 => prio 3.
the egress mappings you already did above should be sufficient, the
question is, do you need the vlan priorities to be mapped to a
specific HW TC dispatchers ?

if not, then you don't need to configure  "tc qdisc add dev mlx5_roce
root ..." at all.
