From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Mon, 24 Jul 2006 11:54:15 -0700
Message-ID: <20060724115415.7cc7acc6@dxpl.pdx.osdl.net>
References: <20060718081625.GA13830@2ka.mipt.ru>
	<20060718230121.GA31474@ms2.inr.ac.ru>
	<20060719155204.0de8882b@localhost.localdomain>
	<20060719.130150.39158599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20196 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932295AbWGXTAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 15:00:54 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060719.130150.39158599.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Jul 2006 13:01:50 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Wed, 19 Jul 2006 15:52:04 -0400
> 
> > As a related note, I am looking into fixing inet hash tables to use RCU.
> 
> IBM had posted a patch a long time ago, which would be not
> so hard to munge into the current tree.  See if you can
> spot it in the archives :)

Srivatsa Vaddagiri from IBM did  patch: http://lkml.org/lkml/2004/8/31/129

And Ben had a patch: http://lwn.net/Articles/174596/

Srivata's was more complete but pre-dates Acme's rearrangement.
Also, there is some code for refcnt's in it that looks wrong.
Or at minimum is masking underlying design flaws.

/* Ungrab socket and destroy it, if it was the last reference. */
 static inline void sock_put(struct sock *sk)
 {
-	if (atomic_dec_and_test(&sk->sk_refcnt))
-		sk_free(sk);
+sp_loop:
+	if (atomic_dec_and_test(&sk->sk_refcnt)) {
+		/* Restore ref count and schedule callback.
+		 * If we don't restore ref count, then the callback can be
+		 * scheduled by more than one CPU.
+		 */
+		atomic_inc(&sk->sk_refcnt);
+
+		if (atomic_read(&sk->sk_refcnt) == 1)
+			call_rcu(&sk->sk_rcu, sk_free_rcu);
+		else
+			goto sp_loop;
+	}
 }

Ben's still left reader writer locks, and needed IPV6 work. He said he
plans to get back to it.


-- 
Stephen Hemminger <shemminger@osdl.org>
"And in the Packet there writ down that doome"
