From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net-next] pppoe: optional deactivation of PADT packet
 handling
Date: Wed, 16 Dec 2015 16:39:17 +0100
Message-ID: <20151216153917.GJ18510@alphalink.fr>
References: <712ac4d53ca9fb8621164a1b72c74eae8c8529aa.1450194732.git.g.nault@alphalink.fr>
 <1450198205.3851.6.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1450198205.3851.6.camel@redhat.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 15, 2015 at 10:50:05AM -0600, Dan Williams wrote:
> On Tue, 2015-12-15 at 17:06 +0100, Guillaume Nault wrote:
> > Kernel space shouldn't handle PADT packets since PADT belongs to
> > PPPoE's control plane.
> > With "handle_padt" module option, user space can now decide to avoid
> > kernel interpretation of PADT packets and be responsible for session
> > disconnection.
> 
> In general, module options like this kinda suck.  How about a new PPPoE
> ioctl so the option can be toggled for a given socket/session instead? 
>  Then at least you're not locked into a specific PPPoE implementation
> for all sessions on the machine.
> 
I've considered this approach too, but by using per session option,
we still have to register pppoed_ptype in pppoe_init() and thus call
pppoe_disc_recv() for any ETH_P_PPP_DISC frame, just in case a session
needs kernel space PADT handling. This makes the approach much less
interesting IMO, hence the original choice for module wide behaviour.
On the other hand, I understand the need for minimising module options.

Thinking a bit more about it, we could drop dev_add_pack() from
pppoe_init() and let pppoe_connect() register ETH_P_PPP_DISC when
necessary. We could even do it per device, as pppoe_connect() knows the
lower device.
The problem is to know when unregistering ETH_P_PPP_DISC. We could
probably use a reference counter, but I'd prefer to avoid complicating
pppoe's connection and disconnection code given that recent history
has shown its relative fragility.
