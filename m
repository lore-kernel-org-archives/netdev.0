From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Mon, 8 Sep 2008 12:21:16 +0200
Message-ID: <7e0dd21a0809080321p6b9e2bc7m73e2cdd57a8d58b8@mail.gmail.com>
References: <20080905131618.GB12246@2ka.mipt.ru>
	 <20080905133748.GA28656@2ka.mipt.ru>
	 <7e0dd21a0809050655n176ec32bo2bf4febe4e0fc363@mail.gmail.com>
	 <20080905141911.GA16586@2ka.mipt.ru>
	 <7e0dd21a0809050745w692328b7v6dd4e0adf59e9535@mail.gmail.com>
	 <20080905145902.GA12762@2ka.mipt.ru>
	 <7e0dd21a0809050830o7c1dcc2do68da5df9900fcfe8@mail.gmail.com>
	 <20080905153811.GA3596@2ka.mipt.ru>
	 <7e0dd21a0809050901q23d0b16xa1a9d0df2f36f6d8@mail.gmail.com>
	 <20080905163446.GB10078@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:33420 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbYIHKVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 06:21:17 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1390906rvb.1
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 03:21:16 -0700 (PDT)
In-Reply-To: <20080905163446.GB10078@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

I've made a test with below patch (with and without UDP fragmentation):

without UDP fragmentation, packet size are almost always equal to
PAGE_SIZE due to my mtu limit (2*PACKET_SIZE > mtu).
with UDP fragmentation, kernel is sending multiple fragmented packets
of 61448Kbytes.

Unfortunately, in both case, bitrate is still 15-20 MB/s :(
According to wireshark, kernel sends 60KB over 9 packets, nothing
during ~5ms, 60KB and so on. strange ... kernel seems to spend its
time during push(). Is there a blocking call somewhere ?

Thanks in advance,
Johann

--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c

@@ -743,7 +743,28 @@ int udp_sendpage(struct sock *sk, struct page
*page, int offset,
                 size_t size, int flags)
 {
        struct udp_sock *up = udp_sk(sk);
+       struct inet_sock *inet = inet_sk(sk);
        int ret;
+       int mtu = inet->cork.fragsize;
+       int fragheaderlen;
+       struct ip_options *opt = NULL;
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
+               lock_sock(sk);
+               ret = udp_push_pending_frames(sk);
+               release_sock(sk);
+               if (ret) {
+                       return 0;
+               }
+       }





-- 
Johann Baudy
johaahn@gmail.com
