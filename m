From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v3] bridge: allow adding of fdb entries pointing
 to the bridge device
Date: Fri, 9 Oct 2015 21:52:35 -0700
Message-ID: <CAE4R7bAQEDj7P=raMNhAmOk3VCSb5Qi079rLEdkz2DTRXCLp0A@mail.gmail.com>
References: <1444325932-1577-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:36662 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbbJJEwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 00:52:55 -0400
Received: by obcgx8 with SMTP id gx8so76583809obc.3
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 21:52:54 -0700 (PDT)
In-Reply-To: <1444325932-1577-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 10:38 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch enables adding of fdb entries pointing to the bridge device.
> This can be used to propagate mac address of vlan interfaces
> configured on top of the vlan filtering bridge.
>
> Before:
> $bridge fdb add 44:38:39:00:27:9f dev bridge
> RTNETLINK answers: Invalid argument
>
> After:
> $bridge fdb add 44:38:39:00:27:9f dev bridge
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> v1 - v2 : fix kbuild warnings
> v2 - v3 : address review comments from Nikolay (use of br_vlan_should_use)
>
>  net/bridge/br_fdb.c  | 122 ++++++++++++++++++++++++++++++++++++++-------------
>  net/bridge/br_vlan.c |   1 +
>  2 files changed, 93 insertions(+), 30 deletions(-)
>
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 7f7d551..f43ce05 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -608,13 +608,14 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
>         }
>  }
>
> -static int fdb_to_nud(const struct net_bridge_fdb_entry *fdb)
> +static int fdb_to_nud(const struct net_bridge *br,
> +                     const struct net_bridge_fdb_entry *fdb)
>  {
>         if (fdb->is_local)
>                 return NUD_PERMANENT;
>         else if (fdb->is_static)
>                 return NUD_NOARP;
> -       else if (has_expired(fdb->dst->br, fdb))
> +       else if (has_expired(br, fdb))
>                 return NUD_STALE;
>         else
>                 return NUD_REACHABLE;
> @@ -640,7 +641,7 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
>         ndm->ndm_flags   = fdb->added_by_external_learn ? NTF_EXT_LEARNED : 0;
>         ndm->ndm_type    = 0;
>         ndm->ndm_ifindex = fdb->dst ? fdb->dst->dev->ifindex : br->dev->ifindex;
> -       ndm->ndm_state   = fdb_to_nud(fdb);
> +       ndm->ndm_state   = fdb_to_nud(br, fdb);
>
>         if (nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->addr))
>                 goto nla_put_failure;
> @@ -785,7 +786,7 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
>                 }
>         }
>
> -       if (fdb_to_nud(fdb) != state) {
> +       if (fdb_to_nud(br, fdb) != state) {


Hi Roopa,

Are the above changes to fdb_to_nud() related to the patch subject?
I was trying to figure out this part of the patch...seems unrelated.
Is fdb->dst->br now not valid in some cases?
