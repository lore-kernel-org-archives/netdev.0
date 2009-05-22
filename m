From: Mark Ryden <markryde@gmail.com>
Subject: Priority of added rules after deleting main and default rules in IPV4
Date: Fri, 22 May 2009 16:17:23 +0300
Message-ID: <dac45060905220617v7e3a9c36q292e1fc21087733a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:36253 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbZEVNRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 09:17:25 -0400
Received: by bwz22 with SMTP id 22so1617541bwz.37
        for <netdev@vger.kernel.org>; Fri, 22 May 2009 06:17:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

As we all know, when policy routing is enabled (CONFIG_IP_MULTIPLE_TABLES is
set, which is the default in many distros kernels) the local rule table
cannot be deleted since it is added with a permanent flag (FIB_RULE_PERMANENT).
Trying to delete the local rule will yield EPERM error 	(see
fib_nl_delrule() in
net/core/fib_rules.c). However, a sysadmin can delete the two other default
rules, (main and default) , for example thus:
ip rule del from all lookup main
ip rule del from all lookup default

(Another question is why he should do it)

Then each rule that we will add will get a priority of 0; (unless we
explicitly specify the priority when we add the rule). If we look at
the code, in
fib4_rule_default_pref(), we will see why is it so. (This method will
return 0, since
if (rule->pref) is evaluated as 0 when we have a single local rule,
which is with priority 0).

This means that after deleting the main and default rules and adding rules,
the priority convention (which says that each new rule as a priority
which is 1 less then the last added) does not hold.  All rules that
will be added will have priority of 0.
The question is: should this be avoided ?
(As I said, I know that the priority of a rule can be specified when
it is added)

I tried for example this series of actions:
ip rule del from all lookup main
ip rule del from all lookup default
ip rule add tos 0x08 table 252
ip rule add tos 0x04 table 252

and then:
ip rule show
0:      from all lookup local
0:      from all tos throughput lookup my_rt_table
0:      from all tos reliability lookup my_rt_table


Also of course trying to add the default (or main) rules will add them
with priority 0.
(trying for example "ip rule add from all lookup default" )

Regards,
Mark
