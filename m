From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH net-next] sk-filter: Add ability to get socket filter program
Date: Fri, 26 Oct 2012 20:07:13 +0200
Message-ID: <CAD6jFUS9LBtJ20Ty=3LTJNMxb0UhyCxRiAg+T7BUeXGEswpkUQ@mail.gmail.com>
References: <508AC533.4000809@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52463 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965638Ab2JZSHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 14:07:21 -0400
Received: from [78.46.5.203] (helo=sslproxy01.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TRoJU-0007hp-B5
	for netdev@vger.kernel.org; Fri, 26 Oct 2012 20:07:20 +0200
Received: from [74.125.83.46] (helo=mail-ee0-f46.google.com)
	by sslproxy01.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TRoJX-00047e-Q4
	for netdev@vger.kernel.org; Fri, 26 Oct 2012 20:07:23 +0200
Received: by mail-ee0-f46.google.com with SMTP id b15so1182118eek.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 11:07:14 -0700 (PDT)
In-Reply-To: <508AC533.4000809@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 26, 2012 at 7:15 PM, Pavel Emelyanov <xemul@parallels.com> wrote:
> The SO_ATTACH_FILTER option is set only. I propose to add the get
> ability by using SO_ATTACH_FILTER in getsockopt. To be less irritating
> to eyes the SO_GET_FILTER alias to it is declared.
>
> There are two issues with getting filter back.
>
> First, kernel modifies the sock_filter->code on filter load, thus in
> order to return the filter element back to user we have to decode it
> into user-visible constants. Fortunately the modification in question
> is interconvertible.
>
> Second, the BPF_S_ALU_DIV_K code modifies the command argument k to
> speed up the run-time division by doing kernel_k = reciprocal(user_k).
> Bad news is that different user_k may result in same kernel_k, so we
> can't get the original user_k back. Good news is that we don't have
> to do it. What we need to is calculate a user2_k so, that
>
>   reciprocal(user2_k) == reciprocal(user_k) == kernel_k
>
> i.e. if it's re-loaded back the compiled again value will be exactly
> the same as it was. That said, the user2_k can be calculated like this
>
>   user2_k = reciprocal(kernel_k)
>
> with an exception, that if kernel_k == 0, then user2_k == 1.
>
> The optlen argument is treated like this -- when zero, kernel returns
> the amount of sock_fprog elements in filter, otherwise it should be
> large enough for the sock_fprog array.
>
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

In your commit message, you address how you implement it, but not
where it could be useful (or ``why one needs it''). For instance, in a
simple case, you have a packet sniffer that uses PF_PACKET, sets up a
socket filter and RX_RING, then you start looking at packets and at
some point you stop and close everything. In which scenario would I
(ever) call this getsockopt()? (Is it just for the sake for having a
missing getter-function?)
