From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows with MD5SIG enabled
Date: Tue, 3 Jun 2008 09:31:02 -0700
Message-ID: <396556a20806030931s9e8ec42hba9e39d9fe3514f1@mail.gmail.com>
References: <396556a20805301140x586093e5o92d44e38f7c2869a@mail.gmail.com>
	 <396556a20805301217k293e5718h6bbf02bfe0683143@europa>
	 <Xine.LNX.4.64.0806020938240.8594@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "James Morris" <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:21774 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbYFCQbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 12:31:04 -0400
Received: by rv-out-0506.google.com with SMTP id l9so1653335rvb.1
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2008 09:31:03 -0700 (PDT)
In-Reply-To: <Xine.LNX.4.64.0806020938240.8594@us.intercode.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 1, 2008 at 4:40 PM, James Morris <jmorris@namei.org> wrote:
> Reviewed-by: James Morris <jmorris@namei.org>


Looking at this code some more, I fear that I've fucked up that patch.
The logic for TCP options seems to be duplicated three times in the
code: the size calculation (patched), the building of the actual
options (tcp_build_and_update_options / tcp_syn_build_options) and the
MSS calculations (tcp_current_mss).

It looks, on second glance, that this code in
tcp_build_and_update_options will include the options even though we
calculated the size without:

if (tp->rx_opt.eff_sacks) {
	struct tcp_sack_block *sp = tp->rx_opt.dsack ? tp->duplicate_sack :
tp->selective_acks;
	int this_sack;

	*ptr++ = htonl((TCPOPT_NOP  << 24) |
		       (TCPOPT_NOP  << 16) |
		       (TCPOPT_SACK <<  8) |
		       (TCPOLEN_SACK_BASE + (tp->rx_opt.eff_sacks *
			     TCPOLEN_SACK_PERBLOCK)));
...

Unless I'm missing something, that patch was incomplete and we're
still sending invalid packets on in the MD5SIG + SACK case.

If so, I'll try and get the other two cases with another patch.

Additionally, it would appear that it would be useful to pull this
logic into a single place: maybe a function which runs multiple times
(to calculate the MSS / header size and a second time to actually
perform the options writes). But that'll be a different patch.

Cheers,

AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
