From: Daniel Borkmann <borkmann@iogearbox.net>
Subject: Fwd: Kernel Oops in __inet_twsk_kill()
Date: Wed, 05 Nov 2014 17:00:52 +0100
Message-ID: <545A49B4.7090107@iogearbox.net>
References: <FB8A4655DFD2B34DB16AE06DDDD6C0E231A6F030@SJEXCHMB12.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: charley.chu@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57072 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754655AbaKEQWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 11:22:30 -0500
In-Reply-To: <FB8A4655DFD2B34DB16AE06DDDD6C0E231A6F030@SJEXCHMB12.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ moving to netdev ]

-------- Original Message --------
Subject: Kernel Oops in __inet_twsk_kill()
Date: Tue, 4 Nov 2014 23:47:18 +0000
From: Charley (Hao Chuan) Chu <charley.chu@broadcom.com>
To: linux-kernel@vger.kernel.org <linux-kernel@vger.kernel.org>

We have situation on our system. It brings the network interface up and down every
a few seconds. Eventually, it brings down the system - the kernel crashed due to BUG
on in __inet_twsk_kill(). The debug message show following call flow.

1) time-wait socket is created by tcp_time_wait() when the socket gets into "TIME_WAIT" state.
     inet_twsk_alloc()               - refcnt= 0
     inet_twsk_hashdance()  - refcnt = 3
     inet_twsk_schedule()      - refcnt = 4
     inet_twsk_put()                 - refcnt = 3
2) tcp_v4_timewait_ack() is called when sync is received
     inet_twsk_put()                  - refcnt= 2      <== where we thing the problem is
     occasionally, second sync is received, so the inet_twsk_put is called twice - refcnt = 1
3) twdr_do_twkill_work() is called when timed out
     call __inet_twsk_kill - BUG_ON!!! as refcnt=2 (supposed to be 3).
     call inet_twsk_put()

In a normal case, the callflow only has step 1 and step 3.  Our understanding is
the time-wait socket has three references - ehash, bhash and timer death row. In
step 2, none of them are touched. Can anyone here explain to us why the inet_twsk_put()
is called in tcp_v4_timewait_ack()?

our system has 3.14 kernel.

Any help would be highly appreciated.

Charley Chu

