From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sun, 1 Jun 2008 00:39:05 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805312332270.2760@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu> <1211966834.12349.62.camel@twins>
  <a01a16b50805310725x4f1c375ep2d091bb044ac0787@mail.gmail.com>
 <Pine.LNX.4.64.0805311839540.2657@wrl-59.cs.helsinki.fi>  <484191BD.8000904@gmail.com>
  <Pine.LNX.4.64.0805312119270.2672@wrl-59.cs.helsinki.fi>
 <a01a16b50805311325w7f58ca69h93d02af9bc28d2ea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1879758402-1212267869=:2760"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: "=?UTF-8?Q?H=C3=A5kon_L=C3=B8vdal?=" <hlovdal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40169 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894AbYEaVjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 17:39:08 -0400
In-Reply-To: <a01a16b50805311325w7f58ca69h93d02af9bc28d2ea@mail.gmail.com>
Content-ID: <Pine.LNX.4.64.0806010014220.2760@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1879758402-1212267869=:2760
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0806010009281.2760@wrl-59.cs.helsinki.fi>

On Sat, 31 May 2008, Håkon Løvdal wrote:

> 2008/5/31 Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>:
>
> > So you had that '-' earlier and you checked at that time but the
> > connection is now already dead?
>
> This is only from checking after the connection was dead.

Could you please rephrase the answer, I failed to understand it... :-)
...You said earlier that you had '-' owned connections like Ingo, when did 
that happen (now the connections won't exists anymore, so at what point of 
time you saw those non-owned connections)?

> By the way,
> I just had to remotely reboot the new machine because the window
> manager locked up, however the old PC are still listing the defunct
> connections after this.

Ok.

> > :-(, I would some much liked to see what they were doing.
>
> I can of course keep on copying for testing purposes, but then I would 
> like to be able to dump only that single tcp connection, any tips of how 
> to do that?
> I found nothing specific in the manuals of wireshark and tcpdump. Of 
> cours it is possible to capture everything and filter afterwards, but 
> since I will be transferring lots of data the logs will get huge and I 
> would not like to have even additional traffic inside...

I didn't really mean tcpdump, I was more thinking of syscall what is the 
syscall where the process is waiting. Though tcpdump might reveal 
something as well about the behavior when nearing the problem,

tcpdump -n -i <iface> host <blahblah> and port <portno> and ...

Host & port as written above matches for either src and dst, I don't 
remember how one could specify just one of them but it's not usually 
necessary (won't be here either).

> > These 7C/D... certainly seem strange values. Which TCP variant you 
> > have in use (cat /proc/sys/net/ipv4/tcp_congestion_control)? It seems 
> > that vegas, veno and yeah at least contain 0x7fffffff there for some 
> > rtt, which could perhaps somehow leak.
> 
> I have not done any specific selection myself. On old_pc: bic, new_pc: 
> cubic.

Ok, after some searching it also seems that it was a dead-end anyway:
  - icsk_retransmit_timer is only set to icsk->icsk_timeout or
    jiffies + (HZ / 20)
  - icsk_timeout is only set after if (when > max_when) limiting (in 
    unsigned quantities)
  - max_when is always given TCP_RTO_MAX by TCP... 

...I'm currently out of ideas with this one then, I think I checked all 
types too and nothing came up :-(.

Hmm, perhaps periodically checking /proc/net/tcp (e.g., once per 10s) if 
the timeout is larger than TCP_RTO_MAX might allow some script to 
immediately notice when things broke while reproducing it. Storing all 
those once per 10s values shouldn't be a too big either, it could even be 
done in both ends for a single flow (but I'll leave a script to do that on 
Monday).

-- 
 i.
---696208474-1879758402-1212267869=:2760--
