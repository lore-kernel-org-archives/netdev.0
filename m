From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: discrepancy in ip(7) wrt. IP DF flag for UDP sockets
Date: Tue, 20 Sep 2011 09:38:37 -0400
Message-ID: <20110920133837.GA16323@hmsreliant.think-freely.org>
References: <20110919121940.GA19942@synalogic.ca>
 <20110919130313.GA27819@hmsreliant.think-freely.org>
 <CAKgNAkgWRdkxgTXNnMi4PVGGsOd-8EHF1siBrk-Bj=rnYenVmQ@mail.gmail.com>
 <20110920132954.GA23041@synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Benjamin Poirier <benjamin.poirier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110920132954.GA23041-k/PPzeaMb74v2OKnPYDugg@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 20, 2011 at 09:29:54AM -0400, Benjamin Poirier wrote:
> On 11-09-20 08:14, Michael Kerrisk wrote:
> > Hello Benjamin, Neil,
> >=20
> > On Mon, Sep 19, 2011 at 3:03 PM, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org=
> wrote:
> > > On Mon, Sep 19, 2011 at 08:19:40AM -0400, Benjamin Poirier wrote:
> > >> Hi,
> > >>
> > >> I noticed what appears to be a discrepancy between the ip(7) man=
 page
> > >> and the kernel code with regards to the IP DF flag for UDP socke=
ts.
> > >>
> > >> The man page says that "The don't-fragment flag is set on all ou=
tgoing
> > >> datagrams" and that the ip_no_pmtu_disc sysctl affects only SOCK=
_STREAM
> > >> sockets. This is quickly disproved by doing:
> > >> echo 1 > /proc/sys/net/ipv4/ip_no_pmtu_disc
> > >> firing up netcat and looking at a few outgoing udp packets in wi=
reshark
> > >> (they don't have the DF flag set).
> >=20
> > Could you describe the required change in terms of how the man page
> > text should look--i.e., rewrite the passage as you think it should
> > look?
>=20
> How about changing it to:
> 	IP_MTU_DISCOVER (since Linux 2.2)
> 	Set or receive the Path MTU Discovery setting for a socket. When
> 	enabled, the don't-fragment flag is set on all outgoing packets.
> 	Linux will perform Path MTU Discovery as defined in RFC 1191 on
> 	SOCK_STREAM sockets. For non-SOCK_STREAM sockets, it is the
> 	user's responsibility to packetize the data in MTU sized chunks
> 	and to do the retransmits if necessary. The kernel will reject
> 	(with EMSGSIZE) datagrams that are bigger than the known path
> 	MTU. The system-wide default is controlled by the
> 	/proc/sys/net/ipv4/ip_no_pmtu_disc file.=20
>=20
> 	Path MTU discovery flags   Meaning
> 	[...]
>=20
> There are some differences between _DO and _WANT that are glossed ove=
r
> in this description, but I suppose there's only so much detail you ca=
n
> put in...
>=20
> Thanks,
> -Ben
>=20
Yeah, I think thats close, but its only the users responsibility to pac=
kage
datagrams in mtu sized chunks if they force the dont fragment bit on.  =
If they
go wtih the default, the stack will fragment a datagram is it sees fit =
according
to the mtu of the path it traverses
Neil

> >=20
> > Thanks,
> >=20
> > Michael
> >=20
> >=20
> > >> 1) in the words of `man 7 ip`:
> > >> IP_MTU_DISCOVER (since Linux 2.2)
> > >> =A0 =A0 =A0 Set or receive the Path MTU Discovery =A0setting =A0=
for =A0a =A0socket.
> > >> =A0 =A0 =A0 When =A0enabled, Linux will perform Path MTU Discove=
ry as defined
> > >> =A0 =A0 =A0 in RFC 1191 on this socket. =A0The don't-fragment fl=
ag is set =A0on
> > >> =A0 =A0 =A0 all =A0outgoing datagrams. =A0The system-wide defaul=
t is controlled
> > >> =A0 =A0 =A0 by the /proc/sys/net/ipv4/ip_no_pmtu_disc file for =A0=
SOCK_STREAM
> > >> =A0 =A0 =A0 sockets, and disabled on all others.
> > >>
> > >> This is the text present in the latest version of the online man=
pages,
> > >> http://webcache.googleusercontent.com/search?q=3Dcache:http://ww=
w.kernel.org/doc/man-pages/reporting_bugs.html&ie=3DUTF-8
> > >>
> > >> 2) in net/ipv4/af_inet.c:inet_create():
> > >> =A0 =A0 =A0 if (ipv4_config.no_pmtu_disc)
> > >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet->pmtudisc =3D IP_PMTUDISC_DONT;
> > >> =A0 =A0 =A0 else
> > >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet->pmtudisc =3D IP_PMTUDISC_WANT;
> > >>
> > >> and pmtudisc is left alone from there on for UDP sockets.
> > >>
> > >> What should be adjusted, the man page or the code?
> > >>
> > > The man page is wrong I think
> > >
> > > By my read, the code:
> > > 1) Affects UDP and TCP the same way (which makes sense to me)
> > >
> > > 2) Is doing exactly what you asked it to, since you set no_pmtu_d=
isc, which
> > > means the stack should be free to fragment a frame as it sees fit=
 according to
> > > the MTU metric of the route its traversing, hence the cleared DF =
bit in the
> > > fraem.
> > >
> > > RFC 1191 can apply equally well to udp, as tcp, and is evident in=
 that you can
> > > set the per-socket option IP_MTU_DISCOVER to any of the 4 accepti=
ble values
> > > offered (DONT/WANT/DO/PROBE), so theres no reason the sysctl gove=
rning the
> > > default value at creation shouldn't apply as well.
> > > Neil
> > >
> > >
> >=20
> >=20
> >=20
> > --=20
> > Michael Kerrisk
> > Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> > Author of "The Linux Programming Interface"; http://man7.org/tlpi/
>=20
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
