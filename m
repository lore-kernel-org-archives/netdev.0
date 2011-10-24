From: Bradley Peterson <despite@gmail.com>
Subject: Re: BUG in skb_pull with e1000e, PPTP, and L2TP
Date: Mon, 24 Oct 2011 16:59:14 -0500
Message-ID: <CAJuWrdvshtxeYGcD6NMLdBYkmkfb-7xkAE93R02QhSxVx7c3=w@mail.gmail.com>
References: <CAJuWrdtOru6KSNTxXhhQNEZUTaX5KvyF7macx4RZYxMzcAo0KQ@mail.gmail.com>
	<1318904666.2571.33.camel@edumazet-laptop>
	<1318909879.2571.43.camel@edumazet-laptop>
	<1318910393.2571.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1318910393.2571.47.camel@edumazet-laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Oct 17, 2011 at 10:59 PM, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
> Le mardi 18 octobre 2011 =E0 05:51 +0200, Eric Dumazet a =E9crit :
>> Le mardi 18 octobre 2011 =E0 04:24 +0200, Eric Dumazet a =E9crit :
>>
>> > diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
>> > index eae542a..d0197e3 100644
>> > --- a/drivers/net/ppp/pptp.c
>> > +++ b/drivers/net/ppp/pptp.c
>> > @@ -305,11 +305,16 @@ static int pptp_rcv_core(struct sock *sk, struct=
 sk_buff *skb)
>> > =A0 =A0 }
>> >
>> > =A0 =A0 header =3D (struct pptp_gre_header *)(skb->data);
>> > + =A0 headersize =A0=3D sizeof(*header);
>> >
>> > =A0 =A0 /* test if acknowledgement present */
>> > =A0 =A0 if (PPTP_GRE_IS_A(header->ver)) {
>> > - =A0 =A0 =A0 =A0 =A0 __u32 ack =3D (PPTP_GRE_IS_S(header->flags)) ?
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 header->ack : he=
ader->seq; /* ack in different place if S =3D 0 */
>> > + =A0 =A0 =A0 =A0 =A0 __u32 ack;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, headersize))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
>>
>> Oh well, this is buggy, I need to set header again, I'll send an updated
>> patch
>>
>
> [PATCH v2] pptp: pptp_rcv_core() misses pskb_may_pull() call
>
> e1000e uses paged frags, so any layer incorrectly pulling bytes from skb
> can trigger a BUG in skb_pull()
>
> [951.142737] =A0[<ffffffff813d2f36>] skb_pull+0x15/0x17
> [951.142737] =A0[<ffffffffa0286824>] pptp_rcv_core+0x126/0x19a [pptp]
> [951.152725] =A0[<ffffffff813d17c4>] sk_receive_skb+0x69/0x105
> [951.163558] =A0[<ffffffffa0286993>] pptp_rcv+0xc8/0xdc [pptp]
> [951.165092] =A0[<ffffffffa02800a3>] gre_rcv+0x62/0x75 [gre]
> [951.165092] =A0[<ffffffff81410784>] ip_local_deliver_finish+0x150/0x1c1
> [951.177599] =A0[<ffffffff81410634>] ? ip_local_deliver_finish+0x0/0x1c1
> [951.177599] =A0[<ffffffff81410846>] NF_HOOK.clone.7+0x51/0x58
> [951.177599] =A0[<ffffffff81410996>] ip_local_deliver+0x51/0x55
> [951.177599] =A0[<ffffffff814105b9>] ip_rcv_finish+0x31a/0x33e
> [951.177599] =A0[<ffffffff8141029f>] ? ip_rcv_finish+0x0/0x33e
> [951.204898] =A0[<ffffffff81410846>] NF_HOOK.clone.7+0x51/0x58
> [951.214651] =A0[<ffffffff81410bb5>] ip_rcv+0x21b/0x246
>
> pptp_rcv_core() is a nice example of a function assuming everything it
> needs is available in skb head.
>
> Reported-by: Bradley Peterson <despite@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =A0drivers/net/ppp/pptp.c | =A0 20 ++++++++++++--------
> =A01 file changed, 12 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
> index eae542a..29730fd 100644
> --- a/drivers/net/ppp/pptp.c
> +++ b/drivers/net/ppp/pptp.c
> @@ -305,11 +305,18 @@ static int pptp_rcv_core(struct sock *sk, struct sk=
_buff *skb)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0header =3D (struct pptp_gre_header *)(skb->data);
> + =A0 =A0 =A0 headersize =A0=3D sizeof(*header);
>
> =A0 =A0 =A0 =A0/* test if acknowledgement present */
> =A0 =A0 =A0 =A0if (PPTP_GRE_IS_A(header->ver)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __u32 ack =3D (PPTP_GRE_IS_S(header->flags)=
) ?
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 header->ack=
 : header->seq; /* ack in different place if S =3D 0 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __u32 ack;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, headersize))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 header =3D (struct pptp_gre_header *)(skb->=
data);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* ack in different place if S =3D 0 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ack =3D PPTP_GRE_IS_S(header->flags) ? head=
er->ack : header->seq;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ack =3D ntohl(ack);
>
> @@ -318,21 +325,18 @@ static int pptp_rcv_core(struct sock *sk, struct sk=
_buff *skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* also handle sequence number wrap-around=
 =A0*/
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (WRAPPED(ack, opt->ack_recv))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0opt->ack_recv =3D ack;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 headersize -=3D sizeof(header->ack);
> =A0 =A0 =A0 =A0}
> -
> =A0 =A0 =A0 =A0/* test if payload present */
> =A0 =A0 =A0 =A0if (!PPTP_GRE_IS_S(header->flags))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto drop;
>
> - =A0 =A0 =A0 headersize =A0=3D sizeof(*header);
> =A0 =A0 =A0 =A0payload_len =3D ntohs(header->payload_len);
> =A0 =A0 =A0 =A0seq =A0 =A0 =A0 =A0 =3D ntohl(header->seq);
>
> - =A0 =A0 =A0 /* no ack present? */
> - =A0 =A0 =A0 if (!PPTP_GRE_IS_A(header->ver))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 headersize -=3D sizeof(header->ack);
> =A0 =A0 =A0 =A0/* check for incomplete packet (length smaller than expect=
ed) */
> - =A0 =A0 =A0 if (skb->len - headersize < payload_len)
> + =A0 =A0 =A0 if (!pskb_may_pull(skb, headersize + payload_len))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto drop;
>
> =A0 =A0 =A0 =A0payload =3D skb->data + headersize;
>
>
>

This patch has been working for me.  5 days uptime, with no crashes.
Thanks for your help!

Bradley Peterson

---------------------------------------------------------------------------=
---
The demand for IT networking professionals continues to grow, and the
demand for specialized networking skills is growing even more rapidly.
Take a complimentary Learning@Cisco Self-Assessment and learn =

about Cisco certifications, training, and career opportunities. =

http://p.sf.net/sfu/cisco-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
