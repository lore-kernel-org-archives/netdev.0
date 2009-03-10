From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: BUG when unloading bonding on 2.6.29-rc7-git3
Date: Tue, 10 Mar 2009 23:23:13 +0000
Message-ID: <1236727393.7958.38.camel@Maple>
References: <49B6CA4A.2040506@mandriva.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Backlund <tmb@mandriva.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:46733 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754984AbZCJXXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 19:23:23 -0400
In-Reply-To: <49B6CA4A.2040506@mandriva.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-03-10 at 22:15 +0200, Thomas Backlund wrote:
> I get this when trying to unloading the bonding module by doing:
> 
> service network stop
> modprobe -r bonding
> 
> Oh, and I have "options ipv6 disable=1" in /etc/modprobe.conf
> 
> 
> > Mar 10 21:43:33 tmb kernel: BUG: unable to handle kernel NULL
> pointer dereference at 0000000000000028
> > Mar 10 21:43:33 tmb kernel: IP: [<ffffffffa038ad6b>]
> ipv6_sysctl_net_exit+0x1b/0x60 [ipv6]

Beyond the null pointer reference in ipv6_sysctl_net_exit caught in the
report, there is at least one further place where ipv6 module exit
breaks with disable=1. 

I've tested this patch with both values of the module parameter, and
with IPv6 built into the kernel rather than as a module.  I cannot
guarantee that something else doesn't break when modules call into an
unitialized ipv6.

---

ipv6:  Fix BUG when disabled ipv6 module is unloaded

Do not try to "uninitialize" ipv6 if its initialization had been skipped
because module parameter disable=1 had been specified.

Reported-by:  Thomas Backlund <tmb@mandriva.org>
Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
---
net/ipv6/af_inet6.c |    3 +++
1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index da944ec..a0f1798 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -1192,6 +1192,9 @@ module_init(inet6_init);

static void __exit inet6_exit(void)
{
+       if (disable_ipv6)
+               return;
+
        /* First of all disallow new sockets creation. */
        sock_unregister(PF_INET6);
        /* Disallow any further netlink messages */
--
1.5.4.3


