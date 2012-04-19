From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid expensive pskb_expand_head()
 calls
Date: Thu, 19 Apr 2012 20:00:36 +0200
Message-ID: <1334858436.2395.212.camel@edumazet-glaptop>
References: <1334653608.6226.11.camel@edumazet-laptop>
	 <1334654187.2696.2.camel@jtkirshe-mobl> <4F8D93E1.9090000@intel.com>
	 <1334681204.2472.41.camel@edumazet-glaptop>
	 <1334698722.2472.71.camel@edumazet-glaptop>
	 <1334764184.2472.299.camel@edumazet-glaptop>
	 <CADVnQy=BkhSBHyN2hyBy=_H64oM8sJvyZZfEjK1x7PYzoLv=5w@mail.gmail.com>
	 <1334776707.2472.316.camel@edumazet-glaptop>
	 <1334778707.2472.333.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1204191401240.735@wel-95.cs.helsinki.fi>
	 <1334835018.2395.66.camel@edumazet-glaptop>
	 <1334841481.2395.175.camel@edumazet-glaptop>
	 <1334843527.2395.182.camel@edumazet-glaptop>
	 <1334844652.2395.187.camel@edumazet-glaptop>  <4F904955.7070403@hp.com>
	 <1334856306.2395.208.camel@edumazet-glaptop>  <4F904FFE.60703@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:62441 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155Ab2DSSAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 14:00:45 -0400
Received: by eaaq12 with SMTP id q12so2288368eaa.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 11:00:44 -0700 (PDT)
In-Reply-To: <4F904FFE.60703@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 10:48 -0700, Rick Jones wrote:
> On 04/19/2012 10:25 AM, Eric Dumazet wrote:
> > On Thu, 2012-04-19 at 10:20 -0700, Rick Jones wrote:
> >
> >> By copying them to smaller buffers? Or just by altering truesize?
> >> Wasn't the whole point of fixing all the broken truesize settings to
> >> accurately account for memory consumed?
> >
> > I checked, their truesize are OK (1024+256) for ixgbe driver.
> > They could be little smaller, but not that much. (512 + 256)
> >
> > No, its only the sk_rcvbuf is small for a tcp sender,
> > and sk_add_backlog() makes sure we dont queue more than sk_rcvbuf
> > bytes in backlog.
> 
> Sounds like a variation on the theme of wildly divergent 
> inbound/outbound bandwidth and constraining ACKs constraining throughput 
> - only with buffer sizes.
> 
> 87380 is the default SO_RCVBUF right?  That should have allowed 
> 87380/1280 or 68 ACKs to be queued.  Without ACK stretching from GRO 
> that should have covered 68 * 2896 or 196928 bytes.  Based on your 
> previous 54 usec to transmit 64 KB that would be 162+ usecs to 
> accumulate those ACKs, so I guess a question becomes if TCP can be 
> held-off processing ACKs for > 162 usecs, and if so and that cannot be 
> changed, the autotuning will have to start increasing SO_SNDBUF 
> alongside so_sndbuf even if the endpoint is not receiving.  As a 
> handwave, since TCP does not know the buffer size(s) used by the driver, 
> by 1 MSS for every 2 MSS it adds to SO_SNDBUF.  Or find some way to do 
> it "on demand" in the about to drop path.
> 
> That or bare ACKs have to be excluded from the overhead checks somehow I 
> guess, or there be more aggressive copying into smaller buffers.
> 

Nope, we need a limit or risk OOM if a malicious peer send ACK flood ;)

To be clear, if I change the tcp_rmem[1] from 87380 to big value, I no
longer have ACK drops, but still poor performance, I am still
investigating.
