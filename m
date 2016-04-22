From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net 3/3] gre: receive also TEB packets for lwtunnels
Date: Fri, 22 Apr 2016 14:07:01 -0700
Message-ID: <CAOrHB_DrFXg=nQAdscOgX8nbUoOC4fMsWiN6R4n907zB5rtD=g@mail.gmail.com>
References: <cover.1461346798.git.jbenc@redhat.com>
	<017d8f2b1c00e8fdbdb92a5898b1b5f365b58d6d.1461346798.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:44117 "EHLO
	slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbcDVVN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 17:13:58 -0400
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net [217.70.183.198])
	by slow1-d.mail.gandi.net (Postfix) with ESMTP id C864747BADD
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 23:07:07 +0200 (CEST)
Received: from mfilter29-d.gandi.net (mfilter29-d.gandi.net [217.70.178.160])
	by relay6-d.mail.gandi.net (Postfix) with ESMTP id B1415FB8A9
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 23:07:03 +0200 (CEST)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
	by mfilter29-d.gandi.net (mfilter29-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id dpjcGUr6Tza7 for <netdev@vger.kernel.org>;
	Fri, 22 Apr 2016 23:07:02 +0200 (CEST)
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	(Authenticated sender: pshelar@ovn.org)
	by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 36FA7FB89E
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 23:07:02 +0200 (CEST)
Received: by mail-ig0-f175.google.com with SMTP id bi2so23903512igb.0
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 14:07:02 -0700 (PDT)
In-Reply-To: <017d8f2b1c00e8fdbdb92a5898b1b5f365b58d6d.1461346798.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 22, 2016 at 10:44 AM, Jiri Benc <jbenc@redhat.com> wrote:
> For ipgre interfaces in collect metadata mode, receive also traffic with
> encapsulated Ethernet headers. The lwtunnel users are supposed to sort this
> out correctly. This allows to have mixed Ethernet + L3-only traffic on the
> same lwtunnel interface.
>
How user is suppose to sort out the type of packet? whether it is L2 or L3.

> To keep backwards compatibility and prevent any surprises, gretap interfaces
> have priority in receiving packets with Ethernet headers.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  include/net/ip_tunnels.h |  1 +
>  net/ipv4/ip_gre.c        | 34 +++++++++++++++++++++++++---------
>  2 files changed, 26 insertions(+), 9 deletions(-)
>

...

> +
> +static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
> +{
> +       struct net *net = dev_net(skb->dev);
> +       struct ip_tunnel_net *itn;
> +       int res;
> +
> +       if (tpi->proto == htons(ETH_P_TEB))
> +               itn = net_generic(net, gre_tap_net_id);
> +       else
> +               itn = net_generic(net, ipgre_net_id);
> +
> +       res = __ipgre_rcv(skb, tpi, itn);
> +       if (res == PACKET_NEXT && tpi->proto == htons(ETH_P_TEB)) {
> +               /* ipgre tunnels in collect metadata mode should receive
> +                * also ETH_P_TEB traffic
> +                */
> +               itn = net_generic(net, ipgre_net_id);
> +               res = __ipgre_rcv(skb, tpi, int);

Is it fine to receive L2 packet over L3 device?
At least ip_tunnel_rcv() is not ready to handle such packet.
