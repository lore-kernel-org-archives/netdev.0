From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH v2 net-next 8/9] openvswitch: Add force commit.
Date: Wed, 8 Feb 2017 15:53:45 -0800
Message-ID: <CAPWQB7HV5FM+1xv_vfvfrSQf3nYXEN6pd0vvjnLYs_cKNxk9cQ@mail.gmail.com>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org> <1486582330-31152-9-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:36817 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752337AbdBHXyN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 18:54:13 -0500
Received: from mfilter15-d.gandi.net (mfilter15-d.gandi.net [217.70.178.143])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 907FD41C04C
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 00:54:08 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter15-d.gandi.net (mfilter15-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id D0yU5HpeD34k for <netdev@vger.kernel.org>;
        Thu,  9 Feb 2017 00:54:07 +0100 (CET)
Received: from mail-qt0-f175.google.com (mail-qt0-f175.google.com [209.85.216.175])
        (Authenticated sender: joe@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 1F15A41C080
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 00:54:07 +0100 (CET)
Received: by mail-qt0-f175.google.com with SMTP id v23so181858218qtb.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 15:54:06 -0800 (PST)
In-Reply-To: <1486582330-31152-9-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8 February 2017 at 11:32, Jarno Rajahalme <jarno@ovn.org> wrote:
> Stateful network admission policy may allow connections to one
> direction and reject connections initiated in the other direction.
> After policy change it is possible that for a new connection an
> overlapping conntrack entry already exists, where the original
> direction of the existing connection is opposed to the new
> connection's initial packet.
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

<snip>

>                 if (help && rcu_access_pointer(help->helper) != info->helper)
>                         return false;
>         }
> +       /* Force conntrack entry direction to the current packet? */
> +       if (info->force && CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL) {
> +               /* Delete the conntrack entry if confirmed, else just release
> +                * the reference.
> +                */
> +               if (nf_ct_is_confirmed(ct))
> +                       nf_ct_delete(ct, 0, 0);
> +               else
> +                       nf_conntrack_put(&ct->ct_general);
> +               skb->nfct = NULL;
> +               skb->nfctinfo = 0;

This can use nf_ct_set().
