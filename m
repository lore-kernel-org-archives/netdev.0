From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [RFC 1/3] vsockmon: Add tap functions.
Date: Fri, 10 Jun 2016 16:44:45 +0100
Message-ID: <20160610154445.GE3855@stefanha-x1.localdomain>
References: <20160528162907.14809-1-ggarcia@deic.uab.cat>
 <20160528162907.14809-2-ggarcia@deic.uab.cat>
 <20160601210703.GF15594@stefanha-x1.localdomain>
 <969687fe-f812-7412-bd06-89b159daa88a@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SNIs70sCzqvszXB4"
Cc: netdev@vger.kernel.org, jhansen@vmware.com
To: Gerard Garcia <ggarcia@abra.uab.cat>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59967 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751949AbcFJPo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 11:44:58 -0400
Content-Disposition: inline
In-Reply-To: <969687fe-f812-7412-bd06-89b159daa88a@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SNIs70sCzqvszXB4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 09, 2016 at 05:02:47PM +0200, Gerard Garcia wrote:
> On 06/01/2016 11:07 PM, Stefan Hajnoczi wrote:
> > On Sat, May 28, 2016 at 06:29:05PM +0200, ggarcia@abra.uab.cat wrote:
> > > diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
> > > index 6b158ab..ec7a05d 100644
> > > --- a/net/vmw_vsock/af_vsock.c
> > > +++ b/net/vmw_vsock/af_vsock.c
> > > @@ -96,6 +96,7 @@
> > >   #include <linux/unistd.h>
> > >   #include <linux/wait.h>
> > >   #include <linux/workqueue.h>
> > > +#include <linux/if_arp.h>
> > >   #include <net/sock.h>
> > >   #include <net/af_vsock.h>
> > > @@ -2012,6 +2013,110 @@ const struct vsock_transport *vsock_core_get_transport(void)
> > >   }
> > >   EXPORT_SYMBOL_GPL(vsock_core_get_transport);
> > > +/**** TAP ****/
> > Feel free to put this in a separate source file.  The Kbuild can link
> > multiple objects into a single kernel module.  That would be cleaner
> > than using a big comment to separate it from af_vsock.c code.
> I'm following the af_vsock.c style, where different logic is separated using
> this style of comments. It is not a lot of code
> so I thought it would be cleaner to have it in the same file.

It's up to the af_vsock.c maintainer, but if we keep appending
independent chunks of code to one file it becomes hard to manage and
chances of conflicts during patch merging increases.

> > > +int vsock_add_tap(struct vsock_tap *vt) {
> > > +	if (unlikely(vt->dev->type != ARPHRD_VSOCKMON))
> > > +		return -EINVAL;
> > > +
> > > +	spin_lock(&vsock_tap_lock);
> > > +	list_add_rcu(&vt->list, &vsock_tap_all);
> > > +	spin_unlock(&vsock_tap_lock);
> > > +
> > > +	__module_get(vt->module);
> > It's slightly safer to get the module before publishing it on the list.
> > But in practice I guess the caller is the module so the module won't
> > disappear underneath us.
> This function is equal to the function in af_netlink.c used by nlmon. As you
> said, in practice the caller is the module
> so it won't disappear.

Yes, there isn't a huge win right now but given that it's easy to
resolve the issue I'd do it.  The problem comes when people copy-paste
code that contains assumptions and the assumption no longer holds.
Better to write it in the safe way, eliminating the assumption, so that
derived code will be correct under more conditions.  There is no
drawback to moving __module_get() above the spin_lock().

--SNIs70sCzqvszXB4
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXWuBtAAoJEJykq7OBq3PIm7UH/A/0Q+knYN6LcDhqdM5BmWP3
sTfxqV3X4aIDMAiQj0JPzU5rv3vdlE+rnqTtZC+1tGWLDHLqKQSUSvL4uK3WsYY3
7lMephCLRXhz7HZXlYKPqWCo3Xyx6AF43bmRIrEvU3psRxmM+BPsxN4Zup4I7ynj
1G+VMUqCOu1pimQsyuPWXdQSdh/kcIBzGCdAvDI2bkAkDY/BDiP8oTpIj8crjFzb
wKiU2S376LgARiPhii9kGAQxwgiE+MiYi1i14zW94nIDQnUDJTeIVX4ljvxSZkwP
A3uswHhcqTE9sYEpq1ySt+DxYSQ3dTlDS9ztiKzWzXRQo7CfQVhgSah3LGX0DCM=
=S0MU
-----END PGP SIGNATURE-----

--SNIs70sCzqvszXB4--
