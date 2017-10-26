From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next 3/3] mlxsw: spectrum_router: Return extack
 message on abort due to fib rules
Date: Thu, 26 Oct 2017 09:40:46 +0300
Message-ID: <20171026064046.GB19803@shredder.mtl.com>
References: <1508994485-24533-1-git-send-email-dsahern@gmail.com>
 <1508994485-24533-4-git-send-email-dsahern@gmail.com>
 <20171026062616.GC1928@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org,
        jiri@mellanox.com, idosch@mellanox.com, johannes.berg@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:45763 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751397AbdJZGkt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 02:40:49 -0400
Content-Disposition: inline
In-Reply-To: <20171026062616.GC1928@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 08:26:16AM +0200, Jiri Pirko wrote:
> Thu, Oct 26, 2017 at 07:08:05AM CEST, dsahern@gmail.com wrote:
> >Adding a FIB rule on a spectrum platform silently aborts FIB offload:
> >    $ ip ru add pref 99 from all to 192.168.1.1 table 10
> >    $ dmesg -c
> >    [  623.144736] mlxsw_spectrum 0000:03:00.0: FIB abort triggered. Note that FIB entries are no longer being offloaded to this device.
> >
> >This patch reworks FIB rule handling to return a message to the user:
> >    $ ip ru add pref 99 from all to 8.8.8.8 table 11
> >    Error: spectrum: FIB rules not supported. Aborting offload.
> >
> >spectrum currently only checks whether the fib rule is a default rule or
> >an l3mdev rule, both of which it knows how to handle. Any other it aborts
> >FIB offload. Since the processing is fairly quick, move the code to inline
> >with the user request rather than a work queue to allow a message to be
> >returned if the offload is aborted. Change the delete handling to just return
> >since it does nothing at the moment.
> >
> >Signed-off-by: David Ahern <dsahern@gmail.com>
> >---
> 
> [...]
> 
> >+static int mlxsw_sp_router_fib_rule_event(unsigned long event,
> >+					  struct fib_notifier_info *info,
> >+					  struct mlxsw_sp *mlxsw_sp)
> >+{
> >+	struct netlink_ext_ack *extack = info->extack;
> >+	struct fib_rule_notifier_info *fr_info;
> >+	struct fib_rule *rule;
> >+	bool add_unsupported_msg = false;
> >+
> >+	/* nothing to do at the moment */
> >+	if (event == FIB_EVENT_RULE_DEL)
> >+		goto out;
> >+
> >+	fr_info = container_of(info, struct fib_rule_notifier_info, info);
> >+	rule = fr_info->rule;
> >+
> >+	switch (info->family) {
> >+	case AF_INET:
> >+		if (!fib4_rule_default(rule) && !rule->l3mdev) {
> 
> Why don't we abort on removal of default rule?

This was discussed during initial VRF offload submission. Users need to
be able to re-order the rule for the local table after the l3mdev rule.
