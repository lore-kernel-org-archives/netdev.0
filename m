From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: netdev ioctl & dev_base_lock : bad idea ?
Date: Fri, 10 Dec 2004 09:14:35 +1100
Message-ID: <1102630475.22746.7.camel@gaston>
References: <1101458929.28048.9.camel@gaston>
	 <20041208220642.6984519f.davem@davemloft.net>
	 <1102573333.16495.2.camel@gaston>
	 <20041208231331.40cd98ad.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041208231331.40cd98ad.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-08 at 23:13 -0800, David S. Miller wrote:
> On Thu, 09 Dec 2004 17:22:13 +1100
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > Right, and I missed the fact that we did indeed take the semaphore and
> > not the lock in the _set_ functions which is just fine, we can actually
> > schedule.... except in set_multicast...
> > 
> > Is there any reason we actually _need_ to get the xmit lock in this one
> > specifically ?
> 
> Since we implement NETIF_F_LLTX, the core packet transmit routines do
> no locking, the driver does it all.
> 
> So if we don't hold the tx lock in the set multicast routine, any other
> cpu can come into our hard_start_xmit function and poke at the hardware.
> 
> Upon further consideration, it seems that it may be OK to drop that tx
> lock right after we do the netif_stop_queue().  But we should regrab
> the tx lock when we do the subsequent netif_wake_queue().

Yes. In fact, I think it should be driver local locking policy, and not
enforced by net/core/*.

For example, for things like USB based networking (or other "remote"
busses like that), it's both very useful to be able to schedule in
set_multicast, and there is no need for any synchronisation with the
xmit code.

For things like sungem, I already have a driver local lock that can be
used if necessary.

Also, the lack of ability  to schedule means we can't suspend and resume
NAPI polling, which basically forces us to take a lock in the NAPI poll
side of the driver... I'm aiming at limiting the amount of locks we take
in sungem along with moving as much as I can to task level so I can do a
bit better power management without having big u/mdelay's all over.
 
Also, why would we need the xmit lock when calling netif_wake_queue() ?
I'm not sure I get that one (but I'm not too familiar with the net core
neither).

Ben.
