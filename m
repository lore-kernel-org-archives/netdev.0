From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] inet_diag: fix oops for IPv4 AF_INET6 TCP SYN-RECV state
Date: Fri, 7 Dec 2012 21:30:25 -0500
Message-ID: <CADVnQykWjmpiPrSpGmOPc_WuamRNK_eO_ZC_6Q_TktRN2ALWew@mail.gmail.com>
References: <1354808546-644-1-git-send-email-ncardwell@google.com>
	<20121207.132019.1647690876686095833.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <edumazet@google.com>, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:53489 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757793Ab2LHCaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 21:30:25 -0500
Received: by mail-ie0-f179.google.com with SMTP id k14so2853236iea.38
        for <netdev@vger.kernel.org>; Fri, 07 Dec 2012 18:30:25 -0800 (PST)
In-Reply-To: <20121207.132019.1647690876686095833.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 7, 2012 at 1:20 PM, David Miller <davem@davemloft.net> wrote:
> From: Neal Cardwell <ncardwell@google.com>
> Date: Thu,  6 Dec 2012 10:42:26 -0500
>
>> Fix inet_diag to be aware of the fact that AF_INET6 TCP connections
>> instantiated for IPv4 traffic and in the SYN-RECV state were actually
>> created with inet_reqsk_alloc(), instead of inet6_reqsk_alloc(). This
>> means that for such connections inet6_rsk(req) returns a pointer to a
>> random spot in memory up to roughly 64KB beyond the end of the
>> request_sock.
>>
>> With this bug, for a server using AF_INET6 TCP sockets and serving
>> IPv4 traffic, an inet_diag user like `ss state SYN-RECV` would lead to
>> inet_diag_fill_req() causing an oops or the export to user space of 16
>> bytes of kernel memory as a garbage IPv6 address, depending on where
>> the garbage inet6_rsk(req) pointed.
>>
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>
> Thanks for this fix, but it opens up more questions.
>
> We don't seem to make any validations upon inet_diag_hostcond's
> prefix_len.  That parameter we pass into bitstring_match() can
> be just about anything.
>
> As another example, what if we do an ipv6 128-bit compare on what's
> actually an ipv4 address in the inet request sock?
>
> I think we need to, using cond->family, make some kind of validations
> upon cond->prefix_len.

OK, sounds good. I will add a patch to fix the adjacent prefix_len
issues you mention.

It also seems like it considers IPv4 and IPv6 with the same prefix as
matching, which seems bogus; eg IMHO 128.0.0.0 should not match 1::/1.
 In general it seems to me that a mismatch between entry->family and
cond->family should prevent a match, except for the IPv4-mapped-IPv6
case it already handles.

Would you like these patches against net or net-next?

neal
