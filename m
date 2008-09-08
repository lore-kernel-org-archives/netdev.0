From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Mon, 8 Sep 2008 15:01:04 +0200
Message-ID: <7e0dd21a0809080601lc250197wde17733522d03125@mail.gmail.com>
References: <20080905133748.GA28656@2ka.mipt.ru>
	 <20080905141911.GA16586@2ka.mipt.ru>
	 <7e0dd21a0809050745w692328b7v6dd4e0adf59e9535@mail.gmail.com>
	 <20080905145902.GA12762@2ka.mipt.ru>
	 <7e0dd21a0809050830o7c1dcc2do68da5df9900fcfe8@mail.gmail.com>
	 <20080905153811.GA3596@2ka.mipt.ru>
	 <7e0dd21a0809050901q23d0b16xa1a9d0df2f36f6d8@mail.gmail.com>
	 <20080905163446.GB10078@2ka.mipt.ru>
	 <7e0dd21a0809080321p6b9e2bc7m73e2cdd57a8d58b8@mail.gmail.com>
	 <20080908112629.GA26488@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:47202 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755AbYIHNBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 09:01:05 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1439850rvb.1
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 06:01:04 -0700 (PDT)
In-Reply-To: <20080908112629.GA26488@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

> Are you sure that it is udp_push_pending_frames() and not some splice
> waiting?
>
No, I'm not sure.
Are there any queue or allocator limits that can slow the bitrate
through this function?
I mean something that will need end of transfer to start a new one.

--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -743,7 +743,29 @@ int udp_sendpage(struct sock *sk, struct page
*page, int offset,
                 size_t size, int flags)
 {
        struct udp_sock *up = udp_sk(sk);
+       struct inet_sock *inet = inet_sk(sk);
        int ret;
+       int mtu, fragheaderlen;
+       struct ip_options *opt = NULL;
+
+       lock_sock(sk);
+       mtu = inet->cork.fragsize;
+
+       if (inet->cork.flags & IPCORK_OPT)
+               opt = inet->cork.opt;
+
+       fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
+
+       // With UDP fragmentation
+       if (inet->cork.length + size >= 0xFFFF - fragheaderlen) {
+       // Without UDP fragmentation
+       //  if( (inet->cork.length + size) > mtu) {
+               ret = udp_push_pending_frames(sk);
+               if (ret) {
+                       return 0;
+               }
+       }
+       release_sock(sk);

        if (!up->pending) {
                struct msghdr msg = {   .msg_flags = flags|MSG_MORE };

Please find above, patch with your rectifications.
Do we must use MTU limit instead offset limit? As you said that UDP
split over IP must be avoided.
If yes, can I force size value forwarded to ip_append_page() in order
to fill the whole packet? Or this will not be handled properly by all
callers?

Thanks in advance,
Johann


-- 
Johann Baudy
johaahn@gmail.com
