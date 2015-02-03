From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Mon, 02 Feb 2015 17:18:50 -0800
Message-ID: <1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	 <1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	 <1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	 <1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	eyalpe-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422903136.21689.114.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-02-02 at 10:52 -0800, Eric Dumazet wrote:

> It seems to break ACK clocking badly (linux stack has a somewhat buggy
> tcp_tso_should_defer(), which relies on ACK being received smoothly, as
> no timer is setup to split the TSO packet.)

Following patch might help the TSO split defer logic.

It would avoid setting the TSO defer 'pseudo timer' twice, if/when TCP
Small Queue logic prevented the xmit at the expiration of first 'timer'.

This patch clears the tso_deferred variable only if we could really
send something.

Please try it, thanks !


diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 65caf8b95e17..e735f38557db 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1821,7 +1821,6 @@ static bool tcp_tso_should_defer(struct sock *sk,
struct sk_buff *skb,
 	return true;
 
 send_now:
-	tp->tso_deferred = 0;
 	return false;
 }
 
@@ -2070,6 +2069,7 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,
 		if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
 			break;
 
+		tp->tso_deferred = 0;
 repair:
 		/* Advance the send_head.  This one is sent out.
 		 * This call will increment packets_out.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
