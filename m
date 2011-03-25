From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [RFC v3 5/6] j1939: add documentation and MAINTAINERS
Date: Fri, 25 Mar 2011 14:55:31 +0100
Message-ID: <20110325135531.GA994@e-circ.dyndns.org>
References: <20110314132004.GA333@e-circ.dyndns.org>
	<20110314135917.GF333@e-circ.dyndns.org>
	<4D8623BE.2080807@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D8623BE.2080807-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 20, 2011 at 04:56:46PM +0100, Oliver Hartkopp wrote:
> On 14.03.2011 14:59, Kurt Van Dijck wrote:
> 
> Hello Kurt,
hello Oliver :-)
> 
> even after our F2F-discussion on the Embedded World i'm still not convinced,
ok

Are you aware of the fact that, since your experience with dynamic addressing
is limited, ignoring this completely will leave you yet with a working,
operational J1939 stack?
When address claiming is not in place, just work with the static addresses. It'll
work. The addition of address claiming in kernel just looses you a few
cpu clock cycles.

At least,  that's the intention of the API.
The patches I sent have proven to have some faults yet. I'm again working on an
update.

> why it should be a good idea to handle all the address claiming process inside
> the kernel.
IMO, it's a good idea to have the kernel support the address claiming process.
Why:
* IMO, J1939 implicitely puts address claiming below Transport protocol.
  As such, you can't really put Transport protocol in kernel & address claim
  in userspace.
* In kernel, an ECU can 'atomically' switch addresses,
  AND have pending transport sessions (in kernel) use the new address.
* in kernel, a sendto() can be held (block) during address claim delays (not yet
  implemented).
* In kernel, you can let userspace participate on a J1939 bus _correctly_
  in an imperative way, rather than the volutary userspace library setups.

The above are arguments to minimize the required overhead in userspace for
supporting address claiming.

I don't want the kernel to handle _all_ the address claiming.
Why:
* address claiming _is_ a policy related thing. I don't put policies
  in kernel. I learned that as soon that a policy is implemented, our customer
  wants it different.
  But our customer should _not_ try modifying the non-policy related part of
  address claiming.

Think of this scenario: we put only transport sessions in kernel.
So, you instruct the kernel to send few kB on j1939 bus, from (A)0x80.
What will happen when (B)0x80 kicks (A) from its 0x80 using address claiming.
(A) will use (eg.) 0x82.  But your transport session is still pending,
and using 0x80 ==>> illegal.

My implementation lets the kernel follow the address claiming traffic, that was
initiated from userspace, so it can handle this situation correctly.

Also note that this is the smallest example to make the point. More elaborated and
complex examples exist.

The important thing, IMO, is how this is controlled from userspace. Yes, you
can instruct the kernel to do magic trickery then, but my implementation
uses the regular API's for this. I just accepted the fact that the 64bit name
is the real reference to indicate an ECU. So I put that in the sockaddr_can too.
> 
> Besides the fact, that other j1939 implementation are *completely* implemented
> in userspace (and can cope with the time restrictions),
They probably do, on a voluntary basis.

When spread across different processes cooperating to the same ECU,
they have no means to guarantee anything. So, every application should
carefully respect the guidelines for the userspace library.
And after that is accomplished, do they take care of the following scenario:
Process A sends a PGN regularly
Process B deals with address claims.
When process B emits a new address, process A should _not_ send new PGN's for
250msec. That is the 'time restriction'
However, their interprocess communication will race with the in-kernel CAN queue's.
So, A may emit PGN's after the address claim, but before the 'address notification'
I don't see a proper way to deal with it.
> i do not see why you
> put the address claiming into the kernel and not only the transport layer stuff.
see above.
> 
> The address claiming can be compared to something like DHCP or DNS in the
> internet protocol world, that are both handled and implemented in userspace
> apps or userspace libraries.
Yes and no.
Yes: DHCP also deals with 'dynamic addresses'. The policies applied there could
be used for J1939 too.
No: DHCP operates in a master-slave way, J1939 does not.
DHCP does not handle conflicts, since the master should not give conflicting leases.
J1939 must deal with conflicts.

A proper comparison on IP would be to eliminate the DHCP server, and let each
client 'just use an IP', and when another ethernet card happens to have chosen
the exact same IP, the winner is decided (on both ends) based on the MAC address.
This would introduce loads of problems in IP too.
The atomic operation & conflict handling are kernel parts IMHO.

another comparison would be ARP, where each node holds its own table, carefully
built from passing network traffic.

The 64bit 'name' is not a name as in DNS, it's a unique ID.
> 
> E.g. these bits from the documentation look like you are starting some kind of
> 'addressing service' daemon:
Yep, to implement the 'address choosing' policy.
I'm still testing all J1939 requirements here, but when this is ready, I feel
I will need to publish such program.
> 
> > +4.1 rtnetlink interface
> > +
> > +  Per default j1939 is not active. Specifying can_ifindex != 0 in bind(2)
> > +  or connect(2) needs an active j1939 on that interface. You must have done
> > +  $ ip link set canX j1939 on
> > +  on that interface.
> > +
> > +  $ ip link set canX j1939 down
> > +  disables j1939 on canX.
> 
> You are activating the 'addressing service' on specific CAN interfaces.
Since no autoprobing of protocols is possible on CAN (in contrast to Ethernet).
> 
> Then you suggest to attach static and/or dynamic addresses to the interface.
Correction: you assign a static address, or a 'name' for use with dynamic addressing.
the name for dynamic addressing is not a 'dynamic address'.
> 
> > +  Assigning addresses is done via
> > +  $ ip addr add dev canX j1939 0xXX
> > +  statically or
> > +  $ ip addr add dev canX j1939 name 0xXX
> > +  dynamically. In the latter case, address claiming must take place
> > +  before other traffic can leave.
> 
> like you would have using DHCP/DNS (adapted for j1939) ...
The userspace part for address claiming (in fact, the right CAN frames should appear
to fullfill the address claiming requirements) can then bind to the name, and claim
addresses for it. The kernel will reccognize those, and act upon them. The kernel
will at no point initiate an address claim.
> 
> > +  Removing addresses is done similarly via
> > +  $ ip addr del dev canX j1939 0xXX
> > +  $ ip addr del dev canX j1939 name 0xXX
> > +
> > +  A static address cannot be assigned together with a 64bit name.
> 
> Ah. You provide two kernel interfaces
Yep, because there are two distinct use cases to address.
With dynamic addressing, the 8bit address is just a temporary placeholder, which may
change in the future. This makes a bad discriminator to differentiate between hosts.
therefore, to specify a host to the kernel (as source or destination), the 8bit
address is irrelevant at that point in time.
Therefore, the kernel _needs_ knowledge of the 64bit name, just to provide a
decent interface to userspace for source/destination identification.

> instead of handling the address claiming
> in userspace and provide only one simple (static) interface to the kernel.
And this is no option IMO.
Just above, I indicated that the kernel needs the 64bit name. Pairing with the 8bit
address in userspace only will:
* add a serious amount of userspace code & userspace timing requirements.
* create a complex library/IPC API.
* not solve the case for pending transport sessions.
* still unspecified how the kernel should treat messages that have specified
  a 64bit destination name with different 8bit destination address.
IMO, doing these things in userspace are unnecessarily complicated.

> 
> This artifact brings this fact out again:
> 
> > +  can_addr.j1939.name contains the 64-bit J1939 NAME.
> > +
> > +  can_addr.j1939.addr contains the source address.
> > +
> > +  When sending data, the source address is applied as follows: If
> > +  can_addr.j1939.name != 0 the NAME is looked up by the kernel and the
> > +  corresponding Source Address is used. If can_addr.j1939.name == 0,
> > +  can_addr.j1939.addr is used.
> 
> Yes. You are providing two programming interfaces to the kernel that can be
> used exclusive-OR only.
ack.
> 
> As other j1939 implementations implement the address claiming in userspace
> too, there's no necessity to implement this inside the kernel. DHCP and DNS
> can also lead to address changes and some 'new j1939 addressing daemon' could
> be implemented in a way that allows to tell registered j1939 apps address
> changes in a fast way (trigger/signal/select/whatever). I don't know how much
This is like saying: the race condition could be improved. But it's still there, isn't it?
> of the 4838 lines of code from your RFC can be removed - but i assume it would
+/- 700
which will move to every userspace application, and they'd still not be correct.
> vastly reduce the complexity of your posted j1939 implementation.
> 
> If you would implement only the j1939 transport layer stuff (using static
> addressing) together with some userspace 'address claiming' daemon and/or
> library (compared to DNS) this would make more sense to me. Especially it
> makes the kernel API clear and simple(!).
and crippled.
Being clear and simple is no justification for introducing race conditions!
> As a side-effect this would remove
> the need for a separate system-wide configuration
Why is that a problem. I look at it as a powerfull administrative tool.
The fact that J1939 is the first CAN protocol with a 'real' addressing scheme
seems a major problem.
> which would need to be added
> with your suggested netlink extensions in af_can.c, iproute2
It works, and IMO fits in the policies.
> and the other adaptions to the current code to extend the sockaddr_can in size.
Sooner or later, when CAN protocols are added, the sockaddr_can will grow.
Not letting this grow is equivalent of saying that no CAN protocols will be added.

This fits in the current policies. why do BSD socket functions invented
the af_family & socklen_t stuff. Because they faced this problem before.
Putting J1939 inside AF_CAN implies handling this kind of stuff. And I handled it.
I haven't recompiled my old can tools for ages now, but they still work.
> 
> I know you're a fan of j1939 address claiming inside the kernel
I'm no fan. I only respect the fact that it's the only right place.
> but IMO this does not fit other networking addressing concepts inside the kernel
IPv6 automatic router detection?
At least, I disagree.
> and messes up the kernel API for j1939, sigh.
I don't think my proposed API is a mess. It my way of addressing existing problems.
The fact that some userspace library for tons of dollars does not solve my problem
is IMO no reason to make the same fault.
> 
> If it makes sense to you, i would offer my help to implement the address
> claiming daemon based on CAN_RAW and CAN_BCM ... 8-)
Thanks for the offer.
I have no clue yet how to do the necessary IPC in a way that userspace would
be easy to work with _UNDER ALL CIRCUMSTANCES_ (sorry for the capitals).
> 
> Anyway: Thanks for you contribution!
Thanks for looking at the API.
For what it's worth, since the discussion started, I also think the API has improved
a lot. Thanks for that!

Kurt
> 
> Oliver
