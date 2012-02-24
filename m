From: Joe Perches <joe@perches.com>
Subject: [PATCH v2] checkpatch: Add some --strict coding style checks
Date: Fri, 24 Feb 2012 10:37:55 -0800
Message-ID: <1330108675.18464.21.camel@joe2Laptop>
References: <20120221151435.GA19354@tuxdriver.com>
	 <20120221.144417.1445117001833888214.davem@davemloft.net>
	 <CAMXE1-qB8_5oGey2=Ypa5BitZnye3YqdM=yB8oKCGLvoZu_8HQ@mail.gmail.com>
	 <20120221.154053.2103818562080068513.davem@davemloft.net>
	 <1329857959.5143.11.camel@joe2Laptop>
	 <804857E1F29AAC47BF68C404FC60A18429B3EE@ORSMSX102.amr.corp.intel.com>
	 <1329874581.5143.22.camel@joe2Laptop>
	 <804857E1F29AAC47BF68C404FC60A18429B8F2@ORSMSX102.amr.corp.intel.com>
	 <1329875935.5143.24.camel@joe2Laptop>
	 <804857E1F29AAC47BF68C404FC60A18429B98A@ORSMSX102.amr.corp.intel.com>
	 <1329968622.5143.46.camel@joe2Laptop>
	 <804857E1F29AAC47BF68C404FC60A1842A1D36@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	David Miller <davem@davemloft.net>,
	"andrei.emeltchenko.news@gmail.com"
	<andrei.emeltchenko.news@gmail.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Andy Whitcroft <apw@shadowen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <804857E1F29AAC47BF68C404FC60A1842A1D36@ORSMSX102.amr.corp.intel.com>
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

V2: Scan the entire line for balanced parentheses,
    use the position of the last non-balanced open parenthesis.
    Allow all space indentation too, checkpatch will complain
    in a different message about that if it's too long.

 scripts/checkpatch.pl |   65 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 63 insertions(+), 2 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 89d24b3..7a0514b 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -330,10 +330,11 @@ sub build_types {
 }
 build_types();
 
-our $match_balanced_parentheses = qr/(\((?:[^\(\)]+|(-1))*\))/;
+our $balanced_parens = qr/(\((?:[^\(\)]++|(?-1))*\))/;
+our $lval_parens = qr/(\((?:[^\(\)]+|(-1))*\))/;
 
 our $Typecast	= qr{\s*(\(\s*$NonptrType\s*\)){0,1}\s*};
-our $LvalOrFunc	= qr{($Lval)\s*($match_balanced_parentheses{0,1})\s*};
+our $LvalOrFunc	= qr{($Lval)\s*($lval_parens{0,1})\s*};
 our $FuncArg = qr{$Typecast{0,1}($LvalOrFunc|$Constant)};
 
 sub deparenthesize {
@@ -1330,6 +1331,36 @@ sub check_absolute_file {
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
+			$pos += length($1);
+		}
+
+		if (substr($line, $pos, 1) eq '(') {
+			$last_openparen = $pos;
+		}
+	}
+
+	return $last_openparen + 1;
+}
+
 sub process {
 	my $filename = shift;
 
@@ -1783,6 +1814,36 @@ sub process {
 			     "please, no space before tabs\n" . $herevet);
 		}
 
+# check for && or || at the start of a line
+		if ($rawline =~ /^\+\s*(&&|\|\|)/) {
+			CHK("LOGICAL_CONTINUATIONS",
+			    "Logical continuations should be on the previous line\n" . $hereprev);
+		}
+
+# check multi-line statement indentation matches previous line
+		if ($prevline =~ /^\+(\t*)(if \(|$Ident\().*(\&\&|\|\||,)\s*$/) {
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
