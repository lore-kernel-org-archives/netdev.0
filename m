From: =?iso-8859-1?Q?St=E9phane?= Graber <stgraber@ubuntu.com>
Subject: Re: [Patch net-next] net: make neigh tables per netns
Date: Tue, 4 Nov 2014 10:49:58 -0500
Message-ID: <20141104154958.GC19513@dakara>
References: <87lhskpizv.fsf@x220.int.ebiederm.org>
 <20140626.134335.2147671135749217539.davem@davemloft.net>
 <87egybibh5.fsf@x220.int.ebiederm.org>
 <20140626.154428.1099304313432511688.davem@davemloft.net>
 <CAM_iQpX7iPR=32kog=QJm4G1tgRfg80Hr8Y=BOgUiGnym5EmKw@mail.gmail.com>
 <87vbrl8vmz.fsf@x220.int.ebiederm.org>
 <20140630201518.653ebbaf@redhat.com>
 <1404154474.14692.136223169.48BE9C85@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="PuGuTyElPB9bOcsM"
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <cwang@twopensource.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	chris.j.arges@canonical.com,
	Serge Hallyn <serge.hallyn@canonical.com>,
	containers@lists.linuxfoundation.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:43841 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754533AbaKDPuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 10:50:14 -0500
Content-Disposition: inline
In-Reply-To: <1404154474.14692.136223169.48BE9C85@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--PuGuTyElPB9bOcsM
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 30, 2014 at 08:54:34PM +0200, Hannes Frederic Sowa wrote:
> Hi,
>=20
> On Mon, Jun 30, 2014, at 20:15, Jesper Dangaard Brouer wrote:
> >=20
> > On Fri, 27 Jun 2014 22:12:52 -0700 ebiederm@xmission.com (Eric W.
> > Biederman) wrote:
> > > Cong Wang <xiyou.wangcong@gmail.com> writes:
> > > > On Thu, Jun 26, 2014 at 3:44 PM, David Miller <davem@davemloft.net>=
 wrote:
> > > >>
> > [...]
> > > >
> > > > Hmm, I did overlook the potential DOS problem. But hold on, isn't
> > > > IP fragments have the same problem? The fragment queues are per
> > > > netns, and the thresh is per netns as well, we will eventually have
> > > > memory pressure as well.
> > >=20
> > > Interesting.  It does look like ip fragments are susceptible that way.
> >=20
> > For IP fragments we have per netns mem-limit and LRU-list, but all
> > netns share the same hash table, which have its own DoS potential.
> >=20
> > And argh! - we have a hardcoded INETFRAGS_MAXDEPTH=3D128, which can be
> > used for (slow) DoS of IP frags if enough netns are created.
> >=20
> > https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/ne=
t/ipv4/inet_fragment.c#n344
> >=20
> > Introduced by commit 5a3da1fe9 ("inet: limit length of fragment queue
> > hash table bucket lists").
>=20
> Sure, but we need that, otherwise even a single netns can get exploited
> up to a remotely triggered lockup of the box - e.g.
> https://gist.github.com/hannes/5116331 - on some smaller machines.
> INETFRAGS_MAXDEPTH is a property of the hashtable and walking a chain
> with more than 128 elements is just crazy.
>=20
> Also, for me making this user configurable doesn't seem to provide a
> benefit.
>=20
> Sure, it does introduce some kind of unfairness between the namespaces,
> but so does all code which overcommits shared resources.
>=20
> Bye,
> Hannes

Hello,

As a way to test this issue and show how easy it is to DoS a machine by
filling the IPv6 neighborhood table, I've written this small example:
https://dl.stgraber.org/ipv6-dos.c

This can be run as a nobody user on any kernel with user namespaces enabled.
What it does is unshare a new user namespace and then a new network
namespace inside it. It then creates a veth pair, assigns 4000 IPv6
addresses on the first interface of the pair, then forks, unshares
another network namespace, moves the second interface of the pair in
there and assigns another 4000 IPv6 addresses.

At that point, you have two interfaces, one in the first network
namespace the second in the other network namespace, each with 4000 IPv6
addresses. This tool will then start a simple TCP server in one of the
namespace and in the other, open 4000 connections, each using a
different source and destination address.

The result is 4000 open connections, in theory requiring 8000 IPv6
neighborhood table entries.


Once the tool is done attempting to open that many connections, any
attempt to connect to a host in a directly connected IPv6 subnet
(so requiring a new neighborhood table entry) will fail with EINVAL.



While the global limit can indeed be bumped, so can the number of
connections established by this tool. I don't believe a global limit
influence by the number of namespaces would help here either since
whatever the resulting global limit ends up being, the tool can be
changed to establish $global_limit+1 connections.

I'm mostly a userspace guy and don't really know the details of the
kernel implementation, but considering that device creation and adding
addresses is now possible by any unprivileged user, having the limit of
neighborhood entries be per-interface rather than global would make
sense to me.


Hopefully this helped clarifiy the problem we've been seeing lately.

--=20
St=E9phane Graber
Ubuntu developer
http://www.canonical.com

--PuGuTyElPB9bOcsM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJUWPWmAAoJEMY4l01keS1n9oEP+wVUE8VmIRduAO13uYNkC0vn
gD3Bnrk7HYNvNMdg4KroJ6o3qFzRn24jHAV464MPSpAXxr65/AHhERp+tfuaNEg4
hdcenlVrz964NzC4F1Smb1R3cq4sA7YmT5TmmIOPlsu/JUhGh4UFMRX9/hhTU/bp
bm0/M5ap+CFRb9RvBzVn1y6D4WKC2LmvgFiwix6Vpt7n8RYE1G7G3E3SBYMtUoax
p8PTdFiTly4i/JVI2EFOgIOdl3NkFwEGJcGyA18KHhNy3cuFwH7viBkCU4uq2iHl
cVUxvPfjdhuBsoY8iGNV81x+0qVf7VxwKHOTPl7BuuJri902tgCeRnTgZLDYb77l
UHzwH+4sSmHhsiMAbFeOjwN5zioKpA9celjC+7tN2jZnEbAQVrV+KyD8FfezjlaW
3A4SToYRLvPWTKSS6Vv9fhIMFJQpU3LL92Nje4Yu131G7OHkqHMhy8JPra5pdXkR
cSAlFw9O7ErFKO7DvRE6UDQc6f50d6UHlWQeK6kE/gS/f6b4ZGNkot5g9XbNKtdW
lcjKNWhzmydK0+hq/6x/GFJyesvrrE319j0suhubxyDfh8ti5VVNq4hUFH9lcnDe
LimUJyTDhDDUllGbjm/omuNF5tRqCmzU71vJaotw3nLt+6gSeapYxpd/OfRK2e9V
J9mTbJ+IdAixd9O5El8/
=Oxao
-----END PGP SIGNATURE-----

--PuGuTyElPB9bOcsM--
