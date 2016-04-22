From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net 1/3] gre: do not assign header_ops in collect metadata mode
Date: Fri, 22 Apr 2016 14:04:48 -0700
Message-ID: <CAOrHB_Dffj93ED0u+RQ89SneRn5YRGFB9piYYiTDFJ43ZGDpNQ@mail.gmail.com>
References: <cover.1461346798.git.jbenc@redhat.com>
	<7c34e7243a146fc5ccdf6349892355746741ff26.1461346798.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:40006 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbcDVVEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 17:04:53 -0400
Received: from mfilter16-d.gandi.net (mfilter16-d.gandi.net [217.70.178.144])
	by relay4-d.mail.gandi.net (Postfix) with ESMTP id 6FAA3172097
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 23:04:51 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
	by mfilter16-d.gandi.net (mfilter16-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id ISZS6YbDZKfy for <netdev@vger.kernel.org>;
	Fri, 22 Apr 2016 23:04:50 +0200 (CEST)
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	(Authenticated sender: pshelar@ovn.org)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id E24D01720A9
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 23:04:49 +0200 (CEST)
Received: by mail-io0-f182.google.com with SMTP id u185so131467423iod.3
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 14:04:49 -0700 (PDT)
In-Reply-To: <7c34e7243a146fc5ccdf6349892355746741ff26.1461346798.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 22, 2016 at 10:44 AM, Jiri Benc <jbenc@redhat.com> wrote:
> In ipgre mode (i.e. not gretap) with collect metadata flag set, the tunnel
> is incorrectly assumed to be mGRE in NBMA mode (see commit 6a5f44d7a048c).
> This is not the case, we're controlling the encapsulation addresses by
> lwtunnel metadata. And anyway, assigning dev->header_ops in collect metadata
> mode does not make sense.
>
> Fixes: 2e15ea390e6f4 ("ip_gre: Add support to collect tunnel metadata.")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  net/ipv4/ip_gre.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index af5d1f38217f..d0abde4236af 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -893,7 +893,7 @@ static int ipgre_tunnel_init(struct net_device *dev)
>         netif_keep_dst(dev);
>         dev->addr_len           = 4;
>
> -       if (iph->daddr) {
> +       if (iph->daddr && !tunnel->collect_md) {
>  #ifdef CONFIG_NET_IPGRE_BROADCAST
>                 if (ipv4_is_multicast(iph->daddr)) {
>                         if (!iph->saddr)
> @@ -902,8 +902,9 @@ static int ipgre_tunnel_init(struct net_device *dev)
>                         dev->header_ops = &ipgre_header_ops;
>                 }
>  #endif

I think we should we return error in case of such configuration rather
than silently ignoring it.
