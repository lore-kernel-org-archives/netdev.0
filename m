From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [v2] Re: [RFC] l2tp/ipv6: support for L2TPv2 over UDP over IPv6
Date: Tue, 10 Apr 2012 19:40:52 -0400
Message-ID: <20120410234052.GG24092@kvack.org>
References: <20120214223112.GB6806@kvack.org> <1329282410.2555.31.camel@edumazet-laptop> <4F3B6C26.4090701@katalix.com> <4F632FB6.9010206@katalix.com> <20120319032807.GD11293@kvack.org> <4F840FCB.9050504@katalix.com> <20120410184916.GE24092@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:46716 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755909Ab2DJXkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 19:40:53 -0400
Content-Disposition: inline
In-Reply-To: <20120410184916.GE24092@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 10, 2012 at 02:49:16PM -0400, Benjamin LaHaise wrote:
...
> Also, I found a bug in OpenL2TPd (1.8 I think): certain types of AVPs are 
> not accepted if they are hidden, despite the fact that RFC 2661 permits 
> hiding these AVPs.  The AVPs in question are: Assigned Tunnel ID, Challege, 
> Challenge Response and Assigned Session ID.

Here's the fix for OpenL2TPd 1.8.  The use-after-realloc() in l2tp_avp_hide() 
doesn't always work if the memory gets moved and glibc scribbles on 
orig_buffer.  There's also an interesting typo in l2tp_avp_message_decode().

		-ben

-- 
"Thought is the essence of where you are now."


--- openl2tp-1.8/l2tp_avp.c.xxx	2008-05-08 15:05:26.000000000 -0400
+++ openl2tp-1.8/l2tp_avp.c	2012-04-10 18:07:05.866208480 -0400
@@ -535,16 +535,18 @@ static int l2tp_avp_hide(void **buffer, 
 	 * and we just need to shift the data up 2 bytes.
 	 */
 	new_buffer_len = orig_buffer_len + 2 + pad + 16;
-	new_buffer = realloc(orig_buffer, new_buffer_len + L2TP_AVP_HEADER_LEN);
+	new_buffer = malloc(new_buffer_len + L2TP_AVP_HEADER_LEN);
 	if (new_buffer == NULL) {
 		return -ENOMEM;
 	}
-	memmove(new_buffer + L2TP_AVP_HEADER_LEN + 2, orig_buffer + L2TP_AVP_HEADER_LEN, orig_buffer_len - L2TP_AVP_HEADER_LEN);
+	memcpy(new_buffer, orig_buffer, L2TP_AVP_HEADER_LEN);
+	memcpy(new_buffer + L2TP_AVP_HEADER_LEN + 2, orig_buffer + L2TP_AVP_HEADER_LEN, orig_buffer_len - L2TP_AVP_HEADER_LEN);
 	orig_len = new_buffer + L2TP_AVP_HEADER_LEN;
 	*orig_len = htons(orig_buffer_len - L2TP_AVP_HEADER_LEN);
 	if (new_buffer != orig_buffer) {
 		*buffer = new_buffer;
 	}
+	free(orig_buffer);
 	flag_len = new_buffer;
 	tmp = ntohs(*flag_len);
 	*flag_len = htons(tmp + 2 + pad);
@@ -1995,7 +1997,7 @@ int l2tp_avp_message_decode(int msg_len,
 				result = l2tp_avp_unhide(avp, &unhidden_avp_len, 
 							 (unsigned char *const) secret, secret_len,
 							 (unsigned char *const) data[TYPE(RANDOM_VECTOR)].value, 
-							 data[TYPE(RANDOM_VECTOR].value_len));
+							 data[TYPE(RANDOM_VECTOR)].value_len);
 				if (result < 0) {
 					l2tp_tunnel_log(tunnel, L2TP_AVPHIDE, LOG_ERR, "AVPHIDE: tunl %hu: avp unhide error: %s", 
 							l2tp_tunnel_id(tunnel), l2tp_strerror(-result));
