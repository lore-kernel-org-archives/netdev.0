From: Ross Kendall Axe <ross.axe@blueyonder.co.uk>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
 using SELinux and SOCK_SEQPACKET
Date: Fri, 19 Nov 2004 03:23:50 +0000
Message-ID: <419D6746.2020603@blueyonder.co.uk>
References: <Xine.LNX.4.44.0411180257300.3144-100000@thoron.boston.redhat.com> <Xine.LNX.4.44.0411180305060.3192-100000@thoron.boston.redhat.com> <20041118084449.Z14339@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2BDD3484146A7E1EC73F5BEF"
Cc: James Morris <jmorris@redhat.com>, netdev@oss.sgi.com,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20041118084449.Z14339@build.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2BDD3484146A7E1EC73F5BEF
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Chris Wright wrote:
> 
> Why not make a unix_seq_sendmsg, which is a very small wrapper?
> e.g.
> static int unix_seq_sendmsg(struct kiocb *kiocb, struct socket *sock,
> 			    struct msghdr *msg, size_t len)
> {
> 	struct sock *sk = sock->sk;
> 
> 	if (sk->sk_type == SOCK_SEQPACKET && sk->sk_state != TCP_ESTABLISHED)
> 		return -ENOTCONN;
> 	if (msg->msg_name || msg->msg_namelen)
> 		return -EINVAL;
> 	return unix_dgram_sendmsg(kiocb, sock, msg, len);
> }
> 
> 
> -chris

Taking this idea further, couldn't we split unix_dgram_sendmsg into 2 
functions, do_unix_dgram_sendmsg and do_unix_connectionless_sendmsg (and 
similarly for unix_stream_sendmsg), then all we'd need is:

<pseudocode>
static int do_unix_dgram_sendmsg(...);
static int do_unix_stream_sendmsg(...);
static int do_unix_connectionless_sendmsg(...);
static int do_unix_connectional_sendmsg(...);

static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
			      struct msghdr *msg, size_t len)
{
	return do_unix_connectionless_sendmsg(kiocb, sock, msg, len,
					      do_unix_dgram_sendmsg);
}
static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
			       struct msghdr *msg, size_t len)
{
	return do_unix_connectional_sendmsg(kiocb, sock, msg, len,
					    do_unix_stream_sendmsg);
}
static int unix_seqpacket_sendmsg(struct kiocb *kiocb, struct socket *sock,
				  struct msghdr *msg, size_t len)
{
	return do_unix_connectional_sendmsg(kiocb, sock, msg, len,
					    do_unix_dgram_sendmsg);
}
</pseudocode>

What do we think?

Ross


--------------enig2BDD3484146A7E1EC73F5BEF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBnWdK9bR4xmappRARAihLAKCzFZPZApRyoBKS4/FQXpqjTV6XYACg2nl3
wa0It2/jwa5kPymDxtXygjk=
=1TBd
-----END PGP SIGNATURE-----

--------------enig2BDD3484146A7E1EC73F5BEF--
