From: Tony Battersby <tonyb@cybernetics.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Wed, 20 Feb 2008 16:29:57 -0500
Message-ID: <47BC9BD5.8040900@cybernetics.com>
References: <47BA0984.2070306@cybernetics.com> <1203381120.13495.78.camel@dell> <20080218.163554.74130592.davem@davemloft.net> <1203383046.13495.87.camel@dell> <47BB00EC.3010607@cybernetics.com> <1203448265.13495.95.camel@dell> <47BB54C2.6090501@cybernetics.com> <20080220013824.GA5416@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, netdev <netdev@vger.kernel.org>,
	gregkh@suse.de, linux-kernel@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.cybernetics.com ([70.169.137.4]:2767 "EHLO
	mail.cybernetics.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754611AbYBTV35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 16:29:57 -0500
In-Reply-To: <20080220013824.GA5416@localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update:

Herbert's patch alters the arguments to alloc_skb_fclone() and
skb_reserve() from within sk_stream_alloc_pskb().  This changes the
skb_headroom() and skb_tailroom() of the returned skb.  I decided to see
if I could detect the precise point at which data corruption started to
happen.  The result is this table:

(sk_stream_alloc_pskb() called with size == 1448;
sk->sk_prot->max_header == 160)

skb_headroom  skb_tailroom  test result  note
216           1448          fail         [1]
344           1448          fail
340           1452          pass
336           1456          pass
332           1460          pass
328           1464          fail
324           1468          pass
320           1472          pass
316           1476          pass
312           1480          fail
308           1484          pass
304           1488          pass
300           1492          pass
296           1496          fail
292           1500          pass
288           1504          pass
284           1508          pass
280           1512          fail
276           1516          pass
272           1520          pass
268           1524          pass
264           1528          fail
260           1532          pass
256           1536          pass         [2]

Notes:
[1] Kernels 2.6.23.4 - 2.6.23.16 and 2.6.24 - current with Herbert's patch
[2] Kernels 2.6.23.3 and before without Herbert's patch

Note that the first row has skb_headroom + skb_tailroom == 1664; the
remaining rows have skb_headroom + skb_tailroom == 1792.

>From these results, it looks like a data alignment issue.  Herbert's
patch unfortunately just happened to change the alignment in a way that
made it break.

Tony

