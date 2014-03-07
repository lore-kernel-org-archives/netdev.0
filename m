From: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: Orphan frags before sending to
 userspace via Netlink to avoid guest stall
Date: Fri, 07 Mar 2014 17:23:14 +0100
Message-ID: <5319F272.1070101@redhat.com>
References: <1393615016-9187-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
 pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1393615016-9187-1-git-send-email-zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 02/28/2014 08:16 PM, Zoltan Kiss wrote:
> The kernel datapath now switched to zerocopy Netlink messages, but that also
> means that the pages on frags array are sent straight to userspace. If those
> pages came outside the kernel, we have to swap them out with local copies.
>
> Signed-off-by: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
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

How about we move the call to skb_orphan_frags() into skb_zerocopy()
itself and call it before we actually reference the frags?

It's not just OVS affected but nfqueue as well.
