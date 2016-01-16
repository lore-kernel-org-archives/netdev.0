From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net v4] ovs: limit ovs recursions in ovs_execute_actions
 to not corrupt stack
Date: Sat, 16 Jan 2016 09:04:50 -0800
Message-ID: <CAOrHB_BCZRG8NinFintTcaRd0MBsYPt-hAH9LG+6uNwOa0GQaA@mail.gmail.com>
References: <1452876675-19834-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Simon Horman <simon.horman@netronome.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:50536 "EHLO
	relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbcAPREz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2016 12:04:55 -0500
Received: from mfilter17-d.gandi.net (mfilter17-d.gandi.net [217.70.178.145])
	by relay6-d.mail.gandi.net (Postfix) with ESMTP id 5DEE6FB87E
	for <netdev@vger.kernel.org>; Sat, 16 Jan 2016 18:04:53 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
	by mfilter17-d.gandi.net (mfilter17-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id Aj_W1l8pPpMs for <netdev@vger.kernel.org>;
	Sat, 16 Jan 2016 18:04:52 +0100 (CET)
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	(Authenticated sender: pshelar@ovn.org)
	by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id EC334FB877
	for <netdev@vger.kernel.org>; Sat, 16 Jan 2016 18:04:51 +0100 (CET)
Received: by mail-ig0-f176.google.com with SMTP id mw1so27712997igb.1
        for <netdev@vger.kernel.org>; Sat, 16 Jan 2016 09:04:51 -0800 (PST)
In-Reply-To: <1452876675-19834-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 15, 2016 at 8:51 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> It was seen that defective configurations of openvswitch could overwrite
> the STACK_END_MAGIC and cause a hard crash of the kernel because of too
> many recursions within ovs.
>
> This problem arises due to the high stack usage of openvswitch. The rest
> of the kernel is fine with the current limit of 10 (RECURSION_LIMIT).
>
> We use the already existing recursion counter in ovs_execute_actions to
> implement an upper bound of 5 recursions.
>
> Cc: Pravin Shelar <pshelar@ovn.org>
> Cc: Simon Horman <simon.horman@netronome.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> ---
> v2) added preemption guards
> v3) Pravin suggested to reuse the ovs_execute_actions counter which this
>     patch does. Also only allow 5 recursions as suggested by Pravin.
> v4) added unlikely as suggested by Eric
>
> Thanks to all reviewers!
>
>  net/openvswitch/actions.c | 21 ++++++++++++++++-----
>  1 file changed, 16 insertions(+), 5 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index c88d0f2d3e019b..da66f9e1660dbb 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -1160,17 +1160,28 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
>                         const struct sw_flow_actions *acts,
>                         struct sw_flow_key *key)
>  {
> -       int level = this_cpu_read(exec_actions_level);
> -       int err;
> +       static const int ovs_recursion_limit = 5;
> +       int err, level;
> +
> +       preempt_disable();

This function always run in soft-irq context. Do we really need this
preempt-disable call here?
