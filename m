From: Johannes Rudolph <johannes.rudolph@googlemail.com>
Subject: Spinlock spinning in __inet_hash_connect
Date: Wed, 6 Mar 2013 10:52:05 +0100
Message-ID: <CAKF7Hnf_EyF38OEKk2rJEvEvn+eftJ4CaHN7-SszqbZius81yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f181.google.com ([209.85.220.181]:61386 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454Ab3CFJw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 04:52:26 -0500
Received: by mail-vc0-f181.google.com with SMTP id f13so4660119vcb.40
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 01:52:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

I hope I'm on the correct mailing list for raising this issue. We are
seeing an issue while running a load test with jmeter against a web
server [1]. The test suite uses 50 threads to connect to a localhost
web server, runs one http request per connection and then loops. What
happens is that after the test runs for about 10 seconds (~ 100000
connections established / closed) the CPU load goes up and connection
rates slow down massively (see [1] for a chart). With `perf top` I'm
observing this on the _client_ side:

 41.39%  [kernel]                                    [k] __ticket_spin_lock
 16.83%  [kernel]                                    [k]
__inet_check_established
 12.50%  [kernel]                                    [k] __inet_hash_connect
  4.35%  [kernel]                                    [k] __ticket_spin_unlock

I've also recorded a call graph a log of which you can find in [2].
This was on Ubuntu 12.10 Linux 3.6.3-030603-generic x86_64. The same
test run against another webserver doesn't show this behavior under
the particular setup.

I've found a related issue for totally different application and setup
[3]. The problem seems related to handing out ephemeral ports when
there are only few ephemeral ports available and (I guess) there's
much congestion on the ephemeral ports hashtable. As suggested in [3]
setting `tcp_tw_reuse=1` seems to fix the issue in the particular test
case but it could be that it is only because it takes pressure from
the ports available.

Before doing more research I wanted to put that here for the record
and for suggestions how to proceed further. What I could do:

 * run the test on a more recent kernel (3.8.2)
 * provide you with instructions how to reproduce the behavior
 * upload the `perf report` if that helps

Thanks,

--
Johannes

[1] https://groups.google.com/d/topic/spray-user/76klWTHtsr4/discussion
[2] https://gist.github.com/jrudolph/5098113
[3] https://bugs.launchpad.net/percona-playback/+bug/1059330

-----------------------------------------------
Johannes Rudolph
http://virtual-void.net
