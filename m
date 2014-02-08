From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Re: REGRESSION f54b311142a92ea2e42598e347b84e1655caf8e3 tcp auto
 corking slows down iSCSI file system creation by factor of 70 [WAS: 4 TB
 VMFS creation takes 15 minutes vs 26 seconds]
Date: Sat, 8 Feb 2014 14:37:45 +0100
Message-ID: <20140208133744.GA20512@glanzmann.de>
References: <20140206153640.GB4103@glanzmann.de>
 <1391727771.14985.41.camel@haakon3.risingtidesystems.com>
 <20140207051500.GB10916@glanzmann.de>
 <20140207075536.GB17815@glanzmann.de>
 <1391801597.1155.28.camel@haakon3.risingtidesystems.com>
 <20140207205142.GA8609@glanzmann.de>
 <20140208093808.GD16336@glanzmann.de>
 <1391865273.10160.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1391865273.10160.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Eric,

> > tcp corking kills iSCSI performance

> Here is the combined patch, could you test it?

the patch did not apply, so I edited by hand. Here is the resulting
patch:

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 03d26b8..40d1958 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -698,7 +698,8 @@ static void tcp_tsq_handler(struct sock *sk)
 	if ((1 << sk->sk_state) &
 	    (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 | TCPF_CLOSING |
 	     TCPF_CLOSE_WAIT  | TCPF_LAST_ACK))
-		tcp_write_xmit(sk, tcp_current_mss(sk), 0, 0, GFP_ATOMIC);
+			tcp_write_xmit(sk, tcp_current_mss(sk), tcp_sk(sk)->nonagle,
+	                               0, GFP_ATOMIC);
 }
 /*
  * One tasklet per cpu tries to send more skbs.
@@ -1904,7 +1905,16 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 
 		if (atomic_read(&sk->sk_wmem_alloc) > limit) {
 			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
-			break;
+			/* It is possible TX completion already happened
+			 * before we set TSQ_THROTTLED, so we must
+			 * test again the condition.
+			 * We abuse smp_mb__after_clear_bit() because
+			 * there is no smp_mb__after_set_bit() yet
+			 */
+			smp_mb__after_clear_bit();
+			if (atomic_read(&sk->sk_wmem_alloc) > limit)
+				break;
+
 		}
 
 		limit = mss_now;

-- cut here --

It fixes my case but if you look at the round trip time it is not even
close what it used to be. So while this fixes my problem I'm still for
disabling it by default.

https://thomas.glanzmann.de/tmp/tcp_auto_corking_on_patched.pcap.bz2
https://thomas.glanzmann.de/tmp/screenshot-mini-2014-02-08-14:36:25.png

Cheers,
        Thomas
