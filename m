From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH 2/3] x25: Handle undersized/fragmented skbs
Date: Mon, 17 Oct 2011 21:28:02 +1100
Message-ID: <CADo0ohiqcN=xJDrJYg8P86v4karbaLFWL27ARtEHmEAqHnnewQ@mail.gmail.com>
References: <1318653905-13716-1-git-send-email-mattjd@gmail.com>
	<1318653905-13716-3-git-send-email-mattjd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	stable <stable@kernel.org>
To: Matthew Daley <mattjd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:43765 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549Ab1JQK2D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 06:28:03 -0400
Received: by vcge1 with SMTP id e1so1845485vcg.19
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 03:28:02 -0700 (PDT)
In-Reply-To: <1318653905-13716-3-git-send-email-mattjd@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ran through with a lot of corrupted data, looks stable.

Acked-by: Andrew Hendry <andrew.hendry@gmail.com>

On Sat, Oct 15, 2011 at 3:45 PM, Matthew Daley <mattjd@gmail.com> wrote=
:
> There are multiple locations in the X.25 packet layer where a skb is
> assumed to be of at least a certain size and that all its data is
> currently available at skb->data. =A0These assumptions are not checke=
d,
> hence buffer overreads may occur. =A0Use pskb_may_pull to check these
> minimal size assumptions and ensure that data is available at skb->da=
ta
> when necessary, as well as use skb_copy_bits where needed.
>
> Signed-off-by: Matthew Daley <mattjd@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Andrew Hendry <andrew.hendry@gmail.com>
> Cc: stable <stable@kernel.org>
> ---
> =A0net/x25/af_x25.c =A0 =A0 =A0 =A0 | =A0 31 ++++++++++++++++++++++++=
-------
> =A0net/x25/x25_dev.c =A0 =A0 =A0 =A0| =A0 =A06 ++++++
> =A0net/x25/x25_facilities.c | =A0 10 ++++++----
> =A0net/x25/x25_in.c =A0 =A0 =A0 =A0 | =A0 40 ++++++++++++++++++++++++=
+++++++++++-----
> =A0net/x25/x25_link.c =A0 =A0 =A0 | =A0 =A03 +++
> =A0net/x25/x25_subr.c =A0 =A0 =A0 | =A0 14 +++++++++++++-
> =A06 files changed, 87 insertions(+), 17 deletions(-)
>
> diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
> index a4bd172..aa567b0 100644
> --- a/net/x25/af_x25.c
> +++ b/net/x25/af_x25.c
> @@ -91,7 +91,7 @@ int x25_parse_address_block(struct sk_buff *skb,
> =A0 =A0 =A0 =A0int needed;
> =A0 =A0 =A0 =A0int rc;
>
> - =A0 =A0 =A0 if (skb->len < 1) {
> + =A0 =A0 =A0 if (!pskb_may_pull(skb, 1)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* packet has no address block */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto empty;
> @@ -100,7 +100,7 @@ int x25_parse_address_block(struct sk_buff *skb,
> =A0 =A0 =A0 =A0len =3D *skb->data;
> =A0 =A0 =A0 =A0needed =3D 1 + (len >> 4) + (len & 0x0f);
>
> - =A0 =A0 =A0 if (skb->len < needed) {
> + =A0 =A0 =A0 if (!pskb_may_pull(skb, needed)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* packet is too short to hold the add=
resses it claims
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 to hold */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D -1;
> @@ -951,10 +951,10 @@ int x25_rx_call_request(struct sk_buff *skb, st=
ruct x25_neigh *nb,
> =A0 =A0 =A0 =A0 *
> =A0 =A0 =A0 =A0 * =A0 =A0 =A0Facilities length is mandatory in call r=
equest packets
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (skb->len < 1)
> + =A0 =A0 =A0 if (!pskb_may_pull(skb, 1))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_clear_request;
> =A0 =A0 =A0 =A0len =3D skb->data[0] + 1;
> - =A0 =A0 =A0 if (skb->len < len)
> + =A0 =A0 =A0 if (!pskb_may_pull(skb, len))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_clear_request;
> =A0 =A0 =A0 =A0skb_pull(skb,len);
>
> @@ -965,6 +965,13 @@ int x25_rx_call_request(struct sk_buff *skb, str=
uct x25_neigh *nb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_clear_request;
>
> =A0 =A0 =A0 =A0/*
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0Get all the call user data so it can be=
 used in
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0x25_find_listener and skb_copy_from_lin=
ear_data up ahead.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (!pskb_may_pull(skb, skb->len))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_clear_request;
> +
> + =A0 =A0 =A0 /*
> =A0 =A0 =A0 =A0 * =A0 =A0 =A0Find a listener for the particular addre=
ss/cud pair.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0sk =3D x25_find_listener(&source_addr,skb);
> @@ -1172,6 +1179,9 @@ static int x25_sendmsg(struct kiocb *iocb, stru=
ct socket *sock,
> =A0 =A0 =A0 =A0 * =A0 =A0 =A0byte of the user data is the logical val=
ue of the Q Bit.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (test_bit(X25_Q_BIT_FLAG, &x25->flags)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, 1))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_kfree_skb;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qbit =3D skb->data[0];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_pull(skb, 1);
> =A0 =A0 =A0 =A0}
> @@ -1250,7 +1260,9 @@ static int x25_recvmsg(struct kiocb *iocb, stru=
ct socket *sock,
> =A0 =A0 =A0 =A0struct x25_sock *x25 =3D x25_sk(sk);
> =A0 =A0 =A0 =A0struct sockaddr_x25 *sx25 =3D (struct sockaddr_x25 *)m=
sg->msg_name;
> =A0 =A0 =A0 =A0size_t copied;
> - =A0 =A0 =A0 int qbit;
> + =A0 =A0 =A0 int qbit, header_len =3D x25->neighbour->extended ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 X25_EXT_MIN_LEN : X25_STD_MIN_LEN;
> +
> =A0 =A0 =A0 =A0struct sk_buff *skb;
> =A0 =A0 =A0 =A0unsigned char *asmptr;
> =A0 =A0 =A0 =A0int rc =3D -ENOTCONN;
> @@ -1271,6 +1283,9 @@ static int x25_recvmsg(struct kiocb *iocb, stru=
ct socket *sock,
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb =3D skb_dequeue(&x25->interrupt_in=
_queue);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, X25_STD_MIN_LEN=
))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_dgram;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_pull(skb, X25_STD_MIN_LEN);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> @@ -1291,10 +1306,12 @@ static int x25_recvmsg(struct kiocb *iocb, st=
ruct socket *sock,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, header_len))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_dgram;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qbit =3D (skb->data[0] & X25_Q_BIT) =3D=
=3D X25_Q_BIT;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_pull(skb, x25->neighbour->extended =
?
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 X25_EXT=
_MIN_LEN : X25_STD_MIN_LEN);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_pull(skb, header_len);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (test_bit(X25_Q_BIT_FLAG, &x25->fla=
gs)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0asmptr =A0=3D skb_push=
(skb, 1);
> diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
> index e547ca1..fa2b418 100644
> --- a/net/x25/x25_dev.c
> +++ b/net/x25/x25_dev.c
> @@ -32,6 +32,9 @@ static int x25_receive_data(struct sk_buff *skb, st=
ruct x25_neigh *nb)
> =A0 =A0 =A0 =A0unsigned short frametype;
> =A0 =A0 =A0 =A0unsigned int lci;
>
> + =A0 =A0 =A0 if (!pskb_may_pull(skb, X25_STD_MIN_LEN))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> =A0 =A0 =A0 =A0frametype =3D skb->data[2];
> =A0 =A0 =A0 =A0lci =3D ((skb->data[0] << 8) & 0xF00) + ((skb->data[1]=
 << 0) & 0x0FF);
>
> @@ -115,6 +118,9 @@ int x25_lapb_receive_frame(struct sk_buff *skb, s=
truct net_device *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto drop;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 if (!pskb_may_pull(skb, 1))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> =A0 =A0 =A0 =A0switch (skb->data[0]) {
>
> =A0 =A0 =A0 =A0case X25_IFACE_DATA:
> diff --git a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
> index f77e4e7..36384a1 100644
> --- a/net/x25/x25_facilities.c
> +++ b/net/x25/x25_facilities.c
> @@ -44,7 +44,7 @@
> =A0int x25_parse_facilities(struct sk_buff *skb, struct x25_facilitie=
s *facilities,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct x25_dte_facilities *dte_facs, u=
nsigned long *vc_fac_mask)
> =A0{
> - =A0 =A0 =A0 unsigned char *p =3D skb->data;
> + =A0 =A0 =A0 unsigned char *p;
> =A0 =A0 =A0 =A0unsigned int len;
>
> =A0 =A0 =A0 =A0*vc_fac_mask =3D 0;
> @@ -60,14 +60,16 @@ int x25_parse_facilities(struct sk_buff *skb, str=
uct x25_facilities *facilities,
> =A0 =A0 =A0 =A0memset(dte_facs->called_ae, '\0', sizeof(dte_facs->cal=
led_ae));
> =A0 =A0 =A0 =A0memset(dte_facs->calling_ae, '\0', sizeof(dte_facs->ca=
lling_ae));
>
> - =A0 =A0 =A0 if (skb->len < 1)
> + =A0 =A0 =A0 if (!pskb_may_pull(skb, 1))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> - =A0 =A0 =A0 len =3D *p++;
> + =A0 =A0 =A0 len =3D skb->data[0];
>
> - =A0 =A0 =A0 if (len >=3D skb->len)
> + =A0 =A0 =A0 if (!pskb_may_pull(skb, 1 + len))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -1;
>
> + =A0 =A0 =A0 p =3D skb->data + 1;
> +
> =A0 =A0 =A0 =A0while (len > 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (*p & X25_FAC_CLASS_MASK) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_FAC_CLASS_A:
> diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
> index 63488fd..a49cd4e 100644
> --- a/net/x25/x25_in.c
> +++ b/net/x25/x25_in.c
> @@ -107,6 +107,8 @@ static int x25_state1_machine(struct sock *sk, st=
ruct sk_buff *skb, int frametyp
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * =A0 =A0 =A0Parse the data in the fr=
ame.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, X25_STD_MIN_LEN=
))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_clear;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_pull(skb, X25_STD_MIN_LEN);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len =3D x25_parse_address_block(skb, &=
source_addr,
> @@ -130,9 +132,8 @@ static int x25_state1_machine(struct sock *sk, st=
ruct sk_buff *skb, int frametyp
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (skb->len > X25_MAX=
_CUD_LEN)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto o=
ut_clear;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_copy_from_linear_da=
ta(skb,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 x25->calluserdata.cuddata,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_copy_bits(skb, 0, x=
25->calluserdata.cuddata,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->le=
n);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25->calluserdata.cudl=
ength =3D skb->len;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!sock_flag(sk, SOCK_DEAD))
> @@ -140,6 +141,9 @@ static int x25_state1_machine(struct sock *sk, st=
ruct sk_buff *skb, int frametyp
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0case X25_CLEAR_REQUEST:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, X25_STD_MIN_LEN=
 + 2))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_clear;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25_write_internal(sk, X25_CLEAR_CONFI=
RMATION);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25_disconnect(sk, ECONNREFUSED, skb->=
data[3], skb->data[4]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> @@ -167,6 +171,9 @@ static int x25_state2_machine(struct sock *sk, st=
ruct sk_buff *skb, int frametyp
> =A0 =A0 =A0 =A0switch (frametype) {
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_CLEAR_REQUEST:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb,=
 X25_STD_MIN_LEN + 2))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto ou=
t_clear;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25_write_internal(sk,=
 X25_CLEAR_CONFIRMATION);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25_disconnect(sk, 0, =
skb->data[3], skb->data[4]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> @@ -180,6 +187,11 @@ static int x25_state2_machine(struct sock *sk, s=
truct sk_buff *skb, int frametyp
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return 0;
> +
> +out_clear:
> + =A0 =A0 =A0 x25_write_internal(sk, X25_CLEAR_REQUEST);
> + =A0 =A0 =A0 x25_start_t23timer(sk);
> + =A0 =A0 =A0 return 0;
> =A0}
>
> =A0/*
> @@ -209,6 +221,9 @@ static int x25_state3_machine(struct sock *sk, st=
ruct sk_buff *skb, int frametyp
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_CLEAR_REQUEST:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb,=
 X25_STD_MIN_LEN + 2))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto ou=
t_clear;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25_write_internal(sk,=
 X25_CLEAR_CONFIRMATION);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25_disconnect(sk, 0, =
skb->data[3], skb->data[4]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> @@ -307,6 +322,12 @@ static int x25_state3_machine(struct sock *sk, s=
truct sk_buff *skb, int frametyp
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return queued;
> +
> +out_clear:
> + =A0 =A0 =A0 x25_write_internal(sk, X25_CLEAR_REQUEST);
> + =A0 =A0 =A0 x25->state =3D X25_STATE_2;
> + =A0 =A0 =A0 x25_start_t23timer(sk);
> + =A0 =A0 =A0 return 0;
> =A0}
>
> =A0/*
> @@ -316,13 +337,13 @@ static int x25_state3_machine(struct sock *sk, =
struct sk_buff *skb, int frametyp
> =A0*/
> =A0static int x25_state4_machine(struct sock *sk, struct sk_buff *skb=
, int frametype)
> =A0{
> + =A0 =A0 =A0 struct x25_sock *x25 =3D x25_sk(sk);
> +
> =A0 =A0 =A0 =A0switch (frametype) {
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_RESET_REQUEST:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25_write_internal(sk,=
 X25_RESET_CONFIRMATION);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_RESET_CONFIRMATION: {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct x25_sock *x25 =3D=
 x25_sk(sk);
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25_stop_timer(sk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25->condition =3D 0x0=
0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25->va =A0 =A0 =A0 =A0=
=3D 0;
> @@ -334,6 +355,9 @@ static int x25_state4_machine(struct sock *sk, st=
ruct sk_buff *skb, int frametyp
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_CLEAR_REQUEST:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb,=
 X25_STD_MIN_LEN + 2))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto ou=
t_clear;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25_write_internal(sk,=
 X25_CLEAR_CONFIRMATION);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25_disconnect(sk, 0, =
skb->data[3], skb->data[4]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> @@ -343,6 +367,12 @@ static int x25_state4_machine(struct sock *sk, s=
truct sk_buff *skb, int frametyp
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return 0;
> +
> +out_clear:
> + =A0 =A0 =A0 x25_write_internal(sk, X25_CLEAR_REQUEST);
> + =A0 =A0 =A0 x25->state =3D X25_STATE_2;
> + =A0 =A0 =A0 x25_start_t23timer(sk);
> + =A0 =A0 =A0 return 0;
> =A0}
>
> =A0/* Higher level upcall for a LAPB frame */
> diff --git a/net/x25/x25_link.c b/net/x25/x25_link.c
> index 037958f..4acacf3 100644
> --- a/net/x25/x25_link.c
> +++ b/net/x25/x25_link.c
> @@ -90,6 +90,9 @@ void x25_link_control(struct sk_buff *skb, struct x=
25_neigh *nb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> =A0 =A0 =A0 =A0case X25_DIAGNOSTIC:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, X25_STD_MIN_LEN=
 + 4))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_WARNING "x25: diagnostic #=
%d - %02X %02X %02X\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->data[3], skb->data[4=
],
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->data[5], skb->data[6=
]);
> diff --git a/net/x25/x25_subr.c b/net/x25/x25_subr.c
> index 24a342e..5170d52 100644
> --- a/net/x25/x25_subr.c
> +++ b/net/x25/x25_subr.c
> @@ -269,7 +269,11 @@ int x25_decode(struct sock *sk, struct sk_buff *=
skb, int *ns, int *nr, int *q,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 int *d, int *m)
> =A0{
> =A0 =A0 =A0 =A0struct x25_sock *x25 =3D x25_sk(sk);
> - =A0 =A0 =A0 unsigned char *frame =3D skb->data;
> + =A0 =A0 =A0 unsigned char *frame;
> +
> + =A0 =A0 =A0 if (!pskb_may_pull(skb, X25_STD_MIN_LEN))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return X25_ILLEGAL;
> + =A0 =A0 =A0 frame =3D skb->data;
>
> =A0 =A0 =A0 =A0*ns =3D *nr =3D *q =3D *d =3D *m =3D 0;
>
> @@ -294,6 +298,10 @@ int x25_decode(struct sock *sk, struct sk_buff *=
skb, int *ns, int *nr, int *q,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (frame[2] =3D=3D X25_RR =A0||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0frame[2] =3D=3D X25_RNR ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0frame[2] =3D=3D X25_REJ) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb,=
 X25_EXT_MIN_LEN))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
X25_ILLEGAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame =3D skb->data;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*nr =3D (frame[3] >> 1=
) & 0x7F;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return frame[2];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -308,6 +316,10 @@ int x25_decode(struct sock *sk, struct sk_buff *=
skb, int *ns, int *nr, int *q,
>
> =A0 =A0 =A0 =A0if (x25->neighbour->extended) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((frame[2] & 0x01) =3D=3D X25_DATA)=
 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb,=
 X25_EXT_MIN_LEN))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
X25_ILLEGAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame =3D skb->data;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*q =A0=3D (frame[0] & =
X25_Q_BIT) =3D=3D X25_Q_BIT;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*d =A0=3D (frame[0] & =
X25_D_BIT) =3D=3D X25_D_BIT;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*m =A0=3D (frame[3] & =
X25_EXT_M_BIT) =3D=3D X25_EXT_M_BIT;
> --
> 1.7.2.5
>
>
