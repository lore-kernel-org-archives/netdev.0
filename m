From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 16603] New: send of data > 4 GB fails on 64
 bit systems
Date: Mon, 27 Sep 2010 20:24:25 -0700 (PDT)
Message-ID: <20100927.202425.71120040.davem@davemloft.net>
References: <bug-16603-10286@https.bugzilla.kernel.org/>
	<20100927161540.776f748e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, bono@onlinehome.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55405
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758011Ab0I1DYG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 23:24:06 -0400
In-Reply-To: <20100927161540.776f748e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, I suspect the following is enough to fix this specific bug
report, TCP sending.

However, as I stated in my previous reply there are creepy
crawlies all over the place.

=46or example, all of the routines in net/core/iovec.c (memcpy_toiovec,
memcpy_toiovecend, memcpy_fromiovec, memcpy_fromiovecend,
csum_partial_copy_fromiovecend) that cast using min_t() are currently
casting "down" to "unsigned int".

They should probably case "up" to "size_t".

Otherwise 4GB iov_len's on 64-bit will be truncated to zero just
as they do in the TCP path being fixed here.

If, alterntatively, we want to try and take the size_t values all
the way down the code paths to the individual copies, that is
a huge undertaking.

It's huge because we end up getting to the architecture specific
csum_copy_*() routines, which all take 'int' as the length and
many are written in assembler and would need audits and potentially
changes before we can make the type 'long' or 'size_t'.

Anyways, this part here is simple enough and I'll push it to
Linus and -stable.

--------------------
tcp: Fix >4GB writes on 64-bit.

=46ixes kernel bugzilla #16603

tcp_sendmsg() truncates iov_len to an 'int' which a 4GB write to write
zero bytes, for example.

There is also the problem higher up of how verify_iovec() works.  It
wants to prevent the total length from looking like an error return
value.

However it does this using 'int', but syscalls return 'long' (and
thus signed 64-bit on 64-bit machines).  So it could trigger
false-positives on 64-bit as written.  So fix it to use 'long'.

Reported-by: Olaf Bonorden <bono@onlinehome.de>
Reported-by: Daniel B=FCse <dbuese@gmx.de>
Reported-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/socket.h b/include/linux/socket.h
index a2fada9..a8f56e1 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -322,7 +322,7 @@ extern int csum_partial_copy_fromiovecend(unsigned =
char *kdata,
 					  int offset,=20
 					  unsigned int len, __wsum *csump);
=20
-extern int verify_iovec(struct msghdr *m, struct iovec *iov, struct so=
ckaddr *address, int mode);
+extern long verify_iovec(struct msghdr *m, struct iovec *iov, struct s=
ockaddr *address, int mode);
 extern int memcpy_toiovec(struct iovec *v, unsigned char *kdata, int l=
en);
 extern int memcpy_toiovecend(const struct iovec *v, unsigned char *kda=
ta,
 			     int offset, int len);
diff --git a/net/core/iovec.c b/net/core/iovec.c
index 1cd98df..e6b133b 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -35,9 +35,10 @@
  *	in any case.
  */
=20
-int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr =
*address, int mode)
+long verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr=
 *address, int mode)
 {
-	int size, err, ct;
+	int size, ct;
+	long err;
=20
 	if (m->msg_namelen) {
 		if (mode =3D=3D VERIFY_READ) {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 95d75d4..f115ea6 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -943,7 +943,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk=
, struct msghdr *msg,
 	sg =3D sk->sk_route_caps & NETIF_F_SG;
=20
 	while (--iovlen >=3D 0) {
-		int seglen =3D iov->iov_len;
+		size_t seglen =3D iov->iov_len;
 		unsigned char __user *from =3D iov->iov_base;
=20
 		iov++;
