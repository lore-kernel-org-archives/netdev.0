From: Olaf Kirch <okir@suse.de>
Subject: Re: ip addr flush hangs
Date: Tue, 9 Mar 2004 16:07:30 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040309150730.GE14419@suse.de>
References: <20040309144824.GD14419@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Q68bSM7Ycu6FN28Q"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040309144824.GD14419@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

On Tue, Mar 09, 2004 at 03:48:24PM +0100, Olaf Kirch wrote:
> This is not entirely consistent. Should a NETDEV_DOWN zap the
> ipv6 configuration completely?

Sorry to follow up on my own mail...

Cross-checking ipv4, I can see that it behaves the same way as IPv6
(i.e. NETDEV_DOWN partly leaves the interface configuration intact).
The difference though is that dump_ifaddr doesn't include multicast
addresses in its report.

The attached patch disables reporting of multicast and anycast
addresses in inet6_dump_ifaddr

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 

--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=ipv6-netdev-down

--- linux-2.6.3/net/ipv6/addrconf.c.orig	2004-03-09 15:46:33.000000000 +0100
+++ linux-2.6.3/net/ipv6/addrconf.c	2004-03-09 16:04:54.000000000 +0100
@@ -2898,6 +2898,11 @@ static int inet6_dump_ifaddr(struct sk_b
 				goto done;
 		}
 #endif
+		/* You can't delete these via RTM_DELADDR, so we shouldn't
+		 * display them here. Otherwise "ip addr flush" will loop
+		 * forever trying to delete ff02::1 etc.
+		 * 				--okir */
+#if 0
 		/* multicast address */
 		for (ifmca = idev->mc_list; ifmca; 
 		     ifmca = ifmca->next, ip_idx++) {
@@ -2918,6 +2923,7 @@ static int inet6_dump_ifaddr(struct sk_b
 			    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0) 
 				goto done;
 		}
+#endif
 		read_unlock_bh(&idev->lock);
 		in6_dev_put(idev);
 	}

--Q68bSM7Ycu6FN28Q--
