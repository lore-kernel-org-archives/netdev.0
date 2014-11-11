From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2] net: move vlan pop/push functions into
 common code
Date: Tue, 11 Nov 2014 16:00:16 +0100
Message-ID: <20141111150016.GD1825@nanopsycho.lan>
References: <1415700789-9171-1-git-send-email-jiri@resnulli.us>
 <1415711181.9613.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	pshelar@nicira.com, therbert@google.com, edumazet@google.com,
	willemb@google.com, dborkman@redhat.com, mst@redhat.com,
	fw@strlen.de, Paul.Durrant@citrix.com, tgraf@suug.ch
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:63796 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbaKKPAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 10:00:19 -0500
Received: by mail-wg0-f53.google.com with SMTP id b13so11845244wgh.26
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 07:00:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1415711181.9613.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 11, 2014 at 02:06:21PM CET, eric.dumazet@gmail.com wrote:
>On Tue, 2014-11-11 at 11:13 +0100, Jiri Pirko wrote:
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
>>  	__wsum (*update)(const void *mem, int len, __wsum wsum);
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
>> +	struct vlan_hdr *vhdr;
>> +	int err;
>> +
>
>
>
>> +	if (!pskb_may_pull(skb, VLAN_ETH_HLEN))
>> +		return -ENOMEM;
>> +
>> +	if (!skb_cloned(skb) || skb_clone_writable(skb, VLAN_ETH_HLEN))
>> +		return 0;
>> +
>> +	err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
>> +	if (unlikely(err))
>> +		return err;
>
>All this should be a function of its own (OVS calls this
>make_writable()).
>
>Its too bad netfilter has a different skb_make_writable()

How different is that? Looking at it it seems it is doing the same
thing. Not sure though...

>
>
>> +
>> +	if (skb->ip_summed == CHECKSUM_COMPLETE)
>> +		skb->csum = csum_sub(skb->csum, csum_partial(skb->data
>> +					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
>
>This looks like skb_postpull_rcsum()
>
>BTW, calling csum_partial() for 4 bytes is quite expensive.
>
>
>
