From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Sun, 31 Oct 2004 12:13:08 +0300
Message-ID: <20041031121308.648e98f9@zanzibar.2ka.mipt.ru>
References: <1099030958.4944.148.camel@uganda>
	<1099053738.1024.104.camel@jzny.localdomain>
	<20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
	<20041030203550.GB6256@gate.ebshome.net>
	<20041031010415.4c798a04@zanzibar.2ka.mipt.ru>
	<20041030205630.GD6256@gate.ebshome.net>
	<20041031012423.74b98698@zanzibar.2ka.mipt.ru>
	<1099179687.1041.117.camel@jzny.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eugene Surovegin <ebs@ebshome.net>, netdev@oss.sgi.com,
        cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1099179687.1041.117.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 30 Oct 2004 19:41:27 -0400
jamal <hadi@cyberus.ca> wrote:

> On Sat, 2004-10-30 at 17:24, Evgeniy Polyakov wrote:
> > On Sat, 30 Oct 2004 13:56:31 -0700
> > Eugene Surovegin <ebs@ebshome.net> wrote:
> 
> 
> > > OK, what about 64 byte packets? I'm not saying hw crypto is useless, 
> > > what I'm saying is it's not that obvious that having hw crypto will 
> > > help in _all_ situations.
> > 
> > Sure.
> > For such cases I offered "rate" or "speed" parameter in my first e-mail, 
> > but it can be implicitly implemented by queue length.
> > With 1 big datflow of packets with high priority and little dataflow of
> > packets with little priority if we will catch high priority packets by SW
> > and thus can have situation when we will _never_ catch low-priority packets, 
> > with even very slow HW we can route all those low-priority packets into it, 
> > at least they will be processed sometimes...
> 
> Can you explain the "rate" or "speed" parameter ?

Driver writer can set "rate" parameter to any number from 0 to 64k -
and it will show speed of this driver in current mode/type/operation.
For example:
struct  crypto_capability cap[] = {
{
	.mode = CRYPTO_MODE_EBC,
	.operation = CRYPTO_OP_ENCRYPT, 
	.type = CRYPTO_TYPE_AES_128,
	.qlen = 1000,
	.rate = 10000
},
{
	.mode = CRYPTO_MODE_EBC,
	.operation = CRYPTO_OP_ENCRYPT, 
	.type = CRYPTO_TYPE_DES,
	.qlen = 1000,
	.rate = 65000
},  

and so on.

That mean that this driver perform des 6 time faster than aes, but 
it should be fair numbers and somehow measured and compared to other
drivers.

This also can be achieved by qlen parameter - if driver writer sets
it to bigger walue then in this mode driver/hardware works faster.
But driver writer can set qlen in a too big value just because
it want it to be such without any means of driver/hardware capabilities.
It is not forbidden.

And the last and the most interesting one is following:
we create per session initialiser parameter "session_processin_time" 
which will be sum of the time slices when driver performed operation 
on session, since we alredy has "scomplete" paramenter which is equal 
to the amount of completed(processed) session then we have _fair_ speed 
of the driver/hardware in a given mode/operation/type.

Of course load blancer should select device with the lowest
session_processing_time/scompleted.

I think third variant is what we want. I will think of it some more
and will implement soon.

> I havent studied your code, however, what Eugene is pointing out is
> valuable detail/feedback.
>
> You should have in your queuing towards the crypto chip ability to
> batch. i.e sort of nagle-like "wait until we have 10 packets/20KB or 20
> jiffies" before you send everything in the queue to the chip.

That is exactly how crypto driver should be written.
Driver has it's queue and number of session in it, so it and only it
can decide when begin to process them in the most effective way.

> As he points out (and i am sure he can back it with data ;->), that
> given the setup cost, packet size, algo and CPU and bus speed, it may
> not make sense to use the chip at all ;->

Michal has numbers - pure hardware beats soft in a certain setups
in a fully synchronous schema, let's work SW and HW in parallel.

Of course SW can encrypt 64 byte faster than it will be transfered to
old ISA crypto card, but it worth to do it for compressing with LZW
9000 bytes jumbo frame.

> 
> cheers,
> jamal
> 
> 


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
