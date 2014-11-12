From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2] net: move vlan pop/push functions into
 common code
Date: Wed, 12 Nov 2014 12:59:33 +0100
Message-ID: <20141112115933.GD1882@nanopsycho.orion>
References: <1415700789-9171-1-git-send-email-jiri@resnulli.us>
 <CALnjE+qRASQx8pcaB7z9D3_x2ybA4h-Uh2Ppn9EJVG3YU8gSGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>, willemb@google.com,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	fw@strlen.de, Paul.Durrant@citrix.com, Thomas Graf <tgraf@suug.ch>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:59014 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507AbaKLL7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 06:59:36 -0500
Received: by mail-wg0-f50.google.com with SMTP id z12so13907135wgg.9
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 03:59:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALnjE+qRASQx8pcaB7z9D3_x2ybA4h-Uh2Ppn9EJVG3YU8gSGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 11, 2014 at 06:24:15PM CET, pshelar@nicira.com wrote:
>On Tue, Nov 11, 2014 at 2:13 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> So it can be used from out of openvswitch code.
>> Did couple of cosmetic changes on the way, namely variable naming and
>> adding support for 8021AD proto.
>>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  include/linux/skbuff.h    |  2 ++
>>  net/core/skbuff.c         | 86 +++++++++++++++++++++++++++++++++++++++++++++++
>>  net/openvswitch/actions.c | 76 ++---------------------------------------
>>  3 files changed, 90 insertions(+), 74 deletions(-)
>>
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 103fbe8..3b0445c 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -2673,6 +2673,8 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet);
>>  unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
>>  struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
>>  struct sk_buff *skb_vlan_untag(struct sk_buff *skb);
>> +int skb_vlan_pop(struct sk_buff *skb);
>> +int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
>>
>>  struct skb_checksum_ops {
>>         __wsum (*update)(const void *mem, int len, __wsum wsum);
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index 7001896..75e53d4 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -4151,6 +4151,92 @@ err_free:
>>  }
>>  EXPORT_SYMBOL(skb_vlan_untag);
>>
>> +/* remove VLAN header from packet and update csum accordingly. */
>> +static int __skb_vlan_pop(struct sk_buff *skb, u16 *vlan_tci)
>> +{
>> +       struct vlan_hdr *vhdr;
>> +       int err;
>> +
>> +       if (!pskb_may_pull(skb, VLAN_ETH_HLEN))
>> +               return -ENOMEM;
>> +
>> +       if (!skb_cloned(skb) || skb_clone_writable(skb, VLAN_ETH_HLEN))
>> +               return 0;
>> +
>> +       err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
>> +       if (unlikely(err))
>> +               return err;
>> +
>> +       if (skb->ip_summed == CHECKSUM_COMPLETE)
>> +               skb->csum = csum_sub(skb->csum, csum_partial(skb->data
>> +                                       + (2 * ETH_ALEN), VLAN_HLEN, 0));
>> +
>> +       vhdr = (struct vlan_hdr *)(skb->data + ETH_HLEN);
>> +       *vlan_tci = ntohs(vhdr->h_vlan_TCI);
>> +
>> +       memmove(skb->data + VLAN_HLEN, skb->data, 2 * ETH_ALEN);
>> +       __skb_pull(skb, VLAN_HLEN);
>> +
>> +       vlan_set_encap_proto(skb, vhdr);
>> +       skb->mac_header += VLAN_HLEN;
>> +       if (skb_network_offset(skb) < ETH_HLEN)
>> +               skb_set_network_header(skb, ETH_HLEN);
>> +       skb_reset_mac_len(skb);
>> +
>> +       return 0;
>> +}
>> +
>> +int skb_vlan_pop(struct sk_buff *skb)
>> +{
>> +       u16 vlan_tci;
>> +       __be16 vlan_proto;
>> +       int err;
>> +
>> +       if (likely(vlan_tx_tag_present(skb))) {
>> +               skb->vlan_tci = 0;
>> +       } else {
>> +               if (unlikely((skb->protocol != htons(ETH_P_8021Q) &&
>> +                             skb->protocol != htons(ETH_P_8021AD)) ||
>> +                            skb->len < VLAN_ETH_HLEN))
>> +                       return 0;
>> +
>> +               err = __skb_vlan_pop(skb, &vlan_tci);
>> +               if (err)
>> +                       return err;
>> +       }
>> +       /* move next vlan tag to hw accel tag */
>> +       if (likely((skb->protocol != htons(ETH_P_8021Q) &&
>> +                   skb->protocol != htons(ETH_P_8021AD)) ||
>> +                  skb->len < VLAN_ETH_HLEN))
>> +               return 0;
>> +
>> +       vlan_proto = skb->protocol;
>> +       err = __skb_vlan_pop(skb, &vlan_tci);
>> +       if (unlikely(err))
>> +               return err;
>> +
>> +       __vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
>> +       return 0;
>> +}
>> +EXPORT_SYMBOL(skb_vlan_pop);
>> +
>> +int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
>> +{
>> +       if (vlan_tx_tag_present(skb)) {
>> +               /* push down current VLAN tag */
>> +               if (!__vlan_put_tag(skb, skb->vlan_proto,
>> +                                   vlan_tx_tag_get(skb)))
>> +                       return -ENOMEM;
>> +
>Since you are restructuring this code, can you also change
>__vlan_put_tag() to not free skb on error. So that these two new
>functions can have common error handling code.

That is not directly related to this patchset. I believe that should be
changed in separate patch later on.
