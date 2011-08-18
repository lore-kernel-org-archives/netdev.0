From: San Mehat <san@google.com>
Subject: Re:
Date: Thu, 18 Aug 2011 15:08:54 -0700
Message-ID: <CAPi7mHp9zp1mspLGdmq_+ibcWbdOcOTL7-qMU+o6LCFQJ1xBOQ@mail.gmail.com>
References: <20110818220732.459185C80B@san.sea.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	digitaleric@google.com, mikew@google.com, miche@google.com,
	maccarro@google.com
To: davem@davemloft.net, mst@redhat.com, rusty@rustcorp.com.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110818220732.459185C80B@san.sea.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pls disregard in favor of the one with an actual subject line :P

-san

On Thu, Aug 18, 2011 at 3:07 PM, San Mehat <san@google.com> wrote:
>
> TL;DR
> -----
> In this RFC we propose the introduction of the concept of hardware so=
cket
> offload to the Linux kernel. Patches will accompany this RFC in a few=
 days,
> but we felt we had enough on the design to solicit constructive discu=
ssion
> from the community at-large.
>
> BACKGROUND
> ----------
> Many applications within enterprise organizations suitable for virtua=
lization
> neither require nor desire a connection to the full internal Ethernet=
+IP
> network. =A0Rather, some specific socket connections -- for processin=
g HTTP
> requests, making database queries, or interacting with storage -- are=
 needed,
> and IP networking in the application may typically be discouraged for
> applications that do not sit on the edge of the network. Furthermore,=
 removing
> the application's need to understand where its inputs come from / go =
to within
> the networking fabric can make save/restore/migration of a virtualize=
d
> application substantially easier - especially in large clusters and o=
n fabrics
> which can't handle IP re-assignment.
>
> REQUIREMENTS
> ------------
> =A0* Allow VM connectivity to internal resources without requiring ad=
ditional
> =A0 network resources (IPs, VLANs, etc).
> =A0* Easy authentication of network streams from a trusted domain (vm=
m).
> =A0* Protect host-kernel & network-fabric from direct exposure to unt=
rusted
> =A0 packet data-structures.
> =A0* Support for multiple distributions of Linux.
> =A0* Minimal third-party software maintenance burden.
> =A0* To be able to co-exist with the existing network stack and ether=
net virtual
> =A0 devices in the event that an applications specific requirements c=
annot be
> =A0 met by this design.
>
> DESIGN
> ------
> The Berkeley sockets coprocessor is a virtual PCI device which has th=
e ability
> to offload socket activity from an unmodified application at the BSD =
sockets
> layer (Layer 4). =A0Offloaded socket requests bypass the local operat=
ing systems
> networking stack entirely via the card and are relayed into the VMM
> (Virtual Machine Manager) for processing. The VMM then passes the req=
uest to a
> socket backend for handling. The difference between a socket backend =
and a
> traditional VM ethernet backend is that the socket backend receives l=
ayer 4
> socket (STREAM/DGRAM) requests instead of a multiplexed stream of lay=
er 2
> packets (ethernet) that must be interpreted by the host. This techniq=
ue also
> improves security isolation as the guest is no longer constructing pa=
ckets which
> are evaluated by the host or underlying network fabric; packet constr=
uction
> happens in the host.
>
> Lastly, pushing socket processing back into the host allows for host-=
side
> control of the network protocols used, which limits the potential con=
gestion
> problems that can arise when various guests are using their own conge=
stion
> control algorithms.
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> =A0 =A0 =A0 =A0 =A0 +------------------------------------------------=
-----------------+
> =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 |
> =A0guest =A0 =A0| =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unmodifi=
ed application =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |
> userspace =A0+-------------------------------------------------------=
----------+
> =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 unmodified libc =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |
> =A0 =A0 =A0 =A0 =A0 +------------------------------------------------=
-----------------+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 / \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D | =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D | =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \ / =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 +------------------------------------=
------------------+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 socket core =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 +----+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D+------------------------------------+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0INET =A0 =A0| =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 / \
> =A0guest =A0 =A0 =A0 =A0 =A0 =A0 =A0 +-----+------+ =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0|
> =A0kernel =A0 =A0 =A0 =A0 =A0 =A0 =A0| TCP | UDP =A0| =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0|
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0+-----+------+ =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 | L4 reqs =A0|
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 NETDEV =A0 | =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0|
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0+------------+ =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0|
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| virtio_net | =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0\ / =A0 =A0 =A0 =A0 |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0+------------+ =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 +------------------+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 / \ =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0hw_socket =A0 =A0 |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0| =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 +------------------+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0| =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0virtio_socket =A0 |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0| =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 +------------------+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0| =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0 / \
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D | =3D=3D | =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D | =3D=3D=3D=3D=3D=3D | =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \ / =A0 | =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \ / =A0 =A0 =A0 |
> =A0host =A0 =A0 =A0 =A0 =A0 +---------------------+ =A0 =A0 =A0 =A0+-=
-----------------------+
> userspace =A0 =A0 =A0 =A0| =A0virito net device =A0| =A0 =A0 =A0 =A0|=
 =A0virtio socket device =A0|
> =A0(vmm) =A0 =A0 =A0 =A0 =A0+---------------------+ =A0 =A0 =A0 =A0+-=
-----------------------+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0ethernet backend =A0 | =A0 =A0 =A0=
 =A0| =A0 =A0 socket backend =A0 =A0 |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 +---------------------+ =A0 =A0 =A0 =A0=
+------------------------+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 / \ =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0 =A0/ \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 L2 =A0 =A0 | =A0 =A0 =A0| =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 | =A0 =A0 L4
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 packets =A0| =A0 =A0 =A0| =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0\ / =A0 =A0 =A0 =A0| =A0requests
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0| =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0+-----------------------+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0| =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0Socket Handlers =A0 =A0|
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0| =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0+-----------------------+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0| =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0/ \
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
 | =3D=3D=3D=3D | =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D | =3D=3D=3D=3D=3D=3D=3D | =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0| =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 |
> =A0 host =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\ / =A0 =A0 | =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0\ / =A0 =A0 =A0 =A0|
> =A0kernel
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> One of the most appealing aspects of this design (to application deve=
lopers) is
> that this approach can be completely transparent to the application, =
provided
> we're able to intercept the application's socket requests in such a w=
ay that we
> do not impact performance in a negative fashion, yet retain the API s=
emantics
> the application expects. In the event that this design is not suitabl=
e for an
> application, the virtual machine may be also fitted with a normal vir=
tual
> ethernet device in addition to the co-processor (as shown in the diag=
ram above).
>
> Since we wish to allow these paravirtualized sockets to coexist peace=
fully with
> the existing Linux socket system, we've chosen to introduce the idea =
that a
> socket can at some point transition from being managed by the O/S soc=
ket system
> to a more enlightened 'hardware assisted' socket. The transition is m=
anaged by
> a 'socket coprocessor' component which intercepts and gets first righ=
t of
> refusal on handling certain global socket calls (connect, sendto, bin=
d, etc...).
> In this initial design, the policy on whether to transition a socket =
or not is
> made by the virtual hardware, although we understand that further mea=
surement
> into operation latency is warranted.
>
> In the event the determination is made to transition a socket to hw-a=
ssisted
> mode, the socket is marked as being assisted by hardware, and all soc=
ket
> operations are offloaded to hardware.
>
> The following flag values have been added to struct socket (only visi=
ble within
> the guest kernel):
>
> =A0* SOCK_HWASSIST
> =A0 =A0Indicates socket operations are handled by hardware
>
> In order to support a variety of socket address families, addresses a=
re
> converted from their native socket family to an opaque string. Our in=
itial
> design formats these strings as URIs. The currently supported convers=
ions are:
>
> +--------------------------------------------------------------------=
---------+
> | =A0 Domain =A0 | =A0 =A0 =A0Type =A0 =A0 | =A0URI example conversio=
n =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> | =A0AF_INET =A0 | =A0SOCK_STREAM =A0| =A0tcp://x.x.x.x:yyyy =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> | =A0AF_INET =A0 | =A0SOCK_DGRAM =A0 | =A0udp://x.x.x.x:yyyy =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> | =A0AF_INET6 =A0| =A0SOCK_STREAM =A0| =A0tcp6://aaaa:b:cccc:d:eeee:f=
fff:gggg:hhhh/ii =A0 |
> | =A0AF_INET6 =A0| =A0SOCK_DGRAM =A0 | =A0udp6://aaaa:b:cccc:d:eeee:f=
fff:gggg:hhhh/ii =A0 |
> | =A0AF_IPX =A0 =A0| =A0SOCK_DGRAM =A0 | =A0ipx://xxxxxxxx.yyyyyyyyyy=
=2Ezzzz =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> +--------------------------------------------------------------------=
---------+
>
> In order for the socket coprocessor to take control of a socket, hook=
s must be
> added to the socket core. Our initial implementation hooks a number o=
f functions
> in the socket-core (too many), and after consideration we feel we can=
 reduce it
> down considerably by managing the socket 'ops' pointers.
>
> ALTERNATIVE STRATEGIES
> ----------------------
>
> An alternative strategy for providing similar functionality involves =
either
> modifying glibc or using LD_PRELOAD tricks to intercept socket calls.=
 We were
> forced to rule this out due to the complexity (and fragility) involve=
d with
> attempting to maintain a general solution compatible accross various
> distributions where platform-libraries differ.
>
> CAVEATS
> -------
>
> =A0* We're currently hooked into too many socket calls. We should be =
able to
> =A0 reduce the number of hooks to 3 (__sock_create(), sys_connect(), =
sys_bind()).
>
> =A0* Our 'hw_socket' component should be folded into a netdev so we c=
an leverage
> =A0 NAPI.
>
> =A0* We don't handle SOCK_SEQPACKET, SOCK_RAW, SOCK_RDM, or SOCK_PACK=
ET sockets.
>
> =A0* We don't currently have support for /proc/net. Our current plan =
is to
> =A0 add '/proc/net/hwsock' (filename TBD) and add support for these s=
ockets
> =A0 to the net-tools packages (netstat & friends), rather than muck a=
round with
> =A0 plumbing hardware-assisted socket info into '/proc/net/tcp' and
> =A0 '/proc/net/udp'.
>
> =A0* We don't currently have SOCK_DGRAM support implemented (work in =
progress)
>
> =A0* We have insufficient integration testing in place (work in progr=
ess)
>



--=20
San Mehat=A0|=A0Staff Software Engineer=A0|=A0san@google.com=A0|=A0415-=
366-6172
