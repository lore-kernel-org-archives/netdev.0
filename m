From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 30 Sep 2014 23:12:14 -0700
Message-ID: <1412143934.16704.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411962607-27878-1-git-send-email-therbert@google.com>
	 <CAJ3xEMi-TRXevenx87UM7JnKqRQQATW4MBjbz8JdnQE9gk3KZw@mail.gmail.com>
	 <CA+mtBx8r05=qs2J58LFq56762tFB7wF4Dsr3C5TC9w5qQP5jGw@mail.gmail.com>
	 <CAJ3xEMhf6b75TQDFqEPMSXCpL9ToWG1q0OMPtrEuHNSm=-PSwQ@mail.gmail.com>
	 <CA+mtBx_6HcZh5Ys1FJFBXkZ2bWX1gP6bTcjY7gbR6RG_TOy50Q@mail.gmail.com>
	 <CAJ3xEMi0biCWTNtLOJ=0HWZYjOWi6pN2bw2=EWajp6XnpoyVRw@mail.gmail.com>
	 <CA+mtBx-sP6g9hXAYGfHKCPYkCtjgCFM0srueh1uhoNnC2ACr1g@mail.gmail.com>
	 <20140930143700.3dffac4d@urahara>
	 <CA+mtBx-wp5qNHGM0jG+2RjtXor3x1zJcSvZafz7kEKNEm4jYLA@mail.gmail.com>
	 <1412122719.16704.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Andy Zhou <azhou@nicira.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:47330 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbaJAGMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 02:12:14 -0400
Received: by mail-pd0-f179.google.com with SMTP id r10so183985pdi.10
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 23:12:14 -0700 (PDT)
In-Reply-To: <1412122719.16704.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 17:18 -0700, Eric Dumazet wrote:
> On Tue, 2014-09-30 at 17:05 -0700, Tom Herbert wrote:
> 
> > 
> > Will this still be an advantage with the burst TX implementation?
> 
> Segmenting a 64K packet into 45 sk_buff adds an additional 90
> allocations (45 sk_buff, 45 sk->head) and dirtying a _lot_ of memory.
> 
> We now have some helpers that might be used by drivers to perform TSO
> emulation.
> 
> commit e876f208af18b074f800656e4d1b99da75b2135f ("net: Add a software
> TSO helper API")
> 
> Check commit 3ae8f4e0b98b640aadf410c21185ccb6b5b02351 for reference
> ("net: mv643xx_eth: Implement software TSO")

BTW, even for NIC TSO capable, it seems TSO can be slower for small
packets (like 2 MSS packets) on some NICs at least...

In this case forcing segmentation can be a win (consumes more cpu
cycles, but reduce the stress on the NIC)

(Adding an extra check in netif_skb_features() would do as well, I
suppose)

+       if (skb_shinfo(skb)->gso_segs < skb->dev->gso_min_segs)
+               features &= ~NETIF_F_GSO_MASK;
 
