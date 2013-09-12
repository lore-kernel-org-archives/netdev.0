From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH] vsnprintf: Remove use of %n and convert existing
 uses
Date: Wed, 11 Sep 2013 17:04:17 -0700
Message-ID: <1378944257.4714.45.camel@joe-AO722>
References: <1378926562.4714.11.camel@joe-AO722>
	 <CAGXu5jLO6109fkejXqX=WhkQnfAUeWtTcow0v1BNqyi=8=Qa3Q@mail.gmail.com>
	 <1378928700.4714.17.camel@joe-AO722>
	 <CAGXu5jLTjrPr=GwOmMcu55Qp9K-_XS75xq9NJ0vBUEwy-i_YMw@mail.gmail.com>
	 <1378941761.4714.37.camel@joe-AO722>
	 <201309120840.HHE37542.OJMFFHSOQOtVFL@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com,
	keescook@chromium.org, fweisbec@gmail.com,
	dan.carpenter@oracle.com, devel@driverdev.osuosl.org,
	gregkh@linuxfoundation.org, tushar.behera@linaro.org,
	lidza.louina@gmail.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	courmisch@gmail.com, vyasevich@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201309120840.HHE37542.OJMFFHSOQOtVFL@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-09-12 at 08:40 +0900, Tetsuo Handa wrote:
> Joe Perches wrote:
> > -	seq_printf(m, "%s%d%n", con->name, con->index, &len);
> > +	len = seq_printf(m, "%s%d", con->name, con->index);
> 
> Isn't len always 0 or -1 ?

Right.  Well you're no fun...

These uses would seem broken anyway because the
seq_printf isn't itself tested for correctness.

Hmm.

Also, there's a large amount of code that appears
to do calculations with pos or len like:

	pos += seq_printf(handle, fmt. ...)

There are very few that seem to use it correctly
like netfilter.

$ grep -rP --include=*.[ch] "^[ \t]*\S[ \t\S]*\bseq_[v]?printf\b" *

Suggestions?

> int seq_vprintf(struct seq_file *m, const char *f, va_list args)
> {
> 	int len;
> 
> 	if (m->count < m->size) {
> 		len = vsnprintf(m->buf + m->count, m->size - m->count, f, args);
> 		if (m->count + len < m->size) {
> 			m->count += len;
> 			return 0;
> 		}
> 	}
> 	seq_set_overflow(m);
> 	return -1;
> }
> EXPORT_SYMBOL(seq_vprintf);
> 
> int seq_printf(struct seq_file *m, const char *f, ...)
> {
> 	int ret;
> 	va_list args;
> 
> 	va_start(args, f);
> 	ret = seq_vprintf(m, f, args);
> 	va_end(args);
> 
> 	return ret;
> }
> EXPORT_SYMBOL(seq_printf);
