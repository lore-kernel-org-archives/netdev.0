From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next sample action optimization v2 4/4] Openvswitch:
 Refactor sample and recirc actions implementation
Date: Thu, 16 Mar 2017 12:24:20 -0700
Message-ID: <CAOrHB_ANWNUDU_HaM-ohvDb_LhWe+_Sk_e4fkiAX=Aq=oSkM6w@mail.gmail.com>
References: <1489532891-33497-1-git-send-email-azhou@ovn.org> <1489532891-33497-5-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:60049 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752353AbdCPTdL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 15:33:11 -0400
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id D544A47B708
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 20:25:25 +0100 (CET)
Received: from mfilter18-d.gandi.net (mfilter18-d.gandi.net [217.70.178.146])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id A9011C5A49
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 20:24:23 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter18-d.gandi.net (mfilter18-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id f8duDimc_d1F for <netdev@vger.kernel.org>;
        Thu, 16 Mar 2017 20:24:21 +0100 (CET)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 81DA8C5A67
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 20:24:21 +0100 (CET)
Received: by mail-wm0-f51.google.com with SMTP id v203so5309402wmg.0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 12:24:21 -0700 (PDT)
In-Reply-To: <1489532891-33497-5-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 4:08 PM, Andy Zhou <azhou@ovn.org> wrote:
> Added execute_or_defer_actions() that both sample and recirc
> action's implementation can use.
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>
> ---
>  net/openvswitch/actions.c | 96 +++++++++++++++++++++++++++++------------------
>  1 file changed, 59 insertions(+), 37 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 1638370..fd7d903 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
...

> @@ -1286,6 +1262,52 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>         return 0;
>  }
>
> +static int execute_or_defer_actions(struct datapath *dp, struct sk_buff *skb,
> +                                   struct sw_flow_key *clone,
> +                                   struct sw_flow_key *key,
> +                                   u32 *recirc_id,
> +                                   const struct nlattr *actions, int len)
> +{
> +       struct deferred_action *da;
> +
> +       /* If within the limit of 'OVS_DEFERRED_ACTION_THRESHOLD',
> +        * recirc immediately, otherwise, defer it for later execution.
> +        */
> +       if (clone) {
> +               if (recirc_id) {
> +                       clone->recirc_id = *recirc_id;
> +                       ovs_dp_process_packet(skb, clone);
> +                       return 0;
> +               } else {
> +                       return do_execute_actions(dp, skb, clone,
> +                                                 actions, len);

the exec_actions_level inc and dec should be moved here, since it is
only needed around this function.
