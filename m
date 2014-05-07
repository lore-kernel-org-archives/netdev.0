From: Octavian Purdila <octavian.purdila@intel.com>
Subject: Re: [RFC] tcp: add support for scheduling TCP options on TCP sockets
Date: Wed, 7 May 2014 17:04:36 +0300
Message-ID: <CAE1zotKWAcPfSPrXHfea_x_CMnsn_wVVQqY5L=aRQ84aspDHvw@mail.gmail.com>
References: <1399399524-28550-1-git-send-email-octavian.purdila@intel.com>
	<20140507.013820.1357850416047414291.davem@davemloft.net>
	<bc98535539ef4d2c9cb6f53f85068b65@UCL-MBX03.OASIS.UCLOUVAIN.BE>
	<20140507134620.GF4686@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:58105 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932352AbaEGOEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 10:04:38 -0400
Received: by mail-wi0-f180.google.com with SMTP id hi2so1396127wib.1
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 07:04:37 -0700 (PDT)
In-Reply-To: <20140507134620.GF4686@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 7, 2014 at 4:46 PM, Christoph Paasch
<christoph.paasch@uclouvain.be> wrote:
> Hello Octavian,
>
> On 07/05/14 - 07:30:23, Octavian Purdila wrote:
>> On Wed, May 7, 2014 at 8:38 AM, David Miller <davem@davemloft.net> wrote:
>> > Sorry I don't like this.
>> >
>> > Walking a linked list unnecessary is going to add overhead to every
>> > single packet transmission.  I think more people want our TCP stack to
>> > be fast (everyone) than those who want option processing to be
>> > abstracted enough to be modular (you).
>> >
>> > Just make the intrusive changes, they are necessary as they force you
>> > to think fully about how one option might interact with another.
>> >
>>
>> Unfortunately skb_tcp_cb does not have enough space to hold
>> information for new large options. To work around that, the MPTCP
>> implementation is pushing the option data in the skb and then
>> occasionally uses the following when the pskb_copy is used:
>>
>> -               else
>> +               if (unlikely(skb_cloned(skb))) {
>> +                       struct sk_buff *newskb;
>> +                       if (mptcp_is_data_seq(skb))
>> +                               skb_push(skb, MPTCP_SUB_LEN_DSS_ALIGN +
>> +                                             MPTCP_SUB_LEN_ACK_ALIGN +
>> +                                             MPTCP_SUB_LEN_SEQ_ALIGN);
>> +
>> +                       newskb = pskb_copy(skb, gfp_mask);
>> +
>> +                       if (mptcp_is_data_seq(skb)) {
>> +                               skb_pull(skb, MPTCP_SUB_LEN_DSS_ALIGN +
>> +                                             MPTCP_SUB_LEN_ACK_ALIGN +
>> +                                             MPTCP_SUB_LEN_SEQ_ALIGN);
>> +                               if (newskb)
>> +                                       skb_pull(newskb,
>> MPTCP_SUB_LEN_DSS_ALIGN +
>> +
>> MPTCP_SUB_LEN_ACK_ALIGN +
>> +
>> MPTCP_SUB_LEN_SEQ_ALIGN);
>> +                       }
>> +                       skb = newskb;
>> +               } else {
>>                         skb = skb_clone(skb, gfp_mask);
>> +               }
>>
>> MPTCP has many other intrusive changes in the TCP stack. To avoid that
>> complexity, we could do the bulk of the implementation in a separate
>> layer, on top of TCP. But we would need a mechanism to pass the
>> options down to the TCP layer somehow.
>
> Why not extend the head-space of the linear data of the skb as we discussed
> already previously on mptcp-dev? Just in a similar way as 'struct can_skb_priv'
> is being used. This would avoid this expensive list-processing and clean up
> the above example you give.
>
> Or did something else prevented to do it in such a way?
>

You mean storing options at skb->head? Wouldn't we have the same issue
as above for pskb_copy?
