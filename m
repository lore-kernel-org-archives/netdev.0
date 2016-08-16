From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: Linux tcp_xmit_retransmit_queue use after free on 4.8-rc1 /
 master]
Date: Tue, 16 Aug 2016 11:39:08 -0700
Message-ID: <1471372748.4943.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160816104551.GA28052@kroah.com>
	 <1471361940.4943.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Marco Grassi <marco.gra@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36518 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbcHPSjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 14:39:10 -0400
Received: by mail-pf0-f194.google.com with SMTP id y134so5869590pfg.3
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 11:39:10 -0700 (PDT)
In-Reply-To: <1471361940.4943.4.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-16 at 08:39 -0700, Eric Dumazet wrote:
> On Tue, 2016-08-16 at 12:45 +0200, Greg KH wrote:
> > For some reason Marco's emails can't make it to netdev, so I'm
> > forwarding this on.  Please cc: him on responses.
> 
> Thanks for the report Greg and Marco.
> 
> My first guess is this is caused by 
> 
> d41a69f1d390 tcp: make tcp_sendmsg() aware of socket backlog
> 
> And a combination of funky sendmsg() flags (like FastOpen)
> 
> I will look at this problem today.
> 

No, above commit was innocent ;)

It looks like the bug is very old, and following patch would fix it.
I will submit it formally after few tests.


diff --git a/include/net/tcp.h b/include/net/tcp.h
index c00e7d51bb18..7717302cab91 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1523,6 +1523,8 @@ static inline void tcp_check_send_head(struct sock *sk, struct sk_buff *skb_unli
 {
 	if (sk->sk_send_head == skb_unlinked)
 		sk->sk_send_head = NULL;
+	if (tcp_sk(sk)->highest_sack == skb_unlinked)
+		tcp_sk(sk)->highest_sack = NULL;
 }
 
 static inline void tcp_init_send_head(struct sock *sk)
