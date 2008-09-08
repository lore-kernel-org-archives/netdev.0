From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Mon, 8 Sep 2008 15:26:29 +0400
Message-ID: <20080908112629.GA26488@2ka.mipt.ru>
References: <20080905133748.GA28656@2ka.mipt.ru> <7e0dd21a0809050655n176ec32bo2bf4febe4e0fc363@mail.gmail.com> <20080905141911.GA16586@2ka.mipt.ru> <7e0dd21a0809050745w692328b7v6dd4e0adf59e9535@mail.gmail.com> <20080905145902.GA12762@2ka.mipt.ru> <7e0dd21a0809050830o7c1dcc2do68da5df9900fcfe8@mail.gmail.com> <20080905153811.GA3596@2ka.mipt.ru> <7e0dd21a0809050901q23d0b16xa1a9d0df2f36f6d8@mail.gmail.com> <20080905163446.GB10078@2ka.mipt.ru> <7e0dd21a0809080321p6b9e2bc7m73e2cdd57a8d58b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:47318 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753556AbYIHL1A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 07:27:00 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809080321p6b9e2bc7m73e2cdd57a8d58b8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann.

On Mon, Sep 08, 2008 at 12:21:16PM +0200, Johann Baudy (johaahn@gmail.com) wrote:
> I've made a test with below patch (with and without UDP fragmentation):
> 
> without UDP fragmentation, packet size are almost always equal to
> PAGE_SIZE due to my mtu limit (2*PACKET_SIZE > mtu).
> with UDP fragmentation, kernel is sending multiple fragmented packets
> of 61448Kbytes.
> 
> Unfortunately, in both case, bitrate is still 15-20 MB/s :(
> According to wireshark, kernel sends 60KB over 9 packets, nothing
> during ~5ms, 60KB and so on. strange ... kernel seems to spend its
> time during push(). Is there a blocking call somewhere ?

Are you sure that it is udp_push_pending_frames() and not some splice
waiting?

> Thanks in advance,
> Johann
> 
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> 
> @@ -743,7 +743,28 @@ int udp_sendpage(struct sock *sk, struct page
> *page, int offset,
>                  size_t size, int flags)
>  {
>         struct udp_sock *up = udp_sk(sk);
> +       struct inet_sock *inet = inet_sk(sk);
>         int ret;
> +       int mtu = inet->cork.fragsize;
> +       int fragheaderlen;
> +       struct ip_options *opt = NULL;
> +
> +       if (inet->cork.flags & IPCORK_OPT)
> +               opt = inet->cork.opt;

This has to be checked under socket lock.

> +       fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
> +
> +       // With UDP fragmentation
> +       if (inet->cork.length + size >= 0xFFFF - fragheaderlen) {
> +       // Without UDP fragmentation
> +       //  if( (inet->cork.length + size) > mtu) {

This also should be protected. Two threads can simultaneously check
inet->cork.length and both suceed.

> +               lock_sock(sk);
> +               ret = udp_push_pending_frames(sk);
> +               release_sock(sk);
> +               if (ret) {
> +                       return 0;
> +               }
> +       }

-- 
	Evgeniy Polyakov
