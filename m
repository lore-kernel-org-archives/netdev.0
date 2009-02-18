From: Brian Haley <brian.haley@hp.com>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Wed, 18 Feb 2009 14:57:14 -0500
Message-ID: <499C681A.6000008@hp.com>
References: <200902172001.41804.arvidjaar@mail.ru> <20090217.142946.232071526.davem@davemloft.net> <25143.1234932076@turing-police.cc.vt.edu> <20090217.212919.259912220.davem@davemloft.net> <20090218135537.GF3600@mini-me.lan> <06F54D7E-EE07-49C9-AD8F-B46BD6B02ABA@oracle.com> <499C5486.5020807@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020600060606060306030002"
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Theodore Tso <tytso@mit.edu>, Valdis.Kletnieks@vt.edu,
	arvidjaar@mail.ru, rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756530AbZBRT5g@vger.kernel.org>
In-Reply-To: <499C5486.5020807@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020600060606060306030002
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Vlad Yasevich wrote:
> Having worked in other environments where ipv6 has to be explicitly
> enabled per interface, I've thought that this level of control was
> always missing from linux.  Being able to configure only the interface
> that users want seems like a good thing to have.
> Would a module parameter that disables ipv6 or at least addrconf be
> enough of a solution?

There does seem to be a sysctl for it, just doesn't seem to work. 
Possible patch below.

This actually brings up the issue that the "all" ipv6 sysctl, for 
example net.ipv6.conf.all.disable_ipv6, doesn't actually do anything (at 
least it didn't seem to for me).  Maybe it's time to fix that too to be 
like IPv4, things like IN_DEV_RPFILTER() and friends aren't looking so 
bad...

I tested this patch on lo and a few Ethernet devices and saw no IPv6 
addresses.  Don't know if EPERM is the right errno since we don't know 
if the user set this or DAD failed.


The disable_ipv6 knob was meant to be used for the kernel to disable 
IPv6 on an interface when DAD failed for the link-local address based on 
the MAC, but we should also be able to administratively disable it on an 
interface, or the entire system.  This patch fixes the per-interface 
problem.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------020600060606060306030002
Content-Type: text/x-diff;
 name="noipv6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="noipv6.patch"

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 03e2a1a..9bc761f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -603,6 +603,11 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 		goto out2;
 	}
 
+	if (idev->cnf.disable_ipv6) {
+		err = -EPERM;
+		goto out2;
+	}
+
 	write_lock(&addrconf_hash_lock);
 
 	/* Ignore adding duplicate addresses on an interface */

--------------020600060606060306030002--
