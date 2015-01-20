From: "Harout Hedeshian" <harouth@codeaurora.org>
Subject: RE: [PATCH v2 net-next] net: ipv6: Add sysctl entry to disable MTU updates from RA
Date: Tue, 20 Jan 2015 09:48:52 -0700
Message-ID: <006301d034d0$f9e10520$eda30f60$@codeaurora.org>
References: <1421703363-3376-1-git-send-email-harouth@codeaurora.org> <54BD8CB0.8050800@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'Daniel Borkmann'" <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:33066 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752267AbbATQs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 11:48:56 -0500
In-Reply-To: <54BD8CB0.8050800@redhat.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
> > index 73cb02d..437a6a4 100644
> > --- a/include/uapi/linux/ipv6.h
> > +++ b/include/uapi/linux/ipv6.h
> > @@ -169,6 +169,7 @@ enum {
> >   	DEVCONF_SUPPRESS_FRAG_NDISC,
> >   	DEVCONF_ACCEPT_RA_FROM_LOCAL,
> >   	DEVCONF_USE_OPTIMISTIC,
> > +	DEVCONF_ACCEPT_RA_MTU,
> >   	DEVCONF_MAX
> >   };
> 
> You also need a corresponding ipv6_store_devconf() entry, otherwise
> netlink dumps will always see this setting as disabled.

I added the following:
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cdd70ed..5743293 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4378,6 +4378,7 @@ static inline void ipv6_store_devconf(struct
ipv6_devconf *cnf,
        array[DEVCONF_NDISC_NOTIFY] = cnf->ndisc_notify;
        array[DEVCONF_SUPPRESS_FRAG_NDISC] = cnf->suppress_frag_ndisc;
        array[DEVCONF_ACCEPT_RA_FROM_LOCAL] = cnf->accept_ra_from_local;
+       array[DEVCONF_ACCEPT_RA_MTU] = cnf->accept_ra_mtu;
 }

I will upload v3 with the following changes:
 - Fix tab indentation in documentation
 - Remove changes from sysctl_binary.c and sysctl.h
 - Fixed netlink dumps

-- Sanity test results below --

As a quick test, I wrote a very simple utility to dump out the raw contents
of a RTM_NEWLINK event and tested it out on a UML instance by assigning some
easily identifiable (but meaningless) value:

root@debian-wheezy-template:/mnt/host# ./a.out &
root@debian-wheezy-template:/mnt/host# cd /proc/sys/net/ipv6/conf/eth0
root@debian-wheezy-template:/proc/sys/net/ipv6/conf/eth0# echo 90 >
accept_ra_mtu #should print the letter 'Z'
root@debian-wheezy-template:/proc/sys/net/ipv6/conf/eth0# ifconfig eth0 up
&& ifconfig eth0 down
Read 1152 bytes from the socket
           0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
...<truncated>...
00000020| 09 00 03 00 65 74 68 30 00 00 00 00 08 00 0D 00 | ....eth0........
...<truncated>...
00000300| 00 00 00 00 00 00 00 00 5A 00 00 00 24 01 03 00 | ........Z...$...
root@debian-wheezy-template:/proc/sys/net/ipv6/conf/eth0# echo 89 >
accept_ra_mtu # should print the letter 'Y'
root@debian-wheezy-template:/proc/sys/net/ipv6/conf/eth0# ifconfig eth0 up
&& ifconfig eth0 down
Read 1152 bytes from the socket
           0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
...<truncated>...
00000020| 09 00 03 00 65 74 68 30 00 00 00 00 08 00 0D 00 | ....eth0........
...<truncated>...
00000300| 00 00 00 00 00 00 00 00 59 00 00 00 24 01 03 00 | ........Y...$...


Thanks,
Harout

--
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux
Foundation Collaborative Project
