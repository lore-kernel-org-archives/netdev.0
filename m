From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: 16/32 bit issues at nfulnl_recv_config
Date: Fri, 19 May 2006 03:20:51 +0400
Message-ID: <20060518232050.GA31257@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0102.google.com ([72.14.214.198]:24407 "EHLO
	hu-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1750944AbWERXWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 May 2006 19:22:22 -0400
Received: by hu-out-0102.google.com with SMTP id 23so268762huc
        for <netdev@vger.kernel.org>; Thu, 18 May 2006 16:22:20 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm talking about net/netfilter/nfnetlink_log.c::^nfulnl_recv_config
below. I'm totally confused and beer supply almost ended, so can someone else
also look at it...

Put your attention at line 905:

net/netfilter/nfnetlink_log.c:

   902		if (nfula[NFULA_CFG_FLAGS-1]) {
   903			u_int16_t flags =
   904				*(u_int16_t *)NFA_DATA(nfula[NFULA_CFG_FLAGS-1]);
   905			nfulnl_set_flags(inst, ntohl(flags));


1) Cast should be made to __be16, and history of fixing endian warning
   slightly above supports it.
2) Assuming __be16, ntohl(__be16) is whooops.
3) nfulnl_set_flags() wants something 16-bit wide as a second argument,
   so ntohling there is double whoops.
4) NFULNL_CFG_F_SEQ* defines fit into 16 bit and are host-endian;
   inst->flags is &'ed with host endian so it's probably host-endian and

   static int
   nfulnl_set_flags(struct nfulnl_instance *inst, u_int16_t flags)
   						  ^^^^^^^^^
						  this should be made __be16.
   {
	spin_lock_bh(&inst->lock);
	inst->flags = ntohs(flags);
	spin_unlock_bh(&inst->lock);
	return 0;
   }

   What to do with lines 903-905 if it is.

	Alexey "confused in Moscow" Dobriyan

