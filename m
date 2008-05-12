From: "Damon L. Chesser" <damon@damtek.com>
Subject: Re: Fix FRTO+NewReno problem (Was: Re: This has a work around)
Date: Mon, 12 May 2008 07:55:59 -0400
Message-ID: <4828304F.4040908@damtek.com>
References: <48207F06.50306@damtek.com> <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi> <4821C37A.7040306@damtek.com> <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi> <4823437D.20005@damtek.com> <Pine.LNX.4.64.0805082336440.31776@wrl-59.cs.helsinki.fi> <Pine.LNX.4.64.0805120859470.1041@wrl-59.cs.helsinki.fi> <4828279C.3010102@damtek.com> <Pine.LNX.4.64.0805121419330.1888@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from damtek.com ([72.172.134.65]:58643 "EHLO damtek.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753961AbYELLzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 07:55:46 -0400
In-Reply-To: <Pine.LNX.4.64.0805121419330.1888@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> Big snip
Ilpo,

I ran the first patch and received this error:

root@dam-main:/usr/src/linux-2.6.24.1# patch -p1 < ../1st_frto_patch.di=
ff
patching file net/ipv4/tcp_input.c
patch: **** malformed patch at line 17: @@ -1685,6 +1683,10 @@ static=20
inline void tcp_reset_reno_sack(struct tcp_sock *tp)

root@dam-main:/usr/src/linux-2.6.24.1#

below is the text of the patch.diff I have:

net/ipv4/tcp_input.c |   12 +++++++-----
1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0298f80..5c503e0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -113,8 +113,6 @@ int sysctl_tcp_abc __read_mostly;
#define FLAG_FORWARD_PROGRESS    (FLAG_ACKED|FLAG_DATA_SACKED)
#define FLAG_ANY_PROGRESS    (FLAG_FORWARD_PROGRESS|FLAG_SND_UNA_ADVANC=
ED)

-#define IsSackFrto() (sysctl_tcp_frto =3D=3D 0x2)
-
#define TCP_REMNANT (TCP_FLAG_FIN|TCP_FLAG_URG|TCP_FLAG_SYN|TCP_FLAG_PS=
H)
#define TCP_HP_BITS (~(TCP_RESERVED_BITS|TCP_FLAG_PSH))

@@ -1685,6 +1683,10 @@ static inline void tcp_reset_reno_sack(struct=20
tcp_sock *tp)=20
    tp->sacked_out =3D 0;
}

static int tcp_is_sackfrto(const struct tcp_sock *tp)
{
    return (sysctl_tcp_frto =3D=3D 0x2) && !tcp_is_reno(tp);
}
/* F-RTO can only be used if TCP has never retransmitted anything other=
 than
 * head (SACK enhanced variant from Appendix B of RFC4138 is more robus=
t=20
here)
 */
@@ -1701,7 +1703,7 @@ int tcp_use_frto(struct sock *sk)
    if (icsk->icsk_mtup.probe_size)
        return 0;

-    if (IsSackFrto())
+    if (tcp_is_sackfrto(tp))
        return 1;

    /* Avoid expensive walking of rexmit queue if possible */
@@ -1791,7 +1793,7 @@ void tcp_enter_frto(struct sock *sk)
    /* Earlier loss recovery underway (see RFC4138; Appendix B).
     * The last condition is necessary at least in tp->frto_counter cas=
e.
     */
-    if (IsSackFrto() && (tp->frto_counter ||
+    if (tcp_is_sackfrto(tp) && (tp->frto_counter ||
        ((1 << icsk->icsk_ca_state) & (TCPF_CA_Recovery|TCPF_CA_Loss)))=
 &&
        after(tp->high_seq, tp->snd_una)) {
        tp->frto_highmark =3D tp->high_seq;
@@ -3123,7 +3125,7 @@ static int tcp_process_frto(struct sock *sk, int =
flag)
        return 1;
    }

-    if (!IsSackFrto() || tcp_is_reno(tp)) {
+    if (!tcp_is_sackfrto(tp)) {
        /* RFC4138 shortcoming in step 2; should also have case c):
         * ACK isn't duplicate nor advances window, e.g., opposite dir
         * data, winupdate
--=20
1.5.2.2


----------------

and in the name of completeness this is the patch file I have for the=20
2nd patch (in the event I did not copy all the correct code):

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 81ece1f..4c2255c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2481,7 +2481,7 @@ static void tcp_try_to_open(struct sock *sk, int =
flag)

    tcp_verify_left_out(tp);

-    if (tp->retrans_out =3D=3D 0)
+    if (!tp->frto_counter && tp->retrans_out =3D=3D 0)
        tp->retrans_stamp =3D 0;

    if (flag & FLAG_ECE)
--=20
1.5.2.2

--------------------------

Am I doing something wrong or have I missed something?  Patched against=
=20
a 2.6.24.1 kernel from kernel.org


--=20
Damon L. Chesser
damon@damtek.com
http://www.linkedin.com/in/dchesser

