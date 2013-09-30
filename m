From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v1 net-next] net: pkt_sched: PIE AQM scheme
Date: Mon, 30 Sep 2013 10:19:32 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7367@saturn3.aculab.com>
References: <1380333383-9507-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <shemminger@vyatta.com>,
	<eric.dumazet@gmail.com>, "Mythili Prabhu" <mysuryan@cisco.com>,
	"Dave Taht" <dave.taht@bufferbloat.net>
To: "Vijay Subramanian" <subramanian.vijay@gmail.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53744 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752369Ab3I3JU7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 05:20:59 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15253-10 for <netdev@vger.kernel.org>;
 Mon, 30 Sep 2013 10:20:56 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1380333383-9507-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +#define PIE_DEFAULT_QUEUE_LIMIT 200	/* in packets */
> +#define QUEUE_THRESHOLD (5000)
> +#define DQCOUNT_INVALID -1
> +#define THRESHOLD_PKT_SIZE	1500
> +#define MAX_INT_VALUE  0xffffffff
> +#define MAX_INT_VALUE_CAP  (0xffffffff >> 8)

The above 2 constants are both unsigned (unless 'int' is larger than 32 bits).
If nothing else this means that they are very badly named.

> +
> +typedef u32 pie_time_t;
> +typedef s32 pie_tdiff_t;
> +#define PIE_SHIFT 10
> +#define MS2PIETIME(a) ((a * NSEC_PER_MSEC) >> PIE_SHIFT)
> +#define PIE_TIME_PER_SEC  ((NSEC_PER_SEC >> PIE_SHIFT))
> +
> +static inline pie_time_t pie_get_time(void)
> +{
> +	u64 ns = ktime_to_ns(ktime_get());
> +	return ns >> PIE_SHIFT;
> +}
> +
> +static inline u32 pie_time_to_ms(pie_time_t val)
> +{
> +	u64 valms = ((u64) val << PIE_SHIFT);
> +
> +	do_div(valms, NSEC_PER_MSEC);
> +	return (u32) valms;
> +}

There seems to be a lot of conversions between 1/1000 ms and 1/1024 ms.
On 32 bit systems they are horrid.
Not only that the conversions are open coded a lot of times as well.
It might also be better replacing '(val * 1000u) >> 10' with
'(val * (u64)(1000 << (32 - 10))) >> 32' since I'm not sure the compiler
will perform that substitution.

What happens if pie_time_to_ms() overflows 32 bits?
If it is only ever called for small values, there may be no need for
64bit maths at all.

...
> +	if (delta > (s32) (MAX_INT_VALUE * 2 / 100)
> +	    && q->vars.prob >= MAX_INT_VALUE / 10) {
> +		delta = MAX_INT_VALUE * 2 / 100;

Calculating 'MAX_INT_VALUE * 2' isn't a good idea!
Whatever value it is supposed to be, it should be a named constant.

	David
