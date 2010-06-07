From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netconsole: queue console messages to send later
Date: Mon, 07 Jun 2010 16:50:24 -0700 (PDT)
Message-ID: <20100607.165024.135517125.davem@davemloft.net>
References: <24059.1275417767@death.nxdomain.ibm.com>
	<1275938692-26997-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com, fubar@us.ibm.com,
	fbl@sysclose.org, mpm@selenic.com, gospo@redhat.com,
	nhorman@tuxdriver.com, jmoyer@redhat.com,
	shemminger@linux-foundation.org, linux-kernel@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	bonding-devel@lists.sourceforge.net
To: fleitner@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1275938692-26997-1-git-send-email-fleitner@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Flavio Leitner <fleitner@redhat.com>
Date: Mon,  7 Jun 2010 16:24:52 -0300

> There are some networking drivers that hold a lock in the
> transmit path. Therefore, if a console message is printed
> after that, netconsole will push it through the transmit path,
> resulting in a deadlock.
> 
> This patch fixes the re-injection problem by queuing the console
> messages in a preallocated circular buffer and then scheduling a
> workqueue to send them later with another context.
> 
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>

You absolutely and positively MUST NOT do this.  Otherwise netconsole
becomes completely useless.  Your idea has been proposed several times
as far back as 6 years ago, it was unacceptable then and it's
unacceptable now.

The whole point of netconsole is that we may be deep in an interrupt
or other atomic context, the machine is about to hard hang, and it's
absolutely essential that we get out any and all kernel logging
messages that we can, immediately.

There may not be another timer or workqueue able to execute after the
printk() we're trying to emit.  We may never get to that point.

So if we defer messages, that means we won't get the message and we
won't be able to debug the problem.

Fix the locking in the drivers or layers that cause the issue instead
of breaking netconsole.
