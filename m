From: "David S. Miller" <davem@redhat.com>
Subject: Re: crash in fib_hash_move
Date: Fri, 17 Sep 2004 12:36:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040917123614.282a55a1.davem@redhat.com>
References: <20040917114249.7449b9ff@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040917114249.7449b9ff@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 17 Sep 2004 11:42:49 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Current 2.6 tree is crashing on bootup in fib code.
> Looks like recent FIB changes problem.

Missing memset()'s on the newly allocated hash tables,
fixed by the following which I just pused to Linus:

Return-Path: <dgibson@ozlabs.org>
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by devserv.devel.redhat.com (8.12.11/8.12.10) with ESMTP id i8H6XIL3028885
	for <davem@devserv.devel.redhat.com>; Fri, 17 Sep 2004 02:33:18 -0400
Received: from mx1.redhat.com (mx1.redhat.com [172.16.48.31])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i8H6XPr27780
	for <davem@redhat.com>; Fri, 17 Sep 2004 02:33:25 -0400
Received: from ozlabs.org (ozlabs.org [203.10.76.45])
	by mx1.redhat.com (8.12.11/8.12.10) with ESMTP id i8H6XOij016918
	for <davem@redhat.com>; Fri, 17 Sep 2004 02:33:24 -0400
Received: by ozlabs.org (Postfix, from userid 1007)
	id B10E92BD6A; Fri, 17 Sep 2004 16:33:17 +1000 (EST)
Date: Fri, 17 Sep 2004 16:20:42 +1000
From: David Gibson <david@gibson.dropbear.id.au>
To: Andrew Morton <akpm@osdl.org>
Cc: David Miller <davem@redhat.com>, trivial@rustcorp.com.au,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Subject: [TRIVIAL] Fix recent bug in fib_semantics.c
Message-ID: <20040917062042.GE6523@zax>
Mail-Followup-To: David Gibson <david@gibson.dropbear.id.au>,
	Andrew Morton <akpm@osdl.org>, David Miller <davem@redhat.com>,
	trivial@rustcorp.com.au, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.6+20040818i
X-RedHat-Spam-Score: 0 
Status:   

Andrew, please apply:

When fib_create_info() allocates new hash tables, it neglects to
initialize them.  This leads to an oops during boot on at least
machine I use.  This patch addresses the problem.

Signed-off-by: David Gibson <dwg@au1.ibm.com>

Index: working-2.6/net/ipv4/fib_semantics.c
===================================================================
--- working-2.6.orig/net/ipv4/fib_semantics.c	2004-09-17 09:20:04.000000000 +1000
+++ working-2.6/net/ipv4/fib_semantics.c	2004-09-17 16:24:42.634638304 +1000
@@ -604,8 +604,12 @@
 		if (!new_info_hash || !new_laddrhash) {
 			fib_hash_free(new_info_hash, bytes);
 			fib_hash_free(new_laddrhash, bytes);
-		} else
+		} else {
+			memset(new_info_hash, 0, bytes);
+			memset(new_laddrhash, 0, bytes);
+
 			fib_hash_move(new_info_hash, new_laddrhash, new_size);
+		}
 
 		if (!fib_hash_size)
 			goto failure;



-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
