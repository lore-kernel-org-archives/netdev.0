From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: bind() use stronger condition for bind_conflict
Date: Fri, 13 Apr 2012 08:36:31 +0300
Message-ID: <CAEnQRZALcP8AOOPzu0_Nn+FGbTDu_geSj-AzGNe39E4GHitFSQ@mail.gmail.com>
References: <1333698444-24144-1-git-send-email-alex.mihai.c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fbl@redhat.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: alex.mihai.c@gmail.com, davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:47332 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab2DMFgc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 01:36:32 -0400
Received: by obbta14 with SMTP id ta14so169861obb.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 22:36:31 -0700 (PDT)
In-Reply-To: <1333698444-24144-1-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 6, 2012 at 10:47 AM, Alexandru Copot <alex.mihai.c@gmail.co=
m> wrote:
> From: Alex Copot <alex.mihai.c@gmail.com>
>
> We must try harder to get unique (addr, port) pairs when
> doing port autoselection for sockets with SO_REUSEADDR
> option set.
>
> We achieve this by adding a relaxation parameter to
> inet_csk_bind_conflict. When 'relax' parameter is off
> we return a conflict whenever the current searched
> pair (addr, port) is not unique.
>
> This tries to address the problems reported in patch:
> =A0 =A0 =A0 =A08d238b25b1ec22a73b1c2206f111df2faaff8285
> =A0 =A0 =A0 =A0Revert "tcp: bind() fix when many ports are bound"
>
> Tests where ran for creating and binding(0) many sockets
> on 100 IPs. The results are, on average:
>
> =A0 =A0 =A0 =A0* 60000 sockets, 600 ports / IP:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 0.210 s, 620 (IP, port) duplicates w=
ithout patch
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 0.219 s, no duplicates with patch
> =A0 =A0 =A0 =A0* 100000 sockets, 1000 ports / IP:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 0.371 s, 1720 duplicates without pat=
ch
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 0.373 s, no duplicates with patch
> =A0 =A0 =A0 =A0* 200000 sockets, 2000 ports / IP:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 0.766 s, 6900 duplicates without pat=
ch
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 0.768 s, no duplicates with patch
> =A0 =A0 =A0 =A0* 500000 sockets, 5000 ports / IP:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 2.227 s, 41500 duplicates without pa=
tch
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 2.284 s, no duplicates with patch
>
> Signed-off-by: Alex Copot <alex.mihai.c@gmail.com>
> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
>
> ---
> Changes from v1:
> =A0- Fixed coding style
> =A0- Replaced int flag with bool
> =A0- Added test results
> ---
> =A0include/net/inet6_connection_sock.h | =A0 =A02 +-
> =A0include/net/inet_connection_sock.h =A0| =A0 =A04 ++--
> =A0net/ipv4/inet_connection_sock.c =A0 =A0 | =A0 17 +++++++++++++----
> =A0net/ipv6/inet6_connection_sock.c =A0 =A0| =A0 =A02 +-
> =A04 files changed, 17 insertions(+), 8 deletions(-)
>
> diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_=
connection_sock.h
> index 3207e58..1866a67 100644
> --- a/include/net/inet6_connection_sock.h
> +++ b/include/net/inet6_connection_sock.h
> @@ -23,7 +23,7 @@ struct sock;
> =A0struct sockaddr;
>
> =A0extern int inet6_csk_bind_conflict(const struct sock *sk,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
const struct inet_bind_bucket *tb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
const struct inet_bind_bucket *tb, bool relax);
>
> =A0extern struct dst_entry* inet6_csk_route_req(struct sock *sk,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 const struct request_sock *req);
> diff --git a/include/net/inet_connection_sock.h b/include/net/inet_co=
nnection_sock.h
> index dbf9aab..46c9e2c 100644
> --- a/include/net/inet_connection_sock.h
> +++ b/include/net/inet_connection_sock.h
> @@ -60,7 +60,7 @@ struct inet_connection_sock_af_ops {
> =A0#endif
> =A0 =A0 =A0 =A0void =A0 =A0 =A0 =A0(*addr2sockaddr)(struct sock *sk, =
struct sockaddr *);
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 (*bind_conflict)(const struct sock=
 *sk,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0const struct inet_bind_bucket *tb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0const struct inet_bind_bucket *tb, bool relax);
> =A0};
>
> =A0/** inet_connection_sock - INET connection oriented sock
> @@ -245,7 +245,7 @@ extern struct request_sock *inet_csk_search_req(c=
onst struct sock *sk,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0const __be32 raddr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0const __be32 laddr);
> =A0extern int inet_csk_bind_conflict(const struct sock *sk,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 con=
st struct inet_bind_bucket *tb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 con=
st struct inet_bind_bucket *tb, bool relax);
> =A0extern int inet_csk_get_port(struct sock *sk, unsigned short snum)=
;
>
> =A0extern struct dst_entry* inet_csk_route_req(struct sock *sk,
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connecti=
on_sock.c
> index 19d66ce..13ef772 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -53,7 +53,7 @@ void inet_get_local_port_range(int *low, int *high)
> =A0EXPORT_SYMBOL(inet_get_local_port_range);
>
> =A0int inet_csk_bind_conflict(const struct sock *sk,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct ine=
t_bind_bucket *tb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct ine=
t_bind_bucket *tb, bool relax)
> =A0{
> =A0 =A0 =A0 =A0struct sock *sk2;
> =A0 =A0 =A0 =A0struct hlist_node *node;
> @@ -79,6 +79,13 @@ int inet_csk_bind_conflict(const struct sock *sk,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
sk2_rcv_saddr =3D=3D sk_rcv_saddr(sk))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!relax && reuse && =
sk2->sk_reuse &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk2->sk=
_state !=3D TCP_LISTEN) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const _=
_be32 sk2_rcv_saddr =3D sk_rcv_saddr(sk2);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sk=
2_rcv_saddr || !sk_rcv_saddr(sk) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 sk2_rcv_saddr =3D=3D sk_rcv_saddr(sk))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return node !=3D NULL;
> @@ -122,12 +129,13 @@ again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0(tb->num_owners < smallest_size || smallest_size =3D=3D=
 -1)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0smallest_size =3D tb->num_owners;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0smallest_rover =3D rover;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 if (atomic_read(&hashinfo->bsockets) > (high -=
 low) + 1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 if (atomic_read(&hashinfo->bsockets) > (high -=
 low) + 1 &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !inet_csk(sk)->icsk_af_ops->bind_confl=
ict(sk, tb, false)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0snum =3D smallest_rover;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto tb_found;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false)) =
{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0snum =3D rover;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0goto tb_found;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0}
> @@ -178,12 +186,13 @@ tb_found:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto success;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D 1;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (inet_csk(sk)->icsk_=
af_ops->bind_conflict(sk, tb)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (inet_csk(sk)->icsk_=
af_ops->bind_conflict(sk, tb, true)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sk=
->sk_reuse && sk->sk_state !=3D TCP_LISTEN &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
smallest_size !=3D -1 && --attempts >=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0spin_unlock(&head->lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0goto again;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto f=
ail_unlock;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connec=
tion_sock.c
> index 02dd203..e6cee52 100644
> --- a/net/ipv6/inet6_connection_sock.c
> +++ b/net/ipv6/inet6_connection_sock.c
> @@ -28,7 +28,7 @@
> =A0#include <net/inet6_connection_sock.h>
>
> =A0int inet6_csk_bind_conflict(const struct sock *sk,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct in=
et_bind_bucket *tb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct in=
et_bind_bucket *tb, bool relax)
> =A0{
> =A0 =A0 =A0 =A0const struct sock *sk2;
> =A0 =A0 =A0 =A0const struct hlist_node *node;
> --
> 1.7.9.6
>
> --

Eric, David can you have a look on this?

thanks,
Daniel.
