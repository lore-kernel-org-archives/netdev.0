From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH] checkpatch: Add some --strict coding style checks
Date: Wed, 22 Feb 2012 19:43:42 -0800
Message-ID: <1329968622.5143.46.camel@joe2Laptop>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"andrei.emeltchenko.news-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org"
	<andrei.emeltchenko.news-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Allan, Bruce W" <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <804857E1F29AAC47BF68C404FC60A18429B98A-P5GAC/sN6hlcIJlls4ac1rfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-02-22 at 02:17 +0000, Allan, Bruce W wrote:
> Example 1:
> 	if (((a == b) ||
> 	     (c == d) ||
> 	     (e == f)) &&
> 	    (bool_var))
> 		baz();
> 
> Example 2:
> 	if ((!(var & FOO_MASK) &&
> 	     (a == b)) ||
> 	    (c == d))
> 		baz();
> 
> Example 3:
> 	if (!((foo & FOO_MASK) &&
> 	      (bar & BAR_MASK)))
> 		baz();
> 

Hi Bruce. (yay, I got your name right)

Thanks.

How about testing this?

It allows all spaces or appropriate tabs for indentation,
and I believe it works OK.

---
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
+	    my $string = substr($line, $pos);
+	    if ($string =~ /^($FuncArg|$balanced_parens)/) {
+		    $pos += length($1);
+	    }
+
+	    if (substr($line, $pos, 1) eq '(') {
+		$last_openparen = $pos;
+	    }
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


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
