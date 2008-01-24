From: =?iso-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: [PATCH] Re: Loopback address to eth0 interface and rooting goes wrong
Date: Thu, 24 Jan 2008 09:08:02 +0100
Message-ID: <87myqvzlwd.fsf_-_@obelix.mork.no>
References: <47f575c20801211153u45920d20p42c459883f04f10a@mail.gmail.com>
	<4795DDF3.8050705@linux.vnet.ibm.com>
	<47f575c20801221243x5f7ad970x5380928419b0d9d1@mail.gmail.com>
	<47972E16.3080400@linux.vnet.ibm.com>
	<47f575c20801230913s7e934a43tf031bb3c00f7aad2@mail.gmail.com>
	<87zluwz8ih.fsf@obelix.mork.no> <47981623.1040100@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: Varun Chandramohan <varunc@linux.vnet.ibm.com>,
	Gary <gary.manchon@gmail.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>, ecki@lina.inka.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:37202 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750928AbYAXIaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 03:30:17 -0500
In-Reply-To: <47981623.1040100@linux.vnet.ibm.com> (Varun Chandramohan's
	message of "Thu, 24 Jan 2008 10:07:55 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=

Hello

Gary < gary.manchon (at) gmail.com > found a problem where he was unable
to recover from a bad network interface configuration 
(ifconfig eth0 127.0.0.1), ref 
http://www.uwsg.iu.edu/hypermail/linux/net/0801.2/0009.html

This was confirmed by several people.

I suspect that the problem might be this code in net/ipv4/devinet.c ,
which sets ifa_scope to RT_SCOPE_HOST if you configure a loopback
address (127/8) on any interface.  I guess it's there to protect us from
sending packets with a loopback source address, which woulnd't look too
good:

static int inet_set_ifa(struct net_device *dev, struct in_ifaddr *ifa)
{
	struct in_device *in_dev = __in_dev_get_rtnl(dev);

	ASSERT_RTNL();

	if (!in_dev) {
		inet_free_ifa(ifa);
		return -ENOBUFS;
	}
	ipv4_devconf_setall(in_dev);
	if (ifa->ifa_dev != in_dev) {
		BUG_TRAP(!ifa->ifa_dev);
		in_dev_hold(in_dev);
		ifa->ifa_dev = in_dev;
	}
	if (LOOPBACK(ifa->ifa_local))
		ifa->ifa_scope = RT_SCOPE_HOST;
	return inet_insert_ifa(ifa);
}



The real problem is that there's never anything resetting this scope if
you change the address later.  This patch adds scope reset when changing
the address.


--=-=-=
Content-Type: text/x-diff
Content-Disposition: inline; filename=devinet-rt_scope-fix.patch

We set the scope to RT_SCOPE_HOST if an IPv4 interface is configured with a 
loopback address (127/8).  This prevents the interface from sending packets 
out the wire.  This patch resets the scope if the address is changed again,
to restore normal functionality.

Signed-off-by: Bjorn Mork <bjorn@mork.no>

 devinet.c |    1 +
 1 file changed, 1 insertion(+)


--- linux-2.6.24-rc8.orig/net/ipv4/devinet.c	2008-01-16 05:22:48.000000000 +0100
+++ linux-2.6.24-rc8/net/ipv4/devinet.c	2008-01-23 19:17:30.000000000 +0100
@@ -753,6 +753,7 @@
 			inet_del_ifa(in_dev, ifap, 0);
 			ifa->ifa_broadcast = 0;
 			ifa->ifa_anycast = 0;
+			ifa->ifa_scope = 0;
 		}
 
 		ifa->ifa_address = ifa->ifa_local = sin->sin_addr.s_addr;

--=-=-=
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable




Bj=F8rn

--=-=-=--
