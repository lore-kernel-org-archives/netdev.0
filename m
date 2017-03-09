From: Joe Stringer <joe@ovn.org>
Subject: Re: [RFC net-next sample action optimization 2/3] openvswitch:
 Refactor recirc key allocation.
Date: Thu, 9 Mar 2017 11:11:02 -0800
Message-ID: <CAPWQB7FsjZ7aUXBT+uH_ht6gu5b4URhAirkX2UX95jTzOZ7g5w@mail.gmail.com>
References: <1488932137-120383-1-git-send-email-azhou@ovn.org> <1488932137-120383-3-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, pravin shelar <pshelar@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:43908 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932164AbdCITL1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 14:11:27 -0500
Received: from mfilter11-d.gandi.net (mfilter11-d.gandi.net [217.70.178.131])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 2A32CFB887
        for <netdev@vger.kernel.org>; Thu,  9 Mar 2017 20:11:25 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter11-d.gandi.net (mfilter11-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 5rB21wx3dmdi for <netdev@vger.kernel.org>;
        Thu,  9 Mar 2017 20:11:23 +0100 (CET)
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
        (Authenticated sender: joe@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id A00D1FB8A4
        for <netdev@vger.kernel.org>; Thu,  9 Mar 2017 20:11:23 +0100 (CET)
Received: by mail-qk0-f177.google.com with SMTP id v125so132118849qkh.2
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 11:11:23 -0800 (PST)
In-Reply-To: <1488932137-120383-3-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 March 2017 at 16:15, Andy Zhou <azhou@ovn.org> wrote:
> The logic of allocating and copy key for each 'exec_actions_level'
> was specific to execute_recirc(). However, future patches will reuse
> as well.  Refactor the logic into its own function clone_key().
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>
> ---

<snip>

> @@ -83,14 +83,32 @@ struct action_fifo {
>         struct deferred_action fifo[DEFERRED_ACTION_FIFO_SIZE];
>  };
>
> -struct recirc_keys {
> -       struct sw_flow_key key[OVS_DEFERRED_ACTION_THRESHOLD];
> +struct action_flow_keys {
> +       struct sw_flow_key key[OVS_ACTION_RECURSION_THRESHOLD];
>  };

I thought the old struct name was clearer on how it would be used -
for when actions are deferred.

>
>  static struct action_fifo __percpu *action_fifos;
> -static struct recirc_keys __percpu *recirc_keys;
> +static struct action_flow_keys __percpu *flow_keys;
>  static DEFINE_PER_CPU(int, exec_actions_level);
>
> +/* Make a clone of the 'key', using the pre-allocated percpu 'flow_keys'
> + * space. Since the storage is pre-allocated, the caller does not
> + * need to check for NULL return pointer.
> + */

Hmm? if level > OVS_ACTION_RECURSION_THRESHOLD, this function returns NULL.
