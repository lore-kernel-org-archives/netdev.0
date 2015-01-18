From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [net-next PATCH v2 06/12] net: rocker: add pipeline model for
 rocker switch
Date: Sat, 17 Jan 2015 22:39:53 -0800
Message-ID: <CAE4R7bCPrjQCNFkF=d8hjQaNGdziwGv+LuQDJOLazWUnCP+GTg@mail.gmail.com>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
	<20150113213739.13874.37091.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Netdev <netdev@vger.kernel.org>, gerlitz.or@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:48189 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbbARGjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 01:39:54 -0500
Received: by mail-we0-f181.google.com with SMTP id q58so26416351wes.12
        for <netdev@vger.kernel.org>; Sat, 17 Jan 2015 22:39:53 -0800 (PST)
In-Reply-To: <20150113213739.13874.37091.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2015 at 1:37 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> This adds rocker support for the net_flow_get_* operations. With this
> we can interrogate rocker.
>
> Here we see that for static configurations enabling the get operations
> is simply a matter of defining a pipeline model and returning the
> structures for the core infrastructure to encapsulate into netlink
> messages.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/ethernet/rocker/rocker.c          |   65 ++++
>  drivers/net/ethernet/rocker/rocker_pipeline.h |  451 +++++++++++++++++++++++++
>  2 files changed, 516 insertions(+)
>  create mode 100644 drivers/net/ethernet/rocker/rocker_pipeline.h
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index 2f398fa..d2ea451 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -36,6 +36,7 @@
>  #include <generated/utsrelease.h>
>
>  #include "rocker.h"
> +#include "rocker_pipeline.h"
>
>  static const char rocker_driver_name[] = "rocker";
>
> @@ -3781,6 +3782,56 @@ static int rocker_port_switch_port_stp_update(struct net_device *dev, u8 state)
>         return rocker_port_stp_update(rocker_port, state);
>  }
>
> +static void rocker_destroy_flow_tables(struct rocker_port *rocker_port)
> +{
> +       int i;
> +
> +       for (i = 0; rocker_table_list[i]; i++)
> +               net_flow_destroy_cache(rocker_table_list[i]);
> +}
> +
> +static int rocker_init_flow_tables(struct rocker_port *rocker_port)
> +{
> +       int i, err;
> +
> +       for (i = 0; rocker_table_list[i]; i++) {
> +               err = net_flow_init_cache(rocker_table_list[i]);
> +               if (err) {
> +                       rocker_destroy_flow_tables(rocker_port);
> +                       return err;
> +               }
> +       }
> +
> +       return 0;
> +}

Can these be moved up above drivers?  They don't seem driver or device
specific.  Call .ndo_flow_get_tbls to get table list.

> +
> +#ifdef CONFIG_NET_FLOW_TABLES
> +static struct net_flow_tbl **rocker_get_tables(struct net_device *d)
> +{
> +       return rocker_table_list;
> +}
> +
> +static struct net_flow_hdr **rocker_get_headers(struct net_device *d)
> +{
> +       return rocker_header_list;
> +}
> +
> +static struct net_flow_action **rocker_get_actions(struct net_device *d)
> +{
> +       return rocker_action_list;
> +}
> +
> +static struct net_flow_tbl_node **rocker_get_tgraph(struct net_device *d)
> +{
> +       return rocker_table_nodes;
> +}
> +
> +static struct net_flow_hdr_node **rocker_get_hgraph(struct net_device *d)
> +{
> +       return rocker_header_nodes;
> +}
> +#endif

Do these need to be functions since they all just return static pointer lists?

>  static const struct net_device_ops rocker_port_netdev_ops = {
>         .ndo_open                       = rocker_port_open,
>         .ndo_stop                       = rocker_port_stop,
> @@ -3795,6 +3846,13 @@ static const struct net_device_ops rocker_port_netdev_ops = {
>         .ndo_bridge_getlink             = rocker_port_bridge_getlink,
>         .ndo_switch_parent_id_get       = rocker_port_switch_parent_id_get,
>         .ndo_switch_port_stp_update     = rocker_port_switch_port_stp_update,
> +#ifdef CONFIG_NET_FLOW_TABLES
> +       .ndo_flow_get_tbls              = rocker_get_tables,
> +       .ndo_flow_get_hdrs              = rocker_get_headers,
> +       .ndo_flow_get_actions           = rocker_get_actions,
> +       .ndo_flow_get_tbl_graph         = rocker_get_tgraph,
> +       .ndo_flow_get_hdr_graph         = rocker_get_hgraph,

Please keep the rocker_port_xxx for .ndo_xxx naming convention.

> +#endif
>  };
>
>  /********************
> @@ -3960,6 +4018,7 @@ static void rocker_remove_ports(struct rocker *rocker)
>                 rocker_port = rocker->ports[i];
>                 rocker_port_ig_tbl(rocker_port, ROCKER_OP_FLAG_REMOVE);
>                 unregister_netdev(rocker_port->dev);
> +               rocker_destroy_flow_tables(rocker_port);
>         }
>         kfree(rocker->ports);
>  }
> @@ -4023,6 +4082,12 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
>                 goto err_port_ig_tbl;
>         }
>
> +       err = rocker_init_flow_tables(rocker_port);
> +       if (err) {
> +               dev_err(&pdev->dev, "install flow table failed\n");

s/table/tables/

> +               goto err_port_ig_tbl;

Need to rocker_port_ig_tbl(rocker_port, ROCKER_OP_FLAG_REMOVE) to clean up.

-scott
