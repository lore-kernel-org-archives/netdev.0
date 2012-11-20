From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH v2] checkpatch: add double empty line check
Date: Tue, 20 Nov 2012 21:10:35 +0200
Message-ID: <1353438635.10779.10.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1353151057.14327.18.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120115239.GA7955@dm>
 <1353421624.6559.9.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120144329.GE7955@dm>
 <1353424027.6559.15.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120154443.GK7955@dm>
 <1353427570.6559.21.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120161417.GA17797@dm> <20121120163607.GB17797@dm>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Joe Perches" <joe@perches.com>,
	"David Rientjes" <rientjes@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "Andy Whitcroft" <apw@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121120163607.GB17797@dm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-11-20 at 18:36 +0200, Andy Whitcroft wrote:
> On Tue, Nov 20, 2012 at 04:14:17PM +0000, Andy Whitcroft wrote:
> > On Tue, Nov 20, 2012 at 06:06:10PM +0200, Eilon Greenstein wrote:
> > > I'm only testing the nextline if the current line is newly added. If I
> > > got it right, when a line is newly added, the next line can be:
> > > a. another new line
> > > b. existing line (provided for context)
> > > c. Does not exist since this is the end of the file (I missed this one
> > > originally)
> > > 
> > > It cannot just jump to the next hunk and it cannot be a deleted line,
> > > right?
> 
> Oh and in theory at least it could be a - line, though diff never
> generates things in that order.
> 

Andy - I could not find any other perl warnings. In the current
suggestion, only $line and $prevline are being accessed unconditionally
and $rawlines[$linenr] is accessed only after checking it exists - so it
seems safe.

About the logic - true, if diff will show deleted lines after newly
added lines, some new double line segments will be missed. However, it
seems like few other things will break if diff will start acting out
like that. The suggestion you posted earlier will miss those as well,
and starting to check for this weird case (of deleted lines after the
added lines) does not seem right.

So this patch seems safe, it does not generate false positives and it
does catch all the cases we can currently generate with diff - can you
please consider applying it to checkpatch?

I'm posting it again below for easier reference, please let me know if
you would like me to send it in a clean email separately.

Thanks,
Eilon

>From 403038375a9c09046631f674d14c221758a0de61 Mon Sep 17 00:00:00 2001
From: Eilon Greenstein <eilong@broadcom.com>
Date: Tue, 20 Nov 2012 21:05:30 +0200
Subject: [PATCH] checkpatch: add double empty line check

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 scripts/checkpatch.pl |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 21a9f5d..c0c610c 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -3579,6 +3579,19 @@ sub process {
 			WARN("EXPORTED_WORLD_WRITABLE",
 			     "Exporting world writable files is usually an error. Consider more restrictive permissions.\n" . $herecurr);
 		}
+
+# check for double empty lines
+		if ($line =~ /^\+\s*$/) {
+			my $nextline = "";
+			if (defined($rawlines[$linenr])) {
+				$nextline = $rawlines[$linenr];
+			}
+			if ($nextline =~ /^\s*$/ ||
+			    $prevline =~ /^\+?\s*$/ && $nextline !~ /^\+\s*$/) {
+				CHK("DOUBLE_EMPTY_LINE",
+				    "One empty line should be sufficient. Consider removing this one.\n" . $herecurr);
+			}
+		}
 	}
 
 	# If we have no input at all, then there is nothing to report on
-- 
1.7.9.5
