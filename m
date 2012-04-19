From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid expensive pskb_expand_head() calls
Date: Thu, 19 Apr 2012 10:48:46 -0700
Message-ID: <4F904FFE.60703@hp.com>
References: <1334653608.6226.11.camel@edumazet-laptop> <1334654187.2696.2.camel@jtkirshe-mobl> <4F8D93E1.9090000@intel.com> <1334681204.2472.41.camel@edumazet-glaptop> <1334698722.2472.71.camel@edumazet-glaptop> <1334764184.2472.299.camel@edumazet-glaptop> <CADVnQy=BkhSBHyN2hyBy=_H64oM8sJvyZZfEjK1x7PYzoLv=5w@mail.gmail.com> <1334776707.2472.316.camel@edumazet-glaptop> <1334778707.2472.333.camel@edumazet-glaptop> <alpine.DEB.2.00.1204191401240.735@wel-95.cs.helsinki.fi> <1334835018.2395.66.camel@edumazet-glaptop> <1334841481.2395.175.camel@edumazet-glaptop> <1334843527.2395.182.camel@edumazet-glaptop> <1334844652.2395.187.camel@edumazet-glaptop>  <4F904955.7070403@hp.com> <1334856306.2395.208.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	=?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:5443 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754435Ab2DSRst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 13:48:49 -0400
In-Reply-To: <1334856306.2395.208.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2012 10:25 AM, Eric Dumazet wrote:
> On Thu, 2012-04-19 at 10:20 -0700, Rick Jones wrote:
>
>> By copying them to smaller buffers? Or just by altering truesize?
>> Wasn't the whole point of fixing all the broken truesize settings to
>> accurately account for memory consumed?
>
> I checked, their truesize are OK (1024+256) for ixgbe driver.
> They could be little smaller, but not that much. (512 + 256)
>
> No, its only the sk_rcvbuf is small for a tcp sender,
> and sk_add_backlog() makes sure we dont queue more than sk_rcvbuf
> bytes in backlog.

Sounds like a variation on the theme of wildly divergent 
inbound/outbound bandwidth and constraining ACKs constraining throughput 
- only with buffer sizes.

87380 is the default SO_RCVBUF right?  That should have allowed 
87380/1280 or 68 ACKs to be queued.  Without ACK stretching from GRO 
that should have covered 68 * 2896 or 196928 bytes.  Based on your 
previous 54 usec to transmit 64 KB that would be 162+ usecs to 
accumulate those ACKs, so I guess a question becomes if TCP can be 
held-off processing ACKs for > 162 usecs, and if so and that cannot be 
changed, the autotuning will have to start increasing SO_SNDBUF 
alongside so_sndbuf even if the endpoint is not receiving.  As a 
handwave, since TCP does not know the buffer size(s) used by the driver, 
by 1 MSS for every 2 MSS it adds to SO_SNDBUF.  Or find some way to do 
it "on demand" in the about to drop path.

That or bare ACKs have to be excluded from the overhead checks somehow I 
guess, or there be more aggressive copying into smaller buffers.

Thankfully, when applications make explicit setsockopt() calls, they 
tend (ok, perhaps that is a bit of a guess) to set both SO_SNDBUF and 
SO_RCVBUF at the same time.

rick
