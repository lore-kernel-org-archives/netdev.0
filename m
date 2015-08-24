From: Santosh R <skrastapur@gmail.com>
Subject: Low throughput in VMs using VxLAN
Date: Mon, 24 Aug 2015 21:49:41 +0530
Message-ID: <CAOoYtEtnvYKcs7s0Bmv+7+L0=nhXdJfeC2uSZa8Nz9i_+jy2Vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37400 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbbHXQTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 12:19:42 -0400
Received: by igui7 with SMTP id i7so59793108igu.0
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 09:19:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi,

   Earlier I was seeing lower throughput in VMs using VxLan as GRO was
not happening in VM.
Tom Herbert suggested to use "vxlan: GRO support at tunnel layer" patch series.
With today's net-next (4.2.0-rc7) in host and VM, I could see GRO
happening for vxlan, macvtap and virtual interface in VM.
The throughput is still low between VMs (around 4Gbps compared to
9Gbps without VxLAN).
Looks like the packet is getting segmented in Host and then GROed in VM.
Is this an expected behaviour? Is my below configuration correct?

Here is the configuration.
eth (VM) - macvtap - vxlan - phy iface  <-> phy iface - vxlan -
macvtap - (VM) eth

VM is started with
# qemu-system-x86_64 -m 4096 -smp 4 -boot c  -device
virtio-net-pci,netdev=hostnet0,id=net0,mac=C2:B2:CA:6F:BC:A4 -device
e1000,netdev=tap0,mac=DE:AD:BE:EF:96:32 -netdev tap,id=hostnet0,fd=3
3<>/dev/tap18 -netdev tap,id=tap0,script=no  -drive
file=/root/vdisk_rhel65.img

Here is the skb_segment count for 10 sec iperf receive test.
host # ./funccount skb_segment
Tracing "skb_segment"... Ctrl-C to end.
^C
FUNC                              COUNT
skb_segment                       58604

# ./functrace skb_segment
...
         <idle>-0     [006] ..s. 17632.030126: skb_segment <-tcp_gso_segment
     ksoftirqd/6-38    [006] ..s. 17632.030177: skb_segment <-tcp_gso_segment
     ksoftirqd/6-38    [006] ..s. 17632.030223: skb_segment <-tcp_gso_segment
     ksoftirqd/6-38    [006] ..s. 17632.030269: skb_segment <-tcp_gso_segment
     ksoftirqd/6-38    [006] ..s. 17632.030298: skb_segment <-tcp_gso_segment
 qemu-system-x86-5932  [006] ..s. 17632.030489: skb_segment <-tcp_gso_segment
 qemu-system-x86-5932  [006] ..s. 17632.030507: skb_segment <-tcp_gso_segment
 qemu-system-x86-5932  [006] ..s. 17632.030528: skb_segment <-tcp_gso_segment
 qemu-system-x86-5932  [006] ..s. 17632.030550: skb_segment <-tcp_gso_segment
 qemu-system-x86-5932  [006] ..s. 17632.030576: skb_segment <-tcp_gso_segment
 qemu-system-x86-5932  [006] ..s1 17632.030759: skb_segment <-tcp_gso_segment
 qemu-system-x86-5932  [006] ..s1 17632.030814: skb_segment <-tcp_gso_segment
..

# Physical interface
21:32:49.749263 IP 102.22.22.14.39561 > 102.22.22.12.otv: UDP, length 2870
21:32:49.749278 IP 102.22.22.14.39561 > 102.22.22.12.otv: UDP, length 9860
21:32:49.749326 IP 102.22.22.12.44214 > 102.22.22.14.otv: UDP, length 74
21:32:49.749333 IP 102.22.22.12.44214 > 102.22.22.14.otv: UDP, length 74
21:32:49.749340 IP 102.22.22.12.44214 > 102.22.22.14.otv: UDP, length 74
21:32:49.749405 IP 102.22.22.14.39561 > 102.22.22.12.otv: UDP, length 2870
21:32:49.749425 IP 102.22.22.14.39561 > 102.22.22.12.otv: UDP, length 11258

# VxLAN
21:32:49.749268 IP 102.44.44.14.60616 > 102.44.44.12.commplex-link:
Flags [.], seq 25:2821, ack 1, win 111, options [nop,nop,TS val
15632994 ecr 13334931], length 2796
21:32:49.749281 IP 102.44.44.14.60616 > 102.44.44.12.commplex-link:
Flags [.], seq 2821:12607, ack 1, win 111, options [nop,nop,TS val
15632994 ecr 13334931], length 9786
21:32:49.749322 IP 102.44.44.12.commplex-link > 102.44.44.14.60616:
Flags [.], ack 2821, win 270, options [nop,nop,TS val 13334931 ecr
15632994], length 0
21:32:49.749331 IP 102.44.44.12.commplex-link > 102.44.44.14.60616:
Flags [.], ack 7015, win 336, options [nop,nop,TS val 13334931 ecr
15632994], length 0
21:32:49.749336 IP 102.44.44.12.commplex-link > 102.44.44.14.60616:
Flags [.], ack 12607, win 423, options [nop,nop,TS val 13334931 ecr
15632994], length 0
21:32:49.749411 IP 102.44.44.14.60616 > 102.44.44.12.commplex-link:
Flags [.], seq 12607:15403, ack 1, win 111, options [nop,nop,TS val
15632994 ecr 13334931], length 2796
21:32:49.749429 IP 102.44.44.14.60616 > 102.44.44.12.commplex-link:
Flags [P.], seq 15403:26587, ack 1, win 111, options [nop,nop,TS val
15632994 ecr 13334931], length 11184

# macvtap
2.44.44.14.60616 > 102.44.44.12.commplex-link: Flags [.], seq 25:2821,
ack 1, win 111, options [nop,nop,TS val 15632994 ecr 13334931], length
2796
21:32:49.749281 IP 102.44.44.14.60616 > 102.44.44.12.commplex-link:
Flags [.], seq 2821:12607, ack 1, win 111, options [nop,nop,TS val
15632994 ecr 13334931], length 9786
21:32:49.749321 IP 102.44.44.12.commplex-link > 102.44.44.14.60616:
Flags [.], ack 2821, win 270, options [nop,nop,TS val 13334931 ecr
15632994], length 0
21:32:49.749330 IP 102.44.44.12.commplex-link > 102.44.44.14.60616:
Flags [.], ack 7015, win 336, options [nop,nop,TS val 13334931 ecr
15632994], length 0
21:32:49.749335 IP 102.44.44.12.commplex-link > 102.44.44.14.60616:
Flags [.], ack 12607, win 423, options [nop,nop,TS val 13334931 ecr
15632994], length 0
21:32:49.749411 IP 102.44.44.14.60616 > 102.44.44.12.commplex-link:
Flags [.], seq 12607:15403, ack 1, win 111, options [nop,nop,TS val
15632994 ecr 13334931], length 2796
21:32:49.749429 IP 102.44.44.14.60616 > 102.44.44.12.commplex-link:
Flags [P.], seq 15403:26587, ack 1, win 111, options [nop,nop,TS val
15632994 ecr 13334931], length 11184

# VM interface
2:02:48.126327 IP 102.44.44.14.60616 > 102.44.44.12.commplex-link:
Flags [.], seq 25:2821, ack 1, win 111, options [nop,nop,TS val
15632994 ecr 13334931], length 2796
12:02:48.126332 IP 102.44.44.12.commplex-link > 102.44.44.14.60616:
Flags [.], ack 2821, win 270, options [nop,nop,TS val 13334931 ecr
15632994], length 0
12:02:48.126352 IP 102.44.44.14.60616 > 102.44.44.12.commplex-link:
Flags [.], seq 2821:7015, ack 1, win 111, options [nop,nop,TS val
15632994 ecr 13334931], length 4194
12:02:48.126357 IP 102.44.44.12.commplex-link > 102.44.44.14.60616:
Flags [.], ack 7015, win 336, options [nop,nop,TS val 13334931 ecr
15632994], length 0
12:02:48.126361 IP 102.44.44.14.60616 > 102.44.44.12.commplex-link:
Flags [.], seq 7015:12607, ack 1, win 111, options [nop,nop,TS val
15632994 ecr 13334931], length 5592
12:02:48.126366 IP 102.44.44.12.commplex-link > 102.44.44.14.60616:
Flags [.], ack 12607, win 423, options [nop,nop,TS val 13334931 ecr
15632994], length 0
12:02:48.126468 IP 102.44.44.14.60616 > 102.44.44.12.commplex-link:
Flags [.], seq 12607:15403, ack 1, win 111, options [nop,nop,TS val
15632994 ecr 13334931], length 2796

Regards
-Santosh
