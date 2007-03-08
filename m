From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH][SCTP] Re: lockdep: inconsistent lock state ipv6_add_addr/sctp_v6_copy_addrlist (2.6.21-rc1)
Date: Thu, 8 Mar 2007 08:47:51 +0100
Message-ID: <20070308074751.GA2085@ff.dom.local>
References: <45E15215.4070600@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: Simon Arlott <simon@arlott.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:52645 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964978AbXCHHnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 02:43:51 -0500
Content-Disposition: inline
In-Reply-To: <45E15215.4070600@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25-02-2007 10:08, Simon Arlott wrote:
> This happens on every boot if more information is needed:
> 
> [   37.393715] =================================
> [   37.393830] [ INFO: inconsistent lock state ]
> [   37.393881] 2.6.21-rc1-git #146
> [   37.393929] ---------------------------------
> [   37.393979] inconsistent {softirq-on-R} -> {in-softirq-W} usage.
> [   37.394040] hotplug/1072 [HC0[0]:SC1[2]:HE1:SE0] takes:
> [   37.394092]  (&ndev->lock){-+-?}, at: [<b04a7944>] ipv6_add_addr+0x164/0x1e0
> [   37.394308] {softirq-on-R} state was registered at:
> [   37.394359]   [<b013fc42>] __lock_acquire+0x622/0xbb0
> [   37.394515]   [<b0140652>] lock_acquire+0x62/0x80
> [   37.394678]   [<b0511c65>] _read_lock+0x35/0x50
> [   37.394834]   [<b050e200>] sctp_v6_copy_addrlist+0x30/0xc0
...

[SCTP] ipv6: inconsistent lock state ipv6_add_addr/sctp_v6_copy_addrlist

lockdep found that dev->lock taken from softirq in ipv6_add_addr
is also taken in sctp_v6_copy_addrlist with softirqs enabled, so
lockup is possible.

Noticed-by: Simon Arlott <simon@arlott.org>
Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp linux-2.6.21-rc2-mm2-/net/sctp/ipv6.c linux-2.6.21-rc2-mm2/net/sctp/ipv6.c
--- linux-2.6.21-rc2-mm2-/net/sctp/ipv6.c	2007-02-21 19:46:49.000000000 +0100
+++ linux-2.6.21-rc2-mm2/net/sctp/ipv6.c	2007-03-07 21:57:37.000000000 +0100
@@ -360,7 +360,7 @@ static void sctp_v6_copy_addrlist(struct
 		return;
 	}
 
-	read_lock(&in6_dev->lock);
+	read_lock_bh(&in6_dev->lock);
 	for (ifp = in6_dev->addr_list; ifp; ifp = ifp->if_next) {
 		/* Add the address to the local list.  */
 		addr = t_new(struct sctp_sockaddr_entry, GFP_ATOMIC);
@@ -374,7 +374,7 @@ static void sctp_v6_copy_addrlist(struct
 		}
 	}
 
-	read_unlock(&in6_dev->lock);
+	read_unlock_bh(&in6_dev->lock);
 	rcu_read_unlock();
 }
 
