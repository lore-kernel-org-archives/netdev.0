From: San Mehat <san@google.com>
Subject: Re: [RFC 0/0] Introducing a generic socket offload framework
Date: Thu, 18 Aug 2011 16:18:47 -0700
Message-ID: <CAPi7mHqV6Pgk5tSt+fJn_2aEZKZbO=aO78JXgw7MvDaW0musoQ@mail.gmail.com>
References: <20110818220756.5C93E5C80B@san.sea.corp.google.com>
	<20110818235719.50365b0b@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, mst@redhat.com, rusty@rustcorp.com.au,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	digitaleric@google.com, mikew@google.com, miche@google.com,
	maccarro@google.com
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110818235719.50365b0b@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 18, 2011 at 3:57 PM, Alan Cox <alan@lxorguk.ukuu.org.uk> wr=
ote:
>> The Berkeley sockets coprocessor is a virtual PCI device which has t=
he ability
>> to offload socket activity from an unmodified application at the BSD=
 sockets
>
> Ok I think there is an important question here. Why is this being
> designed for a specific virtual interface. Unix has always had the no=
tion
> that socket operations can be in part generic and that you can pass a
> properly designed program a socket without any notion of what it is f=
or.

Sorry Alan if I wasn't clear, but I'm not quite sure what you're asking=
=2E..

If you're asking 'why have you only spec'ed out a virtual interface
for this' then
my answer would be 'but of course you could design this in real hardwar=
e and
have a proper driver :)'. If you'd prefer that I call that out
specifically I'm happy to do so.

I have no desire to change the 'genericness' of sockets.. just the
opposite - i wish to
introduce the notion that sockets (can be) completely generic (when
offloaded) as far as
the guest is concerned.

>
>> Lastly, pushing socket processing back into the host allows for host=
-side
>> control of the network protocols used, which limits the potential co=
ngestion
>> problems that can arise when various guests are using their own cong=
estion
>> control algorithms.
>
> Does that not depend which side does the congestion and who parcels o=
ut
> buffers ?

It does, and it does.

>
>> Since we wish to allow these paravirtualized sockets to coexist peac=
efully with
>> the existing Linux socket system, we've chosen to introduce the idea=
 that a
>> socket can at some point transition from being managed by the O/S so=
cket system
>> to a more enlightened 'hardware assisted' socket. The transition is =
managed by
>> a 'socket coprocessor' component which intercepts and gets first rig=
ht of
>> refusal on handling certain global socket calls (connect, sendto, bi=
nd, etc...).
>> In this initial design, the policy on whether to transition a socket=
 or not is
>> made by the virtual hardware, although we understand that further me=
asurement
>> into operation latency is warranted.
>
> Q: whay happens about in process socket syscalls in another thread ?
> Thats always been the ugly in these cases either by intercepting or b=
y
> swapping file operations on an object.
>
>> =A0* SOCK_HWASSIST
>> =A0 =A0 Indicates socket operations are handled by hardware
>
> This guest only view means you can't use the abstraction for local
> sockets too.
>

To be honest, the way we're attempting to integrate is in such a way
that you *could*
offload AF_LOCAL sockets...  but that world gets a bit too much like
the 'Twilight Zone'
for my current linkings..

>> In order to support a variety of socket address families, addresses =
are
>> converted from their native socket family to an opaque string. Our i=
nitial
>> design formats these strings as URIs. The currently supported conver=
sions are:
>
> That makes a lot of sense to me, because its a well understood
> abstraction and you can offload other stuff to this kind of generic
> socket including things like http protocol acceleration, SSL and so o=
n.
>
> Plus its always been annoying that you can't open a socket, but a URI
> interface solves that...

Indeed.

>
>> =A0* We don't handle SOCK_SEQPACKET, SOCK_RAW, SOCK_RDM, or SOCK_PAC=
KET sockets.
>
> But there is no reason SEQPACKET and RDM couldn't be added I assume?

No reason I can think of - we just did not have a specific requirement
for it at the time.

>
> Ok other questions
>
> Suppose instead you just add an abstracted socket interface of
>
> =A0 =A0 =A0 =A0AF_SOMETHING, PF_URI

Mike Waychison and I were saving the 'PF_URI' discussion for a future
date, but indeed
we're on the same wave-length :). Our initial requirements are for an
'extremely minimal
burden of support' on the userspace environments, so we decided to
open up a separate
discussion on PF_URI

>
> it would be easy to convert programs. It would be easier to write
> properly generic programs. It would be easy write some small helpers =
that
> are a good deal less insane than the existing inet ones. At that poin=
t
> you could turn the problem on its head. Instead of 'borrowing' socket=
s
> for a fairly specific concept of hw assist you ask the reverse questi=
on,
> who can accelerate this URI be it some kind of virtual machine interf=
ace,
> something funky like raw data over infiniband, or plain old 'use the
> TCP/IP stack'.

Completely agree.

>
> Your decision making code is going to be interesting but it only has =
to
> make the decision once in simple cases.

Yup.

>
> And yes there is still the complicated cases such as 'the routing tab=
le
> has changed from vitual host to via siberia now what' but I don't bel=
ieve
> your proposal addresses that either.

Can you be more specific? If you mean solving the 'keeping your tcp con=
nections
open to non virtual endpoints across a migration (or whatever)' then
no it doesn't :)

>
> Alan
>

Thanks man,

-san


--=20
San Mehat=A0|=A0Staff Software Engineer=A0|=A0san@google.com=A0|=A0415-=
366-6172
