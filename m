From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 108191] New: tcp option TCP_USER_TIMEOUT working incorrect
 within tcp keepalive.
Date: Fri, 20 Nov 2015 08:22:55 -0800
Message-ID: <20151120082255.61842a04@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35499 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759269AbbKTQXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 11:23:23 -0500
Received: by pacej9 with SMTP id ej9so120652632pac.2
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 08:23:22 -0800 (PST)
Received: from xeon-e3 (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id ag1sm271120pbc.41.2015.11.20.08.23.22
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 08:23:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 20 Nov 2015 11:03:58 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 108191] New: tcp option TCP_USER_TIMEOUT working incorrect within tcp keepalive.


https://bugzilla.kernel.org/show_bug.cgi?id=108191

            Bug ID: 108191
           Summary: tcp option TCP_USER_TIMEOUT working incorrect within
                    tcp keepalive.
           Product: Networking
           Version: 2.5
    Kernel Version: 4.3
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: jj.net@163.com
        Regression: No

The TCP_USER_TIMEOUT semantic means when you send an packet,
how long time no received the ACK should disconnect the connection.

In tcp retransmits case, 
retransmits_timed_out checkout this timeout, it walks well.

but in keepalive case.
the code below may have bugs:

....
    elapsed = keepalive_time_elapsed(tp);

    if (elapsed >= keepalive_time_when(tp)) {
        /* If the TCP_USER_TIMEOUT option is enabled, use that
         * to determine when to timeout instead.
         */
        if ((icsk->icsk_user_timeout != 0 &&
            elapsed >= icsk->icsk_user_timeout &&
            icsk->icsk_probes_out > 0) ||
            (icsk->icsk_user_timeout == 0 &&
            icsk->icsk_probes_out >= keepalive_probes(tp))) {
            tcp_send_active_reset(sk, GFP_ATOMIC);
            tcp_write_err(sk);
            goto out;
        }
.....
elapsed >= icsk->icsk_user_timeout should be
elapsed-keepalive_time_when(tp) >= icsk->icsk_user_timeout 

here is the timeline:

idle   .......   keepalive1         ......       keepalive2 ...
keepalive_probes
<- katime_when ->          <- keepalive_intvl  ->
                 <-  TCP_USER_TIMEOUT ->  // user expected timeout
<---------------elapsed---------------->
                 <-elapsed-katime_when->


/* test code */
int v;
v=1;setsockopt(fd, SOL_SOCKET, SO_KEEPALIVE, &v, 4);
v=30;setsockopt(fd, SOL_TCP, TCP_KEEPIDLE, &v, 4);
v=5;setsockopt(fd, SOL_TCP, TCP_KEEPINTVL, &v, 4);
v=3;setsockopt(fd, SOL_TCP, TCP_KEEPCNT, &v, 4);
v=20*1000; setsockopt(fd, SOL_TCP, TCP_USER_TIMEOUT, &v, 4); 
connect(fd, addr, sizeof(addr);
// when connect
// drop the recv data
// iptables -t filter -A INPUT --protocol tcp --dport 8888 -j DROP
pause();

we can see 30s later, tcp start keepalive, and close connection
without do the  first retransmits (because 30+5 > 20)
but we want waiting 20 second.

-- 
You are receiving this mail because:
You are the assignee for the bug.
