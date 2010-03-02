From: sbs <gexlie@gmail.com>
Subject: Re: Panic at tcp_xmit_retransmit_queue
Date: Tue, 2 Mar 2010 16:16:59 +0300
Message-ID: <53cc795f1003020516y7cbbfccfof73dab2de349277c@mail.gmail.com>
References: <53cc795f1001190813m377c6c91l16b2dc04f63049e7@mail.gmail.com>
	 <53cc795f1002010645w54b98b51s3dbdea18e5eb73f2@mail.gmail.com>
	 <alpine.DEB.2.00.1002031258160.7063@wel-95.cs.helsinki.fi>
	 <alpine.DEB.2.00.1002151520250.7063@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1002151520250.7063@wel-95.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

thank you very much, have stable running server for a week and it
seems that it works like a charm now, i havent detected any panics
since i apply the patch. although seems that the problem stops
ocurring cause i dont see any debug information through netconsole

On Mon, Feb 15, 2010 at 4:21 PM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> On Wed, 3 Feb 2010, Ilpo J=E4rvinen wrote:
>
>> On Mon, 1 Feb 2010, sbs wrote:
>>
>> > actually removing netconsole from kernel didnt help.
>> > i found many guys with the same problem but with different hardwar=
e
>> > configurations here:
>> >
>> > freez in TCP stack :
>> > http://bugzilla.kernel.org/show_bug.cgi?id=3D14470
>> >
>> > is there someone who can investigate it?
>> >
>> >
>> > On Tue, Jan 19, 2010 at 7:13 PM, sbs <gexlie@gmail.com> wrote:
>> > > We are hiting kernel panics on servers with nVidia MCP55 NICs on=
ce a day;
>> > > it appears usualy under a high network trafic ( around 10000Mbit=
/s) but
>> > > it is not a rule, it has happened even on low trafic.
>> > >
>> > > Servers are used as nginx+static content
>> > > On 2 equal servers this panic happens aprox 2 times a day depend=
ing on
>> > > network load. Machine completly freezes till the netconsole rebo=
ots.
>> > >
>> > > Kernel: 2.6.32.3
>> > >
>> > > what can it be? whats wrong with tcp_xmit_retransmit_queue() fun=
ction ?
>> > > can anyone explain or fix?
>>
>> You might want to try with to debug patch below. It might even make =
the
>> box to survive the event (if I got it coded right).
>
> Here should be a better version of the debug patch, hopefully the inf=
inite
> looping is now gone.
>
> --
> =A0i.
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 383ce23..4672a30 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2186,6 +2186,42 @@ static int tcp_can_forward_retransmit(struct s=
ock *sk)
> =A0 =A0 =A0 =A0return 1;
> =A0}
>
> +static void print_queue(struct sock *sk, struct sk_buff *old, struct=
 sk_buff *hole)
> +{
> + =A0 =A0 =A0 struct tcp_sock *tp =3D tcp_sk(sk);
> + =A0 =A0 =A0 struct sk_buff *skb, *prev;
> +
> + =A0 =A0 =A0 skb =3D tcp_write_queue_head(sk);
> + =A0 =A0 =A0 prev =3D (struct sk_buff *)(&sk->sk_write_queue);
> +
> + =A0 =A0 =A0 if (skb =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("NULL head, pkts %u\n", tp->pack=
ets_out);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 printk("head %p tail %p sendhead %p oldhint %p now %p h=
ole %p high %u\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_write_queue_head(sk), tcp_write_queu=
e_tail(sk),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_send_head(sk), old, tp->retransmit_s=
kb_hint, hole,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->retransmit_high);
> +
> + =A0 =A0 =A0 while (skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("skb %p (%u-%u) next %p prev %p =
sacked %u\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb, TCP_SKB_CB(skb)->se=
q, TCP_SKB_CB(skb)->end_seq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->next, skb->prev, TC=
P_SKB_CB(skb)->sacked);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (prev !=3D skb->prev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("Inconsistent pr=
ev\n");
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb =3D=3D tcp_write_queue_tail(sk)=
) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb->next !=3D (str=
uct sk_buff *)(&sk->sk_write_queue))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"Improper next at tail\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prev =3D skb;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D skb->next;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 printk("Encountered unexpected NULL\n");
> +}
> +
> =A0/* This gets called after a retransmit timeout, and the initially
> =A0* retransmitted data is acknowledged. =A0It tries to continue
> =A0* resending the rest of the retransmit queue, until either
> @@ -2194,12 +2230,15 @@ static int tcp_can_forward_retransmit(struct =
sock *sk)
> =A0* based retransmit packet might feed us FACK information again.
> =A0* If so, we use it to avoid unnecessarily retransmissions.
> =A0*/
> +static int caught_it =3D 0;
> +
> =A0void tcp_xmit_retransmit_queue(struct sock *sk)
> =A0{
> =A0 =A0 =A0 =A0const struct inet_connection_sock *icsk =3D inet_csk(s=
k);
> =A0 =A0 =A0 =A0struct tcp_sock *tp =3D tcp_sk(sk);
> =A0 =A0 =A0 =A0struct sk_buff *skb;
> =A0 =A0 =A0 =A0struct sk_buff *hole =3D NULL;
> + =A0 =A0 =A0 struct sk_buff *old =3D tp->retransmit_skb_hint;
> =A0 =A0 =A0 =A0u32 last_lost;
> =A0 =A0 =A0 =A0int mib_idx;
> =A0 =A0 =A0 =A0int fwd_rexmitting =3D 0;
> @@ -2217,6 +2256,16 @@ void tcp_xmit_retransmit_queue(struct sock *sk=
)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0last_lost =3D tp->snd_una;
> =A0 =A0 =A0 =A0}
>
> +checknull:
> + =A0 =A0 =A0 if (skb =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!caught_it)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 print_queue(sk, old, ho=
le);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 caught_it++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (net_ratelimit())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("Errors caught s=
o far %u\n", caught_it);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0tcp_for_write_queue_from(skb, sk) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__u8 sacked =3D TCP_SKB_CB(skb)->sacke=
d;
>
> @@ -2257,7 +2306,7 @@ begin_fwd:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else if (!(sacked & TCPCB_LOST)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (hole =3D=3D NULL &=
& !(sacked & (TCPCB_SACKED_RETRANS|TCPCB_SACKED_ACKED)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hole =3D=
 skb;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto cont;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0last_lost =3D TCP_SKB_=
CB(skb)->end_seq;
> @@ -2268,7 +2317,7 @@ begin_fwd:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sacked & (TCPCB_SACKED_ACKED|TCPCB=
_SACKED_RETRANS))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto cont;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (tcp_retransmit_skb(sk, skb))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> @@ -2278,6 +2327,9 @@ begin_fwd:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inet_csk_reset_xmit_ti=
mer(sk, ICSK_TIME_RETRANS,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0inet_csk(sk)->icsk_rto,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0TCP_RTO_MAX);
> +cont:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D skb->next;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto checknull;
> =A0 =A0 =A0 =A0}
> =A0}
>
