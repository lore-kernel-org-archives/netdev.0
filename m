From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] bridge: modify bridge af spec parser to
 accomodate vlan list and ranges
Date: Thu, 1 Jan 2015 11:20:19 -0800
Message-ID: <CAE4R7bDFsP2FicT0A_q7YUAXCtDjfqeSNatGdnPr9KpiH0avaw@mail.gmail.com>
References: <1420044533-16963-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, hemminger@vyatta.com,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:59105 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbbAATUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 14:20:21 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so23125928wgh.6
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2015 11:20:20 -0800 (PST)
In-Reply-To: <1420044533-16963-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 8:48 AM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch modifies br_afspec to parse incoming IFLA_BRIDGE_VLAN_INFO_LIST
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  net/bridge/br_netlink.c |  115 ++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 85 insertions(+), 30 deletions(-)
>
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 492ef6a..bcba9d2 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -226,53 +226,108 @@ static const struct nla_policy ifla_br_policy[IFLA_MAX+1] = {
>         [IFLA_BRIDGE_VLAN_INFO_LIST] = { .type = NLA_NESTED, },
>  };
>
> +static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
> +                       int cmd, struct bridge_vlan_info *vinfo)
> +{
> +       int err = 0;
> +
> +       switch (cmd) {
> +       case RTM_SETLINK:
> +               if (p) {
> +                       err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
> +                       if (err)
> +                               break;
> +
> +                       if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
> +                               err = br_vlan_add(p->br, vinfo->vid,
> +                                                 vinfo->flags);
> +               } else {
> +                       err = br_vlan_add(br, vinfo->vid, vinfo->flags);
> +               }
> +               break;
> +
> +       case RTM_DELLINK:
> +               if (p) {
> +                       nbp_vlan_delete(p, vinfo->vid);
> +                       if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
> +                               br_vlan_delete(p->br, vinfo->vid);
> +               } else {
> +                       br_vlan_delete(br, vinfo->vid);
> +               }
> +               break;
> +       }
> +
> +       return err;
> +}
> +
>  static int br_afspec(struct net_bridge *br,
>                      struct net_bridge_port *p,
>                      struct nlattr *af_spec,
>                      int cmd)
>  {
>         struct nlattr *tb[IFLA_BRIDGE_MAX+1];
> +       struct nlattr *attr;
>         int err = 0;
> +       int rem;
>
>         err = nla_parse_nested(tb, IFLA_BRIDGE_MAX, af_spec, ifla_br_policy);
>         if (err)
>                 return err;
>
>         if (tb[IFLA_BRIDGE_VLAN_INFO]) {
> -               struct bridge_vlan_info *vinfo;
> -
> -               vinfo = nla_data(tb[IFLA_BRIDGE_VLAN_INFO]);
> -
> -               if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK)
> -                       return -EINVAL;
> -
> -               switch (cmd) {
> -               case RTM_SETLINK:
> -                       if (p) {
> -                               err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
> -                               if (err)
> -                                       break;
> -
> -                               if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
> -                                       err = br_vlan_add(p->br, vinfo->vid,
> -                                                         vinfo->flags);
> -                       } else
> -                               err = br_vlan_add(br, vinfo->vid, vinfo->flags);
> -
> -                       break;
> -
> -               case RTM_DELLINK:
> -                       if (p) {
> -                               nbp_vlan_delete(p, vinfo->vid);
> -                               if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
> -                                       br_vlan_delete(p->br, vinfo->vid);
> -                       } else
> -                               br_vlan_delete(br, vinfo->vid);
> -                       break;
> +               attr = tb[IFLA_BRIDGE_VLAN_INFO];
> +               if (nla_len(attr) != sizeof(struct bridge_vlan_info))
> +                       goto err_inval;

Size check isn't necessary here as it was already done with nla_parse_nested().

> +
> +               err = br_vlan_info(br, p, cmd,
> +                                  (struct bridge_vlan_info *)nla_data(attr));
> +
> +       } else if (tb[IFLA_BRIDGE_VLAN_INFO_LIST]) {

Could you have both IFLA_BRIDGE_VLAN_INFO and
IFLA_BRIDGE_VLAN_INFO_LIST?  If so, drop the else.

> +               struct bridge_vlan_info *vinfo_start = NULL;
> +               struct bridge_vlan_info *vinfo = NULL;

Initializer not needed on this ^^^ one.

> +
> +               nla_for_each_nested(attr, tb[IFLA_BRIDGE_VLAN_INFO_LIST], rem) {
> +                       if (nla_len(attr) != sizeof(struct bridge_vlan_info) ||
> +                           nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
> +                               goto err_inval;

goto isn't necessary...just return -EINVAL...more like this below

> +                       vinfo = nla_data(attr);
> +                       if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_START) {
> +                               if (vinfo_start)
> +                                       goto err_inval;
> +                               vinfo_start = vinfo;
> +                               continue;
> +                       }
> +
> +                       if (vinfo_start) {
> +                               int v;
> +
> +                               if (!(vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END))
> +                                       goto err_inval;
> +
> +                               if (vinfo->vid < vinfo_start->vid)
> +                                       goto err_inval;
> +
> +                               for (v = vinfo_start->vid; v <= vinfo->vid;
> +                                       v++) {

Did the above exceed 80 chars?  If not, one liner.

> +                                       vinfo_start->vid = v;
> +                                       err = br_vlan_info(br, p, cmd,
> +                                                          vinfo_start);
> +                                       if (err)
> +                                               break;
> +                               }
> +                               vinfo_start = NULL;
> +                       } else {
> +                               err = br_vlan_info(br, p, cmd, vinfo);
> +                       }
> +                       if (err)
> +                               break;
>                 }
>         }
>
>         return err;
> +
> +err_inval:
> +       return -EINVAL;
>  }
>
>  static const struct nla_policy br_port_policy[IFLA_BRPORT_MAX + 1] = {
> --
> 1.7.10.4
>
