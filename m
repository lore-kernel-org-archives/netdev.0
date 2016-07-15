From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH v3 6/8] thunderbolt: Networking state machine
Date: Thu, 14 Jul 2016 20:25:15 -0400
Message-ID: <CAP=VYLoAUw+8B7BwzopBTeZjMYbZpOnUOE9tEnYH6718TjW_pQ@mail.gmail.com>
References: <1468495702-7467-1-git-send-email-amir.jer.levy@intel.com> <1468495702-7467-7-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: andreas.noever@gmail.com,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	bhelgaas@google.com, linux-pci@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, thunderbolt-linux@intel.com,
	mika.westerberg@intel.com, tomas.winkler@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36675 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247AbcGOAZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 20:25:47 -0400
In-Reply-To: <1468495702-7467-7-git-send-email-amir.jer.levy@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 14, 2016 at 7:28 AM, Amir Levy <amir.jer.levy@intel.com> wrote:
> Negotiation states that a peer goes through in order to establish
> the communication with the second peer.
> This includes communication with upper layer and additional
> infrastructure support to communicate with the second peer through ICM.
>
> Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
> ---
>  drivers/thunderbolt/icm/Makefile  |   2 +-
>  drivers/thunderbolt/icm/icm_nhi.c | 304 ++++++++++++++-
>  drivers/thunderbolt/icm/net.c     | 802 ++++++++++++++++++++++++++++++++++++++
>  drivers/thunderbolt/icm/net.h     |  74 ++++
>  4 files changed, 1171 insertions(+), 11 deletions(-)
>  create mode 100644 drivers/thunderbolt/icm/net.c
>
> diff --git a/drivers/thunderbolt/icm/Makefile b/drivers/thunderbolt/icm/Makefile
> index 3adfc35..624ee31 100644
> --- a/drivers/thunderbolt/icm/Makefile
> +++ b/drivers/thunderbolt/icm/Makefile
> @@ -25,4 +25,4 @@
>  ################################################################################
>
>  obj-${CONFIG_THUNDERBOLT_ICM} += thunderbolt-icm.o
> -thunderbolt-icm-objs := icm_nhi.o
> +thunderbolt-icm-objs := icm_nhi.o net.o
> diff --git a/drivers/thunderbolt/icm/icm_nhi.c b/drivers/thunderbolt/icm/icm_nhi.c
> index 9d178a5..060bb38 100644
> --- a/drivers/thunderbolt/icm/icm_nhi.c
> +++ b/drivers/thunderbolt/icm/icm_nhi.c
> @@ -101,6 +101,12 @@ static const struct nla_policy nhi_genl_policy[NHI_ATTR_MAX + 1] = {
>                                         .len = TBT_ICM_RING_MAX_FRAME_SIZE },
>         [NHI_ATTR_MSG_FROM_ICM]         = { .type = NLA_BINARY,
>                                         .len = TBT_ICM_RING_MAX_FRAME_SIZE },
> +       [NHI_ATTR_LOCAL_ROUTE_STRING]   = {.len = sizeof(struct route_string)},
> +       [NHI_ATTR_LOCAL_UNIQUE_ID]      = { .len = sizeof(unique_id) },
> +       [NHI_ATTR_REMOTE_UNIQUE_ID]     = { .len = sizeof(unique_id) },
> +       [NHI_ATTR_LOCAL_DEPTH]          = { .type = NLA_U8, },
> +       [NHI_ATTR_ENABLE_FULL_E2E]      = { .type = NLA_FLAG, },
> +       [NHI_ATTR_MATCH_FRAME_ID]       = { .type = NLA_FLAG, },
>  };
>
>  /* NHI genetlink family */
> @@ -531,6 +537,29 @@ int nhi_mailbox(struct tbt_nhi_ctxt *nhi_ctxt, u32 cmd, u32 data, bool deinit)
>         return 0;
>  }
>
> +static inline bool nhi_is_path_disconnected(u32 cmd, u8 num_ports)
> +{
> +       return (cmd >= DISCONNECT_PORT_A_INTER_DOMAIN_PATH &&
> +               cmd < (DISCONNECT_PORT_A_INTER_DOMAIN_PATH + num_ports));
> +}
> +
> +static int nhi_mailbox_disconn_path(struct tbt_nhi_ctxt *nhi_ctxt, u32 cmd)
> +       __releases(&controllers_list_rwsem)
> +{
> +       struct port_net_dev *port;
> +       u32 port_num = cmd - DISCONNECT_PORT_A_INTER_DOMAIN_PATH;
> +
> +       port = &(nhi_ctxt->net_devices[port_num]);
> +       mutex_lock(&port->state_mutex);
> +
> +       up_read(&controllers_list_rwsem);
> +       port->medium_sts = MEDIUM_READY_FOR_APPROVAL;
> +       if (port->net_dev)
> +               negotiation_events(port->net_dev, MEDIUM_DISCONNECTED);
> +       mutex_unlock(&port->state_mutex);
> +       return  0;
> +}
> +
>  static int nhi_mailbox_generic(struct tbt_nhi_ctxt *nhi_ctxt, u32 mb_cmd)
>         __releases(&controllers_list_rwsem)
>  {
> @@ -579,13 +608,93 @@ static int nhi_genl_mailbox(__always_unused struct sk_buff *u_skb,
>         down_read(&controllers_list_rwsem);
>
>         nhi_ctxt = nhi_search_ctxt(*(u32 *)info->userhdr);
> -       if (nhi_ctxt && !nhi_ctxt->d0_exit)
> -               return nhi_mailbox_generic(nhi_ctxt, mb_cmd);
> +       if (nhi_ctxt && !nhi_ctxt->d0_exit) {
> +
> +               /* rwsem is released later by the below functions */
> +               if (nhi_is_path_disconnected(cmd, nhi_ctxt->num_ports))
> +                       return nhi_mailbox_disconn_path(nhi_ctxt, cmd);
> +               else
> +                       return nhi_mailbox_generic(nhi_ctxt, mb_cmd);
> +
> +       }
>
>         up_read(&controllers_list_rwsem);
>         return -ENODEV;
>  }
>
> +static int nhi_genl_approve_networking(__always_unused struct sk_buff *u_skb,
> +                                      struct genl_info *info)
> +{
> +       struct tbt_nhi_ctxt *nhi_ctxt;
> +       struct route_string *route_str;
> +       int res = -ENODEV;
> +       u8 port_num;
> +
> +       if (!info || !info->userhdr || !info->attrs ||
> +           !info->attrs[NHI_ATTR_LOCAL_ROUTE_STRING] ||
> +           !info->attrs[NHI_ATTR_LOCAL_UNIQUE_ID] ||
> +           !info->attrs[NHI_ATTR_REMOTE_UNIQUE_ID] ||
> +           !info->attrs[NHI_ATTR_LOCAL_DEPTH])
> +               return -EINVAL;
> +
> +       /*
> +        * route_str is an unique topological address
> +        * used for approving remote controller
> +        */
> +       route_str = nla_data(info->attrs[NHI_ATTR_LOCAL_ROUTE_STRING]);
> +       /* extracts the port we're connected to */
> +       port_num = PORT_NUM_FROM_LINK(L0_PORT_NUM(route_str->lo));
> +
> +       down_read(&controllers_list_rwsem);
> +
> +       nhi_ctxt = nhi_search_ctxt(*(u32 *)info->userhdr);
> +       if (nhi_ctxt && !nhi_ctxt->d0_exit) {
> +               struct port_net_dev *port;
> +
> +               if (port_num >= nhi_ctxt->num_ports) {
> +                       res = -EINVAL;
> +                       goto free_ctl_list;
> +               }
> +
> +               port = &(nhi_ctxt->net_devices[port_num]);
> +
> +               mutex_lock(&port->state_mutex);
> +               up_read(&controllers_list_rwsem);
> +
> +               if (port->medium_sts != MEDIUM_READY_FOR_APPROVAL) {
> +                       dev_info(&nhi_ctxt->pdev->dev,
> +                               "%s: controller id %#x in state %u <> MEDIUM_READY_FOR_APPROVAL\n",
> +                               __func__, nhi_ctxt->id, port->medium_sts);
> +                       goto unlock;
> +               }
> +
> +               port->medium_sts = MEDIUM_READY_FOR_CONNECTION;
> +
> +               if (!port->net_dev) {
> +                       port->net_dev = nhi_alloc_etherdev(nhi_ctxt, port_num,
> +                                                          info);
> +                       if (!port->net_dev) {
> +                               mutex_unlock(&port->state_mutex);
> +                               return -ENOMEM;
> +                       }
> +               } else {
> +                       nhi_update_etherdev(nhi_ctxt, port->net_dev, info);
> +
> +                       negotiation_events(port->net_dev,
> +                                          MEDIUM_READY_FOR_CONNECTION);
> +               }
> +
> +unlock:
> +               mutex_unlock(&port->state_mutex);
> +
> +               return 0;
> +       }
> +
> +free_ctl_list:
> +       up_read(&controllers_list_rwsem);
> +
> +       return res;
> +}
>
>  static int nhi_genl_send_msg(struct tbt_nhi_ctxt *nhi_ctxt, enum pdf_value pdf,
>                              const u8 *msg, u32 msg_len)
> @@ -635,17 +744,169 @@ genl_put_reply_failure:
>         return res;
>  }
>
> +static bool nhi_handle_inter_domain_msg(struct tbt_nhi_ctxt *nhi_ctxt,
> +                                       struct thunderbolt_ip_header *hdr)
> +{
> +       struct port_net_dev *port;
> +       u8 port_num;
> +
> +       const unique_id_be proto_uuid = APPLE_THUNDERBOLT_IP_PROTOCOL_UUID;
> +
> +       if (memcmp(proto_uuid, hdr->apple_tbt_ip_proto_uuid,
> +                  sizeof(proto_uuid)) != 0) {
> +               dev_dbg(&nhi_ctxt->pdev->dev,
> +                       "controller id %#x XDomain discovery message\n",
> +                       nhi_ctxt->id);
> +               return true;
> +       }
> +
> +       dev_dbg(&nhi_ctxt->pdev->dev,
> +               "controller id %#x ThunderboltIP %u\n",
> +               nhi_ctxt->id, be32_to_cpu(hdr->packet_type));
> +
> +       port_num = PORT_NUM_FROM_LINK(
> +                               L0_PORT_NUM(be32_to_cpu(hdr->route_str.lo)));
> +
> +       if (unlikely(port_num >= nhi_ctxt->num_ports)) {
> +               dev_err(&nhi_ctxt->pdev->dev,
> +                       "controller id %#x invalid port %u in ThunderboltIP message\n",
> +                       nhi_ctxt->id, port_num);
> +               return false;
> +       }
> +
> +       port = &(nhi_ctxt->net_devices[port_num]);
> +       mutex_lock(&port->state_mutex);
> +       if (likely(port->net_dev != NULL))
> +               negotiation_messages(port->net_dev, hdr);
> +       else
> +               dev_notice(&nhi_ctxt->pdev->dev,
> +                          "controller id %#x port %u in ThunderboltIP message was not initialized\n",
> +                          nhi_ctxt->id, port_num);
> +       mutex_unlock(&port->state_mutex);
> +
> +       return false;
> +}
> +
> +static void nhi_handle_notification_msg(struct tbt_nhi_ctxt *nhi_ctxt,
> +                                       const u8 *msg)
> +{
> +       struct port_net_dev *port;
> +       u8 port_num;
> +
> +#define INTER_DOMAIN_LINK_SHIFT 0
> +#define INTER_DOMAIN_LINK_MASK GENMASK(2, INTER_DOMAIN_LINK_SHIFT)
> +       switch (msg[3]) {
> +
> +       case NC_INTER_DOMAIN_CONNECTED:
> +               port_num = PORT_NUM_FROM_MSG(msg[5]);
> +#define INTER_DOMAIN_APPROVED BIT(3)
> +               if (likely(port_num < nhi_ctxt->num_ports)) {
> +                       if (!(msg[5] & INTER_DOMAIN_APPROVED))
> +                               nhi_ctxt->net_devices[
> +                                       port_num].medium_sts =
> +                                    MEDIUM_READY_FOR_APPROVAL;
> +               } else {
> +                       dev_err(&nhi_ctxt->pdev->dev,
> +                               "controller id %#x invalid port %u in inter domain connected message\n",
> +                               nhi_ctxt->id, port_num);
> +               }
> +               break;
> +
> +       case NC_INTER_DOMAIN_DISCONNECTED:
> +               port_num = PORT_NUM_FROM_MSG(msg[5]);
> +
> +               if (unlikely(port_num >= nhi_ctxt->num_ports)) {
> +                       dev_err(&nhi_ctxt->pdev->dev,
> +                               "controller id %#x invalid port %u in inter domain disconnected message\n",
> +                               nhi_ctxt->id, port_num);
> +                       break;
> +               }
> +
> +               port = &(nhi_ctxt->net_devices[port_num]);
> +               mutex_lock(&port->state_mutex);
> +               port->medium_sts = MEDIUM_DISCONNECTED;
> +
> +               if (likely(port->net_dev != NULL))
> +                       negotiation_events(port->net_dev,
> +                                          MEDIUM_DISCONNECTED);
> +               else
> +                       dev_notice(&nhi_ctxt->pdev->dev,
> +                                  "controller id %#x port %u in inter domain disconnected message was not initialized\n",
> +                                  nhi_ctxt->id, port_num);
> +               mutex_unlock(&port->state_mutex);
> +               break;
> +       }
> +}
> +
> +static bool nhi_handle_icm_response_msg(struct tbt_nhi_ctxt *nhi_ctxt,
> +                                       const u8 *msg)
> +{
> +       struct port_net_dev *port;
> +       bool send_event = true;
> +       u8 port_num;
> +
> +       if (nhi_ctxt->ignore_icm_resp &&
> +           msg[3] == RC_INTER_DOMAIN_PKT_SENT) {
> +               nhi_ctxt->ignore_icm_resp = false;
> +               send_event = false;
> +       }
> +       if (nhi_ctxt->wait_for_icm_resp) {
> +               nhi_ctxt->wait_for_icm_resp = false;
> +               up(&nhi_ctxt->send_sem);
> +       }
> +
> +       if (msg[3] == RC_APPROVE_INTER_DOMAIN_CONNEXION) {
> +#define APPROVE_INTER_DOMAIN_ERROR BIT(0)
> +               if (unlikely(msg[2] & APPROVE_INTER_DOMAIN_ERROR)) {
> +                       dev_err(&nhi_ctxt->pdev->dev,
> +                               "controller id %#x inter domain approve error\n",
> +                               nhi_ctxt->id);
> +                       return send_event;
> +               }
> +               port_num = PORT_NUM_FROM_LINK((msg[5]&INTER_DOMAIN_LINK_MASK)>>
> +                                              INTER_DOMAIN_LINK_SHIFT);
> +
> +               if (unlikely(port_num >= nhi_ctxt->num_ports)) {
> +                       dev_err(&nhi_ctxt->pdev->dev,
> +                               "controller id %#x invalid port %u in inter domain approve message\n",
> +                               nhi_ctxt->id, port_num);
> +                       return send_event;
> +               }
> +
> +               port = &(nhi_ctxt->net_devices[port_num]);
> +               mutex_lock(&port->state_mutex);
> +               port->medium_sts = MEDIUM_CONNECTED;
> +
> +               if (likely(port->net_dev != NULL))
> +                       negotiation_events(port->net_dev, MEDIUM_CONNECTED);
> +               else
> +                       dev_err(&nhi_ctxt->pdev->dev,
> +                               "controller id %#x port %u in inter domain approve message was not initialized\n",
> +                               nhi_ctxt->id, port_num);
> +               mutex_unlock(&port->state_mutex);
> +       }
> +
> +       return send_event;
> +}
> +
>  static bool nhi_msg_from_icm_analysis(struct tbt_nhi_ctxt *nhi_ctxt,
>                                         enum pdf_value pdf,
>                                         const u8 *msg, u32 msg_len)
>  {
> -       /*
> -        * preparation for messages that won't be sent,
> -        * currently unused in this patch.
> -        */
>         bool send_event = true;
>
>         switch (pdf) {
> +       case PDF_INTER_DOMAIN_REQUEST:
> +       case PDF_INTER_DOMAIN_RESPONSE:
> +               send_event = nhi_handle_inter_domain_msg(
> +                                       nhi_ctxt,
> +                                       (struct thunderbolt_ip_header *)msg);
> +               break;
> +
> +       case PDF_FW_TO_SW_NOTIFICATION:
> +               nhi_handle_notification_msg(nhi_ctxt, msg);
> +               break;
> +
>         case PDF_ERROR_NOTIFICATION:
>                 dev_err(&nhi_ctxt->pdev->dev,
>                         "controller id %#x PDF_ERROR_NOTIFICATION %hhu msg len %u\n",
> @@ -661,10 +922,7 @@ static bool nhi_msg_from_icm_analysis(struct tbt_nhi_ctxt *nhi_ctxt,
>                 break;
>
>         case PDF_FW_TO_SW_RESPONSE:
> -               if (nhi_ctxt->wait_for_icm_resp) {
> -                       nhi_ctxt->wait_for_icm_resp = false;
> -                       up(&nhi_ctxt->send_sem);
> -               }
> +               send_event = nhi_handle_icm_response_msg(nhi_ctxt, msg);
>                 break;
>
>         default:
> @@ -869,6 +1127,12 @@ static const struct genl_ops nhi_ops[] = {
>                 .doit = nhi_genl_mailbox,
>                 .flags = GENL_ADMIN_PERM,
>         },
> +       {
> +               .cmd = NHI_CMD_APPROVE_TBT_NETWORKING,
> +               .policy = nhi_genl_policy,
> +               .doit = nhi_genl_approve_networking,
> +               .flags = GENL_ADMIN_PERM,
> +       },
>  };
>
>  static int nhi_suspend(struct device *dev) __releases(&nhi_ctxt->send_sem)
> @@ -876,6 +1140,17 @@ static int nhi_suspend(struct device *dev) __releases(&nhi_ctxt->send_sem)
>         struct tbt_nhi_ctxt *nhi_ctxt = pci_get_drvdata(to_pci_dev(dev));
>         void __iomem *rx_reg, *tx_reg;
>         u32 rx_reg_val, tx_reg_val;
> +       int i;
> +
> +       for (i = 0; i < nhi_ctxt->num_ports; i++) {
> +               struct port_net_dev *port = &nhi_ctxt->net_devices[i];
> +
> +               mutex_lock(&port->state_mutex);
> +               port->medium_sts = MEDIUM_DISCONNECTED;
> +               if (port->net_dev)
> +                       negotiation_events(port->net_dev, MEDIUM_DISCONNECTED);
> +               mutex_unlock(&port->state_mutex);
> +       }
>
>         /* must be after negotiation_events, since messages might be sent */
>         nhi_ctxt->d0_exit = true;
> @@ -1035,6 +1310,15 @@ static void icm_nhi_remove(struct pci_dev *pdev)
>
>         nhi_suspend(&pdev->dev);
>
> +       for (i = 0; i < nhi_ctxt->num_ports; i++) {
> +               mutex_lock(&nhi_ctxt->net_devices[i].state_mutex);
> +               if (nhi_ctxt->net_devices[i].net_dev) {
> +                       nhi_dealloc_etherdev(nhi_ctxt->net_devices[i].net_dev);
> +                       nhi_ctxt->net_devices[i].net_dev = NULL;
> +               }
> +               mutex_unlock(&nhi_ctxt->net_devices[i].state_mutex);
> +       }
> +
>         if (nhi_ctxt->net_workqueue)
>                 destroy_workqueue(nhi_ctxt->net_workqueue);
>
> diff --git a/drivers/thunderbolt/icm/net.c b/drivers/thunderbolt/icm/net.c
> new file mode 100644
> index 0000000..e983dfb
> --- /dev/null
> +++ b/drivers/thunderbolt/icm/net.c
> @@ -0,0 +1,802 @@
> +/*******************************************************************************
> + *
> + * Intel Thunderbolt(TM) driver
> + * Copyright(c) 2014 - 2016 Intel Corporation.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program.  If not, see <http://www.gnu.org/licenses/>.
> + *
> + * The full GNU General Public License is included in this distribution in
> + * the file called "COPYING".
> + *
> + * Contact Information:
> + * Intel Thunderbolt Mailing List <thunderbolt-software@lists.01.org>
> + * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
> + *
> + ******************************************************************************/
> +
> +#include <linux/module.h>

I did not see anything like module_init in this driver;  I think it
seems like you
want linux/moduleparam.h here.

Thanks,
Paul.
