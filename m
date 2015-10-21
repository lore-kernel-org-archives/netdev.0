From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Wed, 21 Oct 2015 06:29:44 -0700
Message-ID: <1445434184.22974.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151019095938.72ea48e6@xeon-e3>
	 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562594E1.8040403@oracle.com>
	 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56261092.7080003@oracle.com>
	 <1445347173.22974.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56264596.90104@oracle.com>
	 <1445355027.22974.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5626887D.5050308@oracle.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBBD206@AcuExch.aculab.com>
	 <56276DA2.8010905@oracle.com>
	 <1445426932.22974.43.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56278D3D.1010608@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33836 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbbJUN3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 09:29:46 -0400
Received: by padhk11 with SMTP id hk11so55315495pad.1
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 06:29:46 -0700 (PDT)
In-Reply-To: <56278D3D.1010608@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-10-21 at 14:03 +0100, Alan Burlison wrote:
> On 21/10/2015 12:28, Eric Dumazet wrote:
> 
> > This works for me. Please double check your programs
> 
> I have just done so, it works as you say for AF_INET sockets but if you 
> switch to AF_UNIX sockets it does the wrong thing in the way I described.
> 

Oh well. Please try the following :


diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 94f658235fb4..24dec8bb571d 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -328,7 +328,8 @@ found:
 
 static inline int unix_writable(struct sock *sk)
 {
-	return (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
+	return sk->sk_state != TCP_LISTEN &&
+	       (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
 }
 
 static void unix_write_space(struct sock *sk)
