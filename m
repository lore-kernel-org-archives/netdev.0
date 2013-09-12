From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH] vsnprintf: Remove use of %n and convert existing
 uses
Date: Wed, 11 Sep 2013 17:41:12 -0700
Message-ID: <1378946472.4714.52.camel@joe-AO722>
References: <1378926562.4714.11.camel@joe-AO722>
	 <CAGXu5jLO6109fkejXqX=WhkQnfAUeWtTcow0v1BNqyi=8=Qa3Q@mail.gmail.com>
	 <1378928700.4714.17.camel@joe-AO722>
	 <CAGXu5jLTjrPr=GwOmMcu55Qp9K-_XS75xq9NJ0vBUEwy-i_YMw@mail.gmail.com>
	 <1378941761.4714.37.camel@joe-AO722>
	 <201309120840.HHE37542.OJMFFHSOQOtVFL@I-love.SAKURA.ne.jp>
	 <1378944257.4714.45.camel@joe-AO722>
	 <20130912001911.GO13318@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com,
	keescook@chromium.org, fweisbec@gmail.com,
	dan.carpenter@oracle.com, devel@driverdev.osuosl.org,
	gregkh@linuxfoundation.org, tushar.behera@linaro.org,
	lidza.louina@gmail.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	courmisch@gmail.com, vyasevich@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130912001911.GO13318@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-09-12 at 01:19 +0100, Al Viro wrote:
> On Wed, Sep 11, 2013 at 05:04:17PM -0700, Joe Perches wrote:
> > On Thu, 2013-09-12 at 08:40 +0900, Tetsuo Handa wrote:
> > > Joe Perches wrote:
> > > > -	seq_printf(m, "%s%d%n", con->name, con->index, &len);
> > > > +	len = seq_printf(m, "%s%d", con->name, con->index);
> > > 
> > > Isn't len always 0 or -1 ?
> > 
> > Right.  Well you're no fun...
> > 
> > These uses would seem broken anyway because the
> > seq_printf isn't itself tested for correctness.
> > 
> > Hmm.
> > 
> > Also, there's a large amount of code that appears
> > to do calculations with pos or len like:
> > 
> > 	pos += seq_printf(handle, fmt. ...)
> 
> ... and most of that code proceeds to ignore pos completely.
> Note that ->show() is *NOT* supposed to return the number of
> characters it has/would like to have produced.  Just return
> 0 and be done with that; overflows are dealt with just fine.
> The large amount, BTW, is below 100 lines, AFAICS, in rather
> few files.

Unfortunately, when you count the uses of
	return seq_printf(...)
it's rather higher and all the callers need
to be chased down too.

$ grep -rP --include=*.[ch] "^[ \t]*(\S[ \t\S]*=|return[\s\(]*)\s*\bseq_[v]?printf\b" * | wc -l
320
$ grep -rPl --include=*.[ch] "^[ \t]*(\S[ \t\S]*=|return[\s\(]*)\s*\bseq_[v]?printf\b" *|wc -l
81

> Just bury the cargo-culting crap.  All those += seq_printf() should
> be simply calling it.

Most likely.

> The *only* reason to look at the return
> value is "if we'd already overflown the buffer, I'd rather skipped
> the costly generation of the rest of the record".  In that case
> seq_printf() returning -1 means "skip it, nothing else will fit and
> caller will be repeating with bigger buffer anyway".

Perhaps changing the seq_vprintf return from 0 to len
and testing for -1 would work.

Still would need to change a few lines in netfilter
and probably a few other places.
