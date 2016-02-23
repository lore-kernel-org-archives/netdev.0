From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 2/5] bridge: notify ensabled devices of headroom changes
Date: Tue, 23 Feb 2016 11:20:42 -0800
Message-ID: <CAOrHB_Cf6Cnp-r4eMChq=9UeUq_Rg7QG41MiP=HmZFAFaCrUAA@mail.gmail.com>
References: <cover.1456163137.git.pabeni@redhat.com>
	<060a30aa8e6d2c3eda16dd893b348851cd4bd195.1456163137.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:36590 "EHLO
	relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453AbcBWTUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 14:20:46 -0500
Received: from mfilter26-d.gandi.net (mfilter26-d.gandi.net [217.70.178.154])
	by relay6-d.mail.gandi.net (Postfix) with ESMTP id 096C1FB882
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 20:20:45 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
	by mfilter26-d.gandi.net (mfilter26-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id A5ePN4NK5gzT for <netdev@vger.kernel.org>;
	Tue, 23 Feb 2016 20:20:43 +0100 (CET)
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	(Authenticated sender: pshelar@ovn.org)
	by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 748F6FB88B
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 20:20:43 +0100 (CET)
Received: by mail-ig0-f181.google.com with SMTP id hb3so105970503igb.0
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 11:20:43 -0800 (PST)
In-Reply-To: <060a30aa8e6d2c3eda16dd893b348851cd4bd195.1456163137.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 4:53 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> On bridge needed_headroom changes, the enslaved devices are
> notified via the ndo_set_rx_headroom method
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/bridge/br_if.c | 36 ++++++++++++++++++++++++++++++++++--
>  1 file changed, 34 insertions(+), 2 deletions(-)
>
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index c367b3e..f42f1da 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -223,6 +223,31 @@ static void destroy_nbp_rcu(struct rcu_head *head)
>         destroy_nbp(p);
>  }
>
> +static unsigned get_max_headroom(struct net_bridge *br)
> +{
> +       unsigned max_headroom = 0;
> +       struct net_bridge_port *p;
> +
> +       list_for_each_entry(p, &br->port_list, list) {
> +               unsigned dev_headroom = netdev_get_fwd_headroom(p->dev);
> +

IFF_PHONY_HEADROOM is only set for veth and ovs-internal-device, so we
can not get headroom for tunnel devices. I guess it worked in your
tests due to the bug in netdev_get_fwd_headroom().
