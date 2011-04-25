From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: RPS will assign different smp_processor_id for the same packet?
Date: Mon, 25 Apr 2011 07:02:10 -0400
Message-ID: <20110425110210.GA24801@hmsreliant.think-freely.org>
References: <BANLkTimvuGKYuiV_ngTo4wtqhNix4iMfmA@mail.gmail.com>
 <1303402094.3685.54.camel@edumazet-laptop>
 <1303403112.3685.61.camel@edumazet-laptop>
 <BANLkTi=gTNwKX1Tb3mqgWJekRf7n_MHpJQ@mail.gmail.com>
 <BANLkTikY6CAZNkcnU-i7UvPpmSfQuXKtNQ@mail.gmail.com>
 <BANLkTimqkq+2X3=RZ1Qb0e5NpO-yRxuCoQ@mail.gmail.com>
 <BANLkTikyntWG6YPUdVipHvwJ8yGuU_Vi4w@mail.gmail.com>
 <1303632033.2747.51.camel@edumazet-laptop>
 <BANLkTintzzpixPi+HDzGUV_agCGr6EX7AQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: zhou rui <zhourui.cn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36737 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758392Ab1DYLCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 07:02:36 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTintzzpixPi+HDzGUV_agCGr6EX7AQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 24, 2011 at 05:36:51PM +0800, zhou rui wrote:
> On Sun, Apr 24, 2011 at 4:00 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le dimanche 24 avril 2011 =E0 10:00 +0800, zhou rui a =E9crit :
> >> On Sun, Apr 24, 2011 at 3:56 AM, Tom Herbert <therbert@google.com>=
 wrote:
> >> > On Sat, Apr 23, 2011 at 8:31 AM, zhou rui <zhourui.cn@gmail.com>=
 wrote:
> >> >> one more question is:
> >> >>
> >> >> in the function "int netif_receive_skb(struct sk_buff *skb)"
> >> >>
> >> >> cpu =3D get_rps_cpu(skb->dev, skb, &rflow);
> >> >> if (cpu >=3D 0) {
> >> >> =A0ret =3D enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
> >> >> ....
> >> >>
> >> >> probably the cpu is different from the current processor id?(sm=
p_processor_id)
> >> >> let's say: get_rps_cpu->cpu 0, smp_processor_id->cpu1
> >> >> when this happen, does it mean that cpu1 is handling the softir=
q but
> >> >> have to divert the packet to cpu0?(via a new softirq?)
> >> >>
> >> >> so for one packet it involve 2 softirqs?
> >> >>
> >> >> possible to get_rps_cpu in interrupt,then let the target cpu do=
 only
> >> >> one softirq to hanle the packet?
> >> >>
> >> > Yes, this is what a non-NAPI driver would do.
> >> >
> >> > Tom
> >> >
> >> non-NAPI will get_rps_cpu in irq, but why NAPI will get_rps_cpu in
> >> softirq?(if I understand correctly netif_receive_skb executed in
> >> softirq?)
> >
> > Thats hard to understand what your problem or question is.
> >
> > All heavy Receive networking stuff is handled in softirq.
> >
> > NAPI allows to reduce number of hardware IRQS in stress/load situat=
ions,
> > fetching several frames at once.
> >
> >
> >
> >
>=20
> my understanding:
>=20
> non-NAPI scenario:
>=20
> netif_rx( in irq, get_rps_cpu,enqueue_to_backlog to deliver packet to
> cpu queue) ------>net_rx_action(in softirq,deque and process packet)
>=20
>=20
> NAPI:
>=20
> what does RPS do?(in
> irq)------------------------>net_rx_action(softirq)----->netif_receiv=
e_skb(get_rps_cpu,enque
> packet)
>=20
> so my question is:
> for NAPI, get_rps_cpu will be done in softirq?
>=20
> if the above situation is true,will this happen?
> packet_for_cpu_1 --> cpu0(netif_receive_skb,in softirq) --->delivered
> to cpu1(softirq)
As Eric noted, NAPI enabled drivers using RPS will have a flow like he
described:
irq
 napi_schedule(driver)
  driver poll
   netif_receive_skb
    enqueue_to_backlog
     ipi
      napi_schedule (backlog dev)
       backlog dev poll
        netif_receive_skb

drivers using netif_rx do the same thing, the only difference is that t=
hey
schedule the local backlog device for a napi poll rather than their own=
 device.
This is done because the ipi to the remote cpu is issued from within th=
e napi
softirq, so we need to kick the local cpu to run a napi poll cycle afte=
r such a
driver receives a frame.

Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
