From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: optimize xmit path
Date: Wed, 01 Oct 2014 21:35:24 -0700
Message-ID: <1412224524.16704.75.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
	 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMhQCf7j48Yn5sjH6jaYYdLQUgOe2hk-OZhhdZ7taOyx+Q@mail.gmail.com>
	 <1411853441.15768.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411964353.30721.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:53108 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbaJBEfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 00:35:08 -0400
Received: by mail-pa0-f44.google.com with SMTP id et14so1555170pad.17
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 21:35:06 -0700 (PDT)
In-Reply-To: <1411964353.30721.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-09-28 at 21:19 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>

...
> 6) mdev->mr.key stored in ring->mr_key to also avoid bswap() and access
>    to cold cache line.
>  


>  		ring->bf.offset ^= ring->bf.buf_size;
>  	} else {
> +		tx_desc->ctrl.vlan_tag = cpu_to_be16(vlan_tag);
> +		tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN *
> +			!!vlan_tx_tag_present(skb);
> +		tx_desc->ctrl.fence_size = real_size;
> +
>  		/* Ensure new descriptor hits memory
>  		 * before setting ownership of this descriptor to HW
>  		 */


Sorry, there is a missing replacement of 

	iowrite32be(ring->doorbell_qpn,
		    ring->bf.uar->map + MLX4_SEND_DOORBELL);

by iowrite32(ring->doorbell_qpn,
	     ring->bf.uar->map + MLX4_SEND_DOORBELL);

Since doorbel_qpn was changed to a __be32 and setup in
mlx4_en_activate_tx_ring()
