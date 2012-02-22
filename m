From: Joe Perches <joe@perches.com>
Subject: RE: [PATCH] checkpatch: Add some --strict coding style checks
Date: Tue, 21 Feb 2012 17:36:21 -0800
Message-ID: <1329874581.5143.22.camel@joe2Laptop>
References: <20120221151435.GA19354@tuxdriver.com>
	 <20120221.144417.1445117001833888214.davem@davemloft.net>
	 <CAMXE1-qB8_5oGey2=Ypa5BitZnye3YqdM=yB8oKCGLvoZu_8HQ@mail.gmail.com>
	 <20120221.154053.2103818562080068513.davem@davemloft.net>
	 <1329857959.5143.11.camel@joe2Laptop>
	 <804857E1F29AAC47BF68C404FC60A18429B3EE@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andy Whitcroft <apw@shadowen.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"andrei.emeltchenko.news@gmail.com"
	<andrei.emeltchenko.news@gmail.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <804857E1F29AAC47BF68C404FC60A18429B3EE@ORSMSX102.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-02-21 at 22:09 +0000, Allan, Bruce W wrote:
> This appears to falsely complain about parenthesis alignment in
> conditional statements with multiple opening parentheses.

Hey Allan.

Can you try this one please?
---
 scripts/checkpatch.pl |   58 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index a3b9782..e95419e 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -1330,6 +1330,35 @@ sub check_absolute_file {
 	}
 }
 
+sub pos_last_openparen {
+
+	my ($args) = @_;
+
+	my $pos = 0;
+	my $len = length($args);
+
+	my $opens = $args =~ tr/\(/\(/;
+	my $closes = $args =~ tr/\)/\)/;
+
+	my $last_openparen = 0;
+
+	if (($opens == 0) || ($closes >= $opens)) {
+		return 0;
+	}
+
+	for ($pos = 0; $pos < $len; $pos++) {
+		if (substr($args, $pos) =~ /^($FuncArg)/) {
+			$pos += length($1);
+		}
+
+		if (substr($args, $pos, 1) eq '(') {
+			$last_openparen = $pos;
+		}
+	}
+
+	return $last_openparen + 1;
+}
+
 sub process {
 	my $filename = shift;
 
@@ -1783,6 +1812,35 @@ sub process {
 			     "please, no space before tabs\n" . $herevet);
 		}
 
+# check for && or || at the start of a line
+		if ($rawline =~ /^\+\s*(&&|\|\|)/) {
+			CHK("LOGICAL_CONTINUATIONS",
+			    "Logical continuations should be on the previous line\n" . $hereprev);
+		}
+
+# check multi-line statement indentation matches previous line
+		if ($prevline =~ /^\+(\t*)(if \(|$Ident\().*(\&\&|\|\||,)\s*$/ && $rawline =~ /^\+([ \t]*)/) {
+			$prevline =~ /^\+(\t*)(if \(|$Ident\()(.*)(\&\&|\|\||,)\s*$/;
+			my $oldindent = $1;
+			my $if_or_func = $2;
+			my $args = $3;
+
+			my $pos = pos_last_openparen($args);
+
+			my $len = length($if_or_func) + $pos;
+			$rawline =~ /^\+([ \t]*)/;
+			my $newindent = $1;
+
+			my $goodindent = $oldindent .
+					 "\t" x ($len / 8) .
+					 " "  x ($len % 8);
+
+			if ($newindent ne $goodindent) {
+				CHK("PARENTHESIS_ALIGNMENT",
+				    "Alignment should match open parenthesis\n" . $hereprev);
+			}
+		}
+
 # check for spaces at the beginning of a line.
 # Exceptions:
 #  1) within comments
