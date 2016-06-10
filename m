From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: Re: [RFC] Handle error writing UINT_MAX to u32 fields
Date: Fri, 10 Jun 2016 08:28:00 +0200
Message-ID: <575A5DF0.7020300@gmx.de>
References: <1465526452-30567-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:54020 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017AbcFJG2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 02:28:13 -0400
In-Reply-To: <1465526452-30567-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/10/2016 04:40 AM, Subash Abhinov Kasiviswanathan wrote:
> We have scripts which write to certain fields on 3.18 kernels but
> this seems to be failing on 4.4 kernels.
> An entry which we write to here is xfrm_aevent_rseqth which is u32.
> 
> echo 4294967295  > /proc/sys/net/core/xfrm_aevent_rseqth
> 
> Commit 230633d109e35b0a24277498e773edeb79b4a331 ("kernel/sysctl.c:
> detect overflows when converting to int") prevented writing to
> sysctl entries when integer overflow occurs.
> However, this does not apply to unsigned integers.
> 
> u32 should be able to hold 4294967295 here, however it fails due
> to this check.
> 
> static int do_proc_dointvec_conv(bool *negp, unsigned long *lvalp,
> ...
> 			if (*lvalp > (unsigned long) INT_MAX)
> 				return -EINVAL;
>

The task of the routine is to move data from unsigned long *lvalp to int
*valv considering the sign in bool *negp. So the output was never meant
to be > INT_MAX.

> I would like to know if introducing a new handler proc_douintvec
> would work here. Sample output and implementation below. This can be
> cleaned up and added for other u32 fields in kernel.

The suggested change would extend the usable range of positive numbers
by one bit only. As many systems are 64 bit this does not seem forward
looking.

I would prefer to have a routine that can handle 64 bit integers with
limits (let's call it proc_doint64vec_minmax) which uses fields extra1
and extra2 of ctl_table as min and max.

Then set xfrm_table[].extra1 = 0 and xfrm_table[].extra2 = UINT_MAX if
you need a result in the u32 range.

Best regards

Heinrich Schuchardt
