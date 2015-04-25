From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v4 RFC 12/15] flow_dissector: introduce support
 for ipv6 addressses
Date: Sat, 25 Apr 2015 21:17:02 +0200
Message-ID: <20150425191702.GA2004@nanopsycho.orion>
References: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
 <1429890701-30052-13-git-send-email-jiri@resnulli.us>
 <CALx6S37xpnWTOQw3vivY5Ugn0BTkvxhNMhWnYABHD88cuZJ7Eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Thomas Graf <tgraf@suug.ch>, jesse@nicira.com, kaber@trash.net,
	Tom Herbert <therbert@google.com>, edumazet@google.com,
	alexander.h.duyck@redhat.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35606 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbbDYTRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 15:17:06 -0400
Received: by widdi4 with SMTP id di4so57082606wid.0
        for <netdev@vger.kernel.org>; Sat, 25 Apr 2015 12:17:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S37xpnWTOQw3vivY5Ugn0BTkvxhNMhWnYABHD88cuZJ7Eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 24, 2015 at 07:28:05PM CEST, tom@herbertland.com wrote:
>Hi Jiri,
>
>Thanks for this work, I think it's a good direction! Some comments below...
>
>On Fri, Apr 24, 2015 at 8:51 AM, Jiri Pirko <jiri@resnulli.us> wrote:

...

>>  enum flow_dissector_key_id {
>>         FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
>>         FLOW_DISSECTOR_KEY_IPV4_ADDRS, /* struct flow_dissector_key_addrs */
>>         FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS, /* struct flow_dissector_key_addrs */
>>         FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
>> +       FLOW_DISSECTOR_KEY_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
>>
>And we'll want to add VLAN ID, (GRE) key-id, IPv6 flow label, maybe a
>couple more.

Definitely. I plan to extend keys for those you mentioned and more in
future. Easy extendability is the goal of this patchset.
 

>
>>         FLOW_DISSECTOR_KEY_MAX,
>>  };
>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>> index 564288e..95e9a21 100644
>> --- a/net/core/flow_dissector.c
>> +++ b/net/core/flow_dissector.c
>> @@ -175,16 +175,29 @@ ipv6:
>>                 ip_proto = iph->nexthdr;
>>                 nhoff += sizeof(struct ipv6hdr);
>>
>> -               if (!skb_flow_dissector_uses_key(flow_dissector,
>> -                                                FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS))
>> -                       break;
>> -               key_addrs = skb_flow_dissector_target(flow_dissector,
>> -                                                     FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
>> -                                                     target_container);
>> +               if (skb_flow_dissector_uses_key(flow_dissector,
>> +                                               FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS)) {
>> +                       key_addrs = skb_flow_dissector_target(flow_dissector,
>> +                                                             FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
>> +                                                             target_container);
>>
>> -               key_addrs->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
>> -               key_addrs->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
>> +                       key_addrs->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
>> +                       key_addrs->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
>> +                       goto flow_label;
>> +               }
>
>So this is still folding the IPv6 addresses so that that we can fit
>into jhash_3words? Can we address this now and include the full IPv6
>address in the hash? I would propose that we extend the flow_keys
>structure (which I think you may already be doing) for full IPv6
>address, VLAN, flow label, etc., and then produce a hash across that
>whole structure. jhash2 can be used on a structure.  jhash is actually
>a very efficient hash performance wise-- the rest of flow dissection
>is likely the dominant cost anyway. We should also minimize calls to
>flow_dissector, I would propose it should be called at most once per
>packet-- I'll be reposting patches to fix that in the various qdiscs.

This hash computation is currently present in kernel. I just ported that
to new programable dissector framework.

I'm not sure how possible is the flow_keys structure extension. In this
patchset, I just maintain the current size and usage. But the thing is
that every individual caller of flow_dissect can use their own struct
which includes exactly what he needs.

Regarding the flow_dissect call reduction, I agree that it is something
we need. The question is how to pass the dissect results through the
code. For example, sch_choke uses qdisc_cb_private for passing flow_keys
struct. However qdisc_skb_cb can by only 20 bytes long (QDISC_CB_PRIV_LEN)
This can be however resolver independently of this patchset.
