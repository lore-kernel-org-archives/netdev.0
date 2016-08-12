From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net v2] gre: set inner_protocol on xmit
Date: Fri, 12 Aug 2016 10:57:15 -0700
Message-ID: <CAOrHB_CJdxnZgQJHQzT00SjeHTXt7J19Lbg2qDUoH_qKR=kOTA@mail.gmail.com>
References: <1471014883-25399-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:52401 "EHLO
	relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbcHLR5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 13:57:21 -0400
Received: from mfilter34-d.gandi.net (mfilter34-d.gandi.net [217.70.178.165])
	by relay6-d.mail.gandi.net (Postfix) with ESMTP id 802E4FB8A0
	for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 19:57:18 +0200 (CEST)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
	by mfilter34-d.gandi.net (mfilter34-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id uir5ourTPeCu for <netdev@vger.kernel.org>;
	Fri, 12 Aug 2016 19:57:17 +0200 (CEST)
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	(Authenticated sender: pshelar@ovn.org)
	by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 0AE45FB882
	for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 19:57:16 +0200 (CEST)
Received: by mail-io0-f171.google.com with SMTP id 38so31520602iol.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 10:57:16 -0700 (PDT)
In-Reply-To: <1471014883-25399-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2016 at 8:14 AM, Simon Horman
<simon.horman@netronome.com> wrote:
> Ensure that the inner_protocol is set on transmit so that GSO segmentation,
> which relies on that field, works correctly.
>
> I have observed this is not the case when OvS transmits GRE using
> lwtunnel metadata (which it always does).
>
> Fixes: 38720352412a ("gre: Use inner_proto to obtain inner header protocol")
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
> v2
> * Added Alexander's Ack
> * Drop RFC designation
> ---
>  net/ipv4/ip_gre.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 5b1481be0282..1571b71448a0 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -451,6 +451,7 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev,
>
>         df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
>
> +       skb_set_inner_protocol(skb, proto);
>         iptunnel_xmit(skb->sk, rt, skb, fl.saddr, key->u.ipv4.dst, IPPROTO_GRE,
>                       key->tos, key->ttl, df, false);
>         return;

This patch is right but can you move this call to gre_build_header().
This way there would less duplicate code. Plus it is more consistent
with vxlan and geneve where the inner protocol is set in respective
build header functions.
