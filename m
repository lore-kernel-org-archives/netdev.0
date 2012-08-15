From: Sage Weil <sage@inktank.com>
Subject: regression with poll(2)?
Date: Wed, 15 Aug 2012 12:46:16 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1208151226250.15721@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <ceph-devel-owner@vger.kernel.org>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm experiencing a stall with Ceph daemons communicating over TCP that 
occurs reliably with 3.6-rc1 (and linus/master) but not 3.5.  The basic 
situation is:

 - the socket is two processes communicating over TCP on the same host, e.g. 

tcp        0 2164849 10.214.132.38:6801      10.214.132.38:51729     ESTABLISHED

 - one end writes a bunch of data in
 - the other end consumes data, but at some point stalls.
 - reads are nonblocking, e.g.

  int got = ::recv( sd, buf, len, MSG_DONTWAIT );

 and between those calls we wait with

  struct pollfd pfd;
  short evmask;
  pfd.fd = sd;
  pfd.events = POLLIN;
#if defined(__linux__)
  pfd.events |= POLLRDHUP;
#endif

  if (poll(&pfd, 1, msgr->timeout) <= 0)
    return -1;

 - in my case the timeout is ~15 minutes.  at that point it errors out, 
and the daemons reconnect and continue for a while until hitting this 
again.

 - at the time of the stall, the reading process is blocked on that 
poll(2) call.  There are a bunch of threads stuck on poll(2), some of them 
stuck and some not, but they all have stacks like

[<ffffffff8118f6f9>] poll_schedule_timeout+0x49/0x70
[<ffffffff81190baf>] do_sys_poll+0x35f/0x4c0
[<ffffffff81190deb>] sys_poll+0x6b/0x100
[<ffffffff8163d369>] system_call_fastpath+0x16/0x1b

 - you'll note that the netstat output shows data queued:

tcp        0 1163264 10.214.132.36:6807      10.214.132.36:41738     ESTABLISHED
tcp        0 1622016 10.214.132.36:41738     10.214.132.36:6807      ESTABLISHED

etc.

Is this a known regression?  Or might I be misusing the API?  What 
information would help track it down?

Thanks!
sage


