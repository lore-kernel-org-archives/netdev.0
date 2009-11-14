From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v6 3/7 RFC] TCPCT part 1c: sysctl_tcp_cookie_size,
 socket option TCP_COOKIE_TRANSACTIONS
Date: Sat, 14 Nov 2009 10:43:33 -0500
Message-ID: <4AFED025.1060202@gmail.com>
References: <4AFCDA9E.8050003@gmail.com>  <4AFCE13B.4060006@gmail.com> <1258137443.16857.124.camel@Joe-Laptop.home> <4AFDB740.3060509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f226.google.com ([209.85.217.226]:33691 "EHLO
	mail-gx0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754698AbZKNPnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 10:43:45 -0500
Received: by gxk26 with SMTP id 26so3855662gxk.1
        for <netdev@vger.kernel.org>; Sat, 14 Nov 2009 07:43:51 -0800 (PST)
In-Reply-To: <4AFDB740.3060509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:
> Joe Perches wrote:
>> or even adding proc_dointvec_minmax_even
>> might save some cycles during cookie handling.
>>
> Well, that would have to be proc_dointvec_minmax_even_zero(), as the
> valid values can be 0, 8, 10, 12, 14, or 16.  ...
> 
> And it seems to me a case of "premature optimization" -- it might save
> 1 or 2 tests in the order I've listed them in tcp_cookie_size_check(),
> ...
> 
> On the server side, we have to test during parsing anyway.  I never trust
> any data that comes over the network....
> 
I looked at this again today, and proc_dointvec_minmax_even_zero() still
seems to be overkill.  I couldn't find anybody else that does such things
at sysctl parsing time.

I did find we could eliminate a test for odd (in part 1f),

+		if (unlikely(0x1 & cookie_size)) {
+			/* 8-bit multiple, illegal, ignore */
+			cookie_size = 0;

by using a better test for the network data (in part 1g), and it
should be faster, too (assuming gcc is smart enough):

Was:
+				if (TCPOLEN_COOKIE_MAX >= opsize
+				 && TCPOLEN_COOKIE_MIN <= opsize) {

Now:
+				switch (opsize) {
+				case TCPOLEN_COOKIE_MIN+0:
+				case TCPOLEN_COOKIE_MIN+2:
+				case TCPOLEN_COOKIE_MIN+4:
+				case TCPOLEN_COOKIE_MIN+6:
+				case TCPOLEN_COOKIE_MAX:

(This division into so many parts for review is driving me crazy....)

Saved 2 if's for every cookie!  Of course, there's a cpu intensive
SHA1 for each cookie, so this pales in comparison.

Premature optimization or not, thanks for the ideas!

