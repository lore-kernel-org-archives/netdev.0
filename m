From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH net-next 3/4] samples/bpf: extend test_tunnel_bpf.sh with
 IPIP test
Date: Thu, 15 Sep 2016 22:16:09 -0700
Message-ID: <CALDO+SYktwsw-uCQRdSvU4U2jP3L1YuOUU4VThaCGDuqKWFLfA@mail.gmail.com>
References: <1473969632-2408261-1-git-send-email-ast@fb.com> <1473969632-2408261-4-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:34340 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751277AbcIPFQv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 01:16:51 -0400
Received: by mail-it0-f41.google.com with SMTP id 15so8619456ita.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 22:16:50 -0700 (PDT)
In-Reply-To: <1473969632-2408261-4-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexei,

Is there a corresponding patch for iproute2? I tested this patch but fails at:
+ ip link add dev ipip11 type ipip external
because my ip command does not support "external".

Thanks
William


On Thu, Sep 15, 2016 at 1:00 PM, Alexei Starovoitov <ast@fb.com> wrote:
> extend existing tests for vxlan, geneve, gre to include IPIP tunnel.
> It tests both traditional tunnel configuration and
> dynamic via bpf helpers.
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> ---
>  samples/bpf/tcbpf2_kern.c      | 58 ++++++++++++++++++++++++++++++++++++++++++
>  samples/bpf/test_tunnel_bpf.sh | 56 ++++++++++++++++++++++++++++++++++------
>  2 files changed, 106 insertions(+), 8 deletions(-)
>
> diff --git a/samples/bpf/tcbpf2_kern.c b/samples/bpf/tcbpf2_kern.c
> index 7a15289da6cc..c1917d968fb4 100644
> --- a/samples/bpf/tcbpf2_kern.c
> +++ b/samples/bpf/tcbpf2_kern.c
> @@ -1,4 +1,5 @@
>  /* Copyright (c) 2016 VMware
> + * Copyright (c) 2016 Facebook
>   *
>   * This program is free software; you can redistribute it and/or
>   * modify it under the terms of version 2 of the GNU General Public
> @@ -188,4 +189,61 @@ int _geneve_get_tunnel(struct __sk_buff *skb)
>         return TC_ACT_OK;
>  }
>
> +SEC("ipip_set_tunnel")
> +int _ipip_set_tunnel(struct __sk_buff *skb)
> +{
> +       struct bpf_tunnel_key key = {};
> +       void *data = (void *)(long)skb->data;
> +       struct iphdr *iph = data;
> +       struct tcphdr *tcp = data + sizeof(*iph);
> +       void *data_end = (void *)(long)skb->data_end;
> +       int ret;
> +
> +       /* single length check */
> +       if (data + sizeof(*iph) + sizeof(*tcp) > data_end) {
> +               ERROR(1);
> +               return TC_ACT_SHOT;
> +       }
> +
> +       key.tunnel_ttl = 64;
> +       if (iph->protocol == IPPROTO_ICMP) {
> +               key.remote_ipv4 = 0xac100164; /* 172.16.1.100 */
> +       } else {
> +               if (iph->protocol != IPPROTO_TCP || iph->ihl != 5)
> +                       return TC_ACT_SHOT;
> +
> +               if (tcp->dest == htons(5200))
> +                       key.remote_ipv4 = 0xac100164; /* 172.16.1.100 */
> +               else if (tcp->dest == htons(5201))
> +                       key.remote_ipv4 = 0xac100165; /* 172.16.1.101 */
> +               else
> +                       return TC_ACT_SHOT;
> +       }
> +
> +       ret = bpf_skb_set_tunnel_key(skb, &key, sizeof(key), 0);
> +       if (ret < 0) {
> +               ERROR(ret);
> +               return TC_ACT_SHOT;
> +       }
> +
> +       return TC_ACT_OK;
> +}
> +
> +SEC("ipip_get_tunnel")
> +int _ipip_get_tunnel(struct __sk_buff *skb)
> +{
> +       int ret;
> +       struct bpf_tunnel_key key;
> +       char fmt[] = "remote ip 0x%x\n";
> +
> +       ret = bpf_skb_get_tunnel_key(skb, &key, sizeof(key), 0);
> +       if (ret < 0) {
> +               ERROR(ret);
> +               return TC_ACT_SHOT;
> +       }
> +
> +       bpf_trace_printk(fmt, sizeof(fmt), key.remote_ipv4);
> +       return TC_ACT_OK;
> +}
> +
>  char _license[] SEC("license") = "GPL";
> diff --git a/samples/bpf/test_tunnel_bpf.sh b/samples/bpf/test_tunnel_bpf.sh
> index 4956589a83ae..1ff634f187b7 100755
> --- a/samples/bpf/test_tunnel_bpf.sh
> +++ b/samples/bpf/test_tunnel_bpf.sh
> @@ -9,15 +9,13 @@
>  # local 172.16.1.200 remote 172.16.1.100
>  # veth1 IP: 172.16.1.200, tunnel dev <type>11
>
> -set -e
> -
>  function config_device {
>         ip netns add at_ns0
>         ip link add veth0 type veth peer name veth1
>         ip link set veth0 netns at_ns0
>         ip netns exec at_ns0 ip addr add 172.16.1.100/24 dev veth0
>         ip netns exec at_ns0 ip link set dev veth0 up
> -       ip link set dev veth1 up
> +       ip link set dev veth1 up mtu 1500
>         ip addr add dev veth1 172.16.1.200/24
>  }
>
> @@ -67,6 +65,19 @@ function add_geneve_tunnel {
>         ip addr add dev $DEV 10.1.1.200/24
>  }
>
> +function add_ipip_tunnel {
> +       # in namespace
> +       ip netns exec at_ns0 \
> +               ip link add dev $DEV_NS type $TYPE local 172.16.1.100 remote 172.16.1.200
> +       ip netns exec at_ns0 ip link set dev $DEV_NS up
> +       ip netns exec at_ns0 ip addr add dev $DEV_NS 10.1.1.100/24
> +
> +       # out of namespace
> +       ip link add dev $DEV type $TYPE external
> +       ip link set dev $DEV up
> +       ip addr add dev $DEV 10.1.1.200/24
> +}
> +
>  function attach_bpf {
>         DEV=$1
>         SET_TUNNEL=$2
> @@ -85,6 +96,7 @@ function test_gre {
>         attach_bpf $DEV gre_set_tunnel gre_get_tunnel
>         ping -c 1 10.1.1.100
>         ip netns exec at_ns0 ping -c 1 10.1.1.200
> +       cleanup
>  }
>
>  function test_vxlan {
> @@ -96,6 +108,7 @@ function test_vxlan {
>         attach_bpf $DEV vxlan_set_tunnel vxlan_get_tunnel
>         ping -c 1 10.1.1.100
>         ip netns exec at_ns0 ping -c 1 10.1.1.200
> +       cleanup
>  }
>
>  function test_geneve {
> @@ -107,21 +120,48 @@ function test_geneve {
>         attach_bpf $DEV geneve_set_tunnel geneve_get_tunnel
>         ping -c 1 10.1.1.100
>         ip netns exec at_ns0 ping -c 1 10.1.1.200
> +       cleanup
> +}
> +
> +function test_ipip {
> +       TYPE=ipip
> +       DEV_NS=ipip00
> +       DEV=ipip11
> +       config_device
> +       tcpdump -nei veth1 &
> +       cat /sys/kernel/debug/tracing/trace_pipe &
> +       add_ipip_tunnel
> +       ethtool -K veth1 gso off gro off rx off tx off
> +       ip link set dev veth1 mtu 1500
> +       attach_bpf $DEV ipip_set_tunnel ipip_get_tunnel
> +       ping -c 1 10.1.1.100
> +       ip netns exec at_ns0 ping -c 1 10.1.1.200
> +       ip netns exec at_ns0 iperf -sD -p 5200 > /dev/null
> +       sleep 0.2
> +       iperf -c 10.1.1.100 -n 5k -p 5200
> +       cleanup
>  }
>
>  function cleanup {
> +       set +ex
> +       pkill iperf
>         ip netns delete at_ns0
>         ip link del veth1
> -       ip link del $DEV
> +       ip link del ipip11
> +       ip link del gretap11
> +       ip link del geneve11
> +       pkill tcpdump
> +       pkill cat
> +       set -ex
>  }
>
> +cleanup
>  echo "Testing GRE tunnel..."
>  test_gre
> -cleanup
>  echo "Testing VXLAN tunnel..."
>  test_vxlan
> -cleanup
>  echo "Testing GENEVE tunnel..."
>  test_geneve
> -cleanup
> -echo "Success"
> +echo "Testing IPIP tunnel..."
> +test_ipip
> +echo "*** PASS ***"
> --
> 2.8.0
>
