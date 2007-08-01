From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: Re: [Bugme-new] [Bug 8808] New: Large file transfer causes
 kernel panic showing b44_poll
Date: Wed, 01 Aug 2007 09:36:45 -0700
Message-ID: <1185986205.30383.7.camel@localhost.localdomain>
References: <bug-8808-10286@http.bugzilla.kernel.org/>
 <20070725115456.f7dac506.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	simsondem@gmail.com
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3582 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765700AbXHASfc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 14:35:32 -0400
In-Reply-To: <20070725115456.f7dac506.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-07-25 at 11:54 -0700, Andrew Morton wrote:
> On Wed, 25 Jul 2007 04:29:33 -0700 (PDT)
> bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=8808
> > 
> >            Summary: Large file transfer causes kernel panic showing b44_poll
> >            Product: Drivers
> >            Version: 2.5
> >      KernelVersion: 2.6.22.1
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: blocking
> >           Priority: P1
> >          Component: Network
> >         AssignedTo: jgarzik@pobox.com
> >         ReportedBy: simsondem@gmail.com
> > 
> > 
> > Most recent kernel where this bug did not occur: /
> > Distribution: ttylinux 
> > Hardware Environment: Dell Inspiron 1300
> > Problem Description: 
> > 
> > A large file transfer (6.5GB) (tried http with wget and plain netcat) causes a
> > kernel panic after more than several GB have been transferred. However, kernel
> > panic does not occur consistently. That is, it has occurred after 1.2GB, 1.8GB,
> > 2.3GB and even 3.4GB transferred. Transfer never finished though. 
> > 
I could not repro the problem, but please give this patch a try:

diff -rup a/b44.c b/b44.c
--- a/b44.c	2007-07-31 15:31:08.000000000 -0700
+++ b/b44.c	2007-08-01 08:03:08.000000000 -0700
@@ -792,15 +792,15 @@ static int b44_rx(struct b44 *bp, int bu
 			goto next_pkt;
 		}
 
-		if (len == 0) {
+		if (len < 5) {
 			int i = 0;
 
 			do {
 				udelay(2);
 				barrier();
 				len = le16_to_cpu(rh->len);
-			} while (len == 0 && i++ < 5);
-			if (len == 0)
+			} while (len < 5 && i++ < 5);
+			if (len < 5)
 				goto drop_it;
 		}
 



