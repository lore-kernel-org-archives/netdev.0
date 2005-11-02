From: Willy Tarreau <willy@w.ods.org>
Subject: [PATCH-2.4][MCAST]IPv6: small fix for ip6_mc_msfilter(...)
Date: Wed, 2 Nov 2005 22:31:09 +0100
Message-ID: <20051102213109.GA17369@alpha.home.local>
References: <20051102054702.GB11266@alpha.home.local> <OF0C913512.B3EB99A5-ON882570AD.0025FB9D-882570AD.00276427@us.ibm.com> <20051102092959.GA15515@alpha.home.local> <20051102134112.GB2609@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens@us.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Yan Zheng <yzcorp@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965269AbVKBVmw@vger.kernel.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Content-Disposition: inline
In-Reply-To: <20051102134112.GB2609@logos.cnet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcelo,

On Wed, Nov 02, 2005 at 11:41:12AM -0200, Marcelo Tosatti wrote:
> Given the fact that it is a bug correction, sure. 
> Could you please prepare a nice e-mail with the full description?

Yes, I see... email was not nice enough to the scripts :-)
Here it is complete and clean below.

Regards,
Willy

[PATCH-2.4][MCAST]IPv6: small fix for ip6_mc_msfilter(...)

Multicast source filters aren't widely used yet, and that's really
the only feature that's affected if an application actually exercises
this bug, as far as I can tell. An ordinary filter-less multicast join
should still work, and only forwarded multicast traffic making use of
filters and doing empty-source filters with the MSFILTER ioctl would
be at risk of not getting multicast traffic forwarded to them because
the reports generated would not be based on the correct counts.
Initial 2.6 patch by Yan Zheng, bug explanation by David Stevens,
patch ACKed by David.

     Signed-off-by: Willy Tarreau <willy@w.ods.org>

diff -urN linux-2.4.32-rc2/net/ipv4/igmp.c linux-2.4.32-rc2-mcast/net/ipv4/igmp.c
--- linux-2.4.32-rc2/net/ipv4/igmp.c	2005-11-02 10:16:03.000000000 +0100
+++ linux-2.4.32-rc2-mcast/net/ipv4/igmp.c	2005-11-02 10:20:33.000000000 +0100
@@ -1876,8 +1876,11 @@
 			sock_kfree_s(sk, newpsl, IP_SFLSIZE(newpsl->sl_max));
 			goto done;
 		}
-	} else
-		newpsl = 0;
+	} else {
+		newpsl = NULL;
+		(void) ip_mc_add_src(in_dev, &msf->imsf_multiaddr,
+		       msf->imsf_fmode, 0, NULL, 0);
+	}
 	psl = pmc->sflist;
 	if (psl) {
 		(void) ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
diff -urN linux-2.4.32-rc2/net/ipv6/mcast.c linux-2.4.32-rc2-mcast/net/ipv6/mcast.c
--- linux-2.4.32-rc2/net/ipv6/mcast.c	2005-11-02 10:16:03.000000000 +0100
+++ linux-2.4.32-rc2-mcast/net/ipv6/mcast.c	2005-11-02 10:21:49.000000000 +0100
@@ -505,8 +505,11 @@
 			sock_kfree_s(sk, newpsl, IP6_SFLSIZE(newpsl->sl_max));
 			goto done;
 		}
-	} else
-		newpsl = 0;
+	} else {
+		newpsl = NULL;
+		(void) ip6_mc_add_src(idev, group, gsf->gf_fmode, 0, NULL, 0);
+	}
+
 	psl = pmc->sflist;
 	if (psl) {
 		(void) ip6_mc_del_src(idev, group, pmc->sfmode,
