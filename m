From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 33902] New: tcpi_state field in tcp_info
 structure reports TCP_CLOSE instead of TCP_TIME_WAIT state
Date: Mon, 06 Jun 2011 17:05:24 -0700 (PDT)
Message-ID: <20110606.170524.310088006.davem@davemloft.net>
References: <bug-33902-10286@https.bugzilla.kernel.org/>
	<20110425143421.3267fcc1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, Dmitry.Izbitsky@oktetlabs.ru
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45084
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755802Ab1FGAFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 20:05:53 -0400
In-Reply-To: <20110425143421.3267fcc1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 25 Apr 2011 14:34:21 -0700

> On Mon, 25 Apr 2011 08:08:36 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> Setup - TCP connection in ESTABLISHED state. Local socket calls
>> shutdown(SHUT_RDWR). After that peer calls shutdown(SHUT_RDWR).
>> 
>> Local socket should now be in TIME_WAIT state (from specification point 
>> of view). And it's indeed in TIME_WAIT (TCP_TIME_WAIT) state if we look at 
>> /proc/net/tcp (or netstat -t). However, if one tries to get connection state
>> via tcp_info (getsockopt(TCP_INFO)) the reported state is CLOSED (TCP_CLOSE).
>> 
>> Looks like the problem is in tcp_time_wait() function
>> (net/ipv4/tcp_minisocks.c).
>> It's called with state=TCP_TIME_WAIT, and sets inet_timewaitk_sock
>> *tw->tw_state field to TCP_TIME_WAIT. That's why the state is reported
>> correctly when looking into /proc. However, at the end it calls tcp_done(sk),
>> which itself calls tcp_set_state(TCP_CLOSE), so sk->sk_state is set to
>> TCP_CLOSE instead of TCP_TIME_WAIT. And it's reported this way via TCP_INFO
>> socket option.
>> 
>> Problem is reproduced on 2.6.26, 2.6.38 and is probably observed on earlier
>> kernels.

As far as the user side of the socket is concerned, it is TCP_CLOSE.

For timewait connections we create a completely seperate light-weight object
to manage the network side visible state of the TCP flow.  This is not
accessible from, and is entirely differently from, the heavy-weight full
socket we keep around until the user gives up his final reference.

So I do not see this behavior changing, it would be quite invasive and
expensive to make this work as you expect, and only for marginal gain.
