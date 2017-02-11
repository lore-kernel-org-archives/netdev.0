From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v4 1/2] qed: Add infrastructure for PTP support.
Date: Sat, 11 Feb 2017 12:16:38 +0100
Message-ID: <20170211111638.GA6564@localhost.localdomain>
References: <1486536194-30872-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1486536194-30872-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170211085810.GA4006@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, Yuval.Mintz@cavium.com
To: Sudarsana Kalluru <Sudarsana.Kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36136 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753308AbdBKLQp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 06:16:45 -0500
Received: by mail-wr0-f194.google.com with SMTP id k90so17598452wrc.3
        for <netdev@vger.kernel.org>; Sat, 11 Feb 2017 03:16:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170211085810.GA4006@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 11, 2017 at 09:58:10AM +0100, Richard Cochran wrote:
> If I am not mistaken, then you can skip the cases val==2 and val==3,
> because they are equivalent to val==4 and 6.

I took a stab at this, and you can see the result, below.  My version
has lower average error than yours in the interval 1 < ppb < 60000,
and it uses only 8 64-bit divisions.  Outside of that interval, your
version has lower error.

So, at the very least, you should introduce a threshold and use this
algorithm for adjustments under 60 ppm.  Better yet, find a way to use
fewer divisions for adjustments greater and 60 ppm...

Thanks,
Richard

---
#include <stdint.h>

#define TEN9		(1000000000UL)

unsigned int calc_min_integer(uint64_t ppb, uint64_t *M)
{
	uint64_t err, m, min, n, N, p2, reg;

	min = TEN9;
	for (n = 4; n <= 7; n++) {
		m = n * TEN9;
		m = (m + ppb/2) / ppb;

		/*truncate to HW resolution*/
		reg = (m + 8) / 16;
		m = reg * 16;

		p2 = (n * TEN9 + m/2) / m;

		err = ppb > p2 ? ppb - p2 : p2 - ppb;

		if (min >= err) {
			min = err;
			N = n;
			*M = m;
		}
	}
	return N;
}
