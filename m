From: Leigh Brown <leigh@solinno.co.uk>
Subject: Re: Spurious timeouts in mvmdio
Date: Tue, 03 Dec 2013 20:57:24 +0000
Message-ID: <abe249f5cba5c267e2c536bd62c57908@doppler.thel33t.co.uk>
References: <529CA42A.3040504@freebox.fr>
 <20131203122346.GD29282@titan.lakedaemon.net>
 <20131203124033.GT16735@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Nicolas Schichan <nschichan@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from doppler.thel33t.co.uk ([193.110.88.198]:48542 "EHLO
	doppler.thel33t.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755090Ab3LCUvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 15:51:03 -0500
In-Reply-To: <20131203124033.GT16735@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Russell and Nicolas,

Apologies for taking so long to respond to this thread.

On 2013-12-03 12:40, Russell King - ARM Linux wrote:
> On Tue, Dec 03, 2013 at 07:23:46AM -0500, Jason Cooper wrote:
>> On Mon, Dec 02, 2013 at 04:15:54PM +0100, Nicolas Schichan wrote:
[...]
>> 11:31 < shesselba> kos_tom: it is already using usecs_to_jiffies()
>> 11:31 < shesselba> the thing is: 1ms is less than a jiffy
> 
> Yes, and the kernels time conversion functions aren't stupid.  Let's
> look at this function's implementation:
> 
> unsigned long usecs_to_jiffies(const unsigned int u)
> {
>         if (u > jiffies_to_usecs(MAX_JIFFY_OFFSET))
>                 return MAX_JIFFY_OFFSET;
> #if HZ <= USEC_PER_SEC && !(USEC_PER_SEC % HZ)
>         return (u + (USEC_PER_SEC / HZ) - 1) / (USEC_PER_SEC / HZ);
> #elif HZ > USEC_PER_SEC && !(HZ % USEC_PER_SEC)
>         return u * (HZ / USEC_PER_SEC);
> #else
>         return (USEC_TO_HZ_MUL32 * u + USEC_TO_HZ_ADJ32)
>                 >> USEC_TO_HZ_SHR32;
> #endif
> }
> 
> Now, assuming HZ=100 and USEC_PER_SEC=1000000, we will use:
> 
> 	return (u + (USEC_PER_SEC / HZ) - 1) / (USEC_PER_SEC / HZ);
> 
> If you ask for 1us, this comes out as:
> 
> 	return (1 + (1000000 / 100) - 1) / (1000000 / 100);
> 
> which is one jiffy.  So, for a requested 1us period, you're given a
> 1 jiffy interval, or 10ms.  For other (sensible) values:
> 
>         return (USEC_TO_HZ_MUL32 * u + USEC_TO_HZ_ADJ32)
>                 >> USEC_TO_HZ_SHR32;
> 
> gets used, which has a similar behaviour.
> 
> Now, depending on how you use this one jiffy interval, the thing to 
> realise
> is that with this kind of loop:
> 
> 	timeout = jiffies + usecs_to_jiffies(1);
> 	do {
> 		something;
> 	} while (time_is_before_jiffies(timeout));
> 
> what this equates to is:
> 
> 	} while (jiffies - timeout < 0);

You've got that last line the wrong way round, but I understand what you 
are
getting at.

> What this means is that the loop breaks at jiffies = timeout, so it can
> indeed timeout before one tick - within 0 to 10ms for HZ=100.  The 
> problem
> is not the usecs_to_jiffies(), it's with the implementation.

> If you use time_is_before_eq_jiffies() instead, it will also loop if
> jiffies == timeout, which will give you the additional safety margin -
> meaning it will timeout after 10 to 20ms instead.

The code in question uses the logic in reverse so it *exits* if
time_is_before_jiffies(end) is true.  In other words it exits if 
"jiffies" is
greater than "end".  Since, as you say, usecs_to_jiffies(somevalue) will 
be a
minimum of 1, that means it will always loop at least twice.  So, I 
think it's
doing what you suggest, but in a different way, when polling.

> You may wish to consider coding this differently as well - if you have
> the error interrupt, there's no need for this loop.  You only need the
> loop if you're using usleep_range().  Note the return value of
> wait_event_timeout() will tell you positively and correctly if the 
> waited
> condition succeeded or you timed out.

Although the the wait_event_timeout is in the loop, it always exits due 
to
setting timedout to 1.  This was done to make the code smaller but I was
probably trying to be cleverer than I should have been.

So, given the above I believe the polling code is correct.  My mistake 
was to
assume that wait_event_timeout() guarantees a minimum of 1 jiffie wait.

Nicolas' patch should fix the issue, but I prefer the following as it is 
more
correct, as it only adjusts the timeout when calling 
wait_event_timeout().  As
I said above,I believe the polling code is correct.

diff --git a/drivers/net/ethernet/marvell/mvmdio.c 
b/drivers/net/ethernet/marvell/mvmdio.c
index 7354960..b187c08 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -92,6 +92,14 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
  			if (time_is_before_jiffies(end))
  				++timedout;
  	        } else {
+			/*
+			 * wait_event_timeout does not guarantee a delay of at
+			 * least one whole jiffie, so timeout must be no less
+			 * than two.
+			 */
+			if (timeout < 2)
+				timeout = 2;
+
  			wait_event_timeout(dev->smi_busy_wait,
  				           orion_mdio_smi_is_done(dev),
  				           timeout);

Nicolas - does the above also fix your issue?  I will also test it on my 
Dreamplug.

Apologies for causing this regression.

Regards,

Leigh.
