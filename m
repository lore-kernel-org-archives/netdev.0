From: "Jon Fraser" <J_Fraser@bit-net.com>
Subject: RE: [Question] SMP for Linux
Date: Fri, 18 Oct 2002 19:29:58 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000b01c276fe$46626720$3701020a@CONCORDIA>
References: <15792.13249.474279.391081@robur.slu.se>
Reply-To: <J_Fraser@bit-net.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Robert Olsson'" <Robert.Olsson@data.slu.se>
In-Reply-To: <15792.13249.474279.391081@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I ran some tests this afternoon. 
The setup is:

	2 x 1ghz PIII cpus w 256k cache
	2 intel 82542 gig-e cards

linux 2.4.20-pre11 kernel.
I don't have the NAPI e1000 driver.  I actually have
to ship a 2.4.18 based kernel, but decided to run some
tests on the 2.4.20 kernel.

The e1000 driver has been modified in a couple of ways.
The interrupts have been limited to 5k/second per card. This
mimics the actual hardware being shipped which uses an
intel 82543 chip but has an fpga used to do some
control functions and generate the interrupts.

We also don't use any transmit interrupts.  The Tx ring
is not cleaned at interrupt time.  It's cleaned when
we transmit frames and the number of free tx descriptors
drops below a threshold.  I also have some code which
directs the freed skb back to the cpu it was allocated on, 
but it's not in this driver version.

I used an ixia traffic generator to create the two udp flows.
Using the same terminology:
	bound = interrupts for both cards bound to one cpu
	float	= no smp affinity
	split = card 0 bound to cpu 0, card 1 bound to cpu 1

The results, in kpps:

                  bound   float   split
			cpu %    cpu%    cpu%
                -----------------------
1 flow           290     270     290
			99%x1	 65%x2   99%x1

2 flows          270     380     450
                 99%x1   82%x2  96%x2

Previously, I've used the CPU performance monitoring counters
to find that cache invalidates tends to be a big problem when
the interrupts are not bound to a pariticular cpu.  Bind the
card to a particular interrupt effectively binds the flow to
a particular cpu.


I'll repeat the same tests on Monday with 82543 based cards.
I would expect similar results.
Oh, I used top and vmstat to collect cpu percentages, interrupts/second,
etc., so they contribute a bit to the load.

	Jon


	
> 
> 
> Jon Fraser writes:
>  > 
>  > What was your cpu utilization like in the bound vs split scenarios?
>  
>  Not measured. Gonna take a look w. varient of Manfred's 
> loadtest when  
>  possible. But measuring the CPU this way also gives affects 
> throughput. 
>  Other softirq's are allowed to run as well now. :-)
> 
>  Over 1 Mpps was injected into eth0 so a good assumption is 
> that for UP 
>  all CPU is used but with SMP we might have some...
>  
>  > Does your e1000 driver have transmit interrupts enabled or 
> disabled?
>  
>  transmit?  
> 
>  > I'd be really interested to see the results with two flows 
> in opposite
>  > directions.
> 
>  Me too.
> 
>  Cheers.
> 						--ro
> 
> 
