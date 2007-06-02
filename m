From: Tim Mann <mann@vmware.com>
Subject: small forcedeth WoL fix
Date: Fri, 1 Jun 2007 17:22:17 -0700
Message-ID: <20070601172217.686a0d5e@mann-lx.eng.vmware.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_nqA/M=NWxLZiJanMTSuSY7Q"
Cc: mann@vmware.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:47448 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755607AbXFBAWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 20:22:18 -0400
Received: from mailhost3.vmware.com (mailhost3.vmware.com [10.16.68.131])
	by smtp-outbound-1.vmware.com (Postfix) with ESMTP id 192D9664E
	for <netdev@vger.kernel.org>; Fri,  1 Jun 2007 17:22:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--MP_nqA/M=NWxLZiJanMTSuSY7Q
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I happened to notice that a system with an NVidia NIC using the
forcedeth driver won't wake-on-LAN if the interface was in promiscuous
mode when you power off.  By experiment, it looks like
the hardware needs to have NvRegPacketFilterFlags set to
NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR (i.e., receive unicast packets to my
address) in order for WoL to work.  At any rate, the attached patch
fixes the problem for me.

-- 
Tim Mann  work: mann@vmware.com  home: tim@tim-mann.org
          http://www.vmware.com  http://tim-mann.org

--MP_nqA/M=NWxLZiJanMTSuSY7Q
Content-Type: text/x-patch; name=wol-fix.patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=wol-fix.patch

--- forcedeth-git-netdev.c	2007-06-01 16:43:19.971507000 -0700
+++ forcedeth-git-netdev-fixed.c	2007-06-01 16:46:53.389713000 -0700
@@ -4830,8 +4830,10 @@
 
 	drain_ring(dev);
 
-	if (np->wolenabled)
+	if (np->wolenabled) {
+		writel(NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR, base + NvRegPacketFilterFlags);
 		nv_start_rx(dev);
+	}
 
 	/* FIXME: power down nic */
 

--MP_nqA/M=NWxLZiJanMTSuSY7Q--
