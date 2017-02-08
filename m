From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH v2 net-next 3/9] openvswitch: Simplify labels length logic.
Date: Wed, 8 Feb 2017 14:47:02 -0800
Message-ID: <CAPWQB7G_HVJXXPf-RAK+kneKwvoRu=0ySFs98PUTqLop4eVFNw@mail.gmail.com>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org> <1486582330-31152-4-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:59379 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751449AbdBHWr1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 17:47:27 -0500
Received: from mfilter22-d.gandi.net (mfilter22-d.gandi.net [217.70.178.150])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 620BAC5A46
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 23:47:25 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter22-d.gandi.net (mfilter22-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id qKcsUVazF-yg for <netdev@vger.kernel.org>;
        Wed,  8 Feb 2017 23:47:24 +0100 (CET)
Received: from mail-qt0-f182.google.com (mail-qt0-f182.google.com [209.85.216.182])
        (Authenticated sender: joe@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id D1D67C5A50
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 23:47:23 +0100 (CET)
Received: by mail-qt0-f182.google.com with SMTP id x49so180100779qtc.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 14:47:23 -0800 (PST)
In-Reply-To: <1486582330-31152-4-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8 February 2017 at 11:32, Jarno Rajahalme <jarno@ovn.org> wrote:
> Since 23014011ba42 ("netfilter: conntrack: support a fixed size of 128
> distinct labels"), the size of conntrack labels extension has fixed to
> 128 bits, so we do not need to check for labels sizes shorter than 128
> at run-time.  This patch simplifies labels length logic accordingly,
> but allows the conntrack labels size to be increased in the future
> without breaking the build.  In the event of conntrack labels
> increasing in size OVS would still be able to deal with the 128 first
> label bits.
>
> Suggested-by: Joe Stringer <joe@ovn.org>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
>  net/openvswitch/conntrack.c | 22 +++++++++++-----------
>  1 file changed, 11 insertions(+), 11 deletions(-)
>
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index 6730f09..a07e5cd 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -129,22 +129,22 @@ static u32 ovs_ct_get_mark(const struct nf_conn *ct)
>  #endif
>  }
>
> +/* Guard against conntrack labels max size shrinking below 128 bits. */
> +#if NF_CT_LABELS_MAX_SIZE < 16
> +#error NF_CT_LABELS_MAX_SIZE must be at least 16 bytes
> +#endif
> +
>  static void ovs_ct_get_labels(const struct nf_conn *ct,
>                               struct ovs_key_ct_labels *labels)
>  {
>         struct nf_conn_labels *cl = ct ? nf_ct_labels_find(ct) : NULL;
>
> -       if (cl) {
> -               size_t len = sizeof(cl->bits);
> -
> -               if (len > OVS_CT_LABELS_LEN)
> -                       len = OVS_CT_LABELS_LEN;
> -               else if (len < OVS_CT_LABELS_LEN)
> -                       memset(labels, 0, OVS_CT_LABELS_LEN);
> -               memcpy(labels, cl->bits, len);
> -       } else {
> +       if (cl)
> +               memcpy(labels, cl->bits,
> +                      sizeof(cl->bits) > OVS_CT_LABELS_LEN
> +                      ? OVS_CT_LABELS_LEN : sizeof(cl->bits));

Is this to be defensive? If sizeof(cl->bits) is larger than
OVS_CT_LABELS_LEN, we'll use OVS_CT_LABELS_LEN; if it's equal, we'll
still use OVS_CT_LABELS_LEN; if it's less, the precompiler will fail
above. Why not memcpy(.., OVS_CT_LABELS_LEN) ?
