From: Chanyeol Park <chanyeol.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] Bluetooth: Fix null pointer dereference in l2cap_chan_send
Date: Tue, 22 May 2012 21:35:52 +0900
Message-ID: <4FBB8828.303@samsung.com>
References: <4FB9932B.9070101@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Minho Ban <mhban-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <4FB9932B.9070101-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi
On 2012=EB=85=84 05=EC=9B=94 21=EC=9D=BC 09:58, Minho Ban wrote:
> If l2cap_chan_send is called will null conn it will cause kernel Oops=
=2E
> This patch checks if conn is valid before entering l2cap_chan_send.
>
> 2871 [  177.271861] Unable to handle kernel NULL pointer dereference =
at virtual address 00000010
> 2872 [  177.271867] pgd =3D eadc0000
> 2873 [  177.271870] [00000010] *pgd=3D6ad03831, *pte=3D00000000, *ppt=
e=3D00000000
> 2874 [  177.271884] Internal error: Oops: 17 [#1] PREEMPT SMP
> 2875 [  177.271891] Modules linked in:
> 2876 [  177.271900] CPU: 3    Not tainted  (3.0.15-00019-g097836e #36=
)
> 2877 [  177.271925] PC is at l2cap_chan_send+0x8c/0x6f8
> 2878 [  177.271933] LR is at 0xc089d59c
> 2879 [  177.271940] pc : [<c0531514>]    lr : [<c089d59c>]    psr: 80=
000013
> 2880 [  177.271943] sp : ddda1d50  ip : 0000035c  fp : ddda1dac
> 2881 [  177.271948] r10: 0000035c  r9 : 00000000  r8 : ddda1f3c
> 2882 [  177.271954] r7 : ed67ec00  r6 : 00000006  r5 : ed67ec00  r4 :=
 00000003
> 2883 [  177.271959] r3 : ddda1d7c  r2 : 0000035c  r1 : 00000000  r0 :=
 ed67ec00
> 2884 [  177.271967] Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32 ISA AR=
M  Segment user
> 2885 [  177.271973] Control: 10c5387d  Table: 6adc004a  DAC: 00000015
> ~~~ snip ~~~~~
> 3000 [  177.272989] Backtrace:
> 3001 [  177.273001] [<c0531488>] (l2cap_chan_send+0x0/0x6f8) from [<c=
053700c>] (l2cap_sock_sendmsg+0xc0/0x15c)
> 3002 [  177.273023] [<c0536f4c>] (l2cap_sock_sendmsg+0x0/0x15c) from =
[<c0458afc>] (sock_sendmsg+0xcc/0xd4)
> 3003 [  177.273035] [<c0458a30>] (sock_sendmsg+0x0/0xd4) from [<c0459=
558>] (sys_sendto+0xb8/0xdc)
> 3004 [  177.273041]  r9:ddda0000 r8:00004040 r7:00000000 r6:ebdf9d40 =
r5:0004fb00
> 3005 [  177.273050] r4:0000035c
> 3006 [  177.273059] [<c04594a0>] (sys_sendto+0x0/0xdc) from [<c045959=
c>] (sys_send+0x20/0x28)
> 3007 [  177.273077] [<c045957c>] (sys_send+0x0/0x28) from [<c00431c0>=
] (ret_fast_syscall+0x0/0x30)
> 3008 [  177.273087] Code: e5901004 e24b3030 e51ba050 e590e21c (e59140=
10)
> 3009 [  177.273096] ---[ end trace 29a418305c9cffba ]---
>
> Signed-off-by: Minho Ban<mhban-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> ---
>   net/bluetooth/l2cap_sock.c |    6 ++++--
>   1 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
> index 3bb1611..98d4541 100644
> --- a/net/bluetooth/l2cap_sock.c
> +++ b/net/bluetooth/l2cap_sock.c
> @@ -727,10 +727,12 @@ static int l2cap_sock_sendmsg(struct kiocb *ioc=
b, struct socket *sock, struct ms
>   	if (msg->msg_flags&  MSG_OOB)
>   		return -EOPNOTSUPP;
>
> -	if (sk->sk_state !=3D BT_CONNECTED)
> +	l2cap_chan_lock(chan);
> +	if (sk->sk_state !=3D BT_CONNECTED || !chan->conn) {
> +		l2cap_chan_unlock(chan);
>   		return -ENOTCONN;
> +	}
>
> -	l2cap_chan_lock(chan);
>   	err =3D l2cap_chan_send(chan, msg, len, sk->sk_priority);
>   	l2cap_chan_unlock(chan);
>  =20
Beside !chan->conn condition,I think it makes sense that sk_state check=
=20
should be moved after l2cap_chan_lock()
because sk_state could be changed due to l2cap_conn_del().

I think sk->state could be protected by l2cap_chan_lock() in the below=20
procedure.

l2cap_conn_del()
->l2cap_chan_lock()
->l2cap_chan_del()
-> lock_sock()
__l2cap_sock_state_change() *
-> release_sock()
->l2cap_chan_unlock()

BR
Chanyeol Park.
