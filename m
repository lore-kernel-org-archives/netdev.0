From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] Fix bug of update IPv4 PMTU when received ICMP Fragmentation
 Needed message
Date: Mon, 04 Jun 2007 08:39:21 +0800
Message-ID: <46635F39.2090009@cn.fujitsu.com>
References: <E1HuRAd-0002Wl-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:49451 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750715AbXFDApd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2007 20:45:33 -0400
In-Reply-To: <E1HuRAd-0002Wl-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> When received ICMP Fragmentation Needed message, PATH MTU is always set 
>> to the 576 even if MTU in ICMP message is lager then 576. This is 
>> because of error condition in function ip_rt_frag_needed(), now if 
>> packet size of that ICMP message is less then new MTU, packet size will 
>> be used ,but RFC says ICMP error message return as much as we can 
>> without exceeding 576 bytes.
>>
>> This patch has Fixed this BUG.
>>
>>     
>
> Huh? The test new_mtu >= old_mtu should only hold if the sending router
> is buggy which is what the hack is for.
>
> Cheers,
>   
Note here old_mtu is not the real old mtu, is the received message's size:
  unsigned short old_mtu = ntohs(iph->tot_len);
So maybe the patch would like following.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- net/ipv4/route.c.orig	2007-05-25 05:22:47.000000000 +0800
+++ net/ipv4/route.c	2007-06-04 08:31:36.000000000 +0800
@@ -1424,7 +1424,7 @@ unsigned short ip_rt_frag_needed(struct 
 			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU))) {
 				unsigned short mtu = new_mtu;
 
-				if (new_mtu < 68 || new_mtu >= old_mtu) {
+				if (new_mtu < 68 || new_mtu >= rth->u.dst.metrics[RTAX_MTU-1]) {
 
 					/* BSD 4.2 compatibility hack :-( */
 					if (mtu == 0 &&


