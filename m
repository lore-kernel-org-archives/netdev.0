From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [RFC v3 5/6] j1939: add documentation and MAINTAINERS
Date: Sun, 20 Mar 2011 16:56:46 +0100
Message-ID: <4D8623BE.2080807@hartkopp.net>
References: <20110314132004.GA333@e-circ.dyndns.org>
	<20110314135917.GF333@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110314135917.GF333-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
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

On 14.03.2011 14:59, Kurt Van Dijck wrote:
> This patch adds the documentation and MAINTAINERS.

Hello Kurt,

even after our F2F-discussion on the Embedded World i'm still not convinced,
why it should be a good idea to handle all the address claiming process inside
the kernel.

Besides the fact, that other j1939 implementation are *completely* implemented
in userspace (and can cope with the time restrictions), i do not see why you
put the address claiming into the kernel and not only the transport layer stuff.

The address claiming can be compared to something like DHCP or DNS in the
internet protocol world, that are both handled and implemented in userspace
apps or userspace libraries.

E.g. these bits from the documentation look like you are starting some kind of
'addressing service' daemon:

> +4.1 rtnetlink interface
> +
> +  Per default j1939 is not active. Specifying can_ifindex != 0 in bind(2)
> +  or connect(2) needs an active j1939 on that interface. You must have done
> +  $ ip link set canX j1939 on
> +  on that interface.
> +
> +  $ ip link set canX j1939 down
> +  disables j1939 on canX.

You are activating the 'addressing service' on specific CAN interfaces.

Then you suggest to attach static and/or dynamic addresses to the interface.

> +  Assigning addresses is done via
> +  $ ip addr add dev canX j1939 0xXX
> +  statically or
> +  $ ip addr add dev canX j1939 name 0xXX
> +  dynamically. In the latter case, address claiming must take place
> +  before other traffic can leave.

like you would have using DHCP/DNS (adapted for j1939) ...

> +  Removing addresses is done similarly via
> +  $ ip addr del dev canX j1939 0xXX
> +  $ ip addr del dev canX j1939 name 0xXX
> +
> +  A static address cannot be assigned together with a 64bit name.

Ah. You provide two kernel interfaces instead of handling the address claiming
in userspace and provide only one simple (static) interface to the kernel.

This artifact brings this fact out again:

> +  can_addr.j1939.name contains the 64-bit J1939 NAME.
> +
> +  can_addr.j1939.addr contains the source address.
> +
> +  When sending data, the source address is applied as follows: If
> +  can_addr.j1939.name != 0 the NAME is looked up by the kernel and the
> +  corresponding Source Address is used. If can_addr.j1939.name == 0,
> +  can_addr.j1939.addr is used.

Yes. You are providing two programming interfaces to the kernel that can be
used exclusive-OR only.

As other j1939 implementations implement the address claiming in userspace
too, there's no necessity to implement this inside the kernel. DHCP and DNS
can also lead to address changes and some 'new j1939 addressing daemon' could
be implemented in a way that allows to tell registered j1939 apps address
changes in a fast way (trigger/signal/select/whatever). I don't know how much
of the 4838 lines of code from your RFC can be removed - but i assume it would
vastly reduce the complexity of your posted j1939 implementation.

If you would implement only the j1939 transport layer stuff (using static
addressing) together with some userspace 'address claiming' daemon and/or
library (compared to DNS) this would make more sense to me. Especially it
makes the kernel API clear and simple(!). As a side-effect this would remove
the need for a separate system-wide configuration which would need to be added
with your suggested netlink extensions in af_can.c, iproute2 and the other
adaptions to the current code to extend the sockaddr_can in size.

I know you're a fan of j1939 address claiming inside the kernel but IMO this
does not fit other networking addressing concepts inside the kernel and messes
up the kernel API for j1939, sigh.

If it makes sense to you, i would offer my help to implement the address
claiming daemon based on CAN_RAW and CAN_BCM ... 8-)

Anyway: Thanks for you contribution!

Oliver
