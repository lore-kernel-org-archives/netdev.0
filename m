From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 3/3] mlxsw: spectrum_router: Return extack
 message on abort due to fib rules
Date: Thu, 26 Oct 2017 08:26:16 +0200
Message-ID: <20171026062616.GC1928@nanopsycho.orion>
References: <1508994485-24533-1-git-send-email-dsahern@gmail.com>
 <1508994485-24533-4-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        johannes.berg@intel.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:48046 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751584AbdJZG0S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 02:26:18 -0400
Received: by mail-wm0-f68.google.com with SMTP id r196so5702093wmf.2
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 23:26:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1508994485-24533-4-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 26, 2017 at 07:08:05AM CEST, dsahern@gmail.com wrote:
>Adding a FIB rule on a spectrum platform silently aborts FIB offload:
>    $ ip ru add pref 99 from all to 192.168.1.1 table 10
>    $ dmesg -c
>    [  623.144736] mlxsw_spectrum 0000:03:00.0: FIB abort triggered. Note that FIB entries are no longer being offloaded to this device.
>
>This patch reworks FIB rule handling to return a message to the user:
>    $ ip ru add pref 99 from all to 8.8.8.8 table 11
>    Error: spectrum: FIB rules not supported. Aborting offload.
>
>spectrum currently only checks whether the fib rule is a default rule or
>an l3mdev rule, both of which it knows how to handle. Any other it aborts
>FIB offload. Since the processing is fairly quick, move the code to inline
>with the user request rather than a work queue to allow a message to be
>returned if the offload is aborted. Change the delete handling to just return
>since it does nothing at the moment.
>
>Signed-off-by: David Ahern <dsahern@gmail.com>
>---

[...]

>+static int mlxsw_sp_router_fib_rule_event(unsigned long event,
>+					  struct fib_notifier_info *info,
>+					  struct mlxsw_sp *mlxsw_sp)
>+{
>+	struct netlink_ext_ack *extack = info->extack;
>+	struct fib_rule_notifier_info *fr_info;
>+	struct fib_rule *rule;
>+	bool add_unsupported_msg = false;
>+
>+	/* nothing to do at the moment */
>+	if (event == FIB_EVENT_RULE_DEL)
>+		goto out;
>+
>+	fr_info = container_of(info, struct fib_rule_notifier_info, info);
>+	rule = fr_info->rule;
>+
>+	switch (info->family) {
>+	case AF_INET:
>+		if (!fib4_rule_default(rule) && !rule->l3mdev) {

Why don't we abort on removal of default rule?



>+			add_unsupported_msg = true;
>+			mlxsw_sp_router_fib_abort(mlxsw_sp);
>+		}
>+		break;
>+	case AF_INET6:
>+		if (!fib6_rule_default(rule) && !rule->l3mdev) {
>+			add_unsupported_msg = true;
>+			mlxsw_sp_router_fib_abort(mlxsw_sp);
>+		}
>+		break;
>+	case RTNL_FAMILY_IPMR:
>+		if (!ipmr_rule_default(rule) && !rule->l3mdev) {
>+			add_unsupported_msg = true;
>+			mlxsw_sp_router_fib_abort(mlxsw_sp);
>+		}
> 		break;
