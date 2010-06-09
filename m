From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
	external.
Date: Wed, 9 Jun 2010 17:54:02 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D791100848F9F@shsmsx502.ccr.corp.intel.com>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
 <20100606161348.427822fb@nehalam>
 <20100608052744.GA21547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32487 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755918Ab0FIJyI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 05:54:08 -0400
In-Reply-To: <20100608052744.GA21547@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Herbert Xu [mailto:herbert@gondor.apana.org.au]
>Sent: Tuesday, June 08, 2010 1:28 PM
>To: Stephen Hemminger
>Cc: Xin, Xiaohui; netdev@vger.kernel.org; kvm@vger.kernel.org;
>linux-kernel@vger.kernel.org; mst@redhat.com; mingo@elte.hu; davem@davemloft.net;
>jdike@linux.intel.com
>Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from external.
>
>On Sun, Jun 06, 2010 at 04:13:48PM -0700, Stephen Hemminger wrote:
>> Still not sure this is a good idea for a couple of reasons:
>>
>> 1. We already have lots of special cases with skb's (frags and fraglist),
>>    and skb's travel through a lot of different parts of the kernel.  So any
>>    new change like this creates lots of exposed points for new bugs. Look
>>    at cases like MD5 TCP and netfilter, and forwarding these SKB's to ipsec
>>    and ppp and ...
>>
>> 2. SKB's can have infinite lifetime in the kernel. If these buffers come from
>>    a fixed size pool in an external device, they can easily all get tied up
>>    if you have a slow listener. What happens then?
>
>I agree with Stephen on this.
>
>FWIW I don't think we even need the external pages concept in
>order to implement zero-copy receive (which I gather is the intent
>here).
>
>Here is one way to do it, simply construct a completely non-linear
>packet in the driver, as you would if you were using the GRO frags
>interface (grep for napi_gro_frags under drivers/net for examples).
>
I'm not sure if I understand your way correctly:
1) Does the way only deal with driver with SG feature? Since packet 
is non-linear...

2) Is skb->data still pointing to guest user buffers?
If yes, how to avoid the modifications to net core change to skb?

3) In our way only parts of drivers need be modified to support zero-copy.
and here, need we modify all the drivers?

If I missed your idea, may you explain it in more detail?

>This way you can transfer the entire contents of the packet without
>copying through to the other side, provided that the host stack does
>not modify the packet.
>

>If the host side did modify the packet then we have to incur the
>memory cost anyway.
>
>IOW I think the only feature provided by the external pages
>construct is allowing the skb->head area to be shared without
>copying.  I'm claiming that this can be done by simply making
>skb->head empty.
>
I think to make skb->head empty at first will cause more effort to pass the check with 
skb header. Have I missed something here? I really make the skb->head NULL
just before kfree(skb) in skb_release_data(), it's done by callback we have made for skb.

Thanks
Xiaohui

>Cheers,
>--
>Visit Openswan at http://www.openswan.org/
>Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
>Home Page: http://gondor.apana.org.au/~herbert/
>PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
