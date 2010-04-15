From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
	avahi-daemon: caller is netif_rx
Date: Thu, 15 Apr 2010 16:27:19 +0800
Message-ID: <k2y412e6f7f1004150127u4e7ec668r80f066bfb3efea81@mail.gmail.com>
References: <l2p412e6f7f1004150030o8a406133s91d6614cbb106796@mail.gmail.com>
	<20100415.003711.159334670.davem@davemloft.net> <u2o412e6f7f1004150047nc9250ffuaef68be066a7575c@mail.gmail.com>
	<20100415.005726.205428265.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, therbert@google.com, eparis@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:38391 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756053Ab0DOI1k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 04:27:40 -0400
Received: by gyg13 with SMTP id 13so616291gyg.19
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 01:27:39 -0700 (PDT)
In-Reply-To: <20100415.005726.205428265.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 3:57 PM, David Miller <davem@davemloft.net> wro=
te:
>
> Why? =C2=A0If we are in an interrupt (either soft or hard) then
> smp_processor_id() is stable, and valid.
>
> Changli, I find it very frustrating to communicate with you, you are
> very terse in your descriptions and analysis and you make many simple
> errors that would be avoided if you spent more time thinking about
> things before sending your emails. :-/
>
> Instead of just showing some pseudo patch, state WHY it is needed.
> Talk about the execution state of environment and what rules or other
> things are being violated which must be corrected.
>

Sorry. English isn't my native language, so sometimes I can't describe
myself clearly.

I think the following patch from Eric should be applied instead.

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c65f18e..d1bcc9f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -120,7 +120,7 @@ static int ip_dev_loopback_xmit(struct sk_buff *new=
skb)
       newskb->pkt_type =3D PACKET_LOOPBACK;
       newskb->ip_summed =3D CHECKSUM_UNNECESSARY;
       WARN_ON(!skb_dst(newskb));
-       netif_rx(newskb);
+       netif_rx_ni(newskb);
       return 0;
 }

As you know  "netif_rx() must be invoked from a hardware or software
interrupt, which implies preemption disabled.", obviously
ip_dev_loopback_xmit() doesn't obey this rule, so the crash isn't the
fault of net_rx(). If there are other users, who don't obey this rule,
they should be fixed too.

=46or this patch:

-       cpu =3D smp_processor_id();
+       ret =3D enqueue_to_backlog(skb, get_cpu());
+       put_cpu();

You said: " If we are in an interrupt (either soft or hard) then
smp_processor_id() is stable, and valid.". so we don't need to call
get_cpu() instead of smp_processor_id(). get_cpu() brings no good but
additional cost preempt_disable().

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
