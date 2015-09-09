From: Palmer Dabbelt <palmer-96lFi9zoCfxBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 13/13] Re-enable and clean up "check_config()" in headers_check.pl
Date: Wed,  9 Sep 2015 14:08:22 -0700
Message-ID: <1441832902-28993-14-git-send-email-palmer@dabbelt.com>
References: <2644177.lVCYzIBfPW@wuerfel>
 <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
Cc: 3chas3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org
Cc: mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org
Cc: jikos-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org
Cc: tomi.valkeinen-l0cyMroinI0@public.gmane.org
Cc: x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: Palmer Dabbelt <palmer-96lFi9zoCfxBDgjK7y7TUQ@public.gmane.org>
In-Reply-To: <1441832902-28993-1-git-send-email-palmer-96lFi9zoCfxBDgjK7y7TUQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I recently got bit by a CONFIG_ in userspace bug.  This has apparently
happened before, but the check got disabled for triggering too much.
In order to reduce false positives, I added some hueristics to avoid
detecting comments.

Since these tests all pass, I've now re-enabled them.

Signed-off-by: Palmer Dabbelt <palmer-96lFi9zoCfxBDgjK7y7TUQ@public.gmane.org>
Reviewed-by: Andrew Waterman <waterman-aFE07iDfcCIb0cFwG/AQJIdd74u8MsAO@public.gmane.org>
Reviewed-by: Albert Ou <aou-aFE07iDfcCIb0cFwG/AQJIdd74u8MsAO@public.gmane.org>
---
 scripts/headers_check.pl | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/scripts/headers_check.pl b/scripts/headers_check.pl
index 62320f93e903..dd413ad9c850 100755
--- a/scripts/headers_check.pl
+++ b/scripts/headers_check.pl
@@ -40,7 +40,7 @@ foreach my $file (@files) {
 		&check_asm_types();
 		&check_sizetypes();
 		&check_declarations();
-		# Dropped for now. Too much noise &check_config();
+		&check_config();
 	}
 	close $fh;
 }
@@ -76,9 +76,24 @@ sub check_declarations
 	}
 }
 
+my $check_config_in_multiline_comment = 0;
 sub check_config
 {
-	if ($line =~ m/[^a-zA-Z0-9_]+CONFIG_([a-zA-Z0-9_]+)[^a-zA-Z0-9_]/) {
+	my $nocomments = $line;
+	$nocomments =~ s/\/\*.*\*\///; # Remove ANSI-style comments (/* to */)
+	$nocomments =~ s/\/\/.*//;     # Remove C99-style comments (// to EOL)
+
+	# Check to see if we're within a multiline comment, and if so
+	# just remove the whole line.  I tried matching on '^ * ', but
+	# there's one header that doesn't prepend multi-line comments
+	# with * so that won't work.
+	if ($nocomments =~ m/\/\*/) { $check_config_in_multiline_comment = 1; }
+	if ($nocomments =~ m/\*\//) { $check_config_in_multiline_comment = 0; }
+	if ($check_config_in_multiline_comment == 1) { $nocomments = "" }
+
+	# Check to see if there is something that looks like CONFIG_
+	# inside a userspace-accessible header file and if so, print that out.
+	if ($nocomments =~ m/[^a-zA-Z0-9_]+CONFIG_([a-zA-Z0-9_]+)[^a-zA-Z0-9_]/) {
 		printf STDERR "$filename:$lineno: leaks CONFIG_$1 to userspace where it is not valid\n";
 	}
 }
-- 
2.4.6
