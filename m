From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Tue, 3 Mar 2015 23:02:33 -0800
Message-ID: <CAE4R7bArwsNUdtNM25Zm=ZccrmVqC8e45E6qsjMdO3s0FrOVog@mail.gmail.com>
References: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:45688 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933252AbbCDHCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 02:02:34 -0500
Received: by mail-qg0-f44.google.com with SMTP id z107so14948536qgd.3
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 23:02:33 -0800 (PST)
In-Reply-To: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 3, 2015 at 4:15 PM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> With the recent addition of the NETIF_F_HW_SWITCH_OFFLOAD flag
> on rocker ports, the second command (bridge link set) below will turn off
> learning in the rocker hw (Scott/Jiri, need some confirmation from
> you that this is indeed a problem and if the below patch is ok).
>
> ip link set dev swp1 master br0
> bridge link set dev swp1 learning off master
> bridge link set dev swp1 learning_sync on self
>
> This patch fixes rocker to ignore learning setting when 'master'
> is set. This makes it possible to set/unset learning in kernel and bridge
> driver independently.
>
> The below command will continue to set learning on in both kernel and rocker
> hw:
> bridge link set dev swp1 learning on
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  drivers/net/ethernet/rocker/rocker.c |    3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index e5a15a4..d7c31d2 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -3769,6 +3769,9 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
>         struct nlattr *attr;
>         int err;
>
> +       if (flags && !(flags & BRIDGE_FLAGS_SELF))
> +               return 0;
> +
>         protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
>                                    IFLA_PROTINFO);
>         if (protinfo) {


NACK on this patch.  This is the problem with netlink creeping into
ndo ops: it's too tempting to push work-arounds down to driver.

In this case, you're making the driver check to see if it's SELF when
it's already SELF by definition.

Rocker setlink wasn't broken prior to the NETIF_F_HW_SWITCH_OFFLOAD
patches.  Now it is, but this isn't the right fix.

Can we revisit this so these two commands only hit MASTER:

   bridge link set dev swp1 learning on
   bridge link set dev swp1 learning on master

And this one hits SELF:

    bridge link set dev swp1 learning on self
