From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: (5/5+1) Autoconfig link-local addr to IPv6 tunnels
Date: Tue, 2 Sep 2003 17:40:15 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309021735350.4244-100000@netcore.fi>
References: <Pine.LNX.4.44.0309011709370.29198-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <yoshfuji@linux-ipv6.org>,
   <usagi-core@linux-ipv6.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0309011709370.29198-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Sep 2003, Ville Nuorvala wrote:
> On Mon, 1 Sep 2003, David S. Miller wrote:
> > On Mon, 1 Sep 2003 13:48:44 +0300 (EEST)
> > Pekka Savola <pekkas@netcore.fi> wrote:
> >
> > > Well, link-local addresses are used e.g. by routing protocols and such, so
> > > having one is probably rather important..
> >
> > Ok.
> >
> > > FWIW, on FreeBSD platform they take the link-local address of the first
> > > physical interface, and give the exact same link-local address on all of
> > > the tunnels, disambiuating them with the scope identifier.  Seems like an
> > > OK appaorach too, and guarantees (to the degree of unique MAC addresses)
> > > that the addresses of the endpoints do not clash.
> >
> > Interesting approach...  I'm not particularly picky about how this
> > uniqueness issue is solved.
> 
> Ok, this incremental patch to my previous addrconf.c patch generates a
> link-local address to the IPv6 tunnel device. It first tries to inherit
> the EUI64 identifier of some other device and if this fails, uses a
> random interface id.

Two comments:

+       /* try to inherit EUI64 from another device */
+       for (dev = dev_base; dev; dev = dev->next) {
+               if (!ipv6_generate_eui64(addr.s6_addr + 8, dev)) {
+                       addrconf_add_linklocal(idev, &addr);
+                       return;
+

==> does this really inherit _EUI64_, *or* MAC address (or something like
it) to derive an EUI64?  Note that there is a significant difference when
you've configured manually e.g. 3ffe:ffff:f00:ba::1 on a device, and the
case when you've auto-configured the interface identifier from the MAC
address of the device.

The latter is probably always unique.  The former is not necessarily
sufficiently unique (but better than nothing, of course).

+#ifdef CONFIG_IPV6_PRIVACY
+       /* else try to generate a random identifier */
+       if (!__ipv6_regen_rndid(idev)) {
+               memcpy(addr.s6_addr + 8, idev->rndid, 8);
+               addrconf_add_linklocal(idev, &addr);
+               return;
+

==> my question is: as the former method to steal an EUI64 should succeed
pretty much always, is it useful to add basically dead code which never
gets executed here?  I certainly can't think of any scenario where you'd
have no interface to steal the MAC address/EUI64 from and you'd have to
fall back to random identifiers?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
