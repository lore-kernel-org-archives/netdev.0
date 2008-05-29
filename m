From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Thu, 29 May 2008 14:14:42 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu> <20080529084524.GA24892@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52984 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbYE2LOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 07:14:45 -0400
In-Reply-To: <20080529084524.GA24892@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 May 2008, Ingo Molnar wrote:
> * Ingo Molnar <mingo@elte.hu> wrote:
> 
> > in an overnight -tip testruns that is based on recent -git i got two 
> > stuck TCP connections:
> > 
> > Active Internet connections (w/o servers)
> > Proto Recv-Q Send-Q Local Address               Foreign Address             State      
> > tcp        0 174592 10.0.1.14:58015             10.0.1.14:3632              ESTABLISHED 
> > tcp    72134      0 10.0.1.14:3632              10.0.1.14:58015             ESTABLISHED 
> 
> update: in the past 5 days of -tip testing i've gathered about 10 
> randconfig kernel configs that all produced such failures.

...I tried yesterday some accept (& read some) & close/exit type 
stressing but I couldn't get it to show up (though I'll try longer 
time later on and also fault style exiting).

> Since the bug itself is very elusive (it takes up to 50 boot + 
> kernel-rebuild-via-distccc iterations to trigger) bisection was still 
> not an option - but with 10 configs statistical analysis of the configs 
> is now possible.
> 
> I made a histogram of all kernel options present in those configs, and 
> one networking related kernel option stood out:
> 
>       5 CONFIG_TCP_CONG_ADVANCED=y
>       6 CONFIG_INET_TCP_DIAG=y
>       6 CONFIG_TCP_MD5SIG=y
>       9 CONFIG_TCP_CONG_CUBIC=y
> 
> that code is called in the bootlogs:
> 
> > [   13.279410] calling  cubictcp_register+0x0/0x80
> > [   13.279412] TCP cubic registered
> 
> the likelyhood of CONFIG_TCP_CONG_CUBIC=y being enabled in my randconfig 
> runs is 75%. The likelyhood of CONFIG_TCP_CONG_CUBIC=y being enabled in 
> 10 configs in a row is 0.75^10, or 5.6%. So statistical analysis can say 
> it with a 95% confidence that the presence of this option correlates to 
> the hung sockets.

Do I understand you correctly... it doesn't explain the tenth case out 
of ten but just nine of them?

> i have started testing this theory now, via the patch below, which turns 
> off TCP_CONG_CUBIC. It will take about 50 bootups on the affected 
> testsystems to confirm. (it will take a couple of hours today as not all 
> testsystems show these hung socket symptoms)
> 
> distributions enable TCP_CONG_CUBIC by default:
> 
>   $ grep CUBIC /boot/config-2.6.24.7-92.fc8
>   CONFIG_TCP_CONG_CUBIC=y
>   CONFIG_DEFAULT_CUBIC=y
> 
> which would explain why Arjan and Peter triggered similar hangs as well.

Main problem with this explanation is that congestion control modules are 
only in use when TCP is in ESTABLISHED and transmitting normally, while it 
has nothing to do how we enter or leave ESTABLISHED.

But if it's really that the process who owned the connection already went 
away, I think we should end up into tcp_close() which changes the state 
from established (and send RST too if there's still data to be received, 
which would be picked up by the other end and that end would no longer 
keep established either). ...A failure to send the reset would show up in 
LINUX_MIB_TCPABORTFAILED. Because both ends remain in established, it kind 
of excludes the possibility that something would have accidently allowed 
the Recv-Q end to return back to established too (due to some bug).

To me there are mainly two weird things:
1) Why we see orphaning with data in the first place (I think distcc would 
be interested to read everything, unless some worker crashed in early...
Though some timeout in distcc could explain it as well but I don't know 
too well how distcc does everything)...
2) Why the connection is still in ESTABLISHED when it was orphaned and 
it has some data to receive... If it had some unread data, should be in 
CLOSE or in FIN_WAIT1 otherwise.

-- 
 i.
