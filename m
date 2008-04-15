From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC PATCH net-2.6.26 (Plan A)] [TCP]: Lower stack usage in tcp4_seq_show().
Date: Tue, 15 Apr 2008 11:45:03 +0100
Message-ID: <20080415104503.GA27459@ZenIV.linux.org.uk>
References: <20080415.192434.05003640.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:41848 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054AbYDOKpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 06:45:08 -0400
Content-Disposition: inline
In-Reply-To: <20080415.192434.05003640.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2008 at 07:24:34PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> tcp4_seq_show() eats about 250 bytes.  By using buffer in seq_file
> directly, it will be reduced under 100 bytes.
> 
> One drawback is slight change of the format - the format was fixed
> size and now its size is variable.
> However, size of the line was 128 bytes in 2.2, and 150 bytes in 2.6,
> so the change may not matter, probably.

> -	sprintf(tmpbuf, "%4d: %08X:%04X %08X:%04X"
> -		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %p",
> +	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
> +		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %p\n",

Or you can just do
	int len;
	...
	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %p%n",
>  		i,
>  		ireq->loc_addr,
>  		ntohs(inet_sk(sk)->sport),
		...,
		&len);
	seq_printf("%*s\n", TMPSZ - 1 - len, "");

and be done with that, keeping the output unchanged.  That's exactly what
%n is for - it allows to get the width of output so far, precisely for
such situations.
