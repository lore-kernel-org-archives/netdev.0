From: Pekka Savola <pekkas@netcore.fi>
Subject: support force_igmp_version=3 and force_mld_version=2 ?
Date: Thu, 25 Sep 2008 09:40:37 +0300 (EEST)
Message-ID: <alpine.LRH.2.00.0809250908590.21286@netcore.fi>
References: <alpine.LRH.2.00.0809241326070.30892@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:54274 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750802AbYIYGkm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 02:40:42 -0400
Received: from netcore.fi (localhost [127.0.0.1])
	by netcore.fi (8.13.8/8.13.8) with ESMTP id m8P6ecRJ021791
	for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 09:40:38 +0300
Received: from localhost (pekkas@localhost)
	by netcore.fi (8.13.8/8.13.8/Submit) with ESMTP id m8P6ebD3021787
	for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 09:40:38 +0300
In-Reply-To: <alpine.LRH.2.00.0809241326070.30892@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Sep 2008, Pekka Savola wrote:
> I've spotted some irritating IGMPv3/v2 compat problems on RHEL4, and 
> I'm working on trying to see if these are due to bugs already fixed 
> in latest kernels.

OK, I've done some tests.

1) in a RHEL4 2.6.8 kernel, the logic of timeouting seeing a V2
    querier earlier seems to be broken -- even if there are no IGMPv2
    reports or queries on the LAN for a long time, the system (as seen
    by /proc/net/igmp) doesn't go back to V3.  I tested that this works
    in 2.6.26.5 so this is OK.

2) only force_igmp_version=[12] is supported.  It might be useful to
    support "force_igmp_version=3" as well, where the system will not
    fall back to IGMPv1 or IGMPv2 compat mode even if it thinks it sees
    or has seen an IGMPv1/v2 query.

    This behaviour would be useful for example in scenarios where you
    know that the router is IGMPv3/MLDv2 capable, and you want to
    ignore queries sent by other routers, snooping switches or rogue
    hosts, or membership reports by other hosts (but Linux currently
    doesn't seem to support group-specific IGMP downgrade so this is
    not a problem right now) [see e.g. RFC4604 for more on various
    other things, e.g. warning errors, that could be added].

    What I refer to something like the follows (not tested, whitespace
    probably broken due to cut'n'pasting), or some similar changes in
    the logic where IGMP_Vx_SEEN is used (similar with MLD_V1_SEEN):

--- igmp.c.orig 2008-09-25 09:33:00.000000000 +0300
+++ igmp.c      2008-09-25 09:35:20.000000000 +0300
@@ -2,9 +2,13 @@
           (IPV4_DEVCONF_ALL(dev_net(in_dev->dev), FORCE_IGMP_VERSION) == 1 || \
            IN_DEV_CONF_GET((in_dev), FORCE_IGMP_VERSION) == 1 || \
            ((in_dev)->mr_v1_seen && \
+           IPV4_DEVCONF_ALL(dev_net(in_dev->dev), FORCE_IGMP_VERSION) != 3 && \
+           IN_DEV_CONF_GET((in_dev), FORCE_IGMP_VERSION) != 3 && \
             time_before(jiffies, (in_dev)->mr_v1_seen)))
  #define IGMP_V2_SEEN(in_dev) \
           (IPV4_DEVCONF_ALL(dev_net(in_dev->dev), FORCE_IGMP_VERSION) == 2 || \
            IN_DEV_CONF_GET((in_dev), FORCE_IGMP_VERSION) == 2 || \
            ((in_dev)->mr_v2_seen && \
+           IPV4_DEVCONF_ALL(dev_net(in_dev->dev), FORCE_IGMP_VERSION) != 3 && \
+           IN_DEV_CONF_GET((in_dev), FORCE_IGMP_VERSION) != 3 && \
             time_before(jiffies, (in_dev)->mr_v2_seen)))

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
