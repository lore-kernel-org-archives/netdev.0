From: Pavel Pisa <pisa-/N2ztlQkxE7Ub/6JBqosbQ@public.gmane.org>
Subject: Re: [PATCH net-next v2] candev: allow SJW user setting for bittiming
	calculation
Date: Fri, 23 Sep 2011 11:32:49 +0200
Message-ID: <201109231132.49976.pisa@cmp.felk.cvut.cz>
References: <4E7B0DE6.9020807@hartkopp.net> <4E7B8F63.6060108@hartkopp.net>
	<4E7C3424.8030406@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4E7C3424.8030406-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Oliver and Wolfgang,

On Friday 23 September 2011 09:24:20 Wolfgang Grandegger wrote:
> Hi Oliver,
>
> On 09/22/2011 09:41 PM, Oliver Hartkopp wrote:
> Then let us set it to 4 (maximum), by default. But other documents
> recommend a value of 1.

I am not expert for CAN timing nor I have time to go through
documentation at this moment. But I hope that I have some
sense/experience  for electronic and dynamic systems
and we have done more designs utilizing CAN at university
and at our company.

So there are some thought about SJW based on my experience.
There could be some inaccuracies, if you want better
analysis, I need time for that.

1) The CAN needs fast local roundrip time for correct operation
of dominant/recessive arbitration.
The time is sum of propagation from CAN controller chip,
propagation delay of optocoupler or other galvanic isolation,
slew rate and delay in Tx circuitry of transceiver, charging
the wire, Rx part of receiver, optocoupler, controller
Rx filtering and Rx,Tx logic level comparator.
Iw we count necessity to synchronize this between multiple
CAN nodes then whole roundtrip time has to be smaller than
50-80% of single bit bit time quantum.

2) From the noise and stabilization of voltage on the wire
the sampling point should be in the middle of bit pulse
delayed by round-trip delay from 1. This is 50% of bit
time (i.e. dependent on bitrate) + round trip delay (dependent
on delay in controller and concrete board circuitry).

3) But sampling point has to allow to decide about collision
before next bit Tx is started => it cannot be moved after
end of the given Tx bit time interval.

4) It is necessary to synchronize bit timing in all
CAN controllers during arbitration (ID sending) phase.
The first sync is done after receiving of the first
edge on the wire. It can be other node start of Tx
or our own Tx dominant level. Controller shifts its Tx
timing such way, that start of the next Tx bit interval
should result in Rx transition at the end the sensed
Rx bit. I.e. it counts only TSEG2 til next bit start.

5) There are some more things to consider if triple
sampling and filtering is enabled to suppress noise
on wire. It can be used only, if time quantum clocks
are fast enough to fit this sampling interval between
stabilization of delayed Rx logic level and end of Tx bit
time interval.

6) If the clock frequencies of all nodes CAN controllers
are guaranteed to be same, then no more synchronization
is necessary during message Tx/Rx (SJW=0). But that assumption
does not hold. That is why bitstuffing is used and guarantees
that there is at least one logic level transition (edge)
after each 6 bit time. If there is zero roundtrip propagation
delay and sampling in 50% of bit time interval then
maximal skew/frequency difference of the clocks could be

  (1+1/6*50%) - 1 i.e. 8%

This means, that SJW bigger than 8% of whole bit time
would not help to synchronize bitrate difference, because
for such case setup cannot work anyway. Propagation delay
is not zero then there is even less time left for sampling
point shift which would not cause incorrect bit data
detection so reasonable maximum is probably lower.

I expect that for reasonable precise setup of bitrate
when exact ratio is found and crystal based oscillators
there is the best option small SJW i.e. 1 or for very
fast TQ clock equivalent of 1% - 2% of bittime.
For nonexact ratio or low quality clocks sources,
bigger SJW values make sense. But big value has other
disadvantage. If there is bigger jitter in Tx/Rx delays
or clocks then it is propagated back to bit timing
and stability of system composed from multiple nodes
could be questionable. There is even bigger interval
where noise pulse could cause lost of the synchronization.

On base of above analysis, I think that blindly set SJW
on maximum is not good idea. It should be at least limited
to 5% of bit time. 

Because bit timing calculation is not what everybody
want to do again and again, the actual code tries
to hide differences of CAN controllers and provide
at least partially understandable knobs to user
with parameters independent on concrete setup low level
details to allow set bitrate for usual Joe user.
The basic parameters are chosen such way, that user need
not to care about actual TQ clock and selecting prescaller,
that is why sampling point is in percent of bittime.
SJW is more problematic, but may it be use of 2 or 5%
of bittime by default with assurance that zero is
replaced by one, would serve to most people pleasure.
May it be, that 0.1 of percent should be used as unit
for external parameter too.

I hope that actual calculation works reasonably well.
But if it should be enhanced, then it would worth
to add additional parameter except crystal/controller
clock source freqency to the concrete boards drivers.
It should be measured round-trip delay of given/used
transceiver/optocouplers combination. This would
allow to have sampling point setup yet more independent
on given HW and same value could be used for different
bitrates. But there is still unknown parameter
capacity/length of connected wires so there is still
something left to user consideration.

Best wishes,


                Pavel Pisa
    e-mail:     pisa-/N2ztlQkxE7Ub/6JBqosbQ@public.gmane.org
    www:        http://cmp.felk.cvut.cz/~pisa
    university: http://dce.fel.cvut.cz/
    company:    http://www.pikron.com/


> > possible. And if an expert told me so and i had a simple config interface
> > to fullfill it, it would be great for me ;-)
>
> Anyway, if SJW does not depend on other bit-timing parameters and it
> usually works fine with the kernel calculated parameters I would no
> longer vote against this patch.
>
> Wolfgang,
