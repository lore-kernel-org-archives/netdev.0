From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 31 Oct 2008 12:42:34 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0810311222240.7072@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810302047030.22084@wrl-59.cs.helsinki.fi>
 <20081031.005219.141937694.davem@davemloft.net>
 <Pine.LNX.4.64.0810311119510.7072@wrl-59.cs.helsinki.fi>
 <20081031.025159.51432990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-2137390123-1225449754=:7072"
Cc: shemminger@vyatta.com, zbr@ioremap.net, rjw@sisk.pl, mingo@elte.hu,
	s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, efault@gmx.de,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751602AbYJaKmw@vger.kernel.org>
In-Reply-To: <20081031.025159.51432990.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-2137390123-1225449754=:7072
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 31 Oct 2008, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Fri, 31 Oct 2008 11:40:16 +0200 (EET)
> 
> > Let me remind that it is just a single process, so no ping-pong & other 
> > lock related cache effects should play any significant role here, no? (I'm 
> > no expert though :-)).
> 
> Not locks or ping-pongs perhaps, I guess.  So it just sends and
> receives over a socket, implementing both ends of the communication
> in the same process?

Effectively its this:

signal(SIGALRM, alarm_handler);
...
while (flag) { /* flagged by alarm_handler */
	loops = 90
	open & setup sockets & connection
	while (--loops > 0) {
		write(wr_fd, buf, size);
		read(rd_fd, buf, size);
	}
	close sockets
}

where size comes from this array (advancing in the inner loop one by one):

static int sizes[] = {
        1, 3, 5, 7, 16, 32, 64, 512, 1024, 2048,        /* misc. sizes */
        1, 3, 5, 7, 16, 32, 64, 512, 1024, 2048,
        32, 32, 32, 32, 32, 32,         /* x windows mostly... */
        512, 512, 512, 512, 512,        /* DBMS's mostly */
};

buf sits in the stack and is not initialized (besides reading into it).

...I think the rest is just bogus complexity :-) ...maybe I should just 
take that from above as basis for Reduced AIM9 benchmark, it nearly 
compiles already.

> If hash chain conflicts do happen for those 2 sockets, just traversing
> the chain 2 entries deep could show up.

No idea on this one.


-- 
 i.
---696208474-2137390123-1225449754=:7072--
