From: jamal <hadi@cyberus.ca>
Subject: Re: iproute2 and kernel headers
Date: 07 Aug 2004 10:04:48 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1091847950.1800.6.camel@jzny.localdomain>
References: <20040805005019.GA11538@bougret.hpl.hp.com>
	 <20040806093920.045b379e@dell_ss3.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, jt@bougret.hpl.hp.com, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com, Mariusz Mazur <mmazur@kernel.pl>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040806093920.045b379e@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-08-06 at 12:39, Stephen Hemminger wrote: 
> On Wed, 4 Aug 2004 17:50:19 -0700
> Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:

[..]

> > 	This is when I introduced version number in the API. This
> > allows the tools to verify that they use the same version of the API
> > as the kernel, and complain if they are not with an explicit error
> > message.

Yes, this is useful. Unfortunately this gives you control only on your
API. If for example someone fscks something you are using, such as the
netlink header you are screwed. So for consistency versioning needs to
exist everywhere.


> > 	By the way, one of the consequence of versioning the API is
> > that I tend to do most API changes in batches. The idea is that I want
> > to minimise the number of API versions, because I have to test the
> > tools and drivers with each of them, and I have finite time.

There should really be no reason you have to change versions. It should
be the last resort. You can use tricks like data structure augmentation
and and new TLV types to go for a long time and still be backward (as
well as forward) compatible. When you are no longer capable of doing
these tricks, then it would make sense upping the version.
There also should be rules for evolution reasons against having data
structures which cross kernel/userspace from having things like 
lookatme[0] elements.



 
> > 	1) Get it right the first time, so no change is ever
> > needed. If things are standardised (POSIX, IEEE), this can work, if
> > you are called Linus, most likely, otherwise, good luck...
> 
> The management API's are what seemed to get changed the most.
> The only relevant standard's seem to be SNMP, but it doesn't match
> the kernel API needs.

I think we could establish certain rules that will make things live for
a long period of time. Some which have been pointed to here already are:

a) use TLVs
b) When you really wanna transport new things, create new Types leaving
old ones intact so older versions of tools dont break.
c) Use data structure augmentation i.e add things at the end of a data
structure. In combination with sizeof operations old tools should work
while new ones can make use of new features.
d) avoid like the plague things like lookatme[0] elements within a
structure that gets transfered between kernel/userspace

> > 	2) Migrate all those kernel APIs to XML. XML is the future,
> > you can validate the output, and you can add/remove nodes/attributes
> > between versions without the full thing falling apart. And we already
> > have a web server in the kernel.
> 
> No, don't reinvent SOAP for kernel API's.

We already have value=attribute in TLVs approach (which could be
nested). 
Your userspace app should be able to use XML and use some DTD to
translate into binary TLV repreasentations.

> > 	3) Every time you need to change the API, migrate it to
> > another delivery mechanism and create a totally different set of
> > tools. If you were using ioctl, migrate to netlink. If you were using
> > netlink, migrate to a pseudo filesystem. Obviously the holy grail is
> > to make it a system call. Also, make sure to kill the old APIs and old
> > tools, otherwise some other folks my continue to maintain it.
> 
> Doesn't make sense unless the new interface is better.
> Just use different ioctl's or message types.

Refer to the rules above.

> > 	4) Distribute all those system utilities as part of the
> > kernel, compile them as part of the kernel, and install them in a
> > kernel specific directory. Basically, treat system utilities exactly
> > the same way as kernel modules.
> > 	That actually would go a long way toward solving the issue of
> > distribution of system utils (where is module-init-tools ?) and push
> > more people to implement their pet project in user space rather than
> > in the kernel.
> 
> Too old school, unix.  It might have worked in the past, and we might
> end up back there, but it ain't going to happen now.

My thought (i have proposed this a few times, probably not eloquently)
is to build discovery. User space should be able to discover at runtime
what the kernel can do. X for example does this in a stupid way: it
attempts featuress and on failure it takes them off its list
.
My approach is to explicitly tell the kernel or ask the kernel
"tell me what you can do"  - this should bring up things like
capabilities and revisions of different things in the kernel.
User space should then adapt accordingly.

> > 	I wish you a lot of luck exploring those issues, and if one of
> > those long nights you have a Eureka moment, please share with us ;-)
> > 	Have fun...
> 
> You ignored the advantage of using simple string interfaces (a.l.a Plan 9)
> or simple name:value pairs. Also, it turns out that some simple things like
> increasing the size of the structure or adding a new rtnetlink message type
> are not too hard to deal with.

Perhaps we need to start accumulating the rules. Ive listed a few - some of 
which you list above.

cheers,
jamal
