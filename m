From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Sun, 31 Oct 2004 00:56:02 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041031005602.2a017131@zanzibar.2ka.mipt.ru>
References: <1099030958.4944.148.camel@uganda>
	<Xine.LNX.4.44.0410291342350.22168-100000@thoron.boston.redhat.com>
	<20041030091932.6a74bdae@zanzibar.2ka.mipt.ru>
	<Pine.LNX.4.61.0410301805360.14888@maxipes.logix.cz>
	<20041030214050.7e23d7b8@zanzibar.2ka.mipt.ru>
	<Pine.LNX.4.61.0410302207040.9742@maxipes.logix.cz>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ludvig <michal@logix.cz>
In-Reply-To: <Pine.LNX.4.61.0410302207040.9742@maxipes.logix.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Oct 2004 22:17:25 +0200 (CEST)
Michal Ludvig <michal@logix.cz> wrote:

> On Sat, 30 Oct 2004, Evgeniy Polyakov wrote:
> 
> > On Sat, 30 Oct 2004 18:57:20 +0200 (CEST)
> > Michal Ludvig <michal@logix.cz> wrote:
> > 
> > > I have compiled and booted with your patches. Not too much 
> > > playing around so far. Anyway some quick observations:
> > 
> > I've wrote mega block device which can work(without hang) only 
> > with 10mb "disks", but what did you expect from midnight hack after
> > several Staropramen's :)
> 
> 10MB is probably too small to get some reliable numbers. The testing 
> should last for at least couple of seconds...

It was repeated of course.
On one of my very little test machine 10 times of 10mb in a two threads
took about 40-42 secs.
Test was like this:
for ((i=0; i<10; ++i)); do 
	dd if=/dev/zero of=/mnt/file bs=1M count=10
	rm -f /mnt/file
done
Where /mnt is /dev/bd0 mount point.
Above script was run from two processes.

Above block device is just _very_ simple in-memory-only block device.
I decided to not change loopback or ramdisk, it was done to remove disk 
latencies and have more fair results.

> > Give me several minutes to complete async_provider.c and I will post
> > numbers, which I expect will be the same for both sync and async
> > driver since I do not have neither SMP(which should benefit I believe) 
> > nor crypto card here.
> 
> At least try it with a SMP kernel (on UP machine) to catch the worst 
> spindeadlocks etc. In the ideal case the acrypto core should know that 
> there are two (four, ...) CPUs and all of them can encrypt in paralel.

I will get access to the real SMP machine only ater tomorrow.
Of course I test acrypto with preempt and SMP kernel to find different 
kind locking issues.
acrypto's callbacks are run from queue_work context so they can be scheduled to 
diferent CPU, but noone forbids to run 2/4/any synchronous threads and
register them as crypto providers with the same capabilities.
It is very easy with acrypto to balance such kind of load by design.

> > > - "rmmod simple_lb" hangs because:
> > > | <6>You are removing crypto load balancer simple_lb which is current and 
> > > | default.
> > > | There is no other crypto load balancers. Removing is delayed untill new 
> > > | load balancer is registered.
> > > Of course I can't re-add it because the module is still there. In this 
> > > case rmmod should fail with a gentle message (-EBUSY) instead of hang. Or 
> > > let it go if not in use.
> > 
> > acrypto module has parameter force_lb_remove which if is set allows to remove
> > last crypto load balancer.
> > But ut has atricky moment - since any crypto_session_alloc() may occur 
> > asyncronously then we can not say if there are any load balancer users
> > without some locks. Currently if there is no any crypto load balancer, then
> > acrypto will catch BUG_ON().
> 
> BUG_ON()? Shouldn't crypto_session_alloc() fail instead? BUG_ON() is for 
> catching conditions that really shouldn't happen in normal operation. 
> Missing module with a load balancer won't be that unusual...

It is impossible and very bad condition when sessions want to be allocated
but there are no even load balancer.
To be honest it is _supposed_ to not happen, that is why it is BUG_ON() there, 
but you are right it is too rude, I will create a patch tomorrow which 
will allow crypto_session_alloc() fail if there is no load balancer
like it is done when there is no appropriate crypto device.
 
> Or should the acrypto.ko module prerequire a balancer to get it loaded 
> automatically?

My first idea was to insert simple_lb as part of acrypto.
And then any other load balancer can be removed with fallback to simple_lb,
but it is not fair enough I think.
But it is still can be easily implemented, if we decide to do it.

> Michal Ludvig
> -- 
> * A mouse is a device used to point at the xterm you want to type in.
> * Personal homepage - http://www.logix.cz/michal


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
