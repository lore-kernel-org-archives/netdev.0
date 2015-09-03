From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [GIT] Networking
Date: Thu, 3 Sep 2015 21:32:42 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1509032121120.2035@localhost6.localdomain6>
References: <20150902.223522.1792493140210966693.davem@davemloft.net>  <CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>  <20150903.104032.767889134756094076.davem@davemloft.net>  <CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com>
 <1441305296.9666.14.camel@perches.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-839460660-1441308074=:2035"
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Lorenzo Bianconi <lorenzo.bianconi83@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:45974 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757623AbbICTcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 15:32:45 -0400
In-Reply-To: <1441305296.9666.14.camel@perches.com>
Content-ID: <alpine.DEB.2.02.1509032121160.2035@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-839460660-1441308074=:2035
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-7
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.02.1509032121161.2035@localhost6.localdomain6>



On Thu, 3 Sep 2015, Joe Perches wrote:

> On Thu, 2015-09-03 at 11:22 -0700, Linus Torvalds wrote:
> > On Thu, Sep 3, 2015 at 10:40 AM, David Miller <davem@davemloft.net> wrote:
> > >
> > > Linus, what GCC version are you using and what does the warning look
> > > like?
> > 
> > I'm on whatever is in F22. gcc -v says
> > 
> >    gcc version 5.1.1 20150618 (Red Hat 5.1.1-4) (GCC)
> > 
> > and the warning looks like so:
> > 
> >   net/mac80211/rate.c: In function ¡rate_control_cap_mask¢:
> >   net/mac80211/rate.c:719:25: warning: ¡sizeof¢ on array function
> > parameter ¡mcs_mask¢ will return size of ¡u8 * {aka unsigned char *}¢
> > [-Wsizeof-array-argument]
> >      for (i = 0; i < sizeof(mcs_mask); i++)
> >                            ^
> > 
> > (note the lack of warning about the use of an array in the function
> > definition parameter list - I tried to find if there's any way to
> > enable such a warning, but couldn't find anything. Maybe my google-fu
> > is weak, but more probably that just doesn't exist).

I find 518 occurrences of a function parameter declaration that contains 
an explicit size.  But only the sizeof(mcs_mask) where there is a sizeof 
on such a parameter.  I also checked for ARRAY_SIZE on such parameters, 
and didn't find any occurrences of that either.

julia


> Coccinelle might be a better tool for this but
> a possible checkpatch patch is below:
> 
> It produces output like:
> 
> $ ./scripts/checkpatch.pl -f net/iucv/iucv.c --types=sized_array_argument
> WARNING: Avoid sized array arguments
> #716: FILE: net/iucv/iucv.c:716:
> +static int iucv_sever_pathid(u16 pathid, u8 userdata[16])
> +{
> 
> WARNING: Avoid sized array arguments
> #878: FILE: net/iucv/iucv.c:878:
> +int iucv_path_accept(struct iucv_path *path, struct iucv_handler *handler,
> +		     u8 userdata[16], void *private)
> +{
> 
> WARNING: Avoid sized array arguments
> #925: FILE: net/iucv/iucv.c:925:
> +int iucv_path_connect(struct iucv_path *path, struct iucv_handler *handler,
> +		      u8 userid[8], u8 system[8], u8 userdata[16],
> +		      void *private)
> +{
> 
> WARNING: Avoid sized array arguments
> #988: FILE: net/iucv/iucv.c:988:
> +int iucv_path_quiesce(struct iucv_path *path, u8 userdata[16])
> +{
> 
> WARNING: Avoid sized array arguments
> #1020: FILE: net/iucv/iucv.c:1020:
> +int iucv_path_resume(struct iucv_path *path, u8 userdata[16])
> +{
> 
> WARNING: Avoid sized array arguments
> #1050: FILE: net/iucv/iucv.c:1050:
> +int iucv_path_sever(struct iucv_path *path, u8 userdata[16])
> +{
> 
> total: 0 errors, 6 warnings, 0 checks, 2119 lines checked
> ---
>  scripts/checkpatch.pl | 18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
> 
> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> index e14dcdb..747b164 100755
> --- a/scripts/checkpatch.pl
> +++ b/scripts/checkpatch.pl
> @@ -5422,6 +5422,24 @@ sub process {
>  			     "externs should be avoided in .c files\n" .  $herecurr);
>  		}
>  
> +# check for function arguments using arg[SIZE]
> +		if ($^V && $^V ge 5.10.0 &&
> +		    defined $stat &&
> +		    $stat =~ /^.\s*(?:$Declare|$DeclareMisordered)\s*$Ident\s*($balanced_parens)\s*\{/s) {
> +			my $func_args = $1;
> +			if ($func_args =~ /(.*)\[\s*(?:$Constant|[A-Z0-9_]+)\s*\]/ && (!defined($1) || $1 !~ /\[\s*\]\s*$/)) {
> +				my $ctx = '';
> +				my $herectx = $here . "\n";
> +				my $cnt = statement_rawlines($stat);
> +				for (my $n = 0; $n < $cnt; $n++) {
> +					$herectx .= raw_line($linenr, $n) . "\n";
> +					$n = $cnt if ($herectx =~ /{/);
> +				}
> +				WARN("SIZED_ARRAY_ARGUMENT",
> +				     "Avoid sized array arguments\n" . $herectx);
> +			}
> +		}
> +
>  # checks for new __setup's
>  		if ($rawline =~ /\b__setup\("([^"]*)"/) {
>  			my $name = $1;
> 
> 
> 
--8323328-839460660-1441308074=:2035--
