From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCHv2 3/4] modem_shm: u8500-shm: U8500 Shared Memory Driver
Date: Wed, 8 Aug 2012 11:46:06 +0100
Message-ID: <20120808114606.2a1a3bd3@pyramind.ukuu.org.uk>
References: <1344322471-3640-1-git-send-email-arun.murthy@stericsson.com>
	<1344322471-3640-4-git-send-email-arun.murthy@stericsson.com>
	<20120807110156.4d0c2571@pyramind.ukuu.org.uk>
	<F45880696056844FA6A73F415B568C695B0E7969E3@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	Sjur BRENDELAND <sjur.brandeland@stericsson.com>
To: Arun MURTHY <arun.murthy@stericsson.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <F45880696056844FA6A73F415B568C695B0E7969E3@EXDCVYMBSTM006.EQ1STM.local>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Basically it doesn't suit our protocol of having base addr, read/write
> pointer, locking etc as the same set of structures and protocol will be
> used on the modem side implementation.

Ok. What happens about endianness or is the modem always the same
endianness as the host ?


> > > +   if (len <= 0)
> > > +           return -EFAULT;
> >
> > How can this occur ?
> 
> Check for error condition

So how can it occur ? The kernel char layer will never pass a negative
length to a driver ?

> > What happens with two parallel reads - I don't see what prevents
> > corruption if that occurs or one racing read freeing the message before
> > another has finished processing it.
> 
> Two parallel reads for different L2 headers can happen, but within the
> same L2 header is out of the scope. Since the client using this in
> user space will not know about the message. i.e which msg is for which
> client. Hence so that scenario is not considered.

What stops a hostile application (or programmer error) from doing so
deliberately ?

> > > +   if (len <= 0 || buf == NULL)
> > > +           return -EFAULT;
> >
> > len < 0 cannot occur, buf == NULL is not an error
> 
> Error handling is for what which is not expected.

Well buf = NULL is not an error (its weird but its not an error)

Also length < 0 is never passed from the char layer to a driver.

> > > +           dev_err(shrm->dev, "Device not opened yet\n");
> > > +           mutex_unlock(&isa_lock);
> > > +           return -ENODEV;
> > > +   }
> > > +   atomic_set(&isa_context->is_open[idx], 1);
> >
> > How do you know it will always be one. Also given it's within the mutex
> > in all uses I can see why is it an atomic ?
> >
> 
> As per our assumptions/protocol only one client per L2 header.

So why use atomic. Also you can't make that assumption. If you need your
device to have one user per channel and one write call at a time you must
enforce it. There is nothing wrong with enforcing it but it needs to be
done.

That means your open path probably wants to do something (locked) like

	if (foo->users)
		return -EBUSY;

you still then need to use a mutex or similar in read and write because a
single open can pass to multiple processes (or multiple writes/reads
occur at once in a multi-threaded app).

User/Kernel is the security boundary so the kernel code must be robust
against a hostile user rather than assuming a correctly functioning
library.

I suspect you simply need to wrap the read/write logic (except for a wait
for new message) with a mutex and all will be well

> > > +   if (get_boot_state() != BOOT_DONE) {
> > > +           dev_err(shrm->dev, "Boot is not done\n");
> > > +           return -EBUSY;
> > > +   }
> >
> > Is it guaranteed that this is a one way path - ie a device never goes
> > back into BOOT state ?
> 
> No, on modem reset, everything happens from first.

So what occurs if this modem reset happens between that test and the next
line. You have no locking on it so you've got no guarantee that it won't
reset during the test. So it covers the initial set up case but not a
reset.

It may not matter providing a reset wakes up things and it is handled
later. It just looks suspicious.

> > > +   isadev = &isa_context->isadev[idx];
> > > +   if (filp != NULL)
> > > +           filp->private_data = isadev;
> >
> > How can filp be NULL ?
> 
> :-) just a error condition check

These tests are not useful, if anything they hide bugs. If you have a
real reason to check (eg its a complicated internal path) then use

	WARN_ON(condition)

or

	BUG_ON(condition)

so it gets noticed. For core kernel things however there is no point
checking. If the kernel ever passes you null as a file pointer the game
is already over.

> > > +   for (no_dev = 0; no_dev < ISA_DEVICES; no_dev++) {
> > > +           atomic_set(&isa_context->is_open[no_dev], 1);
> > > +           device_create(isa_context->shm_class, NULL,
> > > +                           MKDEV(MAJOR(dev_id),
> > > +                           map_dev[no_dev].l2_header), NULL,
> > > +                           map_dev[no_dev].name);
> > > +   }
> >
> > What happens if I open the device right here... ?
> 
> It can be opened, but nothing thereafter, since modem is not booted.

You've not yet set up the isa_context but yes.. looks like it is covered
by the boot check.

(A good rule of thumb is btw to initialise everything, then register
stuff)


Alan
