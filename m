From: Ashwin Rao <ashwin.shirvanthe@gmail.com>
Subject: Restricting payload size in do_tcp_sendpages.
Date: Thu, 1 Mar 2012 16:16:40 +0100
Message-ID: <CAJNbMryYORXmp0CPhL9zt8ne5P5yOKvNLsqnjeNwb4m0OAQeiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:47968 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758115Ab2CAPQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 10:16:41 -0500
Received: by ggnh1 with SMTP id h1so258175ggn.19
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2012 07:16:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like to perform some experiments where I want TCP to send
packets of size less than the MSS even more than an MSS worth of data
is available in the TCP buffers.  I am performing these experiments to
submit a patch that can avoid synchronization of TCP flows. I have
modified the following code in the function do_tcp_sendpages in the
file net/ipv4/tcp.c.  For testing purposes I have currently set the
mss_now to half of the value that would have been typically used. I
have even updated the size_goal which controls the maximum size that
can be sent when offloading is enabled. To avoid coalescing smaller
skbs I have even set the can_coalesce to 0. Despite these changes the
frames sent over the Ethernet have the length of 1514 bytes. I would
like to know which function is responsible for coalescing these
packets despite forcing a small segment size.

*** linux-3.2.6/net/ipv4/tcp.c	
--- linux-3.2.6-modified/net/ipv4/tcp.c
*************** static ssize_t do_tcp_sendpages(struct s
*** 774,779 ****
--- 774,783 ----
  	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);

  	mss_now = tcp_send_mss(sk, &size_goal, flags);
+     /* hack begin */
+     mss_now = mss_now >> 1;
+     size_goal = mss_now;
+     /* hack end */
  	copied = 0;

  	err = -EPIPE;
*************** new_segment:
*** 805,810 ****
--- 809,817 ----

  		i = skb_shinfo(skb)->nr_frags;
  		can_coalesce = skb_can_coalesce(skb, i, page, offset);
+             /* hack begin */
+             can_coalesce = 0;
+             /* hack end */
  		if (!can_coalesce && i >= MAX_SKB_FRAGS) {
  			tcp_mark_push(tp, skb);
  			goto new_segment;
*************** wait_for_memory:
*** 857,862 ****
--- 864,873 ----
  			goto do_error;

  		mss_now = tcp_send_mss(sk, &size_goal, flags);
+             /* hack begin */
+             mss_now = mss_now >> 1;
+             size_goal = mss_now;
+             /* hack end */
  	}


Regards,
Ashwin
