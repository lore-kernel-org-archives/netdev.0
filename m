From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] crash in 2.6.22-git2 sysctl_set_parent()
Date: Fri, 13 Jul 2007 15:47:02 -0700 (PDT)
Message-ID: <20070713.154702.17863636.davem@davemloft.net>
References: <20070713200515.GS5549@austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51038
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934345AbXGMWrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 18:47:03 -0400
In-Reply-To: <20070713200515.GS5549@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: linas@austin.ibm.com (Linas Vepstas)
Date: Fri, 13 Jul 2007 15:05:15 -0500

> 
> This is a patch (& bug report) for a crash in sysctl_set_parent() 
> in 2.6.22-git2. 
> 
> Problem: 2.6.22-git2 crashes with a stack trace 
> [c000000001d0fb00] c000000000067b4c .sysctl_set_parent+0x48/0x7c
> [c000000001d0fb90] c000000000069b40 .register_sysctl_table+0x7c/0xf4
> [c000000001d0fc30] c00000000065e710 .devinet_init+0x88/0xb0
> [c000000001d0fcc0] c00000000065db74 .ip_rt_init+0x17c/0x32c
> [c000000001d0fd70] c00000000065deec .ip_init+0x10/0x34
> [c000000001d0fdf0] c00000000065e898 .inet_init+0x160/0x3dc
> [c000000001d0fea0] c000000000630bc4 .kernel_init+0x204/0x3c8
> 
> A bit of poking around makes it clear what the problem is:
> In sysctl_set_parent(), the for loop 
> 
>    for (; table->ctl_name || table->procname; table++) {
> 
> walks off the end of the table, and into garbage.  Basically,
> this for-loop iterator expects all table arrays to be 
> "null terminated".  However, net/ipv4/devinet.c statically 
> declares an array that is not null-terminated.  The patch 
> below fixes that; it works for me.  Its somewhat conservative;
> if one wishes to assume that the compiler will always zero out
> the empty parts of the structure, then this pach can be shrunk 
> to one line: +	ctl_table		devinet_root_dir[3];
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

Thanks for tracking this down, I'll apply your patch.
