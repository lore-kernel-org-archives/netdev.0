From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH net-next 11/14] rxrpc: Make rxrpc_send_packet() take a
 connection not a transport [ver #2]
Date: Thu, 6 Oct 2016 15:34:25 +0200
Message-ID: <CAMuHMdUU=yRe_XgC64kD-ZtANVmmzUBJS9Rkkz8mp5-W96Z=qw@mail.gmail.com>
References: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
 <146661145065.15011.7115489407328614610.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-afs@lists.infradead.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34291 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751308AbcJFNe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 09:34:27 -0400
In-Reply-To: <146661145065.15011.7115489407328614610.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Jun 22, 2016 at 6:04 PM, David Howells <dhowells@redhat.com> wrote:
> Make rxrpc_send_packet() take a connection not a transport as part of the
> phasing out of the rxrpc_transport struct.
>
> Whilst we're at it, rename the function to rxrpc_send_data_packet() to
> differentiate it from the other packet sending functions.
>
> Signed-off-by: David Howells <dhowells@redhat.com>

This is now upstream commit 985a5c824a52e9f7

> --- a/net/rxrpc/output.c
> +++ b/net/rxrpc/output.c
> @@ -338,7 +338,7 @@ EXPORT_SYMBOL(rxrpc_kernel_abort_call);
>  /*
>   * send a packet through the transport endpoint
>   */
> -int rxrpc_send_packet(struct rxrpc_transport *trans, struct sk_buff *skb=
)
> +int rxrpc_send_data_packet(struct rxrpc_connection *conn, struct sk_buff=
 *skb)
>  {
>         struct kvec iov[1];
>         struct msghdr msg;
> @@ -349,30 +349,30 @@ int rxrpc_send_packet(struct rxrpc_transport *trans=
, struct sk_buff *skb)

net/rxrpc/output.c: In function =E2=80=98rxrpc_send_data_packet=E2=80=99:
net/rxrpc/output.c:252: warning: =E2=80=98ret=E2=80=99 may be used uninitia=
lized in
this function
(line number is from current mainline)

>         iov[0].iov_base =3D skb->head;
>         iov[0].iov_len =3D skb->len;
>
> -       msg.msg_name =3D &trans->peer->srx.transport.sin;
> -       msg.msg_namelen =3D sizeof(trans->peer->srx.transport.sin);
> +       msg.msg_name =3D &conn->params.peer->srx.transport;
> +       msg.msg_namelen =3D conn->params.peer->srx.transport_len;
>         msg.msg_control =3D NULL;
>         msg.msg_controllen =3D 0;
>         msg.msg_flags =3D 0;
>
>         /* send the packet with the don't fragment bit set if we currentl=
y
>          * think it's small enough */
> -       if (skb->len - sizeof(struct rxrpc_wire_header) < trans->peer->ma=
xdata) {
> -               down_read(&trans->local->defrag_sem);
> +       if (skb->len - sizeof(struct rxrpc_wire_header) < conn->params.pe=
er->maxdata) {
> +               down_read(&conn->params.local->defrag_sem);

If this branch is not taken...

>                 /* send the packet by UDP
>                  * - returns -EMSGSIZE if UDP would have to fragment the =
packet
>                  *   to go out of the interface
>                  *   - in which case, we'll have processed the ICMP error
>                  *     message and update the peer record
>                  */
> -               ret =3D kernel_sendmsg(trans->local->socket, &msg, iov, 1=
,
> +               ret =3D kernel_sendmsg(conn->params.local->socket, &msg, =
iov, 1,
>                                      iov[0].iov_len);
>
> -               up_read(&trans->local->defrag_sem);
> +               up_read(&conn->params.local->defrag_sem);
>                 if (ret =3D=3D -EMSGSIZE)
>                         goto send_fragmentable;
>
> -               _leave(" =3D %d [%u]", ret, trans->peer->maxdata);
> +               _leave(" =3D %d [%u]", ret, conn->params.peer->maxdata);
>                 return ret;
>         }
>
> @@ -380,21 +380,28 @@ send_fragmentable:
>         /* attempt to send this message with fragmentation enabled */
>         _debug("send fragment");
>
> -       down_write(&trans->local->defrag_sem);
> -       opt =3D IP_PMTUDISC_DONT;
> -       ret =3D kernel_setsockopt(trans->local->socket, SOL_IP, IP_MTU_DI=
SCOVER,
> -                               (char *) &opt, sizeof(opt));
> -       if (ret =3D=3D 0) {
> -               ret =3D kernel_sendmsg(trans->local->socket, &msg, iov, 1=
,
> -                                    iov[0].iov_len);
> -
> -               opt =3D IP_PMTUDISC_DO;
> -               kernel_setsockopt(trans->local->socket, SOL_IP,
> -                                 IP_MTU_DISCOVER, (char *) &opt, sizeof(=
opt));
> +       down_write(&conn->params.local->defrag_sem);
> +
> +       switch (conn->params.local->srx.transport.family) {
> +       case AF_INET:
> +               opt =3D IP_PMTUDISC_DONT;
> +               ret =3D kernel_setsockopt(conn->params.local->socket,
> +                                       SOL_IP, IP_MTU_DISCOVER,
> +                                       (char *)&opt, sizeof(opt));
> +               if (ret =3D=3D 0) {
> +                       ret =3D kernel_sendmsg(conn->params.local->socket=
, &msg, iov, 1,
> +                                            iov[0].iov_len);
> +
> +                       opt =3D IP_PMTUDISC_DO;
> +                       kernel_setsockopt(conn->params.local->socket, SOL=
_IP,
> +                                         IP_MTU_DISCOVER,
> +                                         (char *)&opt, sizeof(opt));
> +               }
> +               break;

... and none of the cases (current upstream also has AF_INET6 if
CONFIG_AF_RXRPC_IPV6 is enabled) match ...

>         }
>
> -       up_write(&trans->local->defrag_sem);
> -       _leave(" =3D %d [frag %u]", ret, trans->peer->maxdata);
> +       up_write(&conn->params.local->defrag_sem);
> +       _leave(" =3D %d [frag %u]", ret, conn->params.peer->maxdata);
>         return ret;

... then ret is not initialized.

I didn't create a patch, as I'm not sure this is a false positive or not.
Is it possible that none of the cases match?

>  }

Gr{oetje,eeting}s,

                        Geert
