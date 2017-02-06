From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next 4/7] openvswitch: Inherit master's labels.
Date: Mon, 6 Feb 2017 13:53:12 -0800
Message-ID: <CAPWQB7HLGN7LpROpD1XW4+9TH27ZTM14earFB+Cx5fExRXeUAQ@mail.gmail.com>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org> <1486084206-109903-4-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:35335 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751533AbdBFVxh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 16:53:37 -0500
Received: from mfilter10-d.gandi.net (mfilter10-d.gandi.net [217.70.178.139])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 788E041C07E
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 22:53:35 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter10-d.gandi.net (mfilter10-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id aeSa3G-wRgfw for <netdev@vger.kernel.org>;
        Mon,  6 Feb 2017 22:53:34 +0100 (CET)
Received: from mail-qt0-f181.google.com (mail-qt0-f181.google.com [209.85.216.181])
        (Authenticated sender: joe@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id CFF5441C07D
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 22:53:33 +0100 (CET)
Received: by mail-qt0-f181.google.com with SMTP id k15so118326081qtg.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 13:53:33 -0800 (PST)
In-Reply-To: <1486084206-109903-4-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2 February 2017 at 17:10, Jarno Rajahalme <jarno@ovn.org> wrote:
> We avoid calling into nf_conntrack_in() for expected connections, as
> that would remove the expectation that we want to stick around until
> we are ready to commit the connection.  Instead, we do a lookup in the
> expectation table directly.  However, after a successful expectation
> lookup we have set the flow key label field from the master
> connection, whereas nf_conntrack_in() does not do this.  This leads to
> master's labels being iherited after an expectation lookup, but those
> labels not being inherited after the corresponding conntrack action
> with a commit flag.
>
> This patch resolves the problem by changing the commit code path to
> also inherit the master's labels to the expected connection.
> Resolving this conflict in favor or inheriting the labels allows
> information be passed from the master connection to related
> connections, which would otherwise be much harder.  Labels can still
> be set explicitly, so this change only affects the default values of
> the labels in presense of a master connection.
>
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
>  net/openvswitch/conntrack.c | 48 ++++++++++++++++++++++++++++++++-------------
>  1 file changed, 34 insertions(+), 14 deletions(-)
>
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index a163c44..738a4fa 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -265,6 +265,8 @@ static struct nf_conn_labels *ovs_ct_get_conn_labels(struct nf_conn *ct)
>         return cl;
>  }
>
> +static bool labels_nonzero(const struct ovs_key_ct_labels *labels);
> +

These declarations typically live at the top of the file, not
somewhere in the middle.

>  /* Initialize labels for a new, to be committed conntrack entry.  Note that
>   * since the new connection is not yet confirmed, and thus no-one else has
>   * access to it's labels, we simply write them over.  Also, we refrain from
> @@ -275,18 +277,35 @@ static int ovs_ct_init_labels(struct nf_conn *ct, struct sw_flow_key *key,
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
> +
> +       if (!master_cl && !have_mask)
> +               return 0;   /* Nothing to do. */
>
>         cl = ovs_ct_get_conn_labels(ct);
>         if (!cl)
>                 return -ENOSPC;
>
> -       dst = (u32 *)cl->bits;
> -       for (i = 0; i < OVS_CT_LABELS_LEN_32; i++)
> -               dst[i] = (dst[i] & ~mask->ct_labels_32[i]) |
> -                       (labels->ct_labels_32[i] & mask->ct_labels_32[i]);
> +       /* Inherit the master's labels, if any. */
> +       if (master_cl) {
> +               size_t len = sizeof(master_cl->bits);
> +
> +               memcpy(&cl->bits, &master_cl->bits,
> +                      len > OVS_CT_LABELS_LEN ? OVS_CT_LABELS_LEN : len);

Looks like this is another spot where we're trying to handle differing
label lengths, which we could simplify if there was a stronger
guarantee they're the same.

> +       }
> +       if (have_mask) {
> +               u32 *dst = (u32 *)cl->bits;
> +               int i;
> +
> +               for (i = 0; i < OVS_CT_LABELS_LEN_32; i++)
> +                       dst[i] = (dst[i] & ~mask->ct_labels_32[i]) |
> +                               (labels->ct_labels_32[i]
> +                                & mask->ct_labels_32[i]);
> +       }

By the way, is this open-coding nf_connlabels_replace()? Can
ovs_ct_set_labels() and this share the code?

>
>         memcpy(&key->ct.labels, cl->bits, OVS_CT_LABELS_LEN);
>
> @@ -916,13 +935,14 @@ static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
>                 if (err)
>                         return err;
>         }
> -       if (labels_nonzero(&info->labels.mask)) {
> -               if (!nf_ct_is_confirmed(ct))
> -                       err = ovs_ct_init_labels(ct, key, &info->labels.value,
> -                                                &info->labels.mask);
> -               else
> -                       err = ovs_ct_set_labels(ct, key, &info->labels.value,
> -                                               &info->labels.mask);
> +       if (!nf_ct_is_confirmed(ct)) {
> +               err = ovs_ct_init_labels(ct, key, &info->labels.value,
> +                                        &info->labels.mask);
> +               if (err)
> +                       return err;
> +       } else if (labels_nonzero(&info->labels.mask)) {
> +               err = ovs_ct_set_labels(ct, key, &info->labels.value,
> +                                       &info->labels.mask);
>                 if (err)
>                         return err;
>         }
> --
> 2.1.4
>
