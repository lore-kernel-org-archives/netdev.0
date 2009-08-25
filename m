From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2 / tbf with large burst seems broken again
Date: Tue, 25 Aug 2009 06:22:03 +0000
Message-ID: <20090825062203.GA5381@ff.dom.local>
References: <200908250237.05017.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:55276 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292AbZHYGWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 02:22:07 -0400
Received: by fxm17 with SMTP id 17so1859882fxm.37
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2009 23:22:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200908250237.05017.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25-08-2009 01:37, Denys Fedoryschenko wrote:
> Found issue, it seems tc_core_time2tick will overflow with increased 
> resolution on large bucket values. But no idea how to fix it :-(
> 
> I add a warning, something like
>  unsigned tc_core_time2tick(unsigned time)
>  {
> +       long long temp = time*tick_in_usec;
> +       if (temp > INT_MAX)
> +           printf("tc_core_time2tick() overflow!\n");
>         return time*tick_in_usec;
>  }
> 
> Maybe it is good to add in iproute2 mainstream, so user will be warned if 
> buffer set too large? (and it will not set incorrect values, that lead to 
> unpredictable results.

Right, it's about an overflow and it was expected (theoretically) for
very low rates (as for current times) while doing this resolution
change. Probably this kind of warning should be useful if we expect
there're more people who can actually use something like this yet ;-)

Alas INT_MAX could still be not enough to prevent similar issues
because in tbf_dequeue such a value (buffer) is increased with tokens.
I guess we could try to change some variables to 64 bits there, but
the main question is why anybody needs such strange settings today?
Did you try e.g. to browse Internet with that rate and the buffer
e.g. 1500kb or you punish some users only? ;-) Btw, why do you think
'buffer 2000kb' is better "for you" with that rate than e.g. 20kb?

Thanks,
Jarek P.
