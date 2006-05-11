From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] bonding: fix sparse warnings
Date: Wed, 10 May 2006 20:45:13 -0700
Message-ID: <20060510204513.127d9bef@localhost.localdomain>
References: <20060510161405.4ded4250@localhost.localdomain>
	<20060510232203.GK27946@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ctindel@users.sourceforge.net, Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:34272 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965122AbWEKDpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 23:45:33 -0400
To: Al Viro <viro@ftp.linux.org.uk>
In-Reply-To: <20060510232203.GK27946@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 May 2006 00:22:03 +0100
Al Viro <viro@ftp.linux.org.uk> wrote:

> On Wed, May 10, 2006 at 04:14:05PM -0700, Stephen Hemminger wrote:
> > Fix warning from sparse in bonding code about "incorrect type in assignment"
> 
> *snerk*
> 
> Only if you are building without -Wcast-to-as.  It _is_ incorrect type in
> assignment.  And the real fix is to expand the call, killing set_fs()
> in there.

More like this (in br_if.c)?

	struct ethtool_cmd ecmd = { ETHTOOL_GSET };
	struct ifreq ifr;
	mm_segment_t old_fs;
	int err;

	strncpy(ifr.ifr_name, dev->name, IFNAMSIZ);
	ifr.ifr_data = (void __user *) &ecmd;

	old_fs = get_fs();
	set_fs(KERNEL_DS);
	err = dev_ethtool(&ifr);
	set_fs(old_fs);
	
	if (!err)
		...
