From: Thayne Harbaugh <tharbaugh@lnxi.com>
Subject: Re: abysmal e1000 performance (DITR)
Date: Mon, 07 Jun 2004 11:59:52 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086631191.5220.15.camel@tubarao>
References: <1085700138.30156.1322.camel@tubarao>
	 <16580.33370.535347.85788@robur.slu.se>
Reply-To: tharbaugh@lnxi.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16580.33370.535347.85788@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-06-07 at 08:57, Robert Olsson wrote:
> Thayne Harbaugh writes:
> 
>  > This is a patch to include system load when calculating 
>  > the DITR.  It only allows the diff/goc ratio to factor
>  > into the DITR when the 1 minute load average is above .50.
>  > It appears to work quite well and prevents throttling
>  > when the load is below .50 and allows throttling when the
>  > load is in excess of .50.
> 
>  Hello!
> 
>  The experience we had from decorrelating network traffic for use with
> variable interrupt delays etc was that no average based scheme worked
> at the packet resolution we wanted. 

That is absolutely a problem.  The instantaneous load isn't available. 
Because one minute resolution is the lowest granularity then there is
some delay between heavy load and the interrupts being reduced.  This
could be improved by using the derivative of the one-minute load
average, but then the formula starts getting messy and difficult to
follow.  For now, the delay is acceptable with respect to having the
DITR influenced by the load.

>  The only useful measure we found was using the number of packets
> received on the RX-ring. You see this used in tulip driver to get a
> dynamic RX interrupt delay. 

That, however, is exactly the problem.  When only the packets are
considered then interrupts are throttled even when the system can handle
the extra load of heavy interrupts.  When the interrupts are
unnecessarily throttled without considering the system load then network
throughput is greatly reduced - even though the system is mostly idle. 
That approach is too naive for balanced performance between network
throughput and application processing.

In the end, I thing that DITR should be disabled in favor of NAPI which
has a similar goal and is more general.

FWIW, I haven't looked through the tulip driver.  Thanks for the pointer
- I'll go have a peek.

-- 
Thayne Harbaugh
Linux Networx
