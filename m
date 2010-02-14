From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ipcomp: double free at ipcomp_destroy()
Date: Sun, 14 Feb 2010 16:44:15 +0200
Message-ID: <20100214144415.GA8115@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:44633 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819Ab0BNOo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 09:44:29 -0500
Received: by fg-out-1718.google.com with SMTP id 16so141595fgg.1
        for <netdev@vger.kernel.org>; Sun, 14 Feb 2010 06:44:27 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consider using ipcomp with tunnel mode:

	pfkey_add -> xfrm_state_init -> x->type->init_state() == ipcomp4_init_state

1. If ipcomp_tunnel_attach() fails, xfrm_state private data (x->data) are freed
   first time (synchronously), but stale pointer is left.
2. xfrm_state_init() failed, all right, we're going to do error unwind
   but this time asynchronously and we're going to double free x->data
   asynchronously.

Fix by clearing x->data pointer, so second time it'll be fine.

Note, second time can happen in quite arbitrary time, double free
messages were seen in completely irrelevant functions, e. g. 

	INFO: Allocated in icmp_sk_init
	INFO: Freed in icmp_sk_exit

	[<ffffffff810b5ceb>] kfree+0xab/0x140
	[<ffffffff810719ae>] free_sect_attrs	(!)
	[<ffffffff81072353>] free_module

The only common thing was kmalloc-16 cache.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/xfrm/xfrm_ipcomp.c |    1 +
 1 file changed, 1 insertion(+)

--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -332,6 +332,7 @@ void ipcomp_destroy(struct xfrm_state *x)
 	ipcomp_free_data(ipcd);
 	mutex_unlock(&ipcomp_resource_mutex);
 	kfree(ipcd);
+	x->data = NULL;
 }
 EXPORT_SYMBOL_GPL(ipcomp_destroy);
 
