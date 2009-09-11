From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Fri, 11 Sep 2009 12:44:11 +0300
Message-ID: <20090911094411.GA11086@redhat.com>
References: <20090910125929.GA32593@redhat.com> <200909110017.27668.paul.moore@hp.com> <20090911045943.GA1613@redhat.com> <20090911053610.GA10324@redhat.com> <4AA9E9D3.5070406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Moore <paul.moore@hp.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753865AbZIKJpx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 05:45:53 -0400
Content-Disposition: inline
In-Reply-To: <4AA9E9D3.5070406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2009 at 08:10:27AM +0200, Eric Dumazet wrote:
> Michael S. Tsirkin a =E9crit :
> > On Fri, Sep 11, 2009 at 07:59:43AM +0300, Michael S. Tsirkin wrote:
> >> On Fri, Sep 11, 2009 at 12:17:27AM -0400, Paul Moore wrote:
> >>> On Thursday 10 September 2009 08:59:29 am Michael S. Tsirkin wrot=
e:
> >>>> Tun device looks similar to a packet socket
> >>>> in that both pass complete frames from/to userspace.
> >>>>
> >>>> This patch fills in enough fields in the socket underlying tun d=
river
> >>>> to support sendmsg/recvmsg operations, and exports access to thi=
s socket
> >>>> to modules.
> >>>>
> >>>> This way, code using raw sockets to inject packets
> >>>> into a physical device, can support injecting
> >>>> packets into host network stack almost without modification.
> >>>>
> >>>> First user of this interface will be vhost virtualization
> >>>> accelerator.
> >>> No comments on the code at this point - I'm just trying to unders=
tand the=20
> >>> intended user right now which I'm assuming is the vhost-net bits =
you sent=20
> >>> previously?=20
> >> Yes - these now use raw socket,
> >=20
> > More specifically, vhost would then be patched with:
> >=20
> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > index aeffb3a..b54f9d6 100644
> > --- a/drivers/vhost/net.c
> > +++ b/drivers/vhost/net.c
> > @@ -331,15 +331,26 @@ err:
> >  	return ERR_PTR(r);
> >  }
> > =20
> > +static struct socket *get_tun_socket(int fd)
> > +{
> > +	struct file *file =3D fget(fd);
> > +	if (!file)
> > +		return ERR_PTR(-EBADF);
> > +	return tun_get_socket(file);
>=20
> This would leak a reference on file, if it happens not being a tun fi=
le=20

Good catch, thanks! So it should be:

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index aeffb3a..e70f954 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -331,16 +331,30 @@ err:
 	return ERR_PTR(r);
 }
=20
+static struct socket *get_tun_socket(int fd)
+{
+	struct file *file =3D fget(fd);
+	struct socket *sock;
+	if (!file)
+		return ERR_PTR(-EBADF);
+	sock =3D tun_get_socket(file);
+	if (IS_ERR(sock))
+		fput(file);
+	return sock;
+}
+
 static struct socket *get_socket(int fd)
 {
 	struct socket *sock;
 	sock =3D get_raw_socket(fd);
 	if (!IS_ERR(sock))
 		return sock;
+	sock =3D get_tun_socket(fd);
+	if (!IS_ERR(sock))
+		return sock;
 	return ERR_PTR(-ENOTSOCK);
 }
=20
-
 static long vhost_net_set_socket(struct vhost_net *n, int fd)
 {
 	struct socket *sock, *oldsock =3D NULL;
