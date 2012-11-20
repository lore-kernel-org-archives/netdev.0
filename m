From: Andy Whitcroft <apw@canonical.com>
Subject: Re: [PATCH v2] checkpatch: add double empty line check
Date: Tue, 20 Nov 2012 11:52:39 +0000
Message-ID: <20121120115239.GA7955@dm>
References: <1353151057.14327.18.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	David Rientjes <rientjes@google.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1353151057.14327.18.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 17, 2012 at 01:17:37PM +0200, Eilon Greenstein wrote:
> Changes from previous attempt:
> - Use CHK instead of WARN
> - Issue only one warning per empty lines block
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  scripts/checkpatch.pl |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> index 21a9f5d..13d264f 100755
> --- a/scripts/checkpatch.pl
> +++ b/scripts/checkpatch.pl
> @@ -3579,6 +3579,14 @@ sub process {
>  			WARN("EXPORTED_WORLD_WRITABLE",
>  			     "Exporting world writable files is usually an error. Consider more restrictive permissions.\n" . $herecurr);
>  		}
> +
> +# check for double empty lines
> +		if ($line =~ /^\+\s*$/ &&
> +		    ($rawlines[$linenr] =~ /^\s*$/ ||
> +		     $prevline =~ /^\+?\s*$/ && $rawlines[$linenr] !~ /^\+\s*$/)) {
> +			CHK("DOUBLE_EMPTY_LINE",
> +			    "One empty line should be sufficient. Consider removing this one.\n" . $herecurr);
> +		}
>  	}
>  
>  	# If we have no input at all, then there is nothing to report on

In your previous version you indicated you would be emiting one per group
of lines, I do not see how this does that.  Also this fails if the fragment
is at the top of the hunk emiting a perl warning.  We should probabally
use the suppress approach.

How about something like the below.

-apw


>From 848ebffa8656a1ff96a91788ec0f1c04dab9c3e9 Mon Sep 17 00:00:00 2001
From: Andy Whitcroft <apw@canonical.com>
Date: Sat, 17 Nov 2012 13:17:37 +0200
Subject: [PATCH] checkpatch: strict warning for multiple blank lines

Signed-off-by: Andy Whitcroft <apw@canonical.com>
---
 scripts/checkpatch.pl |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index f18750e..dbc68f3 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -1411,6 +1411,7 @@ sub process {
 	my %suppress_whiletrailers;
 	my %suppress_export;
 	my $suppress_statement = 0;
+	my $suppress_multipleblank = -1;
 
 	# Pre-scan the patch sanitizing the lines.
 	# Pre-scan the patch looking for any __setup documentation.
@@ -1521,6 +1522,7 @@ sub process {
 			%suppress_whiletrailers = ();
 			%suppress_export = ();
 			$suppress_statement = 0;
+			$suppress_multipleblank = -1;
 			next;
 
 # track the line number as we move through the hunk, note that
@@ -1930,6 +1932,15 @@ sub process {
 			      "use the SSYNC() macro in asm/blackfin.h\n" . $herevet);
 		}
 
+# multiple blank lines.
+		if ($line =~ /^-/ || ($suppress_multipleblank == $linenr && $line =~ /^[ \+]\s*$/)) {
+			$suppress_multipleblank++;
+		} elsif ($prevline =~ /^\+\s*$/ and $line =~ /^\+\s*$/) {
+			$suppress_multipleblank = $linenr + 1;
+			CHK("MULTIPLE_EMPTY_LINE",
+			    "One empty line should be sufficient. Consider removing this one.\n" . $herecurr);
+		}
+
 # Check for potential 'bare' types
 		my ($stat, $cond, $line_nr_next, $remain_next, $off_next,
 		    $realline_next);
-- 
1.7.10.4
