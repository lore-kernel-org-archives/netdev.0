From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC net-next] net: xfrm: support setting an output mark.
Date: Mon, 7 Aug 2017 22:34:37 +0900
Message-ID: <CAKD1Yr2YXYed+vVgcyYo4XLAFXGjwwdSRucOmg+z2PVZD_A06Q@mail.gmail.com>
References: <20170807092326.10239-1-lorenzo@google.com> <20170807111623.GQ2631@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        herbert@gondor.apana.org.au, Nathan Harold <nharold@google.com>,
        Jonathan Basseri <misterikkit@google.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33772 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751399AbdHGNe6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 09:34:58 -0400
Received: by mail-io0-f177.google.com with SMTP id j32so2651392iod.0
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 06:34:58 -0700 (PDT)
In-Reply-To: <20170807111623.GQ2631@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 7, 2017 at 8:16 PM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> >       XFRMA_OFFLOAD_DEV,      /* struct xfrm_state_offload */
> > +     XFRMA_OUTPUT_MARK,      /* __u32 */
> >       __XFRMA_MAX
>
> Hm, why don't you use the existing xfrm_mark for this?
> Having two different marks on one SA seems to be a bit odd.

I think using a separate mark is conceptually cleaner and much more flexible.

The existing xfrm_mark is constrained to match the mark of the socket
that sends the packet (or the unencrypted packet that is transformed).
Specifically (at least if I'm reading the code correctly),
xfrm_policy_match requires:

    (fl->flowi_mark & pol->mark.m) == pol->mark.v

and xfrm_state_find requires:

    (mark & x->mark.m) == x->mark.v

so basically the SA mark is a subset of the bits of the policy mark,
which is a subset of the bits of sk_mark.

On systems using mark-based routing (or at least on Android [1]), the
mark decides how a packet is routed, and in order for things to work
properly the routing of an IPsec tunnel should depend only on the
tunnel configuration and not on the mark of any socket or any packet
that is routed through that tunnel. The mark might select which tunnel
to go through, and the output mark would decide how the tunnel packets
are routed.

A real use case is IWLAN [2], which is used to connect to 3GPP
networks over wifi. The phone has the same IP addresses on the
cellular interface and on an IPsec tunnel to a carrier gateway (PDG).
On Android, a socket connected on the carrier network through a native
interface such as LTE will have the socket mark that's specific to the
carrier network. If the device then hands over the carrier connection
to the IPsec tunnel over wifi, the socket will still have the mark of
the LTE interface. If we used xfrm_mark, then the tunneled packets
themselves will be routed on LTE instead of being routed on wifi. That
obviously defeats the purpose.

Using XFRM_OUTPUT_MARK makes this much cleaner: the socket can
continue to be marked with the carrier network's mark, and it's the
IPsec tunnel itself that is bound to the wifi network using the mark
in the SA.

Another use case is if there are multiple SAs that apply to a given
socket/packet (e.g., a transport mode SA for an individual TCP
connection, wrapped in a tunnel mode SA that applies to a whole remote
site or network). This is required when running SIP over IWLAN (i.e.,
"wifi calling") - the SIP connection is always encrypted in transport
mode regardless of whether the carrier connection is native or
tunneled over wifi, and when on wifi, the mark that is used to route
the packet must be the tunnel mode SA, not the socket mark or the
transport mode SA mark.


[1] http://www.netdevconf.org/1.1/proceedings/slides/colitti-kline-linux-networking-android-devices.pdf
[2] http://www.etsi.org/deliver/etsi_ts/124300_124399/124327/12.00.00_60/ts_124327v120000p.pdf
