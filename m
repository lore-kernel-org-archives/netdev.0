From: David Miller <davem@davemloft.net>
Subject: Re: Possible bug in netlink_recvmsg()
Date: Fri, 13 Apr 2007 14:11:17 -0700 (PDT)
Message-ID: <20070413.141117.101862281.davem@davemloft.net>
References: <1864.1176487711@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58599
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030325AbXDMVLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 17:11:16 -0400
In-Reply-To: <1864.1176487711@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Fri, 13 Apr 2007 19:08:31 +0100

> AF_NETLINK sockets, however, do not do (3).  See this bit in netlink_recvmsg():
> 
> 	copied = skb->len;
> 	if (len < copied) {
> 		msg->msg_flags |= MSG_TRUNC;
> 		copied = len;
> 	}
> 
> Or is this only true if the caller of recvmsg() passes MSG_TRUNC in?

See this fix in my net-2.6.22 tree:

commit ad495d7b6cfcd1bc2eaf06c42699be0bb5d84234
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Tue Mar 6 17:02:35 2007 -0800

    [NETLINK]: Mirror UDP MSG_TRUNC semantics.
    
    If the user passes MSG_TRUNC in via msg_flags, return
    the full packet size not the truncated size.
    
    Idea from Herbert Xu and Thomas Graf.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index e73d8f5..b31a732 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1242,6 +1242,9 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 
 	scm_recv(sock, msg, siocb->scm, flags);
 
+	if (flags & MSG_TRUNC)
+		copied = skb->len;
+
 out:
 	netlink_rcv_wake(sk);
 	return err ? : copied;
