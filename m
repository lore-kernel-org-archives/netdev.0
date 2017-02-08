From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next 6/7] openvswitch: Add force commit.
Date: Tue, 7 Feb 2017 17:32:20 -0800
Message-ID: <CAPWQB7EcxsKpQ5Q_1sw29P7q2XmMZC59c077yHZgy-tB_3Ttdg@mail.gmail.com>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org>
 <1486084206-109903-6-git-send-email-jarno@ovn.org> <CAPWQB7HX3K9z-aYEv2kkJ2At6iPrEHk24iWce0Gz0TwhDHscYQ@mail.gmail.com>
 <5B795D0B-4C7F-4297-BA2A-6BE3444033D0@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:36005 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932754AbdBHB6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 20:58:18 -0500
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net [217.70.183.197])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 3A2B547AAB6
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 02:33:46 +0100 (CET)
Received: from mfilter18-d.gandi.net (mfilter18-d.gandi.net [217.70.178.146])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id D8E3141C04C
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 02:32:43 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter18-d.gandi.net (mfilter18-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 3S11xFTHcHgW for <netdev@vger.kernel.org>;
        Wed,  8 Feb 2017 02:32:42 +0100 (CET)
Received: from mail-qt0-f169.google.com (mail-qt0-f169.google.com [209.85.216.169])
        (Authenticated sender: joe@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 1A55841C084
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 02:32:41 +0100 (CET)
Received: by mail-qt0-f169.google.com with SMTP id k15so152579468qtg.3
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 17:32:41 -0800 (PST)
In-Reply-To: <5B795D0B-4C7F-4297-BA2A-6BE3444033D0@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 February 2017 at 17:03, Jarno Rajahalme <jarno@ovn.org> wrote:
>
> On Feb 7, 2017, at 2:15 PM, Joe Stringer <joe@ovn.org> wrote:
>
> On 2 February 2017 at 17:10, Jarno Rajahalme <jarno@ovn.org> wrote:
>
> Stateful network admission policy may allow connections to one
> direction and reject connections initiated in the other direction.
> After policy change it is possible that for a new connection an
> overlapping conntrack entry already exist, where the connection
> original direction is opposed to the new connection's initial packet.
>
> Most importantly, conntrack state relating to the current packet gets
> the "reply" designation based on whether the original direction tuple
> or the reply direction tuple matched.  If this "directionality" is
> wrong w.r.t. to the stateful network admission policy it may happen
> that packets in neither direction are correctly admitted.
>
> This patch adds a new "force commit" option to the OVS conntrack
> action that checks the original direction of an existing conntrack
> entry.  If that direction is opposed to the current packet, the
> existing conntrack entry is deleted and a new one is subsequently
> created in the correct direction.
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
> include/uapi/linux/openvswitch.h | 10 ++++++++++
> net/openvswitch/conntrack.c      | 27 +++++++++++++++++++++++++--
> 2 files changed, 35 insertions(+), 2 deletions(-)
>
> diff --git a/include/uapi/linux/openvswitch.h
> b/include/uapi/linux/openvswitch.h
> index 90af8b8..d5ba9a9 100644
> --- a/include/uapi/linux/openvswitch.h
> +++ b/include/uapi/linux/openvswitch.h
> @@ -674,6 +674,10 @@ struct ovs_action_hash {
>  * @OVS_CT_ATTR_HELPER: variable length string defining conntrack ALG.
>  * @OVS_CT_ATTR_NAT: Nested OVS_NAT_ATTR_* for performing L3 network address
>  * translation (NAT) on the packet.
> + * @OVS_CT_ATTR_FORCE_COMMIT: Like %OVS_CT_ATTR_COMMIT, but instead of
> doing
> + * nothing if the connection is already committed will check that the
> current
> + * packet is in conntrack entry's original direction.  If directionality
> does
> + * not match, will delete the existing conntrack entry and commit a new
> one.
>  */
> enum ovs_ct_attr {
>        OVS_CT_ATTR_UNSPEC,
> @@ -684,6 +688,12 @@ enum ovs_ct_attr {
>        OVS_CT_ATTR_HELPER,     /* netlink helper to assist detection of
>                                   related connections. */
>        OVS_CT_ATTR_NAT,        /* Nested OVS_NAT_ATTR_* */
> +       OVS_CT_ATTR_FORCE_COMMIT,  /* No argument, commits connection.  If
> the
> +                                   * conntrack entry original direction
> tuple
> +                                   * does not match the current packet
> header
> +                                   * values, will delete the current
> conntrack
> +                                   * entry and create a new one.
> +                                   */
>
>
> We only need one copy of the explanation, keep it above the enum, then
> the inline comment can be /* No argument */.
>
>
> OK.
>
>        __OVS_CT_ATTR_MAX
> };
>
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index 1afe153..1f27f44 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -65,6 +65,7 @@ struct ovs_conntrack_info {
>        struct nf_conn *ct;
>        u8 commit : 1;
>        u8 nat : 3;                 /* enum ovs_ct_nat */
> +       u8 force : 1;
>        u16 family;
>        struct md_mark mark;
>        struct md_labels labels;
> @@ -631,10 +632,13 @@ static bool skb_nfct_cached(struct net *net,
>         */
>        if (!ct && key->ct.state & OVS_CS_F_TRACKED &&
>            !(key->ct.state & OVS_CS_F_INVALID) &&
> -           key->ct.zone == info->zone.id)
> +           key->ct.zone == info->zone.id) {
>                ct = ovs_ct_find_existing(net, &info->zone, info->family,
> skb,
>                                          !!(key->ct.state
>                                             & OVS_CS_F_NAT_MASK));
> +               if (ct)
> +                       nf_ct_get(skb, &ctinfo);
> +       }
>
>
> If ctinfo is only used with the new call below, we can unconditionally
> fetch this just before it's used...
>
>        if (!ct)
>                return false;
>        if (!net_eq(net, read_pnet(&ct->ct_net)))
> @@ -648,6 +652,19 @@ static bool skb_nfct_cached(struct net *net,
>                if (help && rcu_access_pointer(help->helper) != info->helper)
>                        return false;
>        }
> +       /* Force conntrack entry direction to the current packet? */
>
>
> Here.
>
>
> But then we would be executing nf_ct_get() twice in the common case?

Ah, fair enough. It's fine here.
