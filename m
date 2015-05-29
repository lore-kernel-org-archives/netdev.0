From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] ss: Fix allocation of cong control alg name
Date: Fri, 29 May 2015 18:48:42 +0200
Message-ID: <5568986A.7010000@iogearbox.net>
References: <1432895400-12266-1-git-send-email-vadim4j@gmail.com> <556848F4.6080003@iogearbox.net> <F15B4449A1150D418551CFE4D16B783B86469FBC@FMSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vadim Kochan <vadim4j@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	eric.dumazet@gmail.com
To: "Guzman Mosqueda, Jose R" <jose.r.guzman.mosqueda@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46892 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161059AbbE2Qsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 12:48:47 -0400
In-Reply-To: <F15B4449A1150D418551CFE4D16B783B86469FBC@FMSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2015 06:17 PM, Guzman Mosqueda, Jose R wrote:
> Hi Daniel and Vadim
>
> Thanks for your prompt response and for the patch.
>
> Also, what about the other one? Do you think it is an issue or not?
>
> " File: tc/tc_util.c
> Function: void print_rate(char *buf, int len, __u64 rate)
> Line: ~264
>
> In the case that user inputs a high value for rate, the "for" loop will exit in the condition meaning that variable "i" get the value of 5 which will be an invalid index for the "units" array due to that array has only 5 elements."
>
> I know a very high value is invalid but in the case that it comes directly from user, it could cause and issue, what do you think?

Hm, this prints just the netlink dump from kernel side, but perhaps
we should just change it ...

diff --git a/tc/tc_util.c b/tc/tc_util.c
index dc2b70f..aa6de24 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -250,18 +250,19 @@ void print_rate(char *buf, int len, __u64 rate)
  	extern int use_iec;
  	unsigned long kilo = use_iec ? 1024 : 1000;
  	const char *str = use_iec ? "i" : "";
-	int i = 0;
  	static char *units[5] = {"", "K", "M", "G", "T"};
+	int i;

  	rate <<= 3; /* bytes/sec -> bits/sec */

-	for (i = 0; i < ARRAY_SIZE(units); i++)  {
+	for (i = 0; i < ARRAY_SIZE(units) - 1; i++)  {
  		if (rate < kilo)
  			break;
  		if (((rate % kilo) != 0) && rate < 1000*kilo)
  			break;
  		rate /= kilo;
  	}
+
  	snprintf(buf, len, "%.0f%s%sbit", (double)rate, units[i], str);
  }
