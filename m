From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Wed, 17 Aug 2016 20:59:44 -0600
Message-ID: <18023723-58cc-cab5-21ad-14785e18c072@cumulusnetworks.com>
References: <1471470587-24813-1-git-send-email-dsa@cumulusnetworks.com>
 <1471470587-24813-3-git-send-email-dsa@cumulusnetworks.com>
 <CAKgT0UeU+-jxnBr3H5P6ADzMH2Xv29atDrCyzngcOOEyqObUDg@mail.gmail.com>
 <15a6625f-e969-0c9d-e1fc-72d9361ebb32@cumulusnetworks.com>
 <CAKgT0Ud6NJdVTQM0AiHVbhZTko9fnzyvrZ1juGRPrRFGC-5O-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Simon Horman <simon.horman@netronome.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>, rshearma@brocade.com,
	Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	olivier.dugeon@orange.com, roopa <roopa@cumulusnetworks.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33814 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480AbcHRC7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 22:59:47 -0400
Received: by mail-pa0-f43.google.com with SMTP id fi15so2164700pac.1
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 19:59:47 -0700 (PDT)
In-Reply-To: <CAKgT0Ud6NJdVTQM0AiHVbhZTko9fnzyvrZ1juGRPrRFGC-5O-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/17/16 7:06 PM, Alexander Duyck wrote:
> On Wed, Aug 17, 2016 at 4:23 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> On 8/17/16 5:16 PM, Alexander Duyck wrote:
>>>> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>>>> index 1ecbd7715f6d..6d78f162a88b 100644
>>>> --- a/net/openvswitch/actions.c
>>>> +++ b/net/openvswitch/actions.c
>>>> @@ -167,6 +167,12 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>>>>                 skb->mac_len);
>>>>         skb_reset_mac_header(skb);
>>>>
>>>> +       /* for GSO: set MPLS as network header and encapsulated protocol
>>>> +        * header as inner network header
>>>> +        */
>>>> +       skb_set_network_header(skb, skb->mac_len);
>>>> +       skb_set_inner_network_header(skb, skb->mac_len + MPLS_HLEN);
>>>> +
>>>>         new_mpls_lse = (__be32 *)skb_mpls_header(skb);
>>>>         *new_mpls_lse = mpls->mpls_lse;
>>>>
>>>
>>> So the one question I would have about this is how attached are you to
>>> using the network_header to record the offset for the MPLS header?  I
>>> ask because I think from a hardware offloading perspective it would
>>> make it much easier if instead you used the inner_mac_header to
>>> represent the offset for the MPLS header.  This way device drivers
>>> could just skip over it like a VLAN and just use network and transport
>>> header values like they would otherwise.
>>>
>>
>> Where does the network_header relate to if I change the marker to inner_mac_header? Would it be skipped?
> 
> No, the network header would still be the network header.

If core MPLS code (ie., non-OVS) does not do skb_reset_network_header(skb) after adding the MPLS label nothing works. Not even ping with small packets. tcpdump shows a completely mangled packet. Right now resetting the network_header to mpls is required.
