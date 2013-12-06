From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net v6 1/2] net: sched: tbf: fix the calculation of max_size
Date: Fri, 6 Dec 2013 10:56:41 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7468@saturn3.aculab.com>
References: <1386313205-87660-1-git-send-email-yangyingliang@huawei.com> <1386313205-87660-2-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <eric.dumazet@gmail.com>, <brouer@redhat.com>, <jpirko@redhat.com>,
	<jbrouer@redhat.com>
To: "Yang Yingliang" <yangyingliang@huawei.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38150 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757660Ab3LFK50 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 05:57:26 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06763-07 for <netdev@vger.kernel.org>;
 Fri,  6 Dec 2013 10:57:24 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1386313205-87660-2-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Yang Yingliang
...
> 
> +/* Time to Length, convert time in ns to length in bytes
> + * to determinate how many bytes can be sent in given time.
> + */
> +static u64 psched_ns_t2l(const struct psched_ratecfg *r,
> +			 u64 time_in_ns)
> +{
> +	/* The formula is :
> +	 * len = (time_in_ns * r->rate_bytes_ps) / NSEC_PER_SEC
> +	 */
> +	u64 len = time_in_ns * r->rate_bytes_ps;
> +
> +	do_div(len, NSEC_PER_SEC);

You are multiplying two values then dividing by 10**9
I'd guess that the intermediate value might exceed 2**64.

> +	if (unlikely(r->linklayer == TC_LINKLAYER_ATM))
> +		len = (len / 53) * 48;

You probably want to do the multiply first.
But why not scale rate_bytes_ps instead.

> +	if (len > r->overhead)
> +		len -= r->overhead;
> +	else
> +		len = 0;
> +
> +	return len;
> +}

Personally I'd work out how much time you have to send each byte.
So if you want a rate of 1MB/sec you have a 'time cost' per byte of 1000ns.
The cost of sending a packet is simply the length multiplied by this cost.
To work out whether a packet can be sent you have a credit variable that
tracks current time.
If 'credit > now' the packet can't be sent, queue and schedule a wakeup.
if 'credit + backlog < now' set credit = now - backlog.
if 'credit <= now' send the packet and add the packet's 'cost' to 'credit'.

In the non-ratelimited case this is almost no work.

You'd probably need to work in 1/1024ns time units and/or blocks of 16 bytes.

	David
