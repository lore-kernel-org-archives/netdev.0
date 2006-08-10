From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix memory leak in
 net/ipv4/tcp_probe.c::tcpprobe_read()
Date: Thu, 10 Aug 2006 16:54:28 -0700 (PDT)
Message-ID: <20060810.165428.91994024.davem@davemloft.net>
References: <9a8748490608101518s38c6e6a3r9d8599ca3c106ef3@mail.gmail.com>
	<20060810.163612.71164812.davem@davemloft.net>
	<20060810165216.103c6940@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, jmorris@namei.org, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, pekkas@netcore.fi, kaber@coreworks.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29881
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932339AbWHJXy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 19:54:28 -0400
To: shemminger@osdl.org
In-Reply-To: <20060810165216.103c6940@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 10 Aug 2006 16:52:16 -0700

> Dave, here is my version...
> Don't leak memory on interrupted read. And only allocate
> as much memory as needed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

I think I'm going to go with James's safe original fix
for now, thanks.

commit a7fc5b24a4921a6582ce47c0faf3a31858a80468
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu Aug 10 16:53:33 2006 -0700

    [TCP]: Fix botched memory leak fix to tcpprobe_read().
    
    Somehow I clobbered James's original fix and only my
    subsequent compiler warning change went in for that
    changeset.
    
    Get the real fix in there.
    
    Noticed by Jesper Juhl.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index b343532..dab37d2 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -130,11 +130,12 @@ static ssize_t tcpprobe_read(struct file
 	error = wait_event_interruptible(tcpw.wait,
 					 __kfifo_len(tcpw.fifo) != 0);
 	if (error)
-		return error;
+		goto out_free;
 
 	cnt = kfifo_get(tcpw.fifo, tbuf, len);
 	error = copy_to_user(buf, tbuf, cnt);
 
+out_free:
 	vfree(tbuf);
 
 	return error ? error : cnt;
