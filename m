From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 22 Apr 2013 13:03:24 +1000
Message-ID: <20130422130324.43b4521c6b4719ed7a96ef00@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__22_Apr_2013_13_03_24_+1000_BvZUk3/OpZbV/PBH"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__22_Apr_2013_13_03_24_+1000_BvZUk3/OpZbV/PBH
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ipv4/tcp_input.c between commit 12fb3dd9dc3c ("tcp: call
tcp_replace_ts_recent() from tcp_ack()") from Linus' tree and commit
9b717a8d2450 ("tcp: TLP loss detection") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/tcp_input.c
index 13b9c08,6d9ca35..0000000
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@@ -108,12 -107,10 +107,11 @@@ int sysctl_tcp_early_retrans __read_mos
  #define FLAG_DATA_SACKED	0x20 /* New SACK.				*/
  #define FLAG_ECE		0x40 /* ECE in this ACK				*/
  #define FLAG_SLOWPATH		0x100 /* Do not skip RFC checks for window update.=
*/
- #define FLAG_ONLY_ORIG_SACKED	0x200 /* SACKs only non-rexmit sent before =
RTO */
+ #define FLAG_ORIG_SACK_ACKED	0x200 /* Never retransmitted data are (s)ack=
ed	*/
  #define FLAG_SND_UNA_ADVANCED	0x400 /* Snd_una was changed (!=3D FLAG_DAT=
A_ACKED) */
  #define FLAG_DSACKING_ACK	0x800 /* SACK blocks contained D-SACK info */
- #define FLAG_NONHEAD_RETRANS_ACKED	0x1000 /* Non-head rexmitted data was =
ACKed */
  #define FLAG_SACK_RENEGING	0x2000 /* snd_una advanced to a sacked seq */
 +#define FLAG_UPDATE_TS_RECENT	0x4000 /* tcp_replace_ts_recent() */
 =20
  #define FLAG_ACKED		(FLAG_DATA_ACKED|FLAG_SYN_ACKED)
  #define FLAG_NOT_DUP		(FLAG_DATA|FLAG_WIN_UPDATE|FLAG_ACKED)
@@@ -3565,27 -3265,38 +3266,59 @@@ static void tcp_send_challenge_ack(stru
  	}
  }
 =20
 +static void tcp_store_ts_recent(struct tcp_sock *tp)
 +{
 +	tp->rx_opt.ts_recent =3D tp->rx_opt.rcv_tsval;
 +	tp->rx_opt.ts_recent_stamp =3D get_seconds();
 +}
 +
 +static void tcp_replace_ts_recent(struct tcp_sock *tp, u32 seq)
 +{
 +	if (tp->rx_opt.saw_tstamp && !after(seq, tp->rcv_wup)) {
 +		/* PAWS bug workaround wrt. ACK frames, the PAWS discard
 +		 * extra check below makes sure this can only happen
 +		 * for pure ACK frames.  -DaveM
 +		 *
 +		 * Not only, also it occurs for expired timestamps.
 +		 */
 +
 +		if (tcp_paws_check(&tp->rx_opt, 0))
 +			tcp_store_ts_recent(tp);
 +	}
 +}
 +
+ /* This routine deals with acks during a TLP episode.
+  * Ref: loss detection algorithm in draft-dukkipati-tcpm-tcp-loss-probe.
+  */
+ static void tcp_process_tlp_ack(struct sock *sk, u32 ack, int flag)
+ {
+ 	struct tcp_sock *tp =3D tcp_sk(sk);
+ 	bool is_tlp_dupack =3D (ack =3D=3D tp->tlp_high_seq) &&
+ 			     !(flag & (FLAG_SND_UNA_ADVANCED |
+ 				       FLAG_NOT_DUP | FLAG_DATA_SACKED));
+=20
+ 	/* Mark the end of TLP episode on receiving TLP dupack or when
+ 	 * ack is after tlp_high_seq.
+ 	 */
+ 	if (is_tlp_dupack) {
+ 		tp->tlp_high_seq =3D 0;
+ 		return;
+ 	}
+=20
+ 	if (after(ack, tp->tlp_high_seq)) {
+ 		tp->tlp_high_seq =3D 0;
+ 		/* Don't reduce cwnd if DSACK arrives for TLP retrans. */
+ 		if (!(flag & FLAG_DSACKING_ACK)) {
+ 			tcp_init_cwnd_reduction(sk, true);
+ 			tcp_set_ca_state(sk, TCP_CA_CWR);
+ 			tcp_end_cwnd_reduction(sk);
+ 			tcp_set_ca_state(sk, TCP_CA_Open);
+ 			NET_INC_STATS_BH(sock_net(sk),
+ 					 LINUX_MIB_TCPLOSSPROBERECOVERY);
+ 		}
+ 	}
+ }
+=20
  /* This routine deals with incoming acks, but not outgoing ones. */
  static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
  {

--Signature=_Mon__22_Apr_2013_13_03_24_+1000_BvZUk3/OpZbV/PBH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRdKh8AAoJEECxmPOUX5FEWdMP/jAG4uoLfXBannwYXMTLWtCq
Bk0E2TbPoco+gJZDe89Zvo2v5qyh9H+XbMSC8vLILYudNHfzhMBEsVBoX3mrLrL1
j9jsh8kBNReReU0+d2Dthe/tQ/C7c91jGAx/zv8VNg1ALzxYzbOmPPHCo1jcwkaL
J8dwu0Yf1FlSgA4qRHhycgD0AJoiUbm0n2MlbQCYYY0hbwF47mnSU07obWZ9m2oy
M/qVbzNdKUF3W5pGyPIXznono4J+h5NI2um4BPDvqm4M+eqrQtCZdudxR0EBcyTU
uRG9U/Ea/rXhe7485B/+DmYCaaITZKNHwkx5ApVGqF9dskfTRGoD25hWKXvx91pL
42Id0jN1w1A3uu2cFGJiOfnvj8RIQz7Y2vmTKwgbixcvASwlbe/UwwgPGv4b0GTs
NsaerwisxQwJbDxvZzI0GBNY+zU8DcMgJOJkigU5b22zMwv1FFwYHVG2GVQshnAI
xg3eiQXOrN2xDuOAYJnpUY07SQfIUrEsTDqVqH6+mpMw13UQYqgpuP0wwp6i0f7m
K3tb+Cns53/bDnbXG0vUZWJmVBKXr+o73YrUxFmEmb69r4qg4m5eg6Cum9LbqicY
2vcMAOuOW9adiQVpRuHsi0CloAJnWuTRGyPWU1k/U0luOaYspgdQXOrJ5AlgN6SV
gupQHS7z8qBDSOrwwzP6
=JLzS
-----END PGP SIGNATURE-----

--Signature=_Mon__22_Apr_2013_13_03_24_+1000_BvZUk3/OpZbV/PBH--
