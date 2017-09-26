From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 0/7] nfp: flower vxlan tunnel offload
Date: Tue, 26 Sep 2017 15:41:37 +0300
Message-ID: <CAJ3xEMjEAhzC5=S7-dx8RiS=E7gYBBrtWY=9Cvqj-K3kyT9o3A@mail.gmail.com>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgfRuD2Y-P2eTKmXpciiopA8js4zbO_nNOA6J62sn--mw@mail.gmail.com>
 <20170925170451.GD18763@vergenet.net> <20170926121509.50a32571@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Paul Blakey <paulb@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34891 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936631AbdIZMlj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 08:41:39 -0400
Received: by mail-oi0-f68.google.com with SMTP id r20so6040817oie.2
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 05:41:38 -0700 (PDT)
In-Reply-To: <20170926121509.50a32571@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 1:15 PM, Jiri Benc <jbenc@redhat.com> wrote:
> On Mon, 25 Sep 2017 19:04:53 +0200, Simon Horman wrote:
>> The MAC addresses are extracted from the netdevs already loaded in the
>> kernel and are monitored for any changes. The IP addresses are slightly
>> different in that they are extracted from the rules themselves. We make the
>> assumption that, if a packet is decapsulated at the end point and a match
>> is attempted on the IP address,
>
> You lost me here, I'm afraid. What do you mean by "match"?
>
>> that this IP address should be recognised
>> in the kernel. That being the case, the same traffic pattern should be
>> witnessed if the skip_hw flag is applied.
>
> Just to be really sure that this works correctly, can you confirm that
> this will match the packet:
>
> ip link add vxlan0 type vxlan dstport 4789 dev eth0 external
> ip link set dev vxlan0 up
> tc qdisc add dev vxlan0 ingress
> ethtool -K eth0 hw-tc-offload on
> tc filter add dev vxlan0 protocol ip parent ffff: flower enc_key_id 102 \
>    enc_dst_port 4789 src_ip 3.4.5.6 skip_sw action [...]
>
> while this one will NOT match:

what do you exactly mean by "will not match"

> ip link add vxlan0 type vxlan dstport 4789 dev eth0 external
> ip link set dev vxlan0 up
> tc qdisc add dev eth0 ingress
> ethtool -K eth0 hw-tc-offload on
> tc filter add dev eth0 protocol ip parent ffff: flower enc_key_id 102 \
>    enc_dst_port 4789 src_ip 3.4.5.6 skip_sw action [...]

Please note that the way the rule is being set to the HW driver is by delegation
done in flower, see these commits (specifically "Add offload support
using egress Hardware device")

a6e1693 net/sched: cls_flower: Set the filter Hardware device for all use-cases
7091d8c net/sched: cls_flower: Add offload support using egress Hardware device
255cb30 net/sched: act_mirred: Add new tc_action_ops get_dev()

Since the egress port is not HW port netdev but rather SW virtual tunnel netdev
we have some logic in the kernel to delegate the rule programming to
HW via the HW netdev

OKay? if not, please elaborate

> We found that with mlx5, the second one actually matches, too. Which is
> a very serious bug. (Adding Paolo who found this. And adding a few more
> Mellanox guys to be aware of the bug.)

What is the bug in your view?

Or.
