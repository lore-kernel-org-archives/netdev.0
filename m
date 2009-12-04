From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: pull request: SCTP updates for net-next
Date: Thu, 3 Dec 2009 21:00:50 -0800
Message-ID: <20091203210050.d886f229.akpm@linux-foundation.org>
References: <4B0AF96A.3050709@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux SCTP Dev Mailing list <linux-sctp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrei Pelinescu-Onciul <andrei@iptel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50863 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750733AbZLDFAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 00:00:54 -0500
In-Reply-To: <4B0AF96A.3050709@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Nov 2009 16:06:50 -0500 Vlad Yasevich <vladislav.yasevich@hp.com> wrote:

> Andrei Pelinescu-Onciul (3):
>       sctp: allow setting path_maxrxt independent of SPP_PMTUD_ENABLE
>       sctp: limit maximum autoclose setsockopt value
>       sctp: fix integer overflow when setting the autoclose timer

Problems with this one:

: commit f6778aab6ccc4b510b4dcfa770d9949b696b4545
: Author:     Andrei Pelinescu-Onciul <andrei@iptel.org>
: AuthorDate: Mon Nov 23 15:54:01 2009 -0500
: Commit:     Vlad Yasevich <vladislav.yasevich@hp.com>
: CommitDate: Mon Nov 23 15:54:01 2009 -0500
: 
:     sctp: limit maximum autoclose setsockopt value
:     
:     To avoid overflowing the maximum timer interval when transforming
:     the  autoclose interval from seconds to jiffies, limit the maximum
:     autoclose value to MAX_SCHEDULE_TIMEOUT/HZ.
:     
:     Signed-off-by: Andrei Pelinescu-Onciul <andrei@iptel.org>
:     Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
: 
: diff --git a/net/sctp/socket.c b/net/sctp/socket.c
: index d2681a6..71513b3 100644
: --- a/net/sctp/socket.c
: +++ b/net/sctp/socket.c
: @@ -2086,6 +2086,9 @@ static int sctp_setsockopt_autoclose(struct sock *sk, char __user *optval,
:  		return -EINVAL;
:  	if (copy_from_user(&sp->autoclose, optval, optlen))
:  		return -EFAULT;
: +	/* make sure it won't exceed MAX_SCHEDULE_TIMEOUT */
: +	if (sp->autoclose > (MAX_SCHEDULE_TIMEOUT / HZ) )
: +		sp->autoclose = MAX_SCHEDULE_TIMEOUT / HZ ;
:  
:  	return 0;
:  }

a) it has two coding-style errors in two lines.  Please go away, add
   scripts/checkpatch.pl to your patch development tools and then continue
   reading.

b) have you done that yet?

c) it generates this on 64-bit:

net/sctp/socket.c: In function 'sctp_setsockopt_autoclose':
net/sctp/socket.c:2090: warning: comparison is always false due to limited range of data type

   but that's proving somewhat hard to fix in a nice way.

d) I'm not sure that we should fix it anyway.  Is it really a good
   idea to take an incorrect, invalid setting from userspace, to
   silently modify that setting and to not inform userspace?

   Bear in mind that MAX_SCHEDULE_TIMEOUT has different values on
   32- and 64-bit kernels.  So the same source code will have different
   behaviour depending on what type of kernel it is executed on.

   I think.

   It also means that kernel behaviour will differ as CONFIG_HZ is
   altered, in some way which I can't be bothered working out.


Overall, it would be way simpler and saner to clamp this value to some
explicit time period, IMO.

<pulls number out of thin air>

--- a/net/sctp/socket.c~a
+++ a/net/sctp/socket.c
@@ -2086,9 +2086,8 @@ static int sctp_setsockopt_autoclose(str
 		return -EINVAL;
 	if (copy_from_user(&sp->autoclose, optval, optlen))
 		return -EFAULT;
-	/* make sure it won't exceed MAX_SCHEDULE_TIMEOUT */
-	if (sp->autoclose > (MAX_SCHEDULE_TIMEOUT / HZ) )
-		sp->autoclose = MAX_SCHEDULE_TIMEOUT / HZ ;
+	/* make sure it won't exceed one hour */
+	sp->autoclose = min_t(u32, sp->autoclose, 60 * 60);
 
 	return 0;
 }
_



