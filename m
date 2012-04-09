From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Mon, 9 Apr 2012 10:39:54 +0300
Message-ID: <20120409073953.GD12014@redhat.com>
References: <20120408171323.GA16012@redhat.com>
 <20120408234951.GA15993@gondor.apana.org.au>
 <20120409072849.GA12014@redhat.com>
 <20120409073354.GA3218@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jason Wang <jasowang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120409073354.GA3218@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 09, 2012 at 03:33:54PM +0800, Herbert Xu wrote:
> On Mon, Apr 09, 2012 at 10:28:49AM +0300, Michael S. Tsirkin wrote:
> >
> > > 1) Doesn't this break local UDP push-back?
> > 
> > What is meant by UDP pushback here? Two tap
> > devices communicating by UDP packets locally?
> > This was always broken, see below.
> 
> I mean push-back from UDP transmission to the physical NIC.
> 
> Your patch breaks that

I think there's some misunderstanding. pushback is only disabled
for destinations that set IFF_TX_CAN_STALL. I expect that
no physical NICs set this flag - only tun and possibly
other userspace-controlled devices in the future.

> as now the guest will have no push-back
> whatsoever so anything that transmits UDP without protocol-level
> congestion control will start dropping most of their packets.
> 
> Granted you can argue that these apps are broken, but they do
> exist and we've always catered for them, both on baremetal and
> under virtualisation.
> > Thus we get this situation
> >     tap1 sends packets, some of them to tap2, tap2 does not consume them,
> >     as a result tap2 queue overflows, tap2 stops forever and
> >     packets get queued in the qdisc, now tap1
> >     send buffer gets full so it can not communicate to any destination.
> > 
> > So the problem is one VM can block all networking from another one.
> 
> This should be addressed in the backend, as it can distinguish
> between packets going out to physical and packets stuck going to
> a local VM.

Sorry I still have no clue what you call a backend.
Could you clarify please? All packets from a tun device
go to userspace.

>  In the latter case you can then duplicate and release
> the sender's memory.
> 
> Cheers,

The problem this patch is trying to address is tun device
can get stopped forever, which causes packets to
accumulate in qdisc again forever. So tun does not
get a chance to release sender's memory for these packets.

> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
