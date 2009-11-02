From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 3/3] TCPCT part 1c: initial SYN exchange
 with SYNACK data
Date: Mon, 02 Nov 2009 07:25:12 -0500
Message-ID: <4AEECFA8.1080306@gmail.com>
References: <4AE6E35C.2050101@gmail.com> <4AE6E7C0.2050408@gmail.com> <4AEDDF33.9030205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f212.google.com ([209.85.217.212]:53886 "EHLO
	mail-gx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754660AbZKBMZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 07:25:10 -0500
Received: by gxk4 with SMTP id 4so4124287gxk.8
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 04:25:15 -0800 (PST)
In-Reply-To: <4AEDDF33.9030205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> This part is really hard to review, and might be splitted ?
> 
> cleanups could be done in a cleanup patch only
> 
> Examples:
> 
> -	tmp_opt.mss_clamp = 536;
> -	tmp_opt.user_mss  = tcp_sk(sk)->rx_opt.user_mss;
> +	tmp_opt.mss_clamp = TCP_MIN_RCVMSS;
> +	tmp_opt.user_mss  = tp->rx_opt.user_mss;
> 
> 
> -	tp->mss_cache = 536;
> +	tp->mss_cache = TCP_MIN_RCVMSS;
> 
Often hard to decide what's "cleanup" and what's essential.  I'll look at
that again for the next round, but I've already split the original single
patch into multiple parts.


> Also your tests are reversed, if you look at the existing coding style.
> 
I checked Documentation/CodingStyle, and that's not specified.  I've seen
plenty of examples of modern security coding style around here.

As a long-time (25+ years) consultant and 30 years C programmer, I'm
heedful of the project coding style, and had to endure many variants.

Where I'm working with others' code, you'll note that I keep the same
style, no matter how ugly, as that makes patches easier to read.


> Example :
> 
> +	/* TCP Cookie Transactions */
> +	if (0 < sysctl_tcp_cookie_size) {
> +		/* Default, cookies without s_data. */
> +		tp->cookie_values =
> +			kzalloc(sizeof(*tp->cookie_values),
> +				sk->sk_allocation);
> +		if (NULL != tp->cookie_values)
> +			kref_init(&tp->cookie_values->kref);
> +	}
> 
> should be ->
> 
> +	/* TCP Cookie Transactions */
> +	if (sysctl_tcp_cookie_size > 0) {
> +		/* Default, cookies without s_data. */
> +		tp->cookie_values =
> +			kzalloc(sizeof(*tp->cookie_values),
> +				sk->sk_allocation);
> +		if (tp->cookie_values != NULL)
> +			kref_init(&tp->cookie_values->kref);
> +	}
> 
And "tp->cookie_values != NULL" is egregiously poor C practice.  It's very
hard for code review to ensure that didn't get truncated to "= NULL".  The
important visual element is the NULL, not the variable name.

Also, avoid "!tp->cookie_values", as this is *not* a boolean.

When I'm adding new code, I use constant-to-the-left security coding style,
as they teach in modern universities (lately also for PHP).  And this is a
security extension, so a security style is particularly appropriate.

As in switch statements, constant-to-the-left makes the value obvious,
especially in a series (and assists transforming if series into a switch).

For complex tests, this makes the code much more readable and easier to
visually verify on code walk-through:

+	if (0 < tmp_opt.cookie_plus
+	 && tmp_opt.saw_tstamp
+	 && !tp->cookie_out_never
+	 && (0 < sysctl_tcp_cookie_size
+	  || (NULL != tp->cookie_values
+	   && 0 < tp->cookie_values->cookie_desired))) {

Consistent use of security style would have obviated a lot of foolish >= 0
tests that seem to be constantly in need of fixing.  It's a bad idea to
depend on the compiler to catch non-executable code.
