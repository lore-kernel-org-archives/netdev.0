From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] mlx4: optimize xmit path
Date: Sun, 28 Sep 2014 11:07:16 -0700
Message-ID: <CAMEtUuxwQ8k1wcT8U0VncnVoN=vZjU3zxswgjYPcQTLPw2pRwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:35168 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091AbaI1SHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 14:07:18 -0400
Received: by mail-la0-f53.google.com with SMTP id ty20so4377819lab.12
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 11:07:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 27, 2014 at 3:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> First I implemented skb->xmit_more support, and pktgen throughput
> went from ~5Mpps to ~10Mpps.
>
> Then, looking closely at this driver I found false sharing problems that
> should be addressed by this patch, as my pktgen now reaches 14.7 Mpps
> on a single TX queue, with a burst factor of 8.
>
> So this patch in a whole permits to improve raw performance on a single
> TX queue from about 5 Mpps to 14.7 Mpps.

this is great improvement!
Thank you for leading this effort.
10G line rate is definitely nice :)
Hopefully Or can demo similar numbers with 40G nic as well :)

> +       if (ring->bf_enabled && desc_size <= MAX_BF && !bounce &&
> +           !vlan_tx_tag_present(skb) && send_doorbell) {

feels something wrong here, since it checks for
send_doorbell, but iowrite() happens in the 'else' part
of this branch with another 'if (send_doorbell)'

The previous code seems equally confusing to me.

> +               tx_desc->ctrl.bf_qpn = ring->doorbell_qpn |
> +                                      cpu_to_be32(real_size);
>
>                 op_own |= htonl((bf_index & 0xffff) << 8);
> -               /* Ensure new descirptor hits memory
> -               * before setting ownership of this descriptor to HW */
> +               /* Ensure new descriptor hits memory
> +                * before setting ownership of this descriptor to HW
> +                */
>                 wmb();
>                 tx_desc->ctrl.owner_opcode = op_own;
>
>                 wmb();
>
> -               mlx4_bf_copy(ring->bf.reg + ring->bf.offset, (unsigned long *) &tx_desc->ctrl,
> -                    desc_size);
> +               mlx4_bf_copy(ring->bf.reg + ring->bf.offset,
> +                            &tx_desc->ctrl,
> +                            desc_size);
>
>                 wmb();
>
>                 ring->bf.offset ^= ring->bf.buf_size;
>         } else {
> -               /* Ensure new descirptor hits memory
> -               * before setting ownership of this descriptor to HW */
> +               tx_desc->ctrl.vlan_tag = cpu_to_be16(vlan_tag);
> +               tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN *
> +                       !!vlan_tx_tag_present(skb);
> +               tx_desc->ctrl.fence_size = real_size;
> +
> +               /* Ensure new descriptor hits memory
> +                * before setting ownership of this descriptor to HW
> +                */
>                 wmb();
>                 tx_desc->ctrl.owner_opcode = op_own;
> -               wmb();
> -               iowrite32be(ring->doorbell_qpn, ring->bf.uar->map + MLX4_SEND_DOORBELL);
> +
> +               if (send_doorbell) {
> +                       wmb(); /* ensure owner_opcode is written */
> +                       iowrite32(ring->doorbell_qpn,
> +                                 ring->bf.uar->map + MLX4_SEND_DOORBELL);
> +               }

shinfo, prefetch and access_once additions all look useful to me.

Thanks!
