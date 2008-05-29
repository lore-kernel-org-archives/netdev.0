From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Thu, 29 May 2008 10:45:24 +0200
Message-ID: <20080529084524.GA24892@elte.hu>
References: <20080526115628.GA31316@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:52047 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128AbYE2Ipr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 04:45:47 -0400
Content-Disposition: inline
In-Reply-To: <20080526115628.GA31316@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> in an overnight -tip testruns that is based on recent -git i got two 
> stuck TCP connections:
> 
> Active Internet connections (w/o servers)
> Proto Recv-Q Send-Q Local Address               Foreign Address             State      
> tcp        0 174592 10.0.1.14:58015             10.0.1.14:3632              ESTABLISHED 
> tcp    72134      0 10.0.1.14:3632              10.0.1.14:58015             ESTABLISHED 

update: in the past 5 days of -tip testing i've gathered about 10 
randconfig kernel configs that all produced such failures.

Since the bug itself is very elusive (it takes up to 50 boot + 
kernel-rebuild-via-distccc iterations to trigger) bisection was still 
not an option - but with 10 configs statistical analysis of the configs 
is now possible.

I made a histogram of all kernel options present in those configs, and 
one networking related kernel option stood out:

      5 CONFIG_TCP_CONG_ADVANCED=y
      6 CONFIG_INET_TCP_DIAG=y
      6 CONFIG_TCP_MD5SIG=y
      9 CONFIG_TCP_CONG_CUBIC=y

that code is called in the bootlogs:

> [   13.279410] calling  cubictcp_register+0x0/0x80
> [   13.279412] TCP cubic registered

the likelyhood of CONFIG_TCP_CONG_CUBIC=y being enabled in my randconfig 
runs is 75%. The likelyhood of CONFIG_TCP_CONG_CUBIC=y being enabled in 
10 configs in a row is 0.75^10, or 5.6%. So statistical analysis can say 
it with a 95% confidence that the presence of this option correlates to 
the hung sockets.

i have started testing this theory now, via the patch below, which turns 
off TCP_CONG_CUBIC. It will take about 50 bootups on the affected 
testsystems to confirm. (it will take a couple of hours today as not all 
testsystems show these hung socket symptoms)

distributions enable TCP_CONG_CUBIC by default:

  $ grep CUBIC /boot/config-2.6.24.7-92.fc8
  CONFIG_TCP_CONG_CUBIC=y
  CONFIG_DEFAULT_CUBIC=y

which would explain why Arjan and Peter triggered similar hangs as well.

	Ingo

---------------------->
Subject: qa: no TCP_CONG_CUBIC
From: Ingo Molnar <mingo@elte.hu>
Date: Thu May 29 09:45:51 CEST 2008

---
 net/ipv4/Kconfig |    4 ++++
 1 file changed, 4 insertions(+)

Index: tip/net/ipv4/Kconfig
===================================================================
--- tip.orig/net/ipv4/Kconfig
+++ tip/net/ipv4/Kconfig
@@ -454,6 +454,8 @@ config TCP_CONG_BIC
 config TCP_CONG_CUBIC
 	tristate "CUBIC TCP"
 	default y
+	depends on BROKEN_BOOT_ALLOWED
+	select BROKEN_BOOT
 	---help---
 	This is version 2.0 of BIC-TCP which uses a cubic growth function
 	among other techniques.
@@ -608,6 +610,8 @@ endif
 config TCP_CONG_CUBIC
 	tristate
 	depends on !TCP_CONG_ADVANCED
+	depends on BROKEN_BOOT_ALLOWED
+	select BROKEN_BOOT
 	default y
 
 config DEFAULT_TCP_CONG
