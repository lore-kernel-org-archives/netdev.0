From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND][PATCH 3/4 Rev-3] Initilize and populate age field
Date: Wed, 19 Sep 2007 11:20:24 -0700 (PDT)
Message-ID: <20070919.112024.21594685.davem@davemloft.net>
References: <20070919092434.0d461f0b.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, socketcan@hartkopp.net,
	shemminger@linux-foundation.org, krkumar2@in.ibm.com,
	tgraf@suug.ch, varuncha@in.ibm.com
To: varunc@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34366
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751528AbXISSUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 14:20:24 -0400
In-Reply-To: <20070919092434.0d461f0b.varunc@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Date: Wed, 19 Sep 2007 09:24:34 +0530

> The age field is filled with the current time at the time of creation of the route. When the routes are dumped
> then the age value stored in the route structure is subtracted from the current time value and the difference is the age expressed in secs.
> 
> Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>

This doesn't match what your code does:

> +	/* Note: The ideal place to fill up the time value for a newely created route will be
> +	** in fn_hash_insert(). But we are delaying the time insert procedure to avoid calling
> +	** do_gettimeofday() twice.
> +	*/
> +	do_gettimeofday(&tv);
> +	if (!*age) {
> +		*age = timeval_to_sec(&tv);
> +		NLA_PUT_U32(skb, RTA_AGE, *age);
> +	} else {
> +		NLA_PUT_U32(skb, RTA_AGE, timeval_to_sec(&tv) - *age);
> +	}

In avoiding the age initialization at routing cache insertion time,
you make the value provided totally inaccurate and essentially
useless especially the very first time the value is asked for.

I really don't like these changes, they have had problems every step
of the way, and the above proves that we could essentially always
return an age value of zero and still be compliant with the standards.
