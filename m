From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next 1/3] net: Fix skb_copy_datagram_from_iovec() to
 pass the right offset
Date: Fri, 05 Jun 2009 12:35:40 -0700
Message-ID: <1244230540.1526.76.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:47366 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751699AbZFETfl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2009 15:35:41 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n55JP7YK029478
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 15:25:07 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n55JZhA3177828
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 15:35:43 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n55JZg7n028681
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 15:35:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am working on enabling UFO between KVM guests using virtio-net and i have 
some patches that i got working with 2.6.30-rc8. When i wanted to try them
with net-next-2.6, i noticed that virtio-net is not working with that tree.

After some debugging, it turned out to be several bugs in the recent patches
to fix aio with tun driver, specifically the following 2 commits.

http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=0a1ec07a67bd8b0033dace237249654d015efa21
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=6f26c9a7555e5bcca3560919db9b852015077dae


Fix the call to memcpy_from_iovecend() in skb_copy_datagram_from_iovec
to pass the right iovec offset.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/net/core/datagram.c b/net/core/datagram.c
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -466,7 +466,8 @@ int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
 	if (copy > 0) {
 		if (copy > len)
 			copy = len;
-		if (memcpy_fromiovecend(skb->data + offset, from, 0, copy))
+		if (memcpy_fromiovecend(skb->data + offset, from, from_offset,
+					copy))
 			goto fault;
 		if ((len -= copy) == 0)
 			return 0;


