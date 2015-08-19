From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 9/9] geneve: Implement rtnl changelink
Date: Wed, 19 Aug 2015 12:40:45 -0700
Message-ID: <CAEP_g=8w4wYxFMvZcxUiCMpW5qT5ZMY0JQ9oJ=pxeK4E8Jpudw@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com> <1439845905-31666-10-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:33510 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910AbbHSTlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 15:41:06 -0400
Received: by lbbsx3 with SMTP id sx3so10176775lbb.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 12:41:04 -0700 (PDT)
In-Reply-To: <1439845905-31666-10-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 17, 2015 at 2:11 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index e47cdd9..0d7fbef 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> -static int geneve_configure(struct net *net, struct net_device *dev,
> -                           __be32 rem_addr, __u32 vni, __u8 ttl, __u8 tos,
> -                           __u16 dst_port, bool metadata)
> +static int __geneve_configure(struct net *net, struct net_device *dev,
> +                             __be32 rem_addr, __u32 vni, __u8 ttl, __u8 tos,
> +                             __u16 dst_port, bool metadata)
>  {
[...]
>         geneve->net = net;
>         geneve->dev = dev;

I guess this stuff should really be in geneve_configure() - it seems a
bit odd to change it for a running device (even if it shouldn't
change).

>         geneve->remote.sin_addr.s_addr = rem_addr;
>         if (IN_MULTICAST(ntohl(geneve->remote.sin_addr.s_addr)))
>                 return -EINVAL;
>
> +       u32_to_vni(vni, geneve->vni);
>         list_for_each_entry(t, &gn->geneve_list, next) {
>                 if (!memcmp(geneve->vni, t->vni, sizeof(t->vni)) &&
>                     rem_addr == t->remote.sin_addr.s_addr &&

I'm not sure that these types of operations are safe if the device is
already running. We first overwrite the remote value and then we do
error checking but that means that if there is an error, then the
device will be left in a broken state. Don't we also need to update
the hash table if some of these parameters change?

> +static int geneve_changelink(struct net_device *dev,
> +                            struct nlattr *tb[], struct nlattr *data[])
> +{
[...]
> -       if (data[IFLA_GENEVE_PORT])
> -               dst_port = nla_get_u16(data[IFLA_GENEVE_PORT]);
> +       if (geneve->sock && (dst_port != ntohs(geneve->dst_port) ||
> +                            metadata != geneve->collect_md)) {

It seems like in an ideal world, we wouldn't need to recreate the
socket if metadata collection changed (assuming that there are no new
conflicts).
