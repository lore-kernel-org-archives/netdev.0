From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH] datapath: Fix for force/commit action failures
Date: Thu, 13 Jul 2017 10:46:42 -0700
Message-ID: <CAPWQB7EvfsMCddisznPgfNQPtHMboKz2hoTiH6uknmTwx+B5Dw@mail.gmail.com>
References: <1499963124-7841-1-git-send-email-gvrose8192@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>, ovs dev <dev@openvswitch.org>,
        Pravin Shalar <pshelar@nicira.com>
To: Greg Rose <gvrose8192@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:55677 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752899AbdGMRrI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 13:47:08 -0400
Received: from mfilter14-d.gandi.net (mfilter14-d.gandi.net [217.70.178.142])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 0CC2F1720B2
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 19:47:07 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter14-d.gandi.net (mfilter14-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id MBpmvBXKQbtV for <netdev@vger.kernel.org>;
        Thu, 13 Jul 2017 19:47:05 +0200 (CEST)
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
        (Authenticated sender: joe@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id EB5F8172094
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 19:47:04 +0200 (CEST)
Received: by mail-oi0-f42.google.com with SMTP id 191so52355548oii.2
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 10:47:04 -0700 (PDT)
In-Reply-To: <1499963124-7841-1-git-send-email-gvrose8192@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 July 2017 at 09:25, Greg Rose <gvrose8192@gmail.com> wrote:
> When there is an established connection in direction A->B, it is
> possible to receive a packet on port B which then executes
> ct(commit,force) without first performing ct() - ie, a lookup.
> In this case, we would expect that this packet can delete the existing
> entry so that we can commit a connection with direction B->A. However,
> currently we only perform a check in skb_nfct_cached() for whether
> OVS_CS_F_TRACKED is set and OVS_CS_F_INVALID is not set, ie that a
> lookup previously occurred. In the above scenario, a lookup has not
> occurred but we should still be able to statelessly look up the
> existing entry and potentially delete the entry if it is in the
> opposite direction.
>
> This patch extends the check to also hint that if the action has the
> force flag set, then we will lookup the existing entry so that the
> force check at the end of skb_nfct_cached has the ability to delete
> the connection.
>
> CC: dev@openvswitch.org
> CC: Pravin Shalar <pshelar@nicira.com>
> Signed-off-by: Joe Stringer <joe@ovn.org>
> Signed-off-by: Greg Rose <gvrose8192@gmail.com>
> ---

A couple more administrative notes, on netdev the module name in the
patch subject for openvswitch is "openvswitch" rather than datapath;
and patches rather than having just "PATCH" as the subject prefix
should state the tree. In this case, it's a bugfix so it should be
"PATCH net". Furthermore, if you're able to figure out which commit
introduced the issue (I believe it's introduced by the force commit
patch), then you should place the "Fixes: " tag. I can give you some
pointers off-list on how to do this (git blame and some basic
formatting of the targeted patch should do the trick - this tag
expects a 12-digit hash).

For reference, I ended up looking it up during review, this is the
line you'd add:
Fixes: dd41d33f0b03 ("openvswitch: Add force commit.")

>  net/openvswitch/conntrack.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index 08679eb..9041cf8 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -641,17 +641,21 @@ static bool skb_nfct_cached(struct net *net,
>         ct = nf_ct_get(skb, &ctinfo);
>         /* If no ct, check if we have evidence that an existing conntrack entry
>          * might be found for this skb.  This happens when we lose a skb->_nfct
> -        * due to an upcall.  If the connection was not confirmed, it is not
> -        * cached and needs to be run through conntrack again.
> +        * due to an upcall, or if the direction is being forced.  If the
> +        * connection was not confirmed, it is not cached and needs to be run
> +        * through conntrack again.
>          */
> -       if (!ct && key->ct_state & OVS_CS_F_TRACKED &&
> +       if ((!ct && (key->ct_state & OVS_CS_F_TRACKED) &&
>             !(key->ct_state & OVS_CS_F_INVALID) &&
> -           key->ct_zone == info->zone.id) {
> +            key->ct_zone == info->zone.id) ||
> +            (!key->ct_state && info->force)) {
>                 ct = ovs_ct_find_existing(net, &info->zone, info->family, skb,
>                                           !!(key->ct_state
>                                              & OVS_CS_F_NAT_MASK));
>                 if (ct)
>                         nf_ct_get(skb, &ctinfo);
> +               else
> +                       return false;
>         }
>         if (!ct)
>                 return false;

I was just wondering if this has the potential to prevent
nf_conntrack_in() from being called at all in this case, which is also
not quite right. In the original case of (!ct && (key->ct_state &
OVS_CS_F_TRACKED) && !(key->ct_state & OVS_CS_F_TRACKED)), which I'll
refer to as "ct_executed", we explicitly want to avoid running
nf_conntrack_in() if we already ran it, because the connection tracker
doesn't expect to see the same packet twice (there's also things like
stats/accounting, and potentially L4 state machines that could get
messed up by multiple calls). By the time the info->force and
direction check happens at the end of the function, "ct_executed" is
implied to be true. However, in this new case, ct_executed is actually
false - because there was no ct() before the ct(force,commit). In this
case, we only want to look up the existing entry to see if it should
be deleted; if it should not be deleted, then we still haven't yet
done the nf_conntrack_in() call so we should return false and the
caller, __ovs_ct_lookup() should make the call to nf_conntrack_in().

What I mean is something like the following incremental on your patch:

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 9041cf8b822f..98783f114824 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -637,6 +637,7 @@ static bool skb_nfct_cached(struct net *net,
{
       enum ip_conntrack_info ctinfo;
       struct nf_conn *ct;
+       bool ct_executed;

       ct = nf_ct_get(skb, &ctinfo);
       /* If no ct, check if we have evidence that an existing conntrack entry
@@ -645,10 +646,10 @@ static bool skb_nfct_cached(struct net *net,
        * connection was not confirmed, it is not cached and needs to be run
        * through conntrack again.
        */
-       if ((!ct && (key->ct_state & OVS_CS_F_TRACKED) &&
-           !(key->ct_state & OVS_CS_F_INVALID) &&
-            key->ct_zone == info->zone.id) ||
-            (!key->ct_state && info->force)) {
+       ct_executed = key->ct_state & OVS_CS_F_TRACKED &&
+                     !(key->ct_state & OVS_CS_F_INVALID) &&
+                     key->ct_zone == info->zone.id;
+       if (!ct && (ct_executed || (!key->ct_state && info->force))) {
               ct = ovs_ct_find_existing(net, &info->zone, info->family, skb,
                                         !!(key->ct_state
                                            & OVS_CS_F_NAT_MASK));
@@ -683,7 +684,7 @@ static bool skb_nfct_cached(struct net *net,
               return false;
       }

-       return true;
+       return ct_executed;
}

#ifdef CONFIG_NF_NAT_NEEDED
