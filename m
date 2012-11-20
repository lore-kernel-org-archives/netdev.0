From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH v2] checkpatch: add double empty line check
Date: Tue, 20 Nov 2012 16:27:04 +0200
Message-ID: <1353421624.6559.9.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1353151057.14327.18.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120115239.GA7955@dm>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Joe Perches" <joe@perches.com>,
	"David Rientjes" <rientjes@google.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "Andy Whitcroft" <apw@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121120115239.GA7955@dm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-11-20 at 11:52 +0000, Andy Whitcroft wrote:

Andy, thanks for reviewing this patch.

> On Sat, Nov 17, 2012 at 01:17:37PM +0200, Eilon Greenstein wrote:
> > Changes from previous attempt:
> > - Use CHK instead of WARN
> > - Issue only one warning per empty lines block
> > 
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> > ---
> >  scripts/checkpatch.pl |    8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > diff --git a/scripts/checkpatch.pl b/scripts/linescheckpatch.pl
> > index 21a9f5d..13d264f 100755
> > --- a/scripts/checkpatch.pl
> > +++ b/scripts/checkpatch.pl
> > @@ -3579,6 +3579,14 @@ sub process {
> >  			WARN("EXPORTED_WORLD_WRITABLE",
> >  			     "Exporting world writable files is usually an error. Consider more restrictive permissions.\n" . $herecurr);
> >  		}
> > +
> > +# check for double empty lines
> > +		if ($line =~ /^\+\s*$/ &&
> > +		    ($rawlines[$linenr] =~ /^\s*$/ ||
> > +		     $prevline =~ /^\+?\s*$/ && $rawlines[$linenr] !~ /^\+\s*$/)) {
> > +			CHK("DOUBLE_EMPTY_LINE",
> > +			    "One empty line should be sufficient. Consider removing this one.\n" . $herecurr);
> > +		}
> >  	}
> >  
> >  	# If we have no input at all, then there is nothing to report on
> 
> In your previous version you indicated you would be emiting one per group
> of lines, I do not see how this does that.

This is what I'm testing:
Only if the current line is a new blank line and:
	if the next line is empty but not newly added (this is the part that
will make sure we get only one warning for a bunch of new lines - only
the last newly added line will hit this condition)
or
	if the previous line was empty (either new empty line or existing empty
line) and the next line is not a new empty line (so we will issue just
one warning).

I tested it on few examples, and did not see a problem. Can you share an
example where it issues more than a single warning for a newly
introduced consecutive new lines?

> Also this fails if the fragment
> is at the top of the hunk emiting a perl warning.

I did not see this warning. Can you please share this example? I tried
adding a couple of empty lines at the beginning of a file and it seemed
to work just fine for me (using perl v5.14.2).lines

> We should probabally
> use the suppress approach.
> 
> How about something like the below.
> 
> -apw
> 
> 
> From 848ebffa8656a1ff96a91788ec0f1c04dab9c3e9 Mon Sep 17 00:00:00 2001
> From: Andy Whitcroft <apw@canonical.com>
> Date: Sat, 17 Nov 2012 13:17:37 +0200
> Subject: [PATCH] checkpatch: strict warning for multiple blank lines
> 
> Signed-off-by: Andy Whitcroft <apw@canonical.com>
> ---
>  scripts/checkpatch.pl |   11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> index f18750e..dbc68f3 100755
> --- a/scripts/checkpatch.pl
> +++ b/scripts/checkpatch.pl
> @@ -1411,6 +1411,7 @@ sub process {
>  	my %suppress_whiletrailers;
>  	my %suppress_export;
>  	my $suppress_statement = 0;
> +	my $suppress_multipleblank = -1;
>  
>  	# Pre-scan the patch sanitizing the lines.
>  	# Pre-scan the patch looking for any __setup documentation.
> @@ -1521,6 +1522,7 @@ sub process {
>  			%suppress_whiletrailers = ();
>  			%suppress_export = ();
>  			$suppress_statement = 0;
> +			$suppress_multipleblank = -1;
>  			next;
>  
>  # track the line number as we move through the hunk, note that
> @@ -1930,6 +1932,15 @@ sub process {
>  			      "use the SSYNC() macro in asm/blackfin.h\n" . $herevet);
>  		}
>  
> +# multiple blank lines.
> +		if ($line =~ /^-/ || ($suppress_multipleblank == $linenr && $line =~ /^[ \+]\s*$/)) {
> +			$suppress_multipleblank++;
> +		} elsif ($prevline =~ /^\+\s*$/ and $line =~ /^\+\s*$/) {
> +			$suppress_multipleblank = $linenr + 1;
> +			CHK("MULTIPLE_EMPTY_LINE",
> +			    "One empty line should be sufficient. Consider removing this one.\n" . $herecurr);
> +		}
> +
>  # Check for potential 'bare' types
>  		my ($stat, $cond, $line_nr_next, $remain_next, $off_next,
>  		    $realline_next);

The problem with this version is that it only catches newly added empty
lines. But if there was an empty line before or after this newly added
empty line, there will be no warning. I would like to catch things like
that as well.

Thanks,
Eilon
