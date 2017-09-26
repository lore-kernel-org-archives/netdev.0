From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 0/7] nfp: flower vxlan tunnel offload
Date: Tue, 26 Sep 2017 12:15:09 +0200
Message-ID: <20170926121509.50a32571@griffin>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
        <CAJ3xEMgfRuD2Y-P2eTKmXpciiopA8js4zbO_nNOA6J62sn--mw@mail.gmail.com>
        <20170925170451.GD18763@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>,
        Paolo Abeni <pabeni@redhat.com>, Eli Cohen <eli@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52670 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935308AbdIZKPN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 06:15:13 -0400
In-Reply-To: <20170925170451.GD18763@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Sep 2017 19:04:53 +0200, Simon Horman wrote:
> The MAC addresses are extracted from the netdevs already loaded in the
> kernel and are monitored for any changes. The IP addresses are slightly
> different in that they are extracted from the rules themselves. We make the
> assumption that, if a packet is decapsulated at the end point and a match
> is attempted on the IP address,

You lost me here, I'm afraid. What do you mean by "match"?

> that this IP address should be recognised
> in the kernel. That being the case, the same traffic pattern should be
> witnessed if the skip_hw flag is applied.

Just to be really sure that this works correctly, can you confirm that
this will match the packet:

ip link add vxlan0 type vxlan dstport 4789 dev eth0 external
ip link set dev vxlan0 up
tc qdisc add dev vxlan0 ingress
ethtool -K eth0 hw-tc-offload on
tc filter add dev vxlan0 protocol ip parent ffff: flower enc_key_id 102 \
   enc_dst_port 4789 src_ip 3.4.5.6 skip_sw action [...]

while this one will NOT match:

ip link add vxlan0 type vxlan dstport 4789 dev eth0 external
ip link set dev vxlan0 up
tc qdisc add dev eth0 ingress
ethtool -K eth0 hw-tc-offload on
tc filter add dev eth0 protocol ip parent ffff: flower enc_key_id 102 \
   enc_dst_port 4789 src_ip 3.4.5.6 skip_sw action [...]

We found that with mlx5, the second one actually matches, too. Which is
a very serious bug. (Adding Paolo who found this. And adding a few more
Mellanox guys to be aware of the bug.)

 Jiri
