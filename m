From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: __inet_hash_connect port_offset parameter
Date: Wed, 27 May 2015 09:30:46 -0700
Message-ID: <1432744246.4060.406.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5565E202.8010202@gmail.com>
	 <1432743498.4060.399.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Crestez Dan Leonard <cdleonard@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:35379 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbbE0Qat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 12:30:49 -0400
Received: by igbyr2 with SMTP id yr2so89814623igb.0
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 09:30:48 -0700 (PDT)
In-Reply-To: <1432743498.4060.399.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-27 at 09:18 -0700, Eric Dumazet wrote:
> On Wed, 2015-05-27 at 18:25 +0300, Crestez Dan Leonard wrote:
> > Hello,
> > 
> > I'm confused about the port_offset parameter to __inet_hash_connect.
> > 
> > When allocating the local port for an outgoing TCP connection the port
> > search looks something like this:
> > 
> >     static u32 hint;
> >     u32 offset = hint + port_offset;
> > 
> >     inet_get_local_port_range(net, &low, &high);
> >     remaining = (high - low) + 1;
> > 
> >     for (i = 1; i <= remaining; i++) {
> >         port = low + (i + offset) % remaining;
> >         /* check port is free */
> > 
> > The port_offset is calculated for v4 and v6 based on a hash of src/dst
> > addresses, presumably in order to improve security.
> > 
> > I see a few issues with this:
> >  - The port_offset is calculated even if the local port was already
> > assigned via bind. This wastes a few cycles.
> 
> OK. Not a big deal I guess.

Patch for IPv4 would be :

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 185efef0f1251ba9d45fabb3ed51777a8be097a6..be4bac368b6bfb8a1eca429cce415da99adc5515 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -594,7 +594,11 @@ out:
 int inet_hash_connect(struct inet_timewait_death_row *death_row,
 		      struct sock *sk)
 {
-	return __inet_hash_connect(death_row, sk, inet_sk_port_offset(sk),
+	u32 port_offset = 0;
+
+	if (!inet_sk(sk)->inet_num)
+		port_offset = inet_sk_port_offset(sk);
+	return __inet_hash_connect(death_row, sk, port_offset,
 				   __inet_check_established);
 }
 EXPORT_SYMBOL_GPL(inet_hash_connect);
