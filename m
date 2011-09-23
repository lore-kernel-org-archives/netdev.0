From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH net-next v2] candev: allow SJW user setting for bittiming
	calculation
Date: Fri, 23 Sep 2011 17:50:24 +0200
Message-ID: <4E7CAAC0.7030604@hartkopp.net>
References: <4E7B0DE6.9020807@hartkopp.net> <4E7B8F63.6060108@hartkopp.net>
	<4E7C3424.8030406@grandegger.com>
	<201109231132.49976.pisa@cmp.felk.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Pavel Pisa <pisa-/N2ztlQkxE7Ub/6JBqosbQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201109231132.49976.pisa-/N2ztlQkxE7Ub/6JBqosbQ@public.gmane.org>
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

Hello Pavel, hello Wolfgang,

thanks for the detailed feedback!

Trying to summarize the text for me, i see these relevant topics (in my
probably limited view):

On 09/23/11 11:32, Pavel Pisa wrote:

> On Friday 23 September 2011 09:24:20 Wolfgang Grandegger wrote:
>> Then let us set it to 4 (maximum), by default. But other documents
>> recommend a value of 1.


Putting the SJW to it's max value by default - which is then reduced by tseg2
is obviously bad (see below). SJW = 1 should stay the default value.

(..)

> 6) If the clock frequencies of all nodes CAN controllers

> are guaranteed to be same, then no more synchronization
> is necessary during message Tx/Rx (SJW=0). But that assumption
> does not hold. That is why bitstuffing is used and guarantees
> that there is at least one logic level transition (edge)
> after each 6 bit time.


Ah - i see.

(..)


> I expect that for reasonable precise setup of bitrate
> when exact ratio is found and crystal based oscillators
> there is the best option small SJW i.e. 1 or for very
> fast TQ clock equivalent of 1% - 2% of bittime.


Which already was the default.

> For nonexact ratio or low quality clocks sources,
> bigger SJW values make sense. But big value has other
> disadvantage. If there is bigger jitter in Tx/Rx delays
> or clocks then it is propagated back to bit timing
> and stability of system composed from multiple nodes
> could be questionable. There is even bigger interval
> where noise pulse could cause lost of the synchronization.
> 
> On base of above analysis, I think that blindly set SJW
> on maximum is not good idea. It should be at least limited
> to 5% of bit time.


Ok.

 
> Because bit timing calculation is not what everybody
> want to do again and again, the actual code tries
> to hide differences of CAN controllers and provide
> at least partially understandable knobs to user
> with parameters independent on concrete setup low level
> details to allow set bitrate for usual Joe user.


Yes - like me ;-)

> The basic parameters are chosen such way, that user need
> not to care about actual TQ clock and selecting prescaller,
> that is why sampling point is in percent of bittime.


Btw. defining a sampling point other than CAN CIA recommendations could be
seen as a user specific requirement that is nothing for user Joe too.


> SJW is more problematic, but may it be use of 2 or 5%
> of bittime by default with assurance that zero is
> replaced by one, would serve to most people pleasure.
> May it be, that 0.1 of percent should be used as unit
> for external parameter too.


And then you would like to calculate the SJW based on this percent value? I'm
a bit concerned about this additional complexity (see below).

> I hope that actual calculation works reasonably well.

Yes, it does.

> But if it should be enhanced, then it would worth

> to add additional parameter except crystal/controller
> clock source freqency to the concrete boards drivers.
> It should be measured round-trip delay of given/used
> transceiver/optocouplers combination. This would
> allow to have sampling point setup yet more independent
> on given HW and same value could be used for different
> bitrates. But there is still unknown parameter
> capacity/length of connected wires so there is still
> something left to user consideration.


As i remember from the discussions for the existing algorithm the complexity
is already high enough, so that adding these new details may lead to new
problems (in kernel space), we do not see so far. I think, if someone want's
to go THAT deep the already existing 'expert mode' with the time-quanta based
setting of the bitrate is the right choice.

The in-kernel bittiming calculation is the best approach for user Joe as you
already pointed out. Besides the sampling point (which has a impact on the
bittiming calculation) the tuning of the SJW value would be a second feature
for 'advanced' users that can be modified from the outside.

As we still preserve the reasonable default of SJW=1, adding a new SJW option
to tune just only the resulting SJW value looks risk-free to me.

(..)

>> Anyway, if SJW does not depend on other bit-timing parameters and it
>> usually works fine with the kernel calculated parameters I would no
>> longer vote against this patch.


That's nice. Your Acked-by would be great.

I would provide a patch for the 'ip' tools help text then. Fortunately there
is no code change necessary in iplink_can.c and this functionality can be used
with all iproute2 versions if the kernel supports it. And if not, it's really
easy to patch ;-)

Many thanks,
Oliver
