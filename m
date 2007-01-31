From: Joe Perches <joe@perches.com>
Subject: Re: buggy IFB driver change
Date: Tue, 30 Jan 2007 16:24:40 -0800
Message-ID: <1170203080.31330.26.camel@localhost>
References: <20070130.131246.71091370.davem@davemloft.net>
	 <45BFBE1B.2040508@pobox.com> <20070130.141240.97296236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, m.kozlowski@tuxland.pl,
	akpm@osdl.org, torvalds@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3359 "EHLO Perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932098AbXAaBR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 20:17:28 -0500
In-Reply-To: <20070130.141240.97296236.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-01-30 at 14:12 -0800, David Miller wrote:
> > > Therefore we must decrement "i" twice before the first
> > > free during the cleanup.  One to "undo" the for() loop
> > > increment, and one to "skip" the ifb_init_one() case which
> > > failed.

Perhaps putting the error unwind inside the for loop
is simpler and more intelligible.

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index ca2b21f..0b24c31 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -264,19 +264,20 @@ static void ifb_free_one(int index)
 
 static int __init ifb_init_module(void)
 {
-	int i, err = 0;
+	int i, err;
 	ifbs = kmalloc(numifbs * sizeof(void *), GFP_KERNEL);
 	if (!ifbs)
 		return -ENOMEM;
-	for (i = 0; i < numifbs && !err; i++)
+	for (i = 0; i < numifbs; i++) {
 		err = ifb_init_one(i);
-	if (err) {
-		i--;
-		while (--i >= 0)
-			ifb_free_one(i);
+		if (err) {
+			while (i > 0)
+				ifb_free_one(--i);
+			return err;
+		}
 	}
 
-	return err;
+	return 0;
 }
 
 static void __exit ifb_cleanup_module(void)


