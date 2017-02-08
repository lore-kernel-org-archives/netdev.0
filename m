From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH v2 net-next 6/9] openvswitch: Inherit master's labels.
Date: Wed, 8 Feb 2017 15:25:41 -0800
Message-ID: <CAPWQB7FVmJD07gsKG7WHHzFj5OoBo79OquOouF46AHA=dYs3zw@mail.gmail.com>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org> <1486582330-31152-7-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:46209 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751788AbdBIAhD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 19:37:03 -0500
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 068AE47A8AA
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 00:27:05 +0100 (CET)
Received: from mfilter5-d.gandi.net (mfilter5-d.gandi.net [217.70.178.132])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id A0E65C5A4E
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 00:26:04 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter5-d.gandi.net (mfilter5-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id Cc1vj7F1eLm6 for <netdev@vger.kernel.org>;
        Thu,  9 Feb 2017 00:26:03 +0100 (CET)
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
        (Authenticated sender: joe@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 38B99C5A53
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 00:26:03 +0100 (CET)
Received: by mail-qk0-f181.google.com with SMTP id s186so139820409qkb.1
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 15:26:03 -0800 (PST)
In-Reply-To: <1486582330-31152-7-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8 February 2017 at 11:32, Jarno Rajahalme <jarno@ovn.org> wrote:
> We avoid calling into nf_conntrack_in() for expected connections, as
> that would remove the expectation that we want to stick around until
> we are ready to commit the connection.  Instead, we do a lookup in the
> expectation table directly.  However, after a successful expectation
> lookup we have set the flow key label field from the master
> connection, whereas nf_conntrack_in() does not do this.  This leads to
> master's labels being inherited after an expectation lookup, but those
> labels not being inherited after the corresponding conntrack action
> with a commit flag.
>
> This patch resolves the problem by changing the commit code path to
> also inherit the master's labels to the expected connection.
> Resolving this conflict in favor or inheriting the labels allows more

*of inheriting

> information be passed from the master connection to related
> connections, which would otherwise be much harder if the 32 bits in
> the connmark are not enough.  Labels can still be set explicitly, so
> this change only affects the default values of the labels in presense
> of a master connection.
>
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

<snip>

> @@ -272,18 +274,32 @@ static int ovs_ct_init_labels(struct nf_conn *ct, struct sw_flow_key *key,
>                               const struct ovs_key_ct_labels *labels,
>                               const struct ovs_key_ct_labels *mask)
>  {
> -       struct nf_conn_labels *cl;
> -       u32 *dst;
> -       int i;
> +       struct nf_conn_labels *cl, *master_cl;
> +       bool have_mask = labels_nonzero(mask);
> +
> +       /* Inherit master's labels to the related connection? */
> +       master_cl = (ct->master) ? nf_ct_labels_find(ct->master) : NULL;

I don't think (ct->master) needs the parentheses.
