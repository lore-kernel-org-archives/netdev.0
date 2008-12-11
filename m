From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [Bugme-new] [Bug 12201] New: long wait in call_usermodehelper() / queue_work() / wait_for_completion()
Date: Fri, 12 Dec 2008 02:05:21 +0300
Message-ID: <20081211230521.GA2392@ioremap.net>
References: <bug-12201-10286@http.bugzilla.kernel.org/> <20081211143758.510b51b6.akpm@linux-foundation.org> <20081211225158.GA2169@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mike@nauticaltech.com, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:44864 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757873AbYLKXFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2008 18:05:23 -0500
Content-Disposition: inline
In-Reply-To: <20081211225158.GA2169@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2008 at 01:51:58AM +0300, Evgeniy Polyakov (zbr@ioremap.net) wrote:
> > > If I write a small pilot program that calls socket(PF_NETLINK, SOCK_RAW,
> > > NETLINK_AUDIT), it will delay by 1-2 seconds 100% of the time (assuming server
> > > has been online for a while).  Certain protocol types given to socket() have
> > > zero delay (because no module needs to be loaded).
> > > 
> > > Steps to reproduce:
> > > Once server has been online for a while, a simple call to socket(PF_NETLINK,
> > > SOCK_RAW, NETLINK_AUDIT) shows the problem.
> > 
> > OK, weird.
> > 
> > Please get sysrq working then get us a task trace, so we can see who is
> > sleeping where.  Do this:
> > 
> > 
> > - run your "small pilot program"
> 
> Or send it to us and we will quickly fix the bug :)
> 
> Thank you!

Btw, does this ugly hack fix the problem?
According to your description it may be the case.

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 480184a..2b64eb5 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -434,6 +434,10 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol)
 	if (protocol < 0 || protocol >= MAX_LINKS)
 		return -EPROTONOSUPPORT;
 
+#ifndef CONFIG_AUDIT
+	if (protocol == NETLINK_AUDIT)
+		return -EPROTONOSUPPORT;
+#endif
 	netlink_lock_table();
 #ifdef CONFIG_MODULES
 	if (!nl_table[protocol].registered) {


-- 
	Evgeniy Polyakov
