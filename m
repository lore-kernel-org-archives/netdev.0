From: Paul Moore <paul.moore@hp.com>
Subject: Re: [2.6 patch] security/selinux/netlabel.c: fix double free
Date: Mon, 28 Jan 2008 17:23:46 -0500
Message-ID: <200801281723.46273.paul.moore@hp.com>
References: <20080128220938.GH8767@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>, sds@tycho.nsa.gov,
	eparis@parisplace.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:19304 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754520AbYA1WXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 17:23:51 -0500
In-Reply-To: <20080128220938.GH8767@does.not.exist>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 28 January 2008 5:09:38 pm Adrian Bunk wrote:
> This patch fixes a double free (security_netlbl_sid_to_secattr()
> already calls netlbl_secattr_destroy() when it returns !0) introduced
> by commit 45c950e0f839fded922ebc0bfd59b1081cc71b70 and spotted by the
> Coverity checker.

Hi Adrian,

Thanks for finding this mistake, however, I'd rather see it fixed by 
removing the netlbl_secattr_destroy() call in 
security_netlbl_sid_to_secattr() as it really shouldn't be there 
anymore.  We moved the matching _init() call into 
selinux_netlbl_sock_setsid() and I'd like to see the _init() and 
_destroy() calls done in the same function.  I can push a revised patch 
for this if you would prefer, otherwise I'll be happy to ack an updated 
version ...

> Signed-off-by: Adrian Bunk <bunk@kernel.org>
>
> ---
> --- linux-2.6/security/selinux/netlabel.c.old	2008-01-23
> 00:38:19.000000000 +0200 +++
> linux-2.6/security/selinux/netlabel.c	2008-01-23 00:39:09.000000000
> +0200 @@ -58,22 +58,22 @@ static int selinux_netlbl_sock_setsid(st rc
> = security_netlbl_sid_to_secattr(sid, &secattr);
>  	if (rc != 0)
>  		goto sock_setsid_return;
>  	rc = netlbl_sock_setattr(sk, &secattr);
>  	if (rc == 0) {
>  		spin_lock_bh(&sksec->nlbl_lock);
>  		sksec->nlbl_state = NLBL_LABELED;
>  		spin_unlock_bh(&sksec->nlbl_lock);
>  	}
>
> -sock_setsid_return:
>  	netlbl_secattr_destroy(&secattr);
> +sock_setsid_return:
>  	return rc;
>  }
>
>  /**
>   * selinux_netlbl_cache_invalidate - Invalidate the NetLabel cache
>   *
>   * Description:
>   * Invalidate the NetLabel security attribute mapping cache.
>   *
>   */



-- 
paul moore
linux security @ hp
