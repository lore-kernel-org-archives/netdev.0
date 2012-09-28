From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] rtlwifi: use %*ph[C] to dump small buffers
Date: Fri, 28 Sep 2012 10:24:21 -0700
Message-ID: <1348853061.14262.44.camel@joe-AO722>
References: <1348667852-5957-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1348677946.15175.8.camel@joe-AO722> <5064D318.6090705@lwfinger.net>
	 <1348802023.3030.11.camel@joe-AO722>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B700D@saturn3.aculab.com>
	 <5065D32F.9090107@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:35141 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758680Ab2I1RYW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 13:24:22 -0400
In-Reply-To: <5065D32F.9090107@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-28 at 11:41 -0500, Larry Finger wrote:
> On 09/28/2012 04:04 AM, David Laight wrote:
> >>> Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
[]
> >>> -       *(u32 *)&rate_mask = (ratr_bitmap & 0x0fffffff) |
> >>> -                                    (ratr_index << 28);
> >>> +       for (i = 0; i < 3; i++)
> >>> +               rate_mask[i] = ratr_bitmap & (0xff << (i * 4));
[]
> > So this either fixes, or adds, an endianness bug.
> 
> Yes, the rate_mask array is little endian after this fragment is run, but the 
> only use of the byte array is to write it to the device, and LE is what it needs 
> no matter the platform. This change fixes an endianness bug.
> 
> As I tend to get confused when doing these things, I wrote a small test program 
> and ran it on x86_64 and PPC-32 to confirm the result.
> 
> Thanks for teaching me about a = b >>= 8. I was not aware that C could do that.

The other thing that could be done is to use cpu_to_le32()
but David's method I think is superior for this use as there's
no absolute guarantee that rate_mask is aligned on a u32.

I'd add parens to make the precedence explicit.

	rate_mask[0] = ratr_bitmap;
	rate_mask[1] = (ratr_bitmap >>= 8);
	rate_mask[2] = (ratr_bitmap >>= 8);
	rate_mask[3] = ((ratr_bitmap >> 8) & 0xf) | (ratr_index << 4);
