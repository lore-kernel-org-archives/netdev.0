From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] fix PHY polling system blocking
Date: Sun, 21 Mar 2010 22:54:50 +0100
Message-ID: <1269208490.5748.44.camel@wall-e.seibold.net>
References: <1267894258.18869.2.camel@wall-e>
	 <20100312144248.ade8b700.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100312144248.ade8b700.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I had now analyzed the PHY handling in most of the network drivers. Most
of the PHY communication will be handled in a polling/blocking way,
write  a command word and then wait for the results. Due the nature of
the PHY attachment, this will take some time.

Some of the network drivers do this polling/blocking also in atomic code
paths, like interrupts or timer. So activities on the PHY can cause huge
latency jitters.

On the other side, most of the network driver handle the PHY without
using or only partially using the phylib.

The phylib has also a drawback, because it polls the PHY despite if it
has interrupt support for it or not. I can't see a reason for this
behavior.

So the problem of huge latencies by polling the PHY occurs in most of
the network drivers. For example have a look at the e100 network driver
in the file drivers/net/e100.c, function mdio_ctrl_hw(): This function
will poll for max. of 4000 us or 4 ms.

To fix this latency jitter problem with the PHY polling there are the
following steps to do:

- disable polling in driver/net/phy.c if an interrupt for the PHY is
available
- create an own single or per cpu workqueue for the phylib, so that the
PHY specific code can temporary schedule or block
- prevent all current user of the phylib to access the PHY in a atomic
code path
- modify all current users of the phylib from using cpu_relax() to
cond_resched() and replace the counters against inquiring a timeout 
- modify all other network drivers to use the phylib

What do you think?

Stefani
