From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [patch 7/7] netxen: fix byte-swapping in tx and rx
Date: Wed, 26 Dec 2007 23:53:34 +0000
Message-ID: <20071226235334.GF27894@ZenIV.linux.org.uk>
References: <20071226182352.704678179@netxen.com> <20071226182928.425988922@netxen.com> <20071226223803.GE27894@ZenIV.linux.org.uk> <Pine.LNX.4.64.0712261525490.23059@dut46.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37713 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbXLZXxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2007 18:53:36 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0712261525490.23059@dut46.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 26, 2007 at 03:29:22PM -0800, Dhananjay Phadke wrote:
> I agree for tx desc, the compiler would optimize.
> 
> But for rx (status) desc, I didn't like multiple le64_to_cpu() 
> for extracting various fields out of same status dword.

Fair enough; AFAICS, on rx side you don't mess with conversion in
place and single le64_to_cpu() into a local variable is sane.

BTW,
+       u64 value = le64_to_cpu((status_desc)->status_desc_data); \
+       value &= ~(0x3ULL << 56); \
+       value |= (u64)(((u64)(val) << 56) & (0x3ULL << 56)); \  
+       (status_desc)->status_desc_data = cpu_to_le64(value); \
would be better off as
	status_desc->status_desc_data =
		status_desc->status_desc_data &
		cpu_to_le64(3ULL << 56) |
		cpu_to_le64(((u64)val & 3) << 56);
since the second term will be constant and you get one conversion instead
of two (and if val is constant, you'll get no conversions at all, just
one and + one or)
