From: jamal <hadi@cyberus.ca>
Subject: Re: Asynchronous crypto layer.
Date: 31 Oct 2004 09:56:00 -0500
Message-ID: <1099234559.1040.183.camel@jzny.localdomain>
References: <1099030958.4944.148.camel@uganda>
	 <1099053738.1024.104.camel@jzny.localdomain>
	 <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
	 <20041030203550.GB6256@gate.ebshome.net>
	 <20041031010415.4c798a04@zanzibar.2ka.mipt.ru>
	 <20041030205630.GD6256@gate.ebshome.net>
	 <20041031012423.74b98698@zanzibar.2ka.mipt.ru>
	 <1099179687.1041.117.camel@jzny.localdomain>
	 <20041031121308.648e98f9@zanzibar.2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eugene Surovegin <ebs@ebshome.net>, netdev@oss.sgi.com,
        cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20041031121308.648e98f9@zanzibar.2ka.mipt.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-10-31 at 04:13, Evgeniy Polyakov wrote:
> On 30 Oct 2004 19:41:27 -0400
> jamal <hadi@cyberus.ca> wrote:

> > Can you explain the "rate" or "speed" parameter ?
> 
> Driver writer can set "rate" parameter to any number from 0 to 64k -
> and it will show speed of this driver in current mode/type/operation.
[..]
> 
> That mean that this driver perform des 6 time faster than aes, but 
> it should be fair numbers and somehow measured and compared to other
> drivers.
> 

So you have some init code that does testing? Or is this factor of six
part of the spec provided by chip vendor?

> This also can be achieved by qlen parameter - if driver writer sets
> it to bigger walue then in this mode driver/hardware works faster.
> But driver writer can set qlen in a too big value just because
> it want it to be such without any means of driver/hardware capabilities.
> It is not forbidden.
> 

It is no different than say the way you will do ethernet drivers.
DMA ring sizes and link speeds. harder for ethernet drivers if link
speeds change (Linux net scheduling assumes fixed speed ;->)

> And the last and the most interesting one is following:
> we create per session initialiser parameter "session_processin_time" 
> which will be sum of the time slices when driver performed operation 
> on session, since we alredy has "scomplete" paramenter which is equal 
> to the amount of completed(processed) session then we have _fair_ speed 
> of the driver/hardware in a given mode/operation/type.
> 
> Of course load blancer should select device with the lowest
> session_processing_time/scompleted.
> 
> I think third variant is what we want. I will think of it some more
> and will implement soon.
> 

I think you should be able to have multiple, configurable LB algos.

> > I havent studied your code, however, what Eugene is pointing out is
> > valuable detail/feedback.
> >
> > You should have in your queuing towards the crypto chip ability to
> > batch. i.e sort of nagle-like "wait until we have 10 packets/20KB or 20
> > jiffies" before you send everything in the queue to the chip.
> 
> That is exactly how crypto driver should be written.
> Driver has it's queue and number of session in it, so it and only it
> can decide when begin to process them in the most effective way.
> 

This should be above driver, really.
 
You should have one or more queues where the scheduler feeds off and
shoves to hardware. Perhaps several levels:

->LB-+
     +-> device1 scheduler --> driver queues/rings.
     |
     |
     +-> device2 scheduler --> driver queues/rings.
     |
     .
     .
     +-> devicen scheduler --> driver queues/rings.

If you look at the linux traffic control, the stuff below LB is how it
behaves. That should be generic enough to _not_ sit in the driver.
This allows for adding smart algorithms to it; fe: qos, rate limiting,
feedback to LB so it could make smarter decisions etc.

> > As he points out (and i am sure he can back it with data ;->), that
> > given the setup cost, packet size, algo and CPU and bus speed, it may
> > not make sense to use the chip at all ;->
> 
> Michal has numbers - pure hardware beats soft in a certain setups
> in a fully synchronous schema, let's work SW and HW in parallel.
> 
> Of course SW can encrypt 64 byte faster than it will be transfered to
> old ISA crypto card, but it worth to do it for compressing with LZW
> 9000 bytes jumbo frame.
> 

Would be interesting. I have seen the numbers from Eugene and they are 
quiet intriguing - but they are for the sync mode.

cheers,
jamal
