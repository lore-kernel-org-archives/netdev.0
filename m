From: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
Date: Fri, 11 Sep 2015 14:18:18 +0100
Message-ID: <20150911131818.GP21084@n2100.arm.linux.org.uk>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
 <1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1441976691.4619.58.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 11, 2015 at 06:04:51AM -0700, Eric Dumazet wrote:
> On Fri, 2015-09-11 at 12:38 +0100, Russell King - ARM Linux wrote:
> > I have a recent Marvell Armada 388 board here which uses the mvneta
> > driver.  I'm seeing some weird effects with NFS with it acting as a
> > client.  Unfortunately, the board does not have a functional RTC.
> >=20
> > The NFS server is the same NFS server that I've used for years with
> > multiple other clients (it's my main NFS server) and it continues t=
o
> > support all other clients without any ill effect.  The NFS server
> > kernel is rather old now, being a 3.x kernel.
> >=20
> > The NFS client appears to connect using TCP/IPv6 and initially is
> > accessible.  Everything appears to work normally, and then the NFS
> > server appears to stop responding.
> >=20
> > Running tcpdump on the NFS server, and then dumping the captured
> > packets
> > with tshark (because tcpdump appears not to understand IPv6 SYNs on
> > the
> > NFS port) shows:
> >=20
> >   3   0.030036 armada388 -> n2100 TCP 843=E2=86=92nfs [SYN] Seq=3D9=
36803106
> > Win=3D28800 Len=3D0 MSS=3D1440 SACK_PERM=3D1 TSval=3D892366 TSecr=3D=
0 WS=3D128
>=20
> >   4   0.030409 n2100 -> armada388 TCP nfs=E2=86=92843 [SYN, ACK] Se=
q=3D409465870
> > Ack=3D936803107 Win=3D28560 Len=3D0 MSS=3D1440 SACK_PERM=3D1
> >  TSval=3D818169117 TSecr=3D892366 WS=3D64
>=20
> >   5   0.030493 armada388 -> n2100 TCP [TCP Port numbers reused]
> > 843=E2=86=92nfs [SYN] Seq=3D936803633 Win=3D28800 Len=3D0 MSS=3D144=
0 SACK_PERM=3D1
> > TSval=3D892366 TSecr=3D0 WS=3D128
>=20
> Yes, this packet looks very wrong. Like two simultaneous connect with
> same source port. It is not a retransmit (Seq numbers differ)
>=20
> >   6   0.030699 n2100 -> armada388 TCP nfs=E2=86=92843 [RST, ACK] Se=
q=3D0
> > Ack=3D936803634 Win=3D0 Len=3D0
> >   7   0.030766 armada388 -> n2100 TCP 843=E2=86=92nfs [RST] Seq=3D9=
36803107
> > Win=3D0 Len=3D0
>=20
> I suspect port reuse in NFS being broken.
>=20
> Have you tried to apply

Thanks, I'll give this a go and report back.

I've been trying to debug this unsuccessfully.  It's really not helpful
to enable rpc debugging, and then be greeted with this from printk:

[ 2760.156924] RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
[ 2760.163218] RPC:       xs_tcp_state_change client ee240800...
[ 2760.168976] RPC:       state 5 conn 0 dead 0 zapped 1 sk_shutdown 3
[ 2760.175273] RPC:       xs_tcp_state_change client ee240800...
[ 2760.181032] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
[ 2760.187315] RPC:       disconnected transport ee240800
[ 2760.192467] RPC:       xs_tcp_state_change client ee240800...
[ 2760.198224] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
[ 2760.204505] RPC:       disconnected transport ee240800
[ 2760.209653] RPC:       xs_tcp_data_ready...
[ 2760.215001] RPC:       wake_up_first(ee240918 "xprt_sending")
lspci -vvx |less
[ 2805.912330] RPC:       looking up Generic cred
[ 2805.916791] RPC:       looking up Generic cred
[ 2805.921259] RPC:       looking up Generic cred
[ 2805.921784] RPC:       looking up Generic cred
[ 2805.921787] RPC:       looking up Generic cred
[ 2805.921788] RPC:       looking up Generic cred
[ 2805.921792] RPC:       new task initialized, procpid 327
[ 2805.921794] RPC:       allocated task ee358300
[ 2805.921797] RPC:  1335 __rpc_execute flags=3D0x80
[ 2805.921800] RPC:  1335 call_start nfs3 proc ACCESS (sync)
[ 2805.921801] RPC:  1335 call_reserve (status 0)
[ 2805.921805] RPC:  1335 reserved req ee8a2900 xid af74741b
** 168 printk messages dropped ** [ 2805.928207] RPC:       read reply =
XID b174741b
** 366 printk messages dropped ** [ 2805.941242] RPC:  1343 setting ala=
rm for 60000 ms
** 310 printk messages dropped ** [ 2805.958274] RPC:       xprt =3D ee=
240800, tcp_copied =3D 120, tcp_offset =3D 120, tcp_reclen =3D 120
** 89 printk messages dropped ** [ 2805.959613] RPC:  1350 reserved req=
 ee8a2900 xid be74741b
[ 2805.959614] RPC:       wake_up_first(ee240918 "xprt_sending")

which is just where we want to see the printk messages.  This kind'a
makes printk and the rpc debug stuff rather useless. :(

--=20
=46TTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
