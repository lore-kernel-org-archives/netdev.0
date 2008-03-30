From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [AX25] kernel panic
Date: Sun, 30 Mar 2008 11:16:36 +0200
Message-ID: <20080330091636.GA2847@ami.dom.local>
References: <47E2EC1B.9070405@free.fr> <20080322113620.GA3213@ami.dom.local> <47E68CA1.2040904@free.fr> <20080324205104.GA3721@ami.dom.local> <47E8FCE2.6000308@free.fr> <20080326183538.GA14266@ami.dom.local> <20080328120721.GA11060@ami.dom.local> <47EE3040.3050208@free.fr> <20080329122452.GB3407@ami.dom.local> <47EF529B.8060108@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Bernard Pidoux <bpidoux@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:62331 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbYC3JMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2008 05:12:33 -0400
Received: by ug-out-1314.google.com with SMTP id z38so254874ugc.16
        for <netdev@vger.kernel.org>; Sun, 30 Mar 2008 02:12:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47EF529B.8060108@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 30, 2008 at 10:43:07AM +0200, Bernard Pidoux wrote:
> Hi Jarek,

Hi Bernard,
>
> please find attached another collection of data from  
> /var/log/kernel/info.log that I bziped for it is rather large.

Thanks again. It looks like ROSE sockets aren't released properly.
Here is a try to fix this. Could you test it with all previous patches
present?

Regards,
Jarek P.

(patch #5)
---

diff -Nurp 2.6.24.4-/net/rose/af_rose.c 2.6.24.4+/net/rose/af_rose.c
--- 2.6.24.4-/net/rose/af_rose.c	2008-01-24 23:58:37.000000000 +0100
+++ 2.6.24.4+/net/rose/af_rose.c	2008-03-30 10:53:19.000000000 +0200
@@ -599,17 +599,24 @@ static int rose_release(struct socket *s
 
 	if (sk == NULL) return 0;
 
+	sock_hold(sk);
+	sock_orphan(sk);
+	lock_sock(sk);
 	rose = rose_sk(sk);
 
 	switch (rose->state) {
 	case ROSE_STATE_0:
+		release_sock(sk);
 		rose_disconnect(sk, 0, -1, -1);
+		lock_sock(sk);
 		rose_destroy_socket(sk);
 		break;
 
 	case ROSE_STATE_2:
 		rose->neighbour->use--;
+		release_sock(sk);
 		rose_disconnect(sk, 0, -1, -1);
+		lock_sock(sk);
 		rose_destroy_socket(sk);
 		break;
 
@@ -634,6 +641,8 @@ static int rose_release(struct socket *s
 	}
 
 	sock->sk = NULL;
+	release_sock(sk);
+	sock_put(sk);
 
 	return 0;
 }
