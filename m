From: Ian Campbell <ian.campbell@docker.com>
Subject: Re: [RFC v5 0/5] Add virtio transport for AF_VSOCK
Date: Fri, 08 Apr 2016 16:35:05 +0100
Message-ID: <1460129705.1749.25.camel@docker.com>
References: <1459520587-12337-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Matt Benjamin <mbenjamin@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	Alex =?ISO-8859-1?Q?Benn=E9e?= <alex.bennee@linaro.org>,
	marius vlad <marius.vlad0@gmail.com>, areis@redhat.com,
	Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	virtualization@lists.linux-foundation.org
To: Stefan Hajnoczi <stefanha@redhat.com>, kvm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37908 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758646AbcDHPfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 11:35:09 -0400
Received: by mail-wm0-f46.google.com with SMTP id u206so27247546wme.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 08:35:08 -0700 (PDT)
In-Reply-To: <1459520587-12337-1-git-send-email-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 15:23 +0100, Stefan Hajnoczi wrote:
> This series is based on Michael Tsirkin's vhost branch (v4.5-rc6).
>=20
> I'm about to process Claudio Imbrenda's locking fixes for virtio-vsoc=
k but
> first I want to share the latest version of the code.=C2=A0=C2=A0Seve=
ral people are
> playing with vsock now so sharing the latest code should avoid duplic=
ate work.

Thanks for this, I've been using it in my project and it mostly seems
fine.

One wrinkle I came across, which I'm not sure if it is by design or a
problem is that I can see this sequence coming from the guest (with
other activity in between):

=C2=A0 =C2=A0 1) OP_SHUTDOWN w/ flags =3D=3D SHUTDOWN_RX
=C2=A0=C2=A0=C2=A0=C2=A02) OP_SHUTDOWN w/ flags =3D=3D SHUTDOWN_TX
=C2=A0=C2=A0=C2=A0=C2=A03) OP_SHUTDOWN w/ flags =3D=3D SHUTDOWN_TX|SHUT=
DOWN_RX

I orignally had my backend close things down at #2, however this meant
that when #3 arrived it was for a non-existent socket (or, worse, an
active one if the ports got reused). I checked v5 of the spec
proposal[0] which says:
    If these bits are set and there are no more virtqueue buffers
    pending the socket is disconnected.

but I'm not entirely sure if this behaviour contradicts this or not
(the bits have both been set at #2, but not at the same time).

BTW, how does one tell if there are no more virtqueue buffers pending
or not while processing the op?

Another thing I noticed, which is really more to do with the generic
AF_VSOCK bits than anything to do with your patches is that there is no
limitations on which vsock ports a non-privileged user can bind to and
relatedly that there is no netns support so e.g. users in unproivileged
containers can bind to any vsock port and talk to the host, which might
be undesirable. For my use for now I just went with the big hammer
approach of denying access from anything other than init_net
namespace[1] while I consider what the right answer is.

Ian.

[0]=C2=A0http://thread.gmane.org/gmane.comp.emulators.virtio.devel/1092
[1]
=46rom 366c9c42afb9bd54f92f72518470c09e46f12e88 Mon Sep 17 00:00:00 200=
1
=46rom: Ian Campbell <ian.campbell@docker.com>
Date: Mon, 4 Apr 2016 14:50:10 +0100
Subject: [PATCH] VSOCK: Only allow host network namespace to use AF_VSO=
CK.

The VSOCK addressing schema does not really lend itself to simply creat=
ing an
alternative end point address within a namespace.

Signed-off-by: Ian Campbell <ian.campbell@docker.com>
---
=C2=A0net/vmw_vsock/af_vsock.c | 3 +++
=C2=A01 file changed, 3 insertions(+)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 1e5f5ed..cdb3dd3 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1840,6 +1840,9 @@ static const struct proto_ops vsock_stream_ops =3D=
 {
=C2=A0static int vsock_create(struct net *net, struct socket *sock,
=C2=A0			int protocol, int kern)
=C2=A0{
+	if (!net_eq(net, &init_net))
+		return -EAFNOSUPPORT;
+
=C2=A0	if (!sock)
=C2=A0		return -EINVAL;
=C2=A0
--=C2=A0
2.8.0.rc3
