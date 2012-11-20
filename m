From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH v2] checkpatch: add double empty line check
Date: Tue, 20 Nov 2012 18:06:10 +0200
Message-ID: <1353427570.6559.21.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1353151057.14327.18.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120115239.GA7955@dm>
 <1353421624.6559.9.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120144329.GE7955@dm>
 <1353424027.6559.15.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120154443.GK7955@dm>
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
In-Reply-To: <20121120154443.GK7955@dm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-11-20 at 15:44 +0000, Andy Whitcroft wrote:
> On Tue, Nov 20, 2012 at 05:07:07PM +0200, Eilon Greenstein wrote:
> > On Tue, 2012-11-20 at 14:43 +0000, Andy Whitcroft wrote:
> > 
> > > > > Also this fails if the fragment
> > > > > is at the top of the hunk emiting a perl warning.
> > > > 
> > > > I did not see this warning. Can you please share this example? I tried
> > > > adding a couple of empty lines at the beginning of a file and it seemed
> > > > to work just fine for me (using perl v5.14.2).lines
> > > 
> > > Ok, this is actually if it is at the bottom, not the top.  So if you
> > > have a range of lines newly added to the bottom of the file.  Leading to
> > > this warning:
> > > 
> > > Use of uninitialized value within @rawlines in pattern match (m//) at
> > > ../checkpatch/scripts/checkpatch.pl line 3586.
> > 
> > Oh... of course, I should have seen that. I did not check changes at the
> > end of the file.
> > 
> > What do you say about something like that (using nextline out of
> > rawlines only if it defined):
> > diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> > index 21a9f5d..c0c610c 100755
> > --- a/scripts/checkpatch.pl
> > +++ b/scripts/checkpatch.pl
> > @@ -3579,6 +3579,19 @@ sub process {
> >                         WARN("EXPORTED_WORLD_WRITABLE",
> >                              "Exporting world writable files is usually an error. Consider more restrictive permissions.
> >                 }
> > +
> > +# check for double empty lines
> > +               if ($line =~ /^\+\s*$/) {
> > +                       my $nextline = "";
> > +                       if (defined($rawlines[$linenr])) {
> > +                               $nextline = $rawlines[$linenr];
> > +                       }
> > +                       if ($nextline =~ /^\s*$/ ||
> > +                           $prevline =~ /^\+?\s*$/ && $nextline !~ /^\+\s*$/) {
> > +                               CHK("DOUBLE_EMPTY_LINE",
> > +                                   "One empty line should be sufficient. Consider removing this one.\n" . $herecurr);
> > +                       }
> > +               }
> >         }
> >  
> > 
> > 
> 
> You cannot really rely on nextline even if valid as it may not even be
> from this hunk.  This is why in my attempt I detected the top of a long
> run of blanks and let the hunk start initialisation reset the detector.


I'm only testing the nextline if the current line is newly added. If I
got it right, when a line is newly added, the next line can be:
a. another new line
b. existing line (provided for context)
c. Does not exist since this is the end of the file (I missed this one
originally)

It cannot just jump to the next hunk and it cannot be a deleted line,
right?

> 
> From 6556d7bc2f9447e1d179c1dd32a618b124c26e46 Mon Sep 17 00:00:00 2001
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
> index fb67d47..ae01b90 100755
> --- a/scripts/checkpatch.pl
> +++ b/scripts/checkpatch.pl
> @@ -1413,6 +1413,7 @@ sub process {
>  	my %suppress_whiletrailers;
>  	my %suppress_export;
>  	my $suppress_statement = 0;
> +	my $suppress_multipleblank = -1;
>  
>  	# Pre-scan the patch sanitizing the lines.
>  	# Pre-scan the patch looking for any __setup documentation.
> @@ -1523,6 +1524,7 @@ sub process {
>  			%suppress_whiletrailers = ();
>  			%suppress_export = ();
>  			$suppress_statement = 0;
> +			$suppress_multipleblank = -1;
>  			next;
>  
>  # track the line number as we move through the hunk, note that
> @@ -1945,6 +1947,15 @@ sub process {
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

Please consider this patch as an example to three newly added double
empty lines that are not caught by this version but are seen in the
attempt I sent before:

diff --git a/test.c b/test.c
index e3f1362..5ced040 100644
--- a/test.c
+++ b/test.c
@@ -1,4 +1,5 @@
 
+
 /* there is an empty line just above me (the first line in this file)
  * nothing
  * nothing
@@ -12,17 +13,8 @@
  */
  /* There is an empty line just below me */
 
-/* nothing
- * nothing
- * nothing
- * nothing
- * nothing
- * nothing
- * nothing
- * nothing
- * nothing
- * nothing
- */
+
+/* just added a new empty line after deleting a segment */
 /* nothing
  * nothing
  * nothing
@@ -36,3 +28,4 @@
  */
  /* The last line (right below me) is empty */
 
+
