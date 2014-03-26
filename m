From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [ovs-dev] [patch net-next RFC v2 2/6] skbuff: add "missed_flow"
 flag
Date: Wed, 26 Mar 2014 18:25:01 +0100
Message-ID: <20140326172501.GI2869@minipsycho.orion>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <1395851472-10524-3-git-send-email-jiri@resnulli.us>
 <CAADnVQLJdNHx8bM2zy-cw5kKLK1GG3bLR=xZ=89AQA6fie4GxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	john.r.fastabend@intel.com, Eric Dumazet <edumazet@google.com>,
	andy@greyhouse.net, "dev@openvswitch.org" <dev@openvswitch.org>,
	f.fainelli@gmail.com, jeffrey.t.kirsher@intel.com,
	Or Gerlitz <ogerlitz@mellanox.com>, ben@decadent.org.uk,
	roopa@cumulusnetworks.com, jhs@mojatatu.com,
	linville@tuxdriver.com, vyasevic@redhat.com, nhorman@tuxdriver.com,
	sfeldma@cumulusnetworks.com, stephen@networkplumber.org,
	Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:55521 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaCZRZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 13:25:10 -0400
Received: by mail-ee0-f45.google.com with SMTP id d17so1932632eek.32
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 10:25:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAADnVQLJdNHx8bM2zy-cw5kKLK1GG3bLR=xZ=89AQA6fie4GxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 26, 2014 at 05:59:12PM CET, alexei.starovoitov@gmail.com wrote:
>On Wed, Mar 26, 2014 at 9:31 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> This flag sets incoming switch device in order to let know that the flow
>> which the skb is part of is missed. Listener may react to it
>> appropriately,
>>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  include/linux/filter.h |  1 +
>>  include/linux/skbuff.h | 13 +++++++++++++
>>  net/core/filter.c      |  3 +++
>>  3 files changed, 17 insertions(+)
>>
>> diff --git a/include/linux/filter.h b/include/linux/filter.h
>> index e568c8e..38c7c04 100644
>> --- a/include/linux/filter.h
>> +++ b/include/linux/filter.h
>> @@ -154,6 +154,7 @@ enum {
>>         BPF_S_ANC_VLAN_TAG,
>>         BPF_S_ANC_VLAN_TAG_PRESENT,
>>         BPF_S_ANC_PAY_OFFSET,
>> +       BPF_S_ANC_MISSED_FLOW,
>
>Interesting use case for bpf...
>looks like it's not connected to userspace.
>Are you trying to extend ovs with switchdev api and bpf at once?
>How do you plan to use this bpf extension?

The motive fot this is to provides a user (userspace app) possibility to
get all skbs which were "flow-missed". He can adjust the filter so that
only these can get through.



>
>Thanks
>Alexei
>
>>  };
>>
>>  #endif /* __LINUX_FILTER_H__ */
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 03db95a..0100c2f 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -567,6 +567,7 @@ struct sk_buff {
>>          * headers if needed
>>          */
>>         __u8                    encapsulation:1;
>> +       __u8                    missed_flow:1;
>>         /* 6/8 bit hole (depending on ndisc_nodetype presence) */
>>         kmemcheck_bitfield_end(flags2);
>>
>> @@ -2993,5 +2994,17 @@ static inline unsigned int skb_gso_network_seglen(const struct sk_buff *skb)
>>                                skb_network_header(skb);
>>         return hdr_len + skb_gso_transport_seglen(skb);
>>  }
>> +
>> +/**
>> + * skb_mark_missed_flow - marks skb as a part of missed flow
>> + * @skb: buffer
>> + *
>> + * Marks skb as a part of missed flow.
>> + */
>> +static inline void skb_mark_missed_flow(struct sk_buff *skb)
>> +{
>> +       skb->missed_flow = 1;
>> +}
>> +
>>  #endif /* __KERNEL__ */
>>  #endif /* _LINUX_SKBUFF_H */
>> diff --git a/net/core/filter.c b/net/core/filter.c
>> index ad30d62..048f11a 100644
>> --- a/net/core/filter.c
>> +++ b/net/core/filter.c
>> @@ -350,6 +350,9 @@ load_b:
>>                 case BPF_S_ANC_PAY_OFFSET:
>>                         A = __skb_get_poff(skb);
>>                         continue;
>> +               case BPF_S_ANC_MISSED_FLOW:
>> +                       A = !!skb->missed_flow;
>> +                       continue;
>>                 case BPF_S_ANC_NLATTR: {
>>                         struct nlattr *nla;
>>
>> --
>> 1.8.5.3
>>
>> _______________________________________________
>> dev mailing list
>> dev@openvswitch.org
>> http://openvswitch.org/mailman/listinfo/dev
