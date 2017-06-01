From: Cyril Hrubis <chrubis@suse.cz>
Subject: commit f5f99309 (sock: do not set sk_err in sock_dequeue_err_skb)
 has broken ping
Date: Thu, 1 Jun 2017 16:00:48 +0200
Message-ID: <20170601140048.GA24401@rei.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Pravin B Shelar <pshelar@ovn.org>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Yaogong Wang <wygivan@google.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Al Viro <viro@zeniv.linux.org.uk>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!
I've started to wonder why is ping eating 100% CPU shortly after I've
upgraded my machine to 4.10 and here is what I found:

The ping main_loop() sleeps in poll() on its socket, the poll() usually times
out, at least that's what strace suggets which causes ping to sleep for ~1s in
the kernel.

See ping source at:

https://github.com/iputils/iputils/blob/master/ping_common.c#L587

The poll() seems to start returning POLLERR immediatelly after poll() is called
on the socket in a case that connection has dropped for a short while. It seems to be easily reproducible with:

* Starting ping with some ip address i.e. ping 4.2.2.2
* Letting it ping for a minute or so
* Disconnection a WAN cable from your AP
* After a minute or so ping ends up bussy looping on
  poll() that returns with POLLERR immediatelly
* After plugging the cable back the problem gets only
  worse since we now spend 99% of the time bussy looping
  on the poll() syscall
* And my CPU fan starts to scream loudly

I've bisected the problem to this commit:

commit f5f99309fa7481f59a500f0d08f3379cd6424c1f (HEAD, refs/bisect/bad)
Author: Soheil Hassas Yeganeh <soheil@google.com>
Date:   Thu Nov 3 18:24:27 2016 -0400

    sock: do not set sk_err in sock_dequeue_err_skb

-- 
Cyril Hrubis
chrubis@suse.cz
