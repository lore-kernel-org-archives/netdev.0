From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 33902] New: tcpi_state field in tcp_info
 structure reports TCP_CLOSE instead of TCP_TIME_WAIT state
Date: Mon, 25 Apr 2011 14:34:21 -0700
Message-ID: <20110425143421.3267fcc1.akpm@linux-foundation.org>
References: <bug-33902-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, Dmitry.Izbitsky@oktetlabs.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53379 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752466Ab1DYVfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 17:35:19 -0400
In-Reply-To: <bug-33902-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 25 Apr 2011 08:08:36 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=33902
> 
>            Summary: tcpi_state field in tcp_info structure reports
>                     TCP_CLOSE instead of TCP_TIME_WAIT state
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.38
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: Dmitry.Izbitsky@oktetlabs.ru
>         Regression: No
> 
> 
> Setup - TCP connection in ESTABLISHED state. Local socket calls
> shutdown(SHUT_RDWR). After that peer calls shutdown(SHUT_RDWR).
> 
> Local socket should now be in TIME_WAIT state (from specification point 
> of view). And it's indeed in TIME_WAIT (TCP_TIME_WAIT) state if we look at 
> /proc/net/tcp (or netstat -t). However, if one tries to get connection state
> via tcp_info (getsockopt(TCP_INFO)) the reported state is CLOSED (TCP_CLOSE).
> 
> Looks like the problem is in tcp_time_wait() function
> (net/ipv4/tcp_minisocks.c).
> It's called with state=TCP_TIME_WAIT, and sets inet_timewaitk_sock
> *tw->tw_state field to TCP_TIME_WAIT. That's why the state is reported
> correctly when looking into /proc. However, at the end it calls tcp_done(sk),
> which itself calls tcp_set_state(TCP_CLOSE), so sk->sk_state is set to
> TCP_CLOSE instead of TCP_TIME_WAIT. And it's reported this way via TCP_INFO
> socket option.
> 
> Problem is reproduced on 2.6.26, 2.6.38 and is probably observed on earlier
> kernels.

