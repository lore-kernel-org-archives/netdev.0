From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v6 5/7 RFC] TCPCT part 1e: implement socket
 option TCP_COOKIE_TRANSACTIONS
Date: Wed, 18 Nov 2009 10:03:58 -0500
Message-ID: <4B040CDE.6030507@gmail.com>
References: <4AFCDA9E.8050003@gmail.com> <4AFCEA59.3060707@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040703060204040700020100"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f226.google.com ([209.85.217.226]:60045 "EHLO
	mail-gx0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303AbZKRPD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 10:03:56 -0500
Received: by gxk26 with SMTP id 26so1077861gxk.1
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2009 07:04:02 -0800 (PST)
In-Reply-To: <4AFCEA59.3060707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040703060204040700020100
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

William Allen Simpson wrote:
> Provide per socket control of the TCP cookie option and SYN/SYNACK data.
> 
> This is a straightforward re-implementation of an earlier (year-old)
> patch that no longer applies cleanly, with permission of the original
> author (Adam Langley):
> 
>    http://thread.gmane.org/gmane.linux.network/102586
> 
> The principle difference is using a TCP option to carry the cookie nonce,
> instead of a user configured offset in the data.
> 
> Allocations have been rearranged to avoid requiring GFP_ATOMIC.
> 
> Requires:
>   net: TCP_MSS_DEFAULT, TCP_MSS_DESIRED
>   TCPCT part 1c: sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS
>   TCPCT part 1d: define TCP cookie option, extend existing struct's
> 
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>  net/ipv4/tcp.c |  133 
> +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 131 insertions(+), 2 deletions(-)
> 
Although we've had one comment, explaining that the future documentation
will be sent to another email list, there are still no technical comments.

Same patch as before.  Seeking Acks.

--------------040703060204040700020100
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1e6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1e6.patch"

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3ae01bf..3424499 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2079,8 +2079,9 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	int val;
 	int err = 0;
 
-	/* This is a string value all the others are int's */
-	if (optname == TCP_CONGESTION) {
+	/* These are data/string values, all the others are ints */
+	switch (optname) {
+	case TCP_CONGESTION: {
 		char name[TCP_CA_NAME_MAX];
 
 		if (optlen < 1)
@@ -2097,6 +2098,93 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		release_sock(sk);
 		return err;
 	}
+	case TCP_COOKIE_TRANSACTIONS: {
+		struct tcp_cookie_transactions ctd;
+		struct tcp_cookie_values *cvp = NULL;
+
+		if (sizeof(ctd) > optlen)
+			return -EINVAL;
+		if (copy_from_user(&ctd, optval, sizeof(ctd)))
+			return -EFAULT;
+
+		if (ctd.tcpct_used > sizeof(ctd.tcpct_value)
+		 || ctd.tcpct_s_data_desired > TCP_MSS_DESIRED)
+			return -EINVAL;
+
+		if (ctd.tcpct_cookie_desired == 0) {
+			/* default to global value */
+		} else if ((0x1 & ctd.tcpct_cookie_desired)
+			|| ctd.tcpct_cookie_desired > TCP_COOKIE_MAX
+			|| ctd.tcpct_cookie_desired < TCP_COOKIE_MIN) {
+			return -EINVAL;
+		}
+
+		if (TCP_COOKIE_OUT_NEVER & ctd.tcpct_flags) {
+			/* Supercedes all other values */
+			lock_sock(sk);
+			if (tp->cookie_values != NULL) {
+				kref_put(&tp->cookie_values->kref,
+					 tcp_cookie_values_release);
+				tp->cookie_values = NULL;
+			}
+			tp->rx_opt.cookie_in_always = 0; /* false */
+			tp->rx_opt.cookie_out_never = 1; /* true */
+			release_sock(sk);
+			return err;
+		}
+
+		/* Allocate ancillary memory before locking.
+		 */
+		if (ctd.tcpct_used > 0
+		 || (tp->cookie_values == NULL
+		  && (sysctl_tcp_cookie_size > 0
+		   || ctd.tcpct_cookie_desired > 0
+		   || ctd.tcpct_s_data_desired > 0))) {
+			cvp = kzalloc(sizeof(*cvp) + ctd.tcpct_used,
+				      GFP_KERNEL);
+			if (cvp == NULL)
+				return -ENOMEM;
+		}
+		lock_sock(sk);
+		tp->rx_opt.cookie_in_always =
+			(TCP_COOKIE_IN_ALWAYS & ctd.tcpct_flags);
+		tp->rx_opt.cookie_out_never = 0; /* false */
+
+		if (tp->cookie_values != NULL) {
+			if (cvp != NULL) {
+				/* Changed values are recorded by a changed
+				 * pointer, ensuring the cookie will differ,
+				 * without separately hashing each value later.
+				 */
+				kref_put(&tp->cookie_values->kref,
+					 tcp_cookie_values_release);
+				kref_init(&cvp->kref);
+				tp->cookie_values = cvp;
+			} else {
+				cvp = tp->cookie_values;
+			}
+		}
+		if (cvp != NULL) {
+			cvp->cookie_desired = ctd.tcpct_cookie_desired;
+
+			if (ctd.tcpct_used > 0) {
+				memcpy(cvp->s_data_payload, ctd.tcpct_value,
+				       ctd.tcpct_used);
+				cvp->s_data_desired = ctd.tcpct_used;
+				cvp->s_data_constant = 1; /* true */
+			} else {
+				/* No constant payload data. */
+				cvp->s_data_desired = ctd.tcpct_s_data_desired;
+				cvp->s_data_constant = 0; /* false */
+			}
+		}
+		release_sock(sk);
+		return err;
+	}
+	default:
+		/* fallthru */
+		break;
+	};
 
 	if (optlen < sizeof(int))
 		return -EINVAL;
@@ -2421,6 +2509,47 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		if (copy_to_user(optval, icsk->icsk_ca_ops->name, len))
 			return -EFAULT;
 		return 0;
+
+	case TCP_COOKIE_TRANSACTIONS: {
+		struct tcp_cookie_transactions ctd;
+		struct tcp_cookie_values *cvp = tp->cookie_values;
+
+		if (get_user(len, optlen))
+			return -EFAULT;
+		if (len < sizeof(ctd))
+			return -EINVAL;
+
+		memset(&ctd, 0, sizeof(ctd));
+		ctd.tcpct_flags = (tp->rx_opt.cookie_in_always
+				   ? TCP_COOKIE_IN_ALWAYS : 0)
+				+ (tp->rx_opt.cookie_out_never
+				   ? TCP_COOKIE_OUT_NEVER : 0);
+
+		if (cvp != NULL) {
+			ctd.tcpct_flags += (cvp->s_data_in
+					    ? TCP_S_DATA_IN : 0)
+					 + (cvp->s_data_out
+					    ? TCP_S_DATA_OUT : 0);
+
+			ctd.tcpct_cookie_desired = cvp->cookie_desired;
+			ctd.tcpct_s_data_desired = cvp->s_data_desired;
+
+			/* Cookie(s) saved, return as nonce */
+			if (sizeof(ctd.tcpct_value) < cvp->cookie_pair_size) {
+				/* impossible? */
+				return -EINVAL;
+			}
+			memcpy(&ctd.tcpct_value[0], &cvp->cookie_pair[0],
+			       cvp->cookie_pair_size);
+			ctd.tcpct_used = cvp->cookie_pair_size;
+		}
+
+		if (put_user(sizeof(ctd), optlen))
+			return -EFAULT;
+		if (copy_to_user(optval, &ctd, sizeof(ctd)))
+			return -EFAULT;
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
-- 
1.6.3.3


--------------040703060204040700020100--
