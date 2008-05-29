From: "Adam Langley" <agl@imperialviolet.org>
Subject: SACK + MD5 overflows TCP options space
Date: Wed, 28 May 2008 19:30:37 -0700
Message-ID: <396556a20805281930j4a4521d6r1720f50b02a77476@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:46504 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbYE2Cai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 22:30:38 -0400
Received: by rv-out-0506.google.com with SMTP id l9so3840347rvb.1
        for <netdev@vger.kernel.org>; Wed, 28 May 2008 19:30:37 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in tcp_output.c:tcp_transmit_skb we have:

ifdef CONFIG_TCP_MD5SIG
	/*
	 * Are we doing MD5 on this segment? If so - make
	 * room for it.
	 */
	md5 = tp->af_specific->md5_lookup(sk, sk);
	if (md5)
		tcp_header_size += TCPOLEN_MD5SIG_ALIGNED;
#endif

However, the SACK option can be at least 18 bytes long (I've not
checked the code here, I've just observed a packet go by with that
much SACK in it). With alignment padding, that's 20 bytes. Plus 12
bytes of timestamp option (aligned). Then, adding 18 bytes of MD5SIG
rolls the TCP header size over and we produce garbage, right?

I'm only asking because I've a patch which adds a similar option and,
when SACK kicks in, I'm getting TCP header sizes of 0 or 8 bytes. If
there's a solution to the MD5 case that I'm missing I'd love to use
it. (Otherwise, I've another bodge up my sleeves)


Cheers

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
