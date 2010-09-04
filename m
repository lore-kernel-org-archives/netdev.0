From: Alexander Clouter <alex@digriz.org.uk>
Subject: pimreg zombies
Date: Sat, 4 Sep 2010 22:12:34 +0100
Message-ID: <2bpal7-l68.ln1@chipmunk.wormnet.eu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:36700 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753670Ab0IDWI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Sep 2010 18:08:57 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Os0us-0002Jr-DW
	for netdev@vger.kernel.org; Sun, 05 Sep 2010 00:08:54 +0200
Received: from chipmunk.wormnet.eu ([195.195.131.226])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 05 Sep 2010 00:08:54 +0200
Received: from alex by chipmunk.wormnet.eu with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 05 Sep 2010 00:08:54 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am writing a multicast pim daemon and noticed that if I call 
setsockopt(MRT_ADD_VIF), also occurs for IPv6 too, incorrectly on a 
socket established with socket(AF_INET, SOCK_RAW, IPPROTO_PIM)[1] then 
when the application quits I have zombie pimreg (and pimreg6) interfaces 
that can only be disposed of with a reboot.

I have included the code below to give you something (hopefully) 
reproducible; this problem I see on a 2.6.35.4 kernel.  No idea if there 
was ever a safe kernel but maybe all the recent namespace and multiple 
multicast routing table amendments broke something.

Obviously I know for Linux I should be calling setsockopt() on the IGMP 
socket, however I'm pretty sure zombie pim's should not be appearing :)

Cheers

[1] rather than as I should on an IPPROTO_IGMP raw socket

----
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdio.h>
#include <sysexits.h>
#include <string.h>
#include <netinet/in.h>
#include <linux/mroute.h>
#include <linux/mroute6.h>

int main(int argc, char **argv)
{
	int		pim4, pim6;
	struct vifctl	v4;
	struct mif6ctl	v6;

	pim4 = socket(AF_INET, SOCK_RAW, IPPROTO_PIM);
	if (pim4 < 0) {
		perror("socket(AF_INET, SOCK_RAW, IPPROTO_PIM)");
		return EX_OSERR;
	}

	memset(&v4, 0, sizeof(v4));
	v4.vifc_flags	= VIFF_REGISTER;

	if (setsockopt(pim4, IPPROTO_IP, MRT_ADD_VIF, &v4, sizeof(v4)) < 0) {
		perror("setsockopt(MRT_ADD_VIF)");
		close(pim4);
		return EX_OSERR;
	}

	close(pim4);

	/***********************/

	pim6 = socket(AF_INET6, SOCK_RAW, IPPROTO_PIM);
	if (pim6 < 0) {
		perror("socket(AF_INET6, SOCK_RAW, IPPROTO_PIM)");
		return EX_OSERR;
	}

	memset(&v6, 0, sizeof(v6));
	v6.mif6c_flags = MIFF_REGISTER;

	if (setsockopt(pim6, IPPROTO_IPV6, MRT6_ADD_MIF, &v6, sizeof(v6)) < 0) {
		perror("setsockopt(MRT6_ADD_MIF)");
		close(pim6);
		return EX_OSERR;
	}

	close(pim6);

	return EX_OK;
}
----

-- 
Alexander Clouter
.sigmonster says: You have junk mail.

