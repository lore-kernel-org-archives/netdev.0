From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [bug] af_unix: Reading from a stream socket may lock the
 concurrent poll() call
Date: Mon, 21 Nov 2011 15:38:06 +0100
Message-ID: <1321886286.10470.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAHjqzy7dhqi22yPJX=DP4x916hVXDY2WaDbdmnTEQ54n6qpMXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexey Moiseytsev <himeraster-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHjqzy7dhqi22yPJX=DP4x916hVXDY2WaDbdmnTEQ54n6qpMXw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le lundi 21 novembre 2011 =C3=A0 00:19 +0400, Alexey Moiseytsev a =C3=A9=
crit :
> Hello,
>=20
> The following program shows how the poll() call hangs on a non-empty
> stream socket.
>=20
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <pthread.h>
> #include <stdio.h>
> #include <unistd.h>
> #include <poll.h>
>=20
> int sockets[2];
>=20
> int poll_socket(void) {
>     struct pollfd pfd =3D {
>         .fd =3D sockets[1],
>         .events =3D POLLIN
>     };
>     return poll(&pfd, 1, -1);
> }
>=20
>=20
> /* observer routine doesn't modify amount of data available in the
> socket buffer */
> void* observer(void* arg) {
>     char buffer;
>     for (int j =3D 0; j < 2000; j++) {
>         recv(sockets[1], &buffer, sizeof(buffer), MSG_PEEK);
>         sched_yield();
>     }
>     return NULL;
> }
>=20
> int main(void) {
>     if (socketpair(PF_UNIX, SOCK_STREAM, 0, sockets) =3D=3D -1)
>         return 1;
>     int rc, data[250] =3D {0};
>     if ((rc =3D send(sockets[0], &data, sizeof(data), MSG_DONTWAIT)) =
<=3D 0)
>         return 2;
>     poll_socket();
> /* If the first poll_socket() call didn't hang then the following
> message will be printed */
>     fprintf(stderr, "%d bytes available in input buffer\n", rc);
>     pthread_t observer_thread;
>     pthread_create(&observer_thread, NULL, observer, NULL);
>     for (int j =3D 0; j < 20000; j++) {
> /* If the first poll_socket() call didn't hang then all the following
> calls should do the same */
>         poll_socket();
>     }
>     fprintf(stderr, "Well done\n");
>     pthread_join(observer_thread, NULL);
>     close(sockets[0]);
>     close(sockets[1]);
>     return 0;
> }
>=20
>=20
> Expected output: two lines or nothing (in case of error).
> Observed output: only the first line (and the process never exits).
>=20
> So the first poll() said that there is some data available in the
> socket. And one of the following poll() said that there is no data
> available in the socket. But this is false because the observer threa=
d
> didn't actually consume any data from then socket.
>=20
> I assume that this bug can be eliminated by adding
> sk->sk_data_ready(...) call right after each call to
> skb_queue_head(..) in the unix_stream_recvmsg(...) routine
> (net/unix/af_unix.c)
>=20
> Other info:
> $ uname -srmo
> Linux 2.6.32-5-amd64 x86_64 GNU/Linux
>=20

Hi Alexy

I believe you found a bug and your suggested fix should be just fine.

(Or maybe testing in unix_poll() that at least one thread is currently
handling one skb from sk->receive_queue)

Could you submit an official patch on top of current Linus tree or do
you prefer us to take care of this ?



--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
