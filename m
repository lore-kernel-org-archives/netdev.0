From: Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] tcp: provide SYN headers for passive connections
Date: Mon, 4 May 2015 10:21:55 -0400
Message-ID: <20150504142155.GD6113@akamai.com>
References: <1430502237-5619-1-git-send-email-emunson@akamai.com>
 <1430505777.3711.135.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S34ftz_wDoPwcJg_cMQu4QtnBJF-=d+gF5ieTA=d=r31-Q@mail.gmail.com>
 <20150501201417.GB6113@akamai.com>
 <1430511800.3711.138.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150501202908.GC6113@akamai.com>
 <1430512894.3711.140.camel@edumazet-glaptop2.roam.corp.google.com>
 <1430714086.3711.165.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="F8dlzb82+Fcn6AgP"
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1430714086.3711.165.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--F8dlzb82+Fcn6AgP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, 03 May 2015, Eric Dumazet wrote:

> From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>=20
> This patch allows a server application to get the TCP SYN headers for
> its passive connections.  This is useful if the server is doing
> fingerprinting of clients based on SYN packet contents.
>=20
> Two socket options are added: TCP_SAVE_SYN and TCP_SAVED_SYN.
>=20
> The first is used on a socket to enable saving the SYN headers
> for child connections. This can be set before or after the listen()
> call.
>=20
> The latter is used to retrieve the SYN headers for passive connections,
> if the parent listener has enabled TCP_SAVE_SYN.
>=20
> TCP_SAVED_SYN is read once, it frees the saved SYN headers.
>=20
> The data returned in TCP_SAVED_SYN are network (IPv4/IPv6) and TCP
> headers.
>=20
> Original patch was written by Tom Herbert, I changed it to not hold
> a full skb (and associated dst and conntracking reference).
>=20
> We have used such patch for about 3 years at Google.
>=20
> Signed-off-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/tcp.h        |    8 ++++++++
>  include/net/request_sock.h |    4 +++-
>  include/uapi/linux/tcp.h   |    2 ++
>  net/ipv4/tcp.c             |   35 +++++++++++++++++++++++++++++++++++
>  net/ipv4/tcp_input.c       |   18 ++++++++++++++++++
>  net/ipv4/tcp_ipv4.c        |    1 +
>  net/ipv4/tcp_minisocks.c   |    3 +++
>  7 files changed, 70 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 3b2911502a8c..e6fb5df22db1 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -199,6 +199,7 @@ struct tcp_sock {
>  		syn_fastopen:1,	/* SYN includes Fast Open option */
>  		syn_fastopen_exp:1,/* SYN includes Fast Open exp. option */
>  		syn_data_acked:1,/* data in SYN is acked by SYN-ACK */
> +		save_syn:1,	/* Save headers of SYN packet */
>  		is_cwnd_limited:1;/* forward progress limited by snd_cwnd? */
>  	u32	tlp_high_seq;	/* snd_nxt at the time of TLP retransmit. */
> =20
> @@ -326,6 +327,7 @@ struct tcp_sock {
>  	 * socket. Used to retransmit SYNACKs etc.
>  	 */
>  	struct request_sock *fastopen_rsk;
> +	u32	*saved_syn;
>  };
> =20
>  enum tsq_flags {
> @@ -393,4 +395,10 @@ static inline int fastopen_init_queue(struct sock *s=
k, int backlog)
>  	return 0;
>  }
> =20
> +static inline void tcp_saved_syn_free(struct tcp_sock *tp)
> +{
> +	kfree(tp->saved_syn);
> +	tp->saved_syn =3D NULL;
> +}
> +
>  #endif	/* _LINUX_TCP_H */
> diff --git a/include/net/request_sock.h b/include/net/request_sock.h
> index 9f4265ce8892..87935cad2f7b 100644
> --- a/include/net/request_sock.h
> +++ b/include/net/request_sock.h
> @@ -64,6 +64,7 @@ struct request_sock {
>  	struct timer_list		rsk_timer;
>  	const struct request_sock_ops	*rsk_ops;
>  	struct sock			*sk;
> +	u32				*saved_syn;
>  	u32				secid;
>  	u32				peer_secid;
>  };
> @@ -77,7 +78,7 @@ reqsk_alloc(const struct request_sock_ops *ops, struct =
sock *sk_listener)
>  		req->rsk_ops =3D ops;
>  		sock_hold(sk_listener);
>  		req->rsk_listener =3D sk_listener;
> -
> +		req->saved_syn =3D NULL;
>  		/* Following is temporary. It is coupled with debugging
>  		 * helpers in reqsk_put() & reqsk_free()
>  		 */
> @@ -104,6 +105,7 @@ static inline void reqsk_free(struct request_sock *re=
q)
>  	req->rsk_ops->destructor(req);
>  	if (req->rsk_listener)
>  		sock_put(req->rsk_listener);
> +	kfree(req->saved_syn);
>  	kmem_cache_free(req->rsk_ops->slab, req);
>  }
> =20
> diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
> index faa72f4fa547..51ebedba577f 100644
> --- a/include/uapi/linux/tcp.h
> +++ b/include/uapi/linux/tcp.h
> @@ -113,6 +113,8 @@ enum {
>  #define TCP_TIMESTAMP		24
>  #define TCP_NOTSENT_LOWAT	25	/* limit number of unsent bytes in write qu=
eue */
>  #define TCP_CC_INFO		26	/* Get Congestion Control (optional) info */
> +#define TCP_SAVE_SYN		27	/* Record SYN headers for new connections */
> +#define TCP_SAVED_SYN		28	/* Get SYN headers recorded for connection */

The getsockopt() for TCP_SAVE_SYN doesn't offer much over returning 0
=66rom TCP_SAVED_SYN if the headers are not available. Why not collapse
these into a single option?  If you need to track the difference between
the headers are not avialable and should have been and the headers
should not be available it can be done through error codes from
getsockopt().

> =20
>  struct tcp_repair_opt {
>  	__u32	opt_code;
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 46efa03d2b11..ecccfdc50d76 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2482,6 +2482,13 @@ static int do_tcp_setsockopt(struct sock *sk, int =
level,
>  			icsk->icsk_syn_retries =3D val;
>  		break;
> =20
> +	case TCP_SAVE_SYN:
> +		if (val < 0 || val > 1)
> +			err =3D -EINVAL;
> +		else
> +			tp->save_syn =3D val;
> +		break;
> +
>  	case TCP_LINGER2:
>  		if (val < 0)
>  			tp->linger2 =3D -1;
> @@ -2818,6 +2825,34 @@ static int do_tcp_getsockopt(struct sock *sk, int =
level,
>  	case TCP_NOTSENT_LOWAT:
>  		val =3D tp->notsent_lowat;
>  		break;
> +	case TCP_SAVE_SYN:
> +		val =3D tp->save_syn;
> +		break;
> +	case TCP_SAVED_SYN: {
> +		if (get_user(len, optlen))
> +			return -EFAULT;
> +
> +		lock_sock(sk);
> +		if (tp->saved_syn) {

What happens when userspace uses a buffer that is too small to hold the
saved headers?  They get a partial result back but they do not get a
chance to come back for the rest (or really have any way of knowing
there was more beyond missing some of the tcp_hdr struct).

> +			len =3D min_t(unsigned int, tp->saved_syn[0], len);
> +			if (put_user(len, optlen)) {
> +				release_sock(sk);
> +				return -EFAULT;
> +			}
> +			if (copy_to_user(optval, tp->saved_syn + 1, len)) {
> +				release_sock(sk);
> +				return -EFAULT;
> +			}
> +			tcp_saved_syn_free(tp);
> +			release_sock(sk);
> +		} else {
> +			release_sock(sk);
> +			len =3D 0;
> +			if (put_user(len, optlen))
> +				return -EFAULT;
> +		}
> +		return 0;
> +	}
>  	default:
>  		return -ENOPROTOOPT;
>  	}
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 09bdc4abfcbb..df2ca615cd0c 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -6060,6 +6060,23 @@ static bool tcp_syn_flood_action(struct sock *sk,
>  	return want_cookie;
>  }
> =20
> +static void tcp_reqsk_record_syn(const struct sock *sk,
> +				 struct request_sock *req,
> +				 const struct sk_buff *skb)
> +{
> +	if (tcp_sk(sk)->save_syn) {
> +		u32 len =3D skb_network_header_len(skb) + tcp_hdrlen(skb);
> +		u32 *copy;
> +
> +		copy =3D kmalloc(len + sizeof(u32), GFP_ATOMIC);
> +		if (copy) {
> +			copy[0] =3D len;
> +			memcpy(&copy[1], skb_network_header(skb), len);
> +			req->saved_syn =3D copy;
> +		}
> +	}
> +}
> +
>  int tcp_conn_request(struct request_sock_ops *rsk_ops,
>  		     const struct tcp_request_sock_ops *af_ops,
>  		     struct sock *sk, struct sk_buff *skb)
> @@ -6192,6 +6209,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_o=
ps,
>  		tcp_rsk(req)->tfo_listener =3D false;
>  		af_ops->queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
>  	}
> +	tcp_reqsk_record_syn(sk, req, skb);
> =20
>  	return 0;
> =20
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index fc1c658ec6c1..91cb4768a860 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1802,6 +1802,7 @@ void tcp_v4_destroy_sock(struct sock *sk)
> =20
>  	/* If socket is aborted during connect operation */
>  	tcp_free_fastopen_req(tp);
> +	tcp_saved_syn_free(tp);
> =20
>  	sk_sockets_allocated_dec(sk);
>  	sock_release_memcg(sk);
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index e5d7649136fc..ebe2ab2596ed 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -536,6 +536,9 @@ struct sock *tcp_create_openreq_child(struct sock *sk=
, struct request_sock *req,
>  		newtp->fastopen_rsk =3D NULL;
>  		newtp->syn_data_acked =3D 0;
> =20
> +		newtp->saved_syn =3D req->saved_syn;
> +		req->saved_syn =3D NULL;
> +
>  		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_PASSIVEOPENS);
>  	}
>  	return newsk;
>=20
>=20

--F8dlzb82+Fcn6AgP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVR4CDAAoJELbVsDOpoOa9ZL8P/RrIuJ01UJ58/BpsyPxEH8Z8
ho4Wuy0swwfvCRCDIyl4xpNYqmgjEeIUGANMUVRjL+KH8YOMnSxvWhQYKOdqO21M
DvhnNjElVrpu8B34KuMZWW4j+wAm1eiKzKQZ0ejwTTgGWgCpVULsI+qre/Zi46Si
y8i5GXxWXVhWy8Lgq697Cw7kSvmyO0cSURw8gCkE/TUUVONWy6LHvQHlBYKQAT4+
3gfp1cmbzMNrRB3sTOofeRUSPTqZFYH5nTwfZHK2UKOQmgdkj/8dMiu/LjesyCiA
ylLtfHCCgLyOKKf5I00MSAvLyNGcNgIAIRjPU6mrQKQJVf7lRsRRuPUPA8mfxvTw
twMaDWIBpCAK0mNArZs1vRMojaMzMhBHAB/aqqGBmh4Icf/E1XLTaxgFybhFcWyq
xXhNBrAWkulDUa3FuIxqe2NLiTU5j4H8w10Q6jD0pBdWmnSRTaG5yZoJpplNdzcw
KrxdYu04XCBYv39EsAFpLAmMJUoOAFBR6BLBfiIVSO6upya7lDxmkvVhedpm2EKn
46dpRPGyhrOhEVNWENg9tgpQszhHStqzmX1zvcblde6j4vRU+HXOgB3TDY/qhsxp
CY4fLqCWFu2TKlSxl+mkucFGNTxMP6pdbsDoDe7S++dxjaRWCltMNyvVQr/CmHUN
OpH+5EedVwtTNXQT0Bgk
=ZKNl
-----END PGP SIGNATURE-----

--F8dlzb82+Fcn6AgP--
