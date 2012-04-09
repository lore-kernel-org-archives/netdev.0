From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Mon, 9 Apr 2012 15:33:54 +0800
Message-ID: <20120409073354.GA3218@gondor.apana.org.au>
References: <20120408171323.GA16012@redhat.com> <20120408234951.GA15993@gondor.apana.org.au> <20120409072849.GA12014@redhat.com>
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
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120409072849.GA12014@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 09, 2012 at 10:28:49AM +0300, Michael S. Tsirkin wrote:
>
> > 1) Doesn't this break local UDP push-back?
> 
> What is meant by UDP pushback here? Two tap
> devices communicating by UDP packets locally?
> This was always broken, see below.

I mean push-back from UDP transmission to the physical NIC.

Your patch breaks that as now the guest will have no push-back
whatsoever so anything that transmits UDP without protocol-level
congestion control will start dropping most of their packets.

Granted you can argue that these apps are broken, but they do
exist and we've always catered for them, both on baremetal and
under virtualisation.
 
> Thus we get this situation
>     tap1 sends packets, some of them to tap2, tap2 does not consume them,
>     as a result tap2 queue overflows, tap2 stops forever and
>     packets get queued in the qdisc, now tap1
>     send buffer gets full so it can not communicate to any destination.
> 
> So the problem is one VM can block all networking from another one.

This should be addressed in the backend, as it can distinguish
between packets going out to physical and packets stuck going to
a local VM.  In the latter case you can then duplicate and release
the sender's memory.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
