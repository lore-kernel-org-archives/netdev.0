From: Tom Herbert <tom@herbertland.com>
Subject: Re: GRO not happening in VM with VxLAN
Date: Fri, 3 Jul 2015 11:27:38 -0700
Message-ID: <CALx6S34aL7t7qGDAXtxEAaebCNHKCQaspGs6qYU5N-tSgv5zTw@mail.gmail.com>
References: <CAOoYtEvTAvU-pcO=dS-wso8bPFcAv+5u4zsTP_UAjsQxYsBACA@mail.gmail.com>
	<CAOoYtEs5PPUQiE5rUgKZ2LjXK05YBGmZoG5cqKyubsn6G90-Zw@mail.gmail.com>
	<CAOoYtEsySd7e_Yj88FD8SmejtwZwAENJU5Wc3jcPb7W6cty5EA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Santosh R <skrastapur@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:34110 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754971AbbGCS1j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 14:27:39 -0400
Received: by iebmu5 with SMTP id mu5so80856884ieb.1
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 11:27:38 -0700 (PDT)
In-Reply-To: <CAOoYtEsySd7e_Yj88FD8SmejtwZwAENJU5Wc3jcPb7W6cty5EA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 2, 2015 at 11:47 PM, Santosh R <skrastapur@gmail.com> wrote=
:
> Hi,
>
>    I am testing VxLAN performance between VMs using 3.18 host kernel.
> For this I am using below command to bring up the VM.
> # qemu-system-x86_64 -m 4096 -smp 4 -boot c -device
> virtio-net-pci,netdev=3Dtap0,mac=3D00:11:22:33:44:55 -netdev
> tap,id=3Dtap0,script=3Dno,vhost=3Don  -drive file=3D/root/vdisk_rhel6=
5.img &
>
> Using the below setup, I am not getting good performance between VMs.
>
> VM1--tap1--bridge1--vxlan1--10G Nic1 <--->  10G Nic2--vxlan2--bridge2=
--tap2--VM2
>
This has already been reported. If zero UDP checksums are in use and
the device does not provide checksum unnecessary for the encapsulation
checksum or checksum complete, then GRO is not done at the device.
Also, GRO was not implemented at the vxlan device. Please see the
patches I posted to address the latter.

Thanks,
Tom



> The reason being, when VM1 sends traffic to VM2, the received packets
> are correctly aggregated at Nic2-vxlan2=E2=80=A6bridge2 in host2.
> But they get segmented at tap2 interface as it doesn=E2=80=99t suppor=
t VxLAN
> segmentation offload (tx-udp_tnl-segmentation: off [fixed]).
>
> When bridge interface tries to forward this packet to tap interface
> (br_dev_queue_push_xmit -> __dev_queue_xmit -> validate_xmit_skb),
> netif_needs_gso will succeed (skb_gso_ok returns 0) resulting in
> packet segmentation (which was earlier aggregated).
>
> Is this an expected behaviour? Does tap interface support
> tx-udp_tnl-segmentation?
>
> I had tried to discuss this issue with qemu-devel forum. Here is the
> link http://lists.nongnu.org/archive/html/qemu-devel/2015-06/msg07159=
=2Ehtml
>
> Driver is updating csum_level of sk_buff to 1 and calls napi_gro_frag=
s
> for VxLAN packets.
>
> # brctl show
> bridge name     bridge id               STP enabled     interfaces
> br-vx           8000.323a9146b2d2       no              tap0
>                                                         vxlan0
> # ethtool -k eth35
> Features for eth35:
> rx-checksumming: on
> tx-checksumming: on
>         tx-checksum-ipv4: on
>         tx-checksum-ip-generic: off [fixed]
>         tx-checksum-ipv6: on
>         tx-checksum-fcoe-crc: off [fixed]
>         tx-checksum-sctp: off [fixed]
> scatter-gather: on
>         tx-scatter-gather: on
>         tx-scatter-gather-fraglist: off [fixed]
> tcp-segmentation-offload: on
>         tx-tcp-segmentation: on
>         tx-tcp-ecn-segmentation: on
>         tx-tcp6-segmentation: on
> udp-fragmentation-offload: off [fixed]
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off [fixed]
> rx-vlan-offload: on
> tx-vlan-offload: on
> ntuple-filters: off [fixed]
> receive-hashing: off [fixed]
> highdma: on
> rx-vlan-filter: off [fixed]
> vlan-challenged: off [fixed]
> tx-lockless: off [fixed]
> netns-local: off [fixed]
> tx-gso-robust: off [fixed]
> tx-fcoe-segmentation: off [fixed]
> tx-gre-segmentation: off [fixed]
> tx-ipip-segmentation: off [fixed]
> tx-sit-segmentation: off [fixed]
> tx-udp_tnl-segmentation: on
> tx-mpls-segmentation: off [fixed]
> fcoe-mtu: off [fixed]
> tx-nocache-copy: off
> loopback: off [fixed]
> rx-fcs: off [fixed]
> rx-all: off [fixed]
> tx-vlan-stag-hw-insert: off [fixed]
> rx-vlan-stag-hw-parse: off [fixed]
> rx-vlan-stag-filter: off [fixed]
> l2-fwd-offload: off [fixed]
> busy-poll: on [fixed]
>
> # ethtool -k vxlan0
> Features for vxlan0:
> rx-checksumming: on
> tx-checksumming: on
>         tx-checksum-ipv4: off [fixed]
>         tx-checksum-ip-generic: on
>         tx-checksum-ipv6: off [fixed]
>         tx-checksum-fcoe-crc: off [fixed]
>         tx-checksum-sctp: off [fixed]
> scatter-gather: on
>         tx-scatter-gather: on
>         tx-scatter-gather-fraglist: off [fixed]
> tcp-segmentation-offload: on
>         tx-tcp-segmentation: on
>         tx-tcp-ecn-segmentation: on
>         tx-tcp6-segmentation: on
> udp-fragmentation-offload: on
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off [fixed]
> rx-vlan-offload: off [fixed]
> tx-vlan-offload: on
> ntuple-filters: off [fixed]
> receive-hashing: off [fixed]
> highdma: off [fixed]
> rx-vlan-filter: off [fixed]
> vlan-challenged: off [fixed]
> tx-lockless: on [fixed]
> netns-local: off [fixed]
> tx-gso-robust: off [fixed]
> tx-fcoe-segmentation: off [fixed]
> tx-gre-segmentation: off [fixed]
> tx-ipip-segmentation: off [fixed]
> tx-sit-segmentation: off [fixed]
> tx-udp_tnl-segmentation: off [fixed]
> tx-mpls-segmentation: off [fixed]
> fcoe-mtu: off [fixed]
> tx-nocache-copy: off
> loopback: off [fixed]
> rx-fcs: off [fixed]
> rx-all: off [fixed]
> tx-vlan-stag-hw-insert: on
> rx-vlan-stag-hw-parse: off [fixed]
> rx-vlan-stag-filter: off [fixed]
> l2-fwd-offload: off [fixed]
> busy-poll: off [fixed]
>
> # ethtool -k tap0
> Features for tap0:
> rx-checksumming: off [fixed]
> tx-checksumming: on
>         tx-checksum-ipv4: off [fixed]
>         tx-checksum-ip-generic: on
>         tx-checksum-ipv6: off [fixed]
>         tx-checksum-fcoe-crc: off [fixed]
>         tx-checksum-sctp: off [fixed]
> scatter-gather: on
>         tx-scatter-gather: on
>         tx-scatter-gather-fraglist: on
> tcp-segmentation-offload: on
>         tx-tcp-segmentation: on
>         tx-tcp-ecn-segmentation: on
>         tx-tcp6-segmentation: on
> udp-fragmentation-offload: off [fixed]
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off [fixed]
> rx-vlan-offload: off [fixed]
> tx-vlan-offload: on
> ntuple-filters: off [fixed]
> receive-hashing: off [fixed]
> highdma: off [fixed]
> rx-vlan-filter: off [fixed]
> vlan-challenged: off [fixed]
> tx-lockless: off [fixed]
> netns-local: off [fixed]
> tx-gso-robust: off [fixed]
> tx-fcoe-segmentation: off [fixed]
> tx-gre-segmentation: off [fixed]
> tx-ipip-segmentation: off [fixed]
> tx-sit-segmentation: off [fixed]
> tx-udp_tnl-segmentation: off [fixed]
> tx-mpls-segmentation: off [fixed]
> fcoe-mtu: off [fixed]
> tx-nocache-copy: off
> loopback: off [fixed]
> rx-fcs: off [fixed]
> rx-all: off [fixed]
> tx-vlan-stag-hw-insert: on
> rx-vlan-stag-hw-parse: off [fixed]
> rx-vlan-stag-filter: off [fixed]
> l2-fwd-offload: off [fixed]
> busy-poll: off [fixed]
>
> Thanks
> -Santosh
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
