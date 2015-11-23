From: Dave Watson <davejwatson@fb.com>
Subject: [RFC PATCH 0/2] Crypto kernel TLS socket
Date: Mon, 23 Nov 2015 09:42:24 -0800
Message-ID: <cover.1448299690.git.davejwatson@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	<linux-crypto@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An approach for a kernel TLS socket.

Only the symmetric encryption / decryption is done in-kernel, as well
as minimal framing handling.  The handshake is kept in userspace, and
the negotiated cipher / keys / IVs are then set on the algif_tls
socket, which is then hooked in to a tcp socket using
sk_write_space/sk_data_ready hooks.

If a non application-data TLS record is seen, it is left on the TCP
socket and an error is returned on the ALG socket, and the record is
left for userspace to manage. Userspace can't ignore the message, but
could just close the socket.

TLS could potentially also be done directly on the TCP socket, but
seemed a bit harder to work with the OOB data for non application_data
messages, and the sockopts / CMSGS already exist for ALG sockets.  The
flip side is having to manage two fds in userspace.

Some reasons we're looking at this:

1) Access to sendfile/splice for CDN-type applications.  We were
   inspired by Netflix exploring this in FreeBSD

   https://people.freebsd.org/~rrs/asiabsd_2015_tls.pdf

   For perf, this patch is almost on par with userspace OpenSSL.
   Currently there are some copies and allocs to support
   scatter/gather in aesni-intel_glue.c, but with some extra work to
   remove those (not included here), a sendfile() is faster than the
   equivalent userspace read/SSL_write using a 128k buffer by 2~7%.

2) Access to the unencrypted bytes in kernelspace.  For example, Tom
   Herbert's kcm would need this

   https://lwn.net/Articles/657999/

3) NIC offload. To support running aesni routines on the NIC instead
   of the processor, we would probably need enough of the framing
   interface put in kernel.


Dave Watson (2):
  Crypto support aesni rfc5288
  Crypto kernel tls socket

 arch/x86/crypto/aesni-intel_asm.S        |    6 +
 arch/x86/crypto/aesni-intel_avx-x86_64.S |    4 +
 arch/x86/crypto/aesni-intel_glue.c       |  105 ++-
 crypto/Kconfig                           |   12 +
 crypto/Makefile                          |    1 +
 crypto/algif_tls.c                       | 1233 ++++++++++++++++++++++++++++++
 6 files changed, 1334 insertions(+), 27 deletions(-)
 create mode 100644 crypto/algif_tls.c

--
2.4.6
