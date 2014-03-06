From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH] openvswitch: Orphan frags before sending to userspace
 via Netlink to avoid guest stall
Date: Thu, 6 Mar 2014 17:09:20 +0000
Message-ID: <5318ABC0.4040307@citrix.com>
References: <1393615016-9187-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kvm@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>, <pshelar@nicira.com>,
	<tgraf@redhat.com>, <dev@openvswitch.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393615016-9187-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do you have any feedback on this? I'm also adding KVM list as they might 
be interested in this.

Zoli

On 28/02/14 19:16, Zoltan Kiss wrote:
> The kernel datapath now switched to zerocopy Netlink messages, but that also
> means that the pages on frags array are sent straight to userspace. If those
> pages came outside the kernel, we have to swap them out with local copies.
>
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> ---
>   net/openvswitch/datapath.c |    6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 36f8872..ffb563c 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -464,6 +464,12 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
>   	}
>   	nla->nla_len = nla_attr_size(skb->len);
>
> +	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC))) {
> +		err = -ENOMEM;
> +		skb_tx_error(skb);
> +		goto out;
> +	}
> +
>   	skb_zerocopy(user_skb, skb, skb->len, hlen);
>
>   	/* Pad OVS_PACKET_ATTR_PACKET if linear copy was performed */
>
