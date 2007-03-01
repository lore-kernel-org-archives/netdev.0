From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8107] New: dev->header_cache_update has a
 random value
Date: Thu, 1 Mar 2007 14:34:17 -0800
Message-ID: <20070301143417.00b49e81.akpm@linux-foundation.org>
References: <200703011933.l21JX5hw018666@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, loveminix@yahoo.com.cn,
	khc@pm.waw.pl
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45463 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161044AbXCAWef (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 17:34:35 -0500
In-Reply-To: <200703011933.l21JX5hw018666@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Mar 2007 11:33:05 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8107
> 
>            Summary: dev->header_cache_update has a random value
>     Kernel Version: 2.6.20
>             Status: NEW
>           Severity: high
>              Owner: jgarzik@pobox.com
>          Submitter: loveminix@yahoo.com.cn
> 
> 
> Distribution: Kernel 2.6.20
> 
> Problem Description:
> 
> In struct net_device, there are two fields: hard_header_cache and 
> header_cache_update, both of which are function pointers. The third field, 
> hard_header, is also a function pointer. Whenever hard_header points to a valid 
> function, both hard_header_cache and header_cache_update should have a known 
> value, either NULL or a valid function pointer. However, in 
> drivers/net/wan/hdlc_cisco.c, in function static int cisco_ioctl(struct 
> net_device *dev, struct ifreq *ifr), where dev->hard_header is assigned a valid 
> function, and dev->hard_header_cache is assigned a known value (NULL), dev-
> >header_cache_update is not set to a known value:
> 
> dev->hard_start_xmit = hdlc->xmit;
>         dev->hard_header = cisco_hard_header;
>         dev->hard_header_cache = NULL;
>         dev->type = ARPHRD_CISCO;
>         dev->flags = IFF_POINTOPOINT | IFF_NOARP;
>         dev->addr_len = 0;
> 
> This may cause serious problems when dev->header_cache_update is invoked, 
> because it has an uninitialized value.
> 
> Steps to reproduce:
> 
> I found this suspicious spot with the help of a code-checking tool.
> 

Like this?



From: Andrew Morton <akpm@linux-foundation.org>

Fix http://bugzilla.kernel.org/show_bug.cgi?id=8107: we weren't initialising
the header_cache_update field.

Cc: Krzysztof Halasa <khc@pm.waw.pl>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/wan/hdlc_cisco.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN drivers/net/wan/hdlc_cisco.c~cisco_ioctl-initialise-header_cache_update drivers/net/wan/hdlc_cisco.c
--- a/drivers/net/wan/hdlc_cisco.c~cisco_ioctl-initialise-header_cache_update
+++ a/drivers/net/wan/hdlc_cisco.c
@@ -366,6 +366,7 @@ static int cisco_ioctl(struct net_device
 		dev->hard_start_xmit = hdlc->xmit;
 		dev->hard_header = cisco_hard_header;
 		dev->hard_header_cache = NULL;
+		dev->header_cache_update = NULL;
 		dev->type = ARPHRD_CISCO;
 		dev->flags = IFF_POINTOPOINT | IFF_NOARP;
 		dev->addr_len = 0;
_

