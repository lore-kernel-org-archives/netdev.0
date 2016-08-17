From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Wed, 17 Aug 2016 17:23:34 -0600
Message-ID: <15a6625f-e969-0c9d-e1fc-72d9361ebb32@cumulusnetworks.com>
References: <1471470587-24813-1-git-send-email-dsa@cumulusnetworks.com>
 <1471470587-24813-3-git-send-email-dsa@cumulusnetworks.com>
 <CAKgT0UeU+-jxnBr3H5P6ADzMH2Xv29atDrCyzngcOOEyqObUDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Simon Horman <simon.horman@netronome.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>, rshearma@brocade.com,
	Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	olivier.dugeon@orange.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36582 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210AbcHQXXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:23:37 -0400
Received: by mail-pa0-f46.google.com with SMTP id pp5so735178pac.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 16:23:37 -0700 (PDT)
In-Reply-To: <CAKgT0UeU+-jxnBr3H5P6ADzMH2Xv29atDrCyzngcOOEyqObUDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/17/16 5:16 PM, Alexander Duyck wrote:
>> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>> index 1ecbd7715f6d..6d78f162a88b 100644
>> --- a/net/openvswitch/actions.c
>> +++ b/net/openvswitch/actions.c
>> @@ -167,6 +167,12 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>>                 skb->mac_len);
>>         skb_reset_mac_header(skb);
>>
>> +       /* for GSO: set MPLS as network header and encapsulated protocol
>> +        * header as inner network header
>> +        */
>> +       skb_set_network_header(skb, skb->mac_len);
>> +       skb_set_inner_network_header(skb, skb->mac_len + MPLS_HLEN);
>> +
>>         new_mpls_lse = (__be32 *)skb_mpls_header(skb);
>>         *new_mpls_lse = mpls->mpls_lse;
>>
> 
> So the one question I would have about this is how attached are you to
> using the network_header to record the offset for the MPLS header?  I
> ask because I think from a hardware offloading perspective it would
> make it much easier if instead you used the inner_mac_header to
> represent the offset for the MPLS header.  This way device drivers
> could just skip over it like a VLAN and just use network and transport
> header values like they would otherwise.
> 

Where does the network_header relate to if I change the marker to inner_mac_header? Would it be skipped?

skb->protocol is set to MPLS.
mac_header points to ethernet address
network_header points to ???

inner protocol is set to what is encapsulated (e.g., ipv4 or ipv6)
inner_mac_header points to start of mpls label.
inner_network points to start of network header.

Is that sufficient for h/w drivers?
