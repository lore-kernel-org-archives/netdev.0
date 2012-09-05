From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sctp_close/sk_free: kernel BUG at arch/x86/mm/physaddr.c:18!
Date: Wed, 05 Sep 2012 17:40:45 +0200
Message-ID: <1346859645.13121.146.camel@edumazet-glaptop>
References: <20120904140411.GB15068@localhost>
	 <5046361C.5070602@pengutronix.de> <87mx15zfze.fsf@xmission.com>
	 <20120905145508.GA9450@localhost>  <50476931.20100@pengutronix.de>
	 <1346859046.13121.144.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	networking <netdev@vger.kernel.org>, linux-can@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1346859046.13121.144.camel@edumazet-glaptop>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-05 at 17:30 +0200, Eric Dumazet wrote:
> On Wed, 2012-09-05 at 17:01 +0200, Marc Kleine-Budde wrote:
> > On 09/05/2012 04:55 PM, Fengguang Wu wrote:
> > >>> This in turn means the problem doesn't come from the CAN patches, as
> > >>> both trees have different CAN patches. I'm adding Eric W. Biederman on
> > >>> Cc as he contributed some sctp patches between v3.6 and net-next/master.
> > >>
> > >> Anything is possible, but this seems unlikely as I don't think I touched
> > >> anything close to that part of the code.
> > > 
> > > You are both right.  The bad commit turns out to be one of:
> > > 
> > > 1bed966cc3bd4042110129f0fc51aeeb59c5b200 Merge branch 'tcp_fastopen_server'
> > > 168a8f58059a22feb9e9a2dcc1b8053dbbbc12ef tcp: TCP Fast Open Server - main code path
> > > 8336886f786fdacbc19b719c1f7ea91eb70706d4 tcp: TCP Fast Open Server - support TFO listeners
> > > 
> > > Thanks,
> > > Fengguang
> > 
> > Thanks for your work Fengguang.
> > 
> > Marc
> > 
> 
> OK I have a good idea how to fix the bug, I will send a patch ASAP

Could you test the following patch please ?

(Not sure why sctp doesnt memset/bzero its whole socket by the way...)

Thanks

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 4f70ef0..845372b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -149,11 +149,8 @@ void inet_sock_destruct(struct sock *sk)
 		pr_err("Attempt to release alive inet socket %p\n", sk);
 		return;
 	}
-	if (sk->sk_type == SOCK_STREAM) {
-		struct fastopen_queue *fastopenq =
-			inet_csk(sk)->icsk_accept_queue.fastopenq;
-		kfree(fastopenq);
-	}
+	if (sk->sk_protocol == IPPROTO_TCP)
+		kfree(inet_csk(sk)->icsk_accept_queue.fastopenq);
 
 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
 	WARN_ON(atomic_read(&sk->sk_wmem_alloc));



