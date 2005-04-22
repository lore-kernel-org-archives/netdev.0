From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI, e100, and system performance problem
Date: Fri, 22 Apr 2005 15:01:27 -0400
Message-ID: <1114196487.7978.65.camel@localhost.localdomain>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	 <Pine.LNX.4.61.0504180943290.15052@linux.site>
	 <1113855967.7436.39.camel@localhost.localdomain>
	 <20050419055535.GA12211@sgi.com> <m1hdhzyrdz.fsf@muc.de>
	 <1114173195.7679.30.camel@localhost.localdomain>
	 <20050422172108.GA10598@muc.de>
	 <1114193902.7978.39.camel@localhost.localdomain>
	 <20050422183004.GC10598@muc.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg Banks <gnb@sgi.com>, Arthur Kepner <akepner@sgi.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050422183004.GC10598@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-22-04 at 20:30 +0200, Andi Kleen wrote:
> On Fri, Apr 22, 2005 at 02:18:22PM -0400, jamal wrote:
> > On Fri, 2005-22-04 at 19:21 +0200, Andi Kleen wrote:

> > Why do they run slower? There could be 1000 other variables involved?
> > What is it that makes you so sure it is NAPI?
> > I know you are capable of proving it is NAPI - please do so.
> 
> We tested back then by downgrading to an older non NAPI tg3 driver
> and it made the problem go away :) The broadcom bcm57xx driver which
> did not support NAPI at this time was also much faster.
> 

Dont mean to make this into a meaningless debate - but have you thought
of the fact maybe it could be a driver bug in case of NAPI?
The e1000 NAPI had a serious bug since day one that was only recently
fixed (I think Robert provided the fix - but the intel folks made the
release).
  
> > It would be helpful if you use new kernels of course - that reduces the
> > number of variables to look at. 
> 
> It was customers who use certified SLES kernels.

That makes it hard.
You understand that there could be other issues - thats why its safer to
just ask for latest kernel.

> > There is only one complaint I have ever heard about NAPI and it is about
> > low rates: It consumes more CPU at very low rates. Very low rates
> 
> It was not only more CPU usage, but actually slower network performance
> on systems with plenty of CPU power.
> 

This is definetely a new thing nobody has mentioned before.
Whatever difference there is would not be that much.

> Also I doubt the workload Jesse and Greg/Arthur/SGI saw also had issues
> with CPU power (can you guys confirm?)
> 

The SGI folks seem to be on their way to collect some serious data.
So that should help.

> > You are the first person i have heard that says NAPI would be slower
> > in terms of throughput or latency at low rates. My experiences is there
> > is no difference between the two at low input rate.  It would be
> > interesting to see the data.
> 
> Well, did you ever test a non routing workload?
> 

I did extensive tests with UDP because it was easier to analyze as well
as to pump data at. I did some TCP tests with many connections but the
heursitics of retransmits, congestion control etc made it harder to
analyze. 
If i had a bulk type of workload on a TCP server at gigabit rate it
still isnt that interesting - they tend to go at MTU packet size which
is typically less than 90Kpps worst case.

With a simple UDP sink server that just swallowed packets it was easier.
I could send it 1Mpps and exercise that path. So this is where
i did most of the testing as far as non-routing paths - Robert is the
other person you could ask this question. 

Very interesting observation to note in the case of UDP: at some point
on my slow machine at 100Kpps that NAPI was able to keep up with, the
socket queue got overloaded. And packets started dropping at the socket
queue. 
I did provide patches to have feedback that goes all the way to the
driver level; however intepreting these feedback codes is hard. Look at
the comments in dev.c from Alexey to understand why this is hard;->
comments read as follows:

------
   /* Jamal, now you will not able to escape explaining
    * me how you were going to use this. :-)
    */
-------

That comment serves as a reminder to revist this. About everytime i see
i go back and look at my notes. So the challenge is still on the table.

The old non-NAPI code was never able to stress the socket code the way
NAPI does because the system simply died - so this was never seen.
Things like the classical lazy receiver processing would have been
useful to implement - but very hard to do in Linux.

Back to my comments: We need to analyze why something is happening.
Simply saying "its NAPI" is wrong.

cheers,
jamal
