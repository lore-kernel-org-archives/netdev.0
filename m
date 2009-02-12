From: Clement LECIGNE <clement.lecigne@netasq.com>
Subject: [PATCH] 4 bytes kernel memory disclosure in SO_BSDCOMPAT gsopt try
	#2
Date: Thu, 12 Feb 2009 13:35:45 +0100
Message-ID: <20090212123545.GA46788@clem1.netasq.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758732AbZBLMgT@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

In function sock_getsockopt() located in net/core/sock.c, optval v.val
is not correctly initialized and directly returned in userland in case
we have SO_BSDCOMPAT option set.

This dummy code should trigger the bug:

int main(void)
{
	unsigned char buf[4] =3D { 0, 0, 0, 0 };
	int len;
	int sock;
	sock =3D socket(33, 2, 2);
	getsockopt(sock, 1, SO_BSDCOMPAT, &buf, &len);
	printf("%x%x%x%x\n", buf[0], buf[1], buf[2], buf[3]);
	close(sock);
}

Here is a patch that fix this bug by initalizing v.val just after its d=
eclaration.

--- linux/net/core/sock.c.orig	2008-12-12 12:27:46.000000000 -0800
+++ linux/net/core/sock.c	2008-12-12 12:27:50.000000000 -0800
@@ -695,6 +695,8 @@ int sock_getsockopt(struct socket *sock,
 	if (len < 0)
 		return -EINVAL;
=20
+	v.val =3D 0;
+
 	switch(optname) {
 	case SO_DEBUG:
 		v.val =3D sock_flag(sk, SOCK_DBG);

Signed-off-by: Cl=E9ment Lecigne <clement.lecigne@netasq.com>

--=20
Cl=E9ment LECIGNE,
"In Python, how do you create a string of random characters?" -- "Read =
a Perl file!"
