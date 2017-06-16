From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2] ip6_tunnel: Correct tos value in collect_md mode
Date: Fri, 16 Jun 2017 16:44:28 +0200
Message-ID: <5943EECC.3050809@iogearbox.net>
References: <1497493829-13050-1-git-send-email-yanhaishuang@cmss.chinamobile.com> <20170615135432.78442af5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Peter Dawson <petedaws@gmail.com>,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615135432.78442af5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/15/2017 05:54 AM, Peter Dawson wrote:
> On Thu, 15 Jun 2017 10:30:29 +0800
> Haishuang Yan <yanhaishuang@cmss.chinamobile.com> wrote:
>
>> Same as ip_gre, geneve and vxlan, use key->tos as tos value.
>>
>> CC: Peter Dawson <petedaws@gmail.com>
>> Fixes: 0e9a709560db ("ip6_tunnel, ip6_gre: fix setting of DSCP on
>> encapsulated packets”)
>> Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
>> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>>
>> ---
>> Changes since v2:
>>    * Add fixes information
>>    * mask key->tos with RT_TOS() suggested by Daniel
>> ---
>>   net/ipv6/ip6_tunnel.c | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
>> index ef99d59..6400726 100644
>> --- a/net/ipv6/ip6_tunnel.c
>> +++ b/net/ipv6/ip6_tunnel.c
>> @@ -1249,7 +1249,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
>>   		fl6.flowi6_proto = IPPROTO_IPIP;
>>   		fl6.daddr = key->u.ipv6.dst;
>>   		fl6.flowlabel = key->label;
>> -		dsfield = ip6_tclass(key->label);
>> +		dsfield =  RT_TOS(key->tos);
>>   	} else {
>>   		if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
>>   			encap_limit = t->parms.encap_limit;
>> @@ -1320,7 +1320,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
>>   		fl6.flowi6_proto = IPPROTO_IPV6;
>>   		fl6.daddr = key->u.ipv6.dst;
>>   		fl6.flowlabel = key->label;
>> -		dsfield = ip6_tclass(key->label);
>> +		dsfield = RT_TOS(key->tos);
>>   	} else {
>>   		offset = ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
>>   		/* ip6_tnl_parse_tlv_enc_lim() might have reallocated skb->head */
>
> I don't think it is correct to apply RT_TOS
>
> Here is my understanding based on the RFCs.
>
> IPv4/6 Header:0 |0 1 2 3 |0 1 2 3 |0 1 2 3 |0 1 2 3 |
> RFC2460(IPv6)   |Version | Traffic Class   |        |
> RFC2474(IPv6)   |Version | DSCP        |ECN|        |
> RFC2474(IPv4)   |Version |  IHL   |    DSCP     |ECN|
> RFC1349(IPv4)   |Version |  IHL   | PREC |  TOS   |X|
> RFC791 (IPv4)   |Version |  IHL   |      TOS        |
>
> u8 key->tos stores the full 8bits of Traffic class from an IPv6 header and;
> u8 key->tos stores the full 8bits of TOS(RFC791) from an IPv4 header
> u8 ip6_tclass will return the full 8bits of Traffic Class from an IPv6 flowlabel
>
> RT_TOS will return the RFC1349 4bit TOS field.
>
> Applying RT_TOS to a key->tos will result in lost information and the inclusion of 1 bit of ECN if the original field was a DSCP+ECN.
>
> Based on this understanding of the RFCs (but not years of experience) and since RFC1349 has been obsoleted by RFC2474 I think the use of RT_TOS should be deprecated.
>
> This being said, dsfield = ip6_tclass(key->label) = key->tos isn't fully correct either because the result will contain the ECN bits as well as the DSCP.
>
> I agree that code should be consistent, but not where there is a potential issue.

Yeah, you're right. Looks like initial dsfield = key->tos diff was
the better choice then, sorry for my confusing comment.

For example, bpf_skb_set_tunnel_key() helper that populates the collect
metadata as one user of this infra masks the key->label so that it really
only holds the label meaning previous dsfield = ip6_tclass(key->label)
will always be 0 in that case unlike key->tos that actually gets populated
and would propagate it.
