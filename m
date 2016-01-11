From: Nikos Mavrogiannopoulos <nmav@gnutls.org>
Subject: Re: [RFC PATCH 0/2] Crypto kernel TLS socket
Date: Mon, 11 Jan 2016 16:12:44 +0100
Message-ID: <CAJU7za+TgKsOr64o3YnMicDrhZ8hx0rdjAU+EKrmQ8Qj=s2FVA@mail.gmail.com>
References: <cover.1448299690.git.davejwatson@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:33947 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760403AbcAKPNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 10:13:25 -0500
In-Reply-To: <cover.1448299690.git.davejwatson@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2015 at 6:42 PM, Dave Watson <davejwatson@fb.com> wrote:
> An approach for a kernel TLS socket.
> Only the symmetric encryption / decryption is done in-kernel, as well
> as minimal framing handling.  The handshake is kept in userspace, and
> the negotiated cipher / keys / IVs are then set on the algif_tls
> socket, which is then hooked in to a tcp socket using
> sk_write_space/sk_data_ready hooks.
> If a non application-data TLS record is seen, it is left on the TCP
> socket and an error is returned on the ALG socket, and the record is
> left for userspace to manage. Userspace can't ignore the message, but
> could just close the socket.
> TLS could potentially also be done directly on the TCP socket, but
> seemed a bit harder to work with the OOB data for non application_data
> messages, and the sockopts / CMSGS already exist for ALG sockets.  The
> flip side is having to manage two fds in userspace.
> Some reasons we're looking at this:
>
> 1) Access to sendfile/splice for CDN-type applications.  We were
>    inspired by Netflix exploring this in FreeBSD
>
>    https://people.freebsd.org/~rrs/asiabsd_2015_tls.pdf
>
>    For perf, this patch is almost on par with userspace OpenSSL.
>    Currently there are some copies and allocs to support
>    scatter/gather in aesni-intel_glue.c, but with some extra work to
>    remove those (not included here), a sendfile() is faster than the
>    equivalent userspace read/SSL_write using a 128k buffer by 2~7%.

Hi,
 That's quite an interesting feature as we were investigating
something similar for openconnect VPN. One additional argument for
such functionality is the acceleration of SSL VPNs. With a TLS (or
DTLS) socket one could avoid expensive copies from tun to userspace
and then to network layer and vice versa. The tricky part would be how
easy one could switch from the kernel TLS implementation to userspace
TLS implementation (e.g., to perform a rehandshake) and vice versa.

regards,
Nikos
