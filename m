From: Phil Sutter <phil.sutter@viprinet.com>
Subject: Re: [PATCH] af_packet: flush complete kernel cache in packet_sendmsg
Date: Mon, 5 Sep 2011 21:57:14 +0200
Message-ID: <20110905195714.GC29025@philter>
References: <20110505141107.GC30443@orbit.nwl.cc>
 <1314961686-30870-1-git-send-email-phil.sutter@viprinet.com>
 <1314971179.3092.159.camel@deadeye>
 <20110902172850.GB6619@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vipri.net ([89.207.250.2]:43390 "EHLO mail.vipri.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753600Ab1IET5g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Sep 2011 15:57:36 -0400
Content-Disposition: inline
In-Reply-To: <20110902172850.GB6619@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Sep 02, 2011 at 06:28:50PM +0100, Russell King - ARM Linux wrot=
e:
> On Fri, Sep 02, 2011 at 02:46:17PM +0100, Ben Hutchings wrote:
> > On Fri, 2011-09-02 at 13:08 +0200, Phil Sutter wrote:
> > > This flushes the cache before and after accessing the mmapped pac=
ket
> > > buffer. It seems like the call to flush_dcache_page from inside
> > > __packet_get_status is not enough on Kirkwood (or ARM in general)=
=2E
> > > ---
> > > I know this is far from an optimal solution, but it's in fact the=
 only working
> > > one I found.
> > [...]
> >=20
> > This is ridiculous.  If flush_dcache_page() isn't doing everything =
it
> > should, you need to fix that.
>=20
> It does do everything it should - which is to perform maintanence on
> page cache pages.  It flushes the kernel mapping of the page.  It
> also flushes the userspace mappings of the page which it finds by
> walking the mmap list via the associated struct page.  It does not
> touch vmalloc mappings because it has no way to know whether they
> exist or not.
>=20
> It doesn't do so much for anonymous pages - to do so would only
> duplicate what flush_anon_page() does at the very same callsites.
> Plus the mmap list isn't available for such pages so there's no
> way to find out what userspace addresses to flush.

Indeed very interesting information, thanks a lot!

The code in question uses __get_free_pages(), and if that fails uses
vmalloc() (see alloc_one_pg_vec_page() for reference). Both code paths
show result in the same faulty behaviour.

> If the AF_PACKET buffers are created from anonymous pages and it's
> using flush_dcache_page(), it's using the wrong interface.

So, in order to fix this, which alternative would you suggest? Quite a
lot of work has been done regarding memory allocation, so I guess
changing that side is a no-go.

Greetings, Phil

--=20
Viprinet GmbH
Mainzer Str. 43
55411 Bingen am Rhein
Germany

Zentrale:     +49-6721-49030-0
Durchwahl:    +49-6721-49030-134
=46ax:          +49-6721-49030-209

phil.sutter@viprinet.com
http://www.viprinet.com

Sitz der Gesellschaft: Bingen am Rhein
Handelsregister: Amtsgericht Mainz HRB40380
Gesch=C3=A4ftsf=C3=BChrer: Simon Kissel
