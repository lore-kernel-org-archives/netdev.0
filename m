From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] acess_ok() missing from zerocopy_sg_from_iovec()
Date: Mon, 03 Jun 2013 18:06:09 -0700
Message-ID: <1370307969.24311.196.camel@edumazet-glaptop>
References: <1370306052.24311.193.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33296 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758548Ab3FDBGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 21:06:12 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa11so40904pad.5
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 18:06:11 -0700 (PDT)
In-Reply-To: <1370306052.24311.193.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 17:34 -0700, Eric Dumazet wrote:
> It looks like access_ok(VERIFY_READ, base, len) checks are missing in
> drivers/net/tun.c & drivers/net/macvtap.c before the
> get_user_pages_fast() calls.
> 
> Or am I missing something ?
> 

Patch would be :

[PATCH] tun/macvtap: use access_ok(VERIFY_READ)

Zero copy is good if only we make all needed security checks.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 59e9605..d793b7d 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -522,6 +522,8 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
 		if (i + size > MAX_SKB_FRAGS)
 			return -EMSGSIZE;
+		if (!access_ok(VERIFY_READ, base, len))
+			return -EFAULT;
 		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
 		if (num_pages != size) {
 			for (i = 0; i < num_pages; i++)
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 89776c5..7a7b3b1 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1008,6 +1008,8 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
 		if (i + size > MAX_SKB_FRAGS)
 			return -EMSGSIZE;
+		if (!access_ok(VERIFY_READ, base, len))
+			return -EFAULT;
 		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
 		if (num_pages != size) {
 			for (i = 0; i < num_pages; i++)
