From: Joe Perches <joe@perches.com>
Subject: [PATCH v3] checkpatch: Add some --strict coding style checks
Date: Wed, 29 Feb 2012 20:24:03 -0800
Message-ID: <1330575843.23314.52.camel@joe2Laptop>
References: <20120229173421.GA13733@tuxdriver.com>
	 <477F20668A386D41ADCC57781B1F70430836762D55@SC-VEXCH1.marvell.com>
	 <1330542811.21491.7.camel@joe2Laptop>
	 <477F20668A386D41ADCC57781B1F70430836762D6C@SC-VEXCH1.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
	Andy Whitcroft <apw@shadowen.org>,
	David Miller <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ilan Elias <ilane@ti.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Bruce W. Allen" <bruce.w.allan@intel.com>,
	Bing Zhao <bzhao@marvell.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <477F20668A386D41ADCC57781B1F70430836762D6C@SC-VEXCH1.marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Argument alignment across multiple lines should
match the open parenthesis.

Logical continuations should be at the end of
the previous line, not the start of a new line.

These are not required by CodingStyle so make the
tests active only when using --strict.

Improved_by_examples_from: "Bruce W. Allen" <bruce.w.allan@intel.com>
Signed-off-by: Joe Perches <joe@perches.com>
---
V3: Use perl 5.10 features
    Use a runtime check of perl version so $balanced_parens
    is not used in perl versions that don't support it.
    Update memset and min_t checks for newer $balanced_parens
    test.
    Improve alignment position test.
    Add message suggesting perl upgrade.
V2: Scan the entire line for balanced parentheses,
    use the position of the last non-balanced open parenthesis.
    Allow all space indentation too, checkpatch will complain
    in a different message about that if it's too long.

 scripts/checkpatch.pl |   94 +++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 84 insertions(+), 10 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 89d24b3..308e401 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -330,10 +330,15 @@ sub build_types {
 }
 build_types();
 
-our $match_balanced_parentheses = qr/(\((?:[^\(\)]+|(-1))*\))/;
 
 our $Typecast	= qr{\s*(\(\s*$NonptrType\s*\)){0,1}\s*};
-our $LvalOrFunc	= qr{($Lval)\s*($match_balanced_parentheses{0,1})\s*};
+
+# Using $balanced_parens, $LvalOrFunc, or $FuncArg
+# requires at least perl version v5.10.0
+# Any use must be runtime checked with $^V
+
+our $balanced_parens = qr/(\((?:[^\(\)]++|(?-1))*\))/;
+our $LvalOrFunc	= qr{($Lval)\s*($balanced_parens{0,1})\s*};
 our $FuncArg = qr{$Typecast{0,1}($LvalOrFunc|$Constant)};
 
 sub deparenthesize {
@@ -1330,6 +1335,36 @@ sub check_absolute_file {
 	}
 }
 
+sub pos_last_openparen {
+	my ($line) = @_;
+
+	my $pos = 0;
+
+	my $opens = $line =~ tr/\(/\(/;
+	my $closes = $line =~ tr/\)/\)/;
+
+	my $last_openparen = 0;
+
+	if (($opens == 0) || ($closes >= $opens)) {
+		return -1;
+	}
+
+	my $len = length($line);
+
+	for ($pos = 0; $pos < $len; $pos++) {
+		my $string = substr($line, $pos);
+		if ($string =~ /^($FuncArg|$balanced_parens)/) {
+			$pos += length($1) - 1;
+		} elsif (substr($line, $pos, 1) eq '(') {
+			$last_openparen = $pos;
+		} elsif (index($string, '(') == -1) {
+			last;
+		}
+	}
+
+	return $last_openparen + 1;
+}
+
 sub process {
 	my $filename = shift;
 
@@ -1783,6 +1818,37 @@ sub process {
 			     "please, no space before tabs\n" . $herevet);
 		}
 
+# check for && or || at the start of a line
+		if ($rawline =~ /^\+\s*(&&|\|\|)/) {
+			CHK("LOGICAL_CONTINUATIONS",
+			    "Logical continuations should be on the previous line\n" . $hereprev);
+		}
+
+# check multi-line statement indentation matches previous line
+		if ($^V && $^V ge 5.10.0 &&
+		    $prevline =~ /^\+(\t*)(if \(|$Ident\().*(\&\&|\|\||,)\s*$/) {
+			$prevline =~ /^\+(\t*)(.*)$/;
+			my $oldindent = $1;
+			my $rest = $2;
+
+			my $pos = pos_last_openparen($rest);
+			if ($pos >= 0) {
+				$line =~ /^\+([ \t]*)/;
+				my $newindent = $1;
+
+				my $goodtabindent = $oldindent .
+					"\t" x ($pos / 8) .
+					" "  x ($pos % 8);
+				my $goodspaceindent = $oldindent . " "  x $pos;
+
+				if ($newindent ne $goodtabindent &&
+				    $newindent ne $goodspaceindent) {
+					CHK("PARENTHESIS_ALIGNMENT",
+					    "Alignment should match open parenthesis\n" . $hereprev);
+				}
+			}
+		}
+
 # check for spaces at the beginning of a line.
 # Exceptions:
 #  1) within comments
@@ -3142,12 +3208,13 @@ sub process {
 		}
 
 # Check for misused memsets
-		if (defined $stat &&
+		if ($^V && $^V ge 5.10.0 &&
+		    defined $stat &&
 		    $stat =~ /^\+(?:.*?)\bmemset\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*$FuncArg\s*\)/s) {
 
 			my $ms_addr = $2;
-			my $ms_val = $8;
-			my $ms_size = $14;
+			my $ms_val = $7;
+			my $ms_size = $12;
 
 			if ($ms_size =~ /^(0x|)0$/i) {
 				ERROR("MEMSET",
@@ -3159,17 +3226,18 @@ sub process {
 		}
 
 # typecasts on min/max could be min_t/max_t
-		if (defined $stat &&
+		if ($^V && $^V ge 5.10.0 &&
+		    defined $stat &&
 		    $stat =~ /^\+(?:.*?)\b(min|max)\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\)/) {
-			if (defined $2 || defined $8) {
+			if (defined $2 || defined $7) {
 				my $call = $1;
 				my $cast1 = deparenthesize($2);
 				my $arg1 = $3;
-				my $cast2 = deparenthesize($8);
-				my $arg2 = $9;
+				my $cast2 = deparenthesize($7);
+				my $arg2 = $8;
 				my $cast;
 
-				if ($cast1 ne "" && $cast2 ne "") {
+				if ($cast1 ne "" && $cast2 ne "" && $cast1 ne $cast2) {
 					$cast = "$cast1 or $cast2";
 				} elsif ($cast1 ne "") {
 					$cast = $cast1;
@@ -3391,6 +3459,12 @@ sub process {
 	}
 
 	if ($quiet == 0) {
+
+		if ($^V lt 5.10.0) {
+			print("NOTE: perl $^V is not modern enough to detect all possible issues.\n");
+			print("An upgrade to at least perl v5.10.0 is suggested.\n\n");
+		}
+
 		# If there were whitespace errors which cleanpatch can fix
 		# then suggest that.
 		if ($rpt_cleaners) {
