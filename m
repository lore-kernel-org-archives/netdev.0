From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] tiny af_packet.c cleanup
Date: Sat, 13 Sep 2003 09:35:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030913093559.A23840@electric-eye.fr.zoreil.com>
References: <20030913055033.GB94744@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
Content-Disposition: inline
In-Reply-To: <20030913055033.GB94744@gaz.sfgoth.com>; from mitch@sfgoth.com on Fri, Sep 12, 2003 at 10:50:33PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mitchell Blank Jr <mitch@sfgoth.com> :
[...]
> --- linux-2.6.0-test5-VIRGIN/net/packet/af_packet.c	2003-09-08 12:39:53.000000000 -0700
> +++ linux-2.6.0-test5mnb1/net/packet/af_packet.c	2003-09-12 13:28:53.857179768 -0700
> @@ -433,9 +433,9 @@
>  		struct sk_filter *filter;
>  
>  		bh_lock_sock(sk);
> -		if ((filter = sk->sk_filter) != NULL)
> -			res = sk_run_filter(skb, sk->sk_filter->insns,
> -					    sk->sk_filter->len);
> +		filter = sk->sk_filter;
> +		if (likely(filter != NULL))	/* re-check under lock */
> +			res = sk_run_filter(skb, filter->insns, filter->len);

1 - pointers tests against NULL are naturally supposed "unlikely" by gcc.
2 - I am not completely convinced that the "/* re-check under lock */" 
    comment is really useful either: the lock statement is on the line before.

Make it more spartan:

--- linux-2.6.0-test5-VIRGIN/net/packet/af_packet.c	2003-09-08 12:39:53.000000000 -0700
+++ linux-2.6.0-test5mnb1/net/packet/af_packet.c	2003-09-12 13:28:53.857179768 -0700
@@ -433,9 +433,9 @@
 		struct sk_filter *filter;
 
 		bh_lock_sock(sk);
-		if ((filter = sk->sk_filter) != NULL)
-			res = sk_run_filter(skb, sk->sk_filter->insns,
-					    sk->sk_filter->len);
+		filter = sk->sk_filter;
+		if (filter)
+			res = sk_run_filter(skb, filter->insns, filter->len);
 		bh_unlock_sock(sk);
 
 		if (res == 0)
@@ -537,9 +537,9 @@
 		struct sk_filter *filter;
 
 		bh_lock_sock(sk);
-		if ((filter = sk->sk_filter) != NULL)
-			res = sk_run_filter(skb, sk->sk_filter->insns,
-					    sk->sk_filter->len);
+		filter = sk->sk_filter;
+		if (filter)
+			res = sk_run_filter(skb, filter->insns, filter->len);
 		bh_unlock_sock(sk);
 
 		if (res == 0)
