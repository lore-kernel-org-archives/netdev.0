From: jamal <hadi@cyberus.ca>
Subject: Re: netif_rx packet dumping
Date: 03 Mar 2005 16:18:08 -0500
Message-ID: <1109884688.1090.282.camel@jzny.localdomain>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	 <20050303125556.6850cfe5.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, rhee@eos.ncsu.edu,
        jheffner@psc.edu, Yee-Ting.Li@nuim.ie, baruch@ev-en.org,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050303125556.6850cfe5.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-03 at 15:55, David S. Miller wrote:
> On Thu, 3 Mar 2005 12:38:11 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > The existing throttling algorithm causes all packets to be dumped
> > (until queue emptys) when the packet backlog reaches
> > netdev_max_backog. I suppose this is some kind of DoS prevention
> > mechanism. The problem is that this dumping action creates mulitple
> > packet loss that forces TCP back to slow start.
> > 
> > But, all this is really moot for the case of any reasonably high speed
> > device because of NAPI. netif_rx is not even used for any device that
> > uses NAPI.  The NAPI code path uses net_receive_skb and the receive
> > queue management is done by the receive scheduling (dev->quota) of the
> > rx_scheduler.
> 
> Even without NAPI, netif_rx() ends up using the quota etc. machanisms
> when the queue gets processed via process_backlog().
> 
> ksoftirqd should handle cpu starvation issues at a higher level.
> 
> I think it is therefore safe to remove the netif_max_backlog stuff
> altogether.  "300" is such a non-sense setting, especially for gigabit
> drivers which aren't using NAPI for whatever reason.  It's even low
> for a system with 2 100Mbit devices.

A couple of issues with this
- the rx softirq uses netif_max_backlog as a contraint on how long to
run before yielding. Could probably fix by having a different variable.
It may be fair to decouple those two in any case.
- if you dont put a restriction on how many netif_rx packets get queued
then it is more than likely you will run into an OOM case for non-NAPI
drivers under interupt overload. Could probably resolve this by
increasing the backlog size to several TCP window sizes (handwaving:
2?). What would be the optimal TCP window size in these big fat pipes
assuming real low RTT? 

I would say whoever is worried about this should use a NAPI driver;
otherwise you dont deserve that pipe!

cheers,
jamal
