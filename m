From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] ipv4: properly apply change to
 ignore_routes_on_linkdown to all interfaces
Date: Wed, 2 Mar 2016 13:28:29 -0500
Message-ID: <20160302182827.GZ33942@gospo.home.greyhouse.net>
References: <1456936986-2042-1-git-send-email-gospo@cumulusnetworks.com>
 <56D72E2F.30207@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:33306 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbcCBS2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:28:33 -0500
Received: by mail-qg0-f51.google.com with SMTP id t4so19557335qge.0
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 10:28:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56D72E2F.30207@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 02, 2016 at 10:17:19AM -0800, David Ahern wrote:
> On 3/2/16 8:43 AM, Andy Gospodarek wrote:
> >
> >+/* called with RTNL locked */
> >+static void inet_ignore_routes_change(struct net *net)
> >+{
> >+	struct net_device *dev;
> >+	int on = IPV4_DEVCONF_ALL(net, IGNORE_ROUTES_WITH_LINKDOWN);
> >+
> >+	IPV4_DEVCONF_DFLT(net, IGNORE_ROUTES_WITH_LINKDOWN) = on;
> >+	inet_netconf_notify_devconf(net, NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
> >+				    NETCONFA_IFINDEX_ALL,
> >+				    net->ipv4.devconf_all);
> >+	inet_netconf_notify_devconf(net, NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
> >+				    NETCONFA_IFINDEX_DEFAULT,
> >+				    net->ipv4.devconf_dflt);
> >+
> >+	for_each_netdev(net, dev) {
> >+		struct in_device *in_dev;
> >+
> >+		rcu_read_lock();
> >+		in_dev = __in_dev_get_rcu(dev);
> >+		if (in_dev) {
> >+			IN_DEV_CONF_SET(in_dev,
> >+					IGNORE_ROUTES_WITH_LINKDOWN, on);
> >+			inet_netconf_notify_devconf(net,
> >+						    NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
> >+						    dev->ifindex, &in_dev->cnf);
> >+		}
> >+		rcu_read_unlock();
> >+	}
> >+}
> >+
> 
> This seems wrong -- changing the 'all' and 'default' settings for a sysctl
> should not require walking the interface list.

Not if you want to actually apply the config to all the interfaces.  If
you notice this borrows heavily from the sysctl to control ipv4
forwarding as it behaves in a manner that I would consider to be
proper.
