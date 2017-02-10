From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/packet: use-after-free in packet_rcv_fanout
Date: Thu, 09 Feb 2017 19:23:23 -0800
Message-ID: <1486697003.7793.121.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+a2tTARdXKtjtWny9hAPc9b8Q-v8ya3TOV-T+8s=PR2HQ@mail.gmail.com>
         <CAM_iQpXDwx3=tF4Atu7O+STswdTxLFzzT5-K2bgqtcWcF4aghA@mail.gmail.com>
         <1486696765.7793.119.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>, jarno@ovn.org,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        philip.pettersson@gmail.com, weongyo.linux@gmail.com,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34134 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750940AbdBJDYs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 22:24:48 -0500
In-Reply-To: <1486696765.7793.119.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-09 at 19:19 -0800, Eric Dumazet wrote:

> More likely the bug is in fanout_add(), with a buggy sequence in error
> case, and not correct locking.
> 
> kfree(po->rollover);
> po->rollover = NULL;
> 
> Two cpus entering fanout_add() (using the same af_packet socket,
> syzkaller courtesy...) might both see po->fanout being NULL.
> 
> Then they grab the mutex.  Too late...

Patch could be :

 net/packet/af_packet.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d56ee46b11fc9524e457e5fe8adf10c105a66ab6..11725a350f6953d077f754c10e9f52e48924d780 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1657,7 +1657,6 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		atomic_long_set(&po->rollover->num_failed, 0);
 	}
 
-	mutex_lock(&fanout_mutex);
 	match = NULL;
 	list_for_each_entry(f, &fanout_list, list) {
 		if (f->id == id &&
@@ -1704,7 +1703,6 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		}
 	}
 out:
-	mutex_unlock(&fanout_mutex);
 	if (err) {
 		kfree(po->rollover);
 		po->rollover = NULL;
@@ -3698,7 +3696,10 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 		if (copy_from_user(&val, optval, sizeof(val)))
 			return -EFAULT;
 
-		return fanout_add(sk, val & 0xffff, val >> 16);
+		mutex_lock(&fanout_mutex);
+		ret = fanout_add(sk, val & 0xffff, val >> 16);
+		mutex_unlock(&fanout_mutex);
+		return ret;
 	}
 	case PACKET_FANOUT_DATA:
 	{
