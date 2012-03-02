From: Joe Perches <joe@perches.com>
Subject: [PATCH] checkpatch: Add --strict tests for braces, comments and
 casts
Date: Thu, 01 Mar 2012 21:35:34 -0800
Message-ID: <1330666534.1939.19.camel@joe2Laptop>
References: <20120302025554.GA13493@joana>
	 <20120301.221643.881299898523907213.davem@davemloft.net>
	 <20120301.222316.1877216960521396397.davem@davemloft.net>
	 <20120301.222604.1508242694024394849.davem@davemloft.net>
	 <1330661602.1939.13.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>, gustavo@padovan.org,
	johan.hedberg@gmail.com, linville@tuxdriver.com,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Whitcroft <apw@shadowen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330661602.1939.13.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add some more subjective --strict tests.

Add a test for block comments that start with a blank
line followed only by a line with just the comment block
initiator.  Prefer a blank line followed by /* comment...

Add a test for unnecessary spaces after a cast.

Add a test for symmetric uses of braces in if/else blocks.
If one branch needs braces, then all branches should use braces.

Signed-off-by: Joe Perches <joe@perches.com>
---
 scripts/checkpatch.pl |   40 ++++++++++++++++++++++++++++++++--------
 1 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 308e401..581a14c 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -1849,6 +1849,17 @@ sub process {
 			}
 		}
 
+		if ($line =~ /^\+.*\*[ \t]*\)[ \t]+/) {
+			CHK("SPACING",
+			    "No space is necessary after a cast\n" . $hereprev);
+		}
+
+		if ($rawline =~ /^\+[ \t]*\/\*[ \t]*$/ &&
+		    $prevrawline =~ /^\+[ \t]*$/) {
+			CHK("BLOCK_COMMENT_STYLE",
+			    "Don't begin block comments with only a /* line, use /* comment...\n" . $hereprev);
+		}
+
 # check for spaces at the beginning of a line.
 # Exceptions:
 #  1) within comments
@@ -2954,7 +2965,8 @@ sub process {
 			#print "chunks<$#chunks> linenr<$linenr> endln<$endln> level<$level>\n";
 			#print "APW: <<$chunks[1][0]>><<$chunks[1][1]>>\n";
 			if ($#chunks > 0 && $level == 0) {
-				my $allowed = 0;
+				my @allowed = ();
+				my $allow = 0;
 				my $seen = 0;
 				my $herectx = $here . "\n";
 				my $ln = $linenr - 1;
@@ -2965,6 +2977,7 @@ sub process {
 					my ($whitespace) = ($cond =~ /^((?:\s*\n[+-])*\s*)/s);
 					my $offset = statement_rawlines($whitespace) - 1;
 
+					$allowed[$allow] = 0;
 					#print "COND<$cond> whitespace<$whitespace> offset<$offset>\n";
 
 					# We have looked at and allowed this specific line.
@@ -2977,23 +2990,34 @@ sub process {
 
 					$seen++ if ($block =~ /^\s*{/);
 
-					#print "cond<$cond> block<$block> allowed<$allowed>\n";
+					#print "cond<$cond> block<$block> allowed<$allowed[$allow]>\n";
 					if (statement_lines($cond) > 1) {
 						#print "APW: ALLOWED: cond<$cond>\n";
-						$allowed = 1;
+						$allowed[$allow] = 1;
 					}
 					if ($block =~/\b(?:if|for|while)\b/) {
 						#print "APW: ALLOWED: block<$block>\n";
-						$allowed = 1;
+						$allowed[$allow] = 1;
 					}
 					if (statement_block_size($block) > 1) {
 						#print "APW: ALLOWED: lines block<$block>\n";
-						$allowed = 1;
+						$allowed[$allow] = 1;
 					}
+					$allow++;
 				}
-				if ($seen && !$allowed) {
-					WARN("BRACES",
-					     "braces {} are not necessary for any arm of this statement\n" . $herectx);
+				if ($seen) {
+					my $sum_allowed = 0;
+					foreach (@allowed) {
+						$sum_allowed += $_;
+					}
+					if ($sum_allowed == 0) {
+						WARN("BRACES",
+						     "braces {} are not necessary for any arm of this statement\n" . $herectx);
+					} elsif ($sum_allowed != $allow &&
+						 $seen != $allow) {
+						CHK("BRACES",
+						    "braces {} should be used on all arms of this statement\n" . $herectx);
+					}
 				}
 			}
 		}
-- 
1.7.8.111.gad25c.dirty
