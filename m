From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skbuff truesize incorrect.
Date: Fri, 23 May 2014 09:00:51 -0700
Message-ID: <1400860851.5367.210.camel@edumazet-glaptop2.roam.corp.google.com>
References: <537E4AFD.20304@mentor.com>
	 <1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1400792601.5367.176.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140522.171033.1040508444998374401.davem@davemloft.net>
	 <87ppj5vupf.fsf@nemi.mork.no> <537F0DCA.6030901@mentor.com>
	 <87vbsw4z5x.fsf@nemi.mork.no> <537F6CC1.2000503@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	Jim Baxter <jim_baxter@mentor.com>,
	David Miller <davem@davemloft.net>, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kamal@canonical.com, edumazet@google.com, mszeredi@suse.cz,
	fw@strlen.de
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537F6CC1.2000503@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-05-23 at 08:44 -0700, Rick Jones wrote:

> If you are measuring performance with the likes of netperf, you should 
> be able to get an idea of the performance effect from the change in 
> service demand (CPU consumed per unit of work) even if the maximum 
> throughput remains capped.

This wont be enough to truly get an idea of the gains this patch brings.

Add some random drops in the equation, and instead of dropping packets,
we gently add them in the out of order queue, gently coalesce them,
gently allow SACK enabled flows to recover thanks to fast retransmits,
with no latency effect (No expensive collapse/prunes)

# nstat -az|egrep "TCPRcvCoalesce|TCPOFOQueue|TCPRcvCollapsed|Prune"
TcpExtPruneCalled               118                0.0
TcpExtRcvPruned                 0                  0.0
TcpExtOfoPruned                 0                  0.0
TcpExtTCPRcvCollapsed           1009               0.0
TcpExtTCPRcvCoalesce            857806             0.0
TcpExtTCPOFOQueue               201246             0.0

Yep, we _might_ consume some cpu cycles in the perfect case where no
packet was dropped, but this is kind of an utopia.
