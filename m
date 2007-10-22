From: Joseph Fannin <jfannin@gmail.com>
Subject: Regression in current git - Network Manager fails (bisected)
Date: Sun, 21 Oct 2007 20:58:58 -0400
Message-ID: <20071022005857.GA6317@nineveh.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Denis V. Lunev" <den@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.229]:33118 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbXJVBEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 21:04:07 -0400
Received: by nz-out-0506.google.com with SMTP id s18so282319nze
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2007 18:04:05 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Network Manager (the freedesktop.org one) fails to work with Linus's
current git on a couple of different boxes I have here.  All the boxes
have different NIC types, with different drivers.

I've bisected it down to cd40b7d3983c708aabe3d3008ec64ffce56d33b0 ,
"[NET]: make netlink user -> kernel interface synchronious".  I've
double checked this by testing the kernel as of the immediately
previous commit; Network Manager works with that one, as it did on all
my machines in 2.6.23-mm1.

The netlink change seems to confuse N-M, and it somehow decides that
there's no link beat, so doesn't try to bring up the interface.  If I
run "ifconfig eth0 up", N-M will decide there's a carrier after all
and takes over.  Ethtool detects the link state correctly even with
the interface down.

If I down the interface again with ifconfig, N-M brings it right back
up without a problem, but if I kill N-M, it'll down the interface
before it exits, and fail in the same way as before when restarted.

N-M also emits this error:

"-- Error: Invalid message: type=DONE length=20 flags=<MULTI> sequence-nr=1193012574 pid=1185943630"

...which it doesn't do on kernels where it works normally.
strace'ing NetworkManager shows that it prints that message just after
talking over a netlink socket.

Networking otherwise works fine here with the latest git and N-M, if I
use the ifconfig "trick" to get the link up.

--
Joseph Fannin
jfannin@gmail.com

