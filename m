From: Caitlin Bestler <caitlin.bestler@gmail.com>
Subject: Re: Re: [Rdma-developers] Meeting
	(07/22)summary:OpenRDMA community development discussion
Date: Tue, 2 Aug 2005 09:07:42 -0700
Message-ID: <469958e0050802090757502d3a@mail.gmail.com>
References: <20050801161404.GA15582@lst.de>
	<MAIL2vNuSNGDQ6on7gz0000049f@mail2.ammasso.com>
	<20050802125727.GA2472@lst.de> <42EF7484.5040509@ammasso.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, rdma-developers@lists.sourceforge.net,
	Christoph Hellwig <hch@lst.de>, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Tom Tucker <tom@ammasso.com>
In-Reply-To: <42EF7484.5040509@ammasso.com>
Content-Disposition: inline
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Generally there are two cases to consider: when the TCP mode is not visible
and when it is.

When it is not visible it is certainly easy to manage the TCP connection
with subset logic within the RDMA stack and never involve the host
stack. This is certainly what the initial proposal will rely upon. In=20
the long term it has the problems you cited. Having two stacks
accept TCP connections means that *both* must be updated
to stay current with the latest DoS attacks. While it is more=20
work for the RDMA device, I think there is general agreement=20
amongs the hardware vendors that this is something that the
OS *should* retain control of. Deciding which connections may
be accepted is inherently an OS function.

Beyond that there is a distinct programming model, already=20
accepted in IETF specifications, that requires the application
to begin work in streaming (i.e., socket) mode, and then only
convert to RDMA mode once the two peers have agreed upon
that optimization. To support that model you will eventually=20
have to allow the host stack to transfer a TCP connection to
the RDMA stack *or* you will require the RDMA stack to=20
provide full TCP/socket functionality.

So the real question is not whether to allow the RDMA stack
to "take" a connection from the host stack, but whether to
force the RDMA stack to yield control of the connection to
the host during critical connection setup so that this step
remains firmly under OS control and oversight.


On 8/2/05, Tom Tucker <tom@ammasso.com> wrote:
> =20
> =20
>  'Christoph Hellwig' wrote:
> =20
> =20
>  Can you provide more details on exactly why you think this is a horrible
> idea? I agree it will be complex, but it _could_ be scoped such that the
> complexity is reduced. For instance, the "offload" function could fail
> (with EBUSY or something) if there is _any_ data pending on the socket.
> Thus removing any requirement to pass down pending unacked outgoing data,=
 or
> pending data that has been received but not yet "read" by the application=
.
> The idea here is that the applications at the top "know" they are going i=
nto
> RDMA mode and have effectively quiesced the connection before attempting =
to
> move the connection into RDMA mode. We could, in fact, _require_ the
> connect be quiesced to keep things simpler. I'm quickly sinking into gory
> details, but I want to know if you have other reasons (other than the
> complextity) for why this is a bad idea.
> =20
>  I think your writeup here is more than explanation enough. The offload
> can only work for few special cases, and even for those it's rather
> complicated, especially if you take things as ipsec or complex tunneling
> that get more and more common into account.=20
>  I think Steve's point was that it *can* be simplified as necessary to me=
et
> the demands/needs of the Linux community. It is certainly technically
> possible, but agreeably complicated to offload an active socket.
> =20
> =20
>  What do you archive by
> implementing the offload except trying to make it look more integrated
> to the user than it actually is? Just offload rmda protocols to the
> RDMA hardware and keep the IP stack out of that complexity.
>  You get the benefit of things like SYN flood DOS attack avoidance built
> into the host stack without replicating this functionality in the offload=
ed
> adapter. There are other benefits of integration like failover, etc... IM=
HO,
> however, the bulk of the benefits are for ULP offload like RDMA where the
> remote peer may not be capable of HW RDMA acceleration. This kind of thin=
g
> could be determined in "streaming mode" using the host stack and then
> migrated to an adapter for HW acceleration only if the remote peer is
> capable.
>=20
> =20
> =20
>  _______________________________________________
> openib-general mailing list
> openib-general@openib.org
> http://openib.org/mailman/listinfo/openib-general
>=20
> To unsubscribe, please visit
> http://openib.org/mailman/listinfo/openib-general
> =20
> =20
> =20
> _______________________________________________
> openib-general mailing list
> openib-general@openib.org
> http://openib.org/mailman/listinfo/openib-general
>=20
> To unsubscribe, please visit
> http://openib.org/mailman/listinfo/openib-general
>=20
>=20
b
