From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC PATCH] vsnprintf: Remove use of %n and convert existing uses
Date: Thu, 12 Sep 2013 01:19:11 +0100
Message-ID: <20130912001911.GO13318@ZenIV.linux.org.uk>
References: <1378926562.4714.11.camel@joe-AO722>
 <CAGXu5jLO6109fkejXqX=WhkQnfAUeWtTcow0v1BNqyi=8=Qa3Q@mail.gmail.com>
 <1378928700.4714.17.camel@joe-AO722>
 <CAGXu5jLTjrPr=GwOmMcu55Qp9K-_XS75xq9NJ0vBUEwy-i_YMw@mail.gmail.com>
 <1378941761.4714.37.camel@joe-AO722>
 <201309120840.HHE37542.OJMFFHSOQOtVFL@I-love.SAKURA.ne.jp>
 <1378944257.4714.45.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com,
	keescook@chromium.org, fweisbec@gmail.com,
	dan.carpenter@oracle.com, devel@driverdev.osuosl.org,
	gregkh@linuxfoundation.org, tushar.behera@linaro.org,
	lidza.louina@gmail.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	courmisch@gmail.com, vyasevich@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:33520 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195Ab3ILATZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 20:19:25 -0400
Content-Disposition: inline
In-Reply-To: <1378944257.4714.45.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 11, 2013 at 05:04:17PM -0700, Joe Perches wrote:
> On Thu, 2013-09-12 at 08:40 +0900, Tetsuo Handa wrote:
> > Joe Perches wrote:
> > > -	seq_printf(m, "%s%d%n", con->name, con->index, &len);
> > > +	len = seq_printf(m, "%s%d", con->name, con->index);
> > 
> > Isn't len always 0 or -1 ?
> 
> Right.  Well you're no fun...
> 
> These uses would seem broken anyway because the
> seq_printf isn't itself tested for correctness.
> 
> Hmm.
> 
> Also, there's a large amount of code that appears
> to do calculations with pos or len like:
> 
> 	pos += seq_printf(handle, fmt. ...)

... and most of that code proceeds to ignore pos completely.
Note that ->show() is *NOT* supposed to return the number of
characters it has/would like to have produced.  Just return
0 and be done with that; overflows are dealt with just fine.
The large amount, BTW, is below 100 lines, AFAICS, in rather
few files.

> There are very few that seem to use it correctly
> like netfilter.

> Suggestions?

Just bury the cargo-culting crap.  All those += seq_printf() should
be simply calling it.  The *only* reason to look at the return
value is "if we'd already overflown the buffer, I'd rather skipped
the costly generation of the rest of the record".  In that case
seq_printf() returning -1 means "skip it, nothing else will fit and
caller will be repeating with bigger buffer anyway".
