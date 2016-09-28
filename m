From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net] net: skbuff: skb_vlan_push: Fix wrong unwinding
 of skb->data after __vlan_insert_tag call
Date: Wed, 28 Sep 2016 12:30:56 +0200
Message-ID: <57EB9BE0.4080903@iogearbox.net>
References: <1475053721-27676-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>,
        "David S. Miller" <davem@davemloft.net>,
        Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43341 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752116AbcI1KbB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 06:31:01 -0400
In-Reply-To: <1475053721-27676-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2016 11:08 AM, Shmulik Ladkani wrote:
> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
>
> In case 'skb_vlan_push' is called on an skb with a hw-accel vlan tag
> present, the existing hw-accel tag is inserted into the payload, and
> the new given tag is placed as new hw-accel tag.
>
> In order to insert the existing hw-accel tag, 'skb_vlan_push' adjusts
> the 'data' pointer at the mac_header (if needed), invokes __vlan_insert_tag,
> and finally re-adjusts 'data' back to its original position (according
> to the remembered "adjustment offset").
>
> However, successful '__vlan_insert_tag' pushes 4 more bytes at start of
> frame.
> Alas, the remembered "adjustment offset" is NOT fixed to account for
> these additional 4 bytes, so the subsequent '__skb_pull(skb, offset)'
> fails to unwind 'data' back to its original location.
>
> Since 'skb->mac_len' IS fixed to account for the additional 4 bytes
> (incremented to a total of 18 bytes), any access to
> 'skb->data - skb->mac_len' points to bytes PRIOR start of frame.
>
> This is problematic, as many constructs in the stack are issuing
> 'skb_push(skb, skb->mac_len)' prior xmit to a device (e.g tcf_mirred,
> tcf_bpf, nf_dup_netdev_egress), resulting in bogus frames being
> xmitted (having random 4 bytes at start of frame).
>
> For example:
>
>   # ip l add dev d0 type dummy
>   # tc filter add dev eth0 parent ffff: pref 1 basic \
>       action vlan push protocol 802.1ad id 5 pipe \
>       action mirred egress redirect dev d0
>
>   Any 802.1q (hw-accel) tagged frames arriving on eth0 are xmitted as
>   bogus frames on d0; whereas the expected behavior is having QinQ frames.
>
> Fix, by properly accouting the additionally pushed 4 bytes (in the case
> where an adjustment to point at mac_header was done).
>
> Fixes: 93515d53b1 ("net: move vlan pop/push functions into common code")
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Cc: Pravin Shelar <pshelar@ovn.org>
> Cc: Jiri Pirko <jiri@mellanox.com>
> ---
>   v2: Instead of reducing mac_len by 4 bytes, which was found incorrect,
>       fix the problem of wrong unwinding of 'skb->data'
>
>   David, if patch ok, suggest this goes to -stable
>
>   net/core/skbuff.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index d36c754..3926b79 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4608,6 +4608,8 @@ int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
>
>   		skb->protocol = skb->vlan_proto;
>   		skb->mac_len += VLAN_HLEN;
> +		if (offset)
> +			offset += VLAN_HLEN;
>
>   		skb_postpush_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
>   		__skb_pull(skb, offset);

This looks much better indeed than your v1 of this patch.

v1 would have definitely changed existing behavior for the cls_bpf/act_bpf
case. Both start at the beginning of mac header from ingress and egress side.
So when frame comes in on ingress, skb->data points to start of net header,
we then do __skb_push(skb, skb->mac_len) before running BPF prog, and after
return from BPF prog again __skb_pull(skb, skb->mac_len) to return to original
location. Thus in skb_vlan_push() from BPF helper call offset is always 0;
perhaps similar in ovs case.

With the removed skb->mac_len adjustment in skb_vlan_push() from your v1, we
would then have pointed into vlan header on return to stack instead of net
header location as we do currently.

So the issue might only be visible to act_vlan as the other remaining user of
skb_vlan_push(). Above fix looks better to me. So if we don't start at the
mac header yet, we need to do the __skb_push()/__skb_pull() adjustment from
there, and since we expand mac header, we need to take these 4 bytes into
account as well for returning to original location. My only question would
be: what about __skb_vlan_pop(), wouldn't that then need the same adjustment
a la offset -= VLAN_HLEN?

Thanks,
Daniel
