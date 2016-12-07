From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sock_rps_record_flow() is for connected
 sockets
Date: Wed, 07 Dec 2016 05:58:19 -0800
Message-ID: <1481119099.18162.641.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481020451.6225.38.camel@redhat.com> <1481044098.7129.7.camel@redhat.com>
         <1481046434.18162.599.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481049061.7129.18.camel@redhat.com>
         <1481050715.18162.604.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481051786.7129.22.camel@redhat.com>
         <1481052922.18162.605.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481081570.18162.626.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481097551.5535.14.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34069 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751225AbcLGN6V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 08:58:21 -0500
Received: by mail-pf0-f193.google.com with SMTP id y68so20663621pfb.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 05:58:21 -0800 (PST)
In-Reply-To: <1481097551.5535.14.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-07 at 08:59 +0100, Paolo Abeni wrote:
> On Tue, 2016-12-06 at 19:32 -0800, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Paolo noticed a cache line miss in UDP recvmsg() to access
> > sk_rxhash, sharing a cache line with sk_drops.
> > 
> > sk_drops might be heavily incremented by cpus handling a flood targeting
> > this socket.
> > 
> > We might place sk_drops on a separate cache line, but lets try
> > to avoid wasting 64 bytes per socket just for this, since we have
> > other bottlenecks to take care of.
> > 
> > sock_rps_record_flow() should only access sk_rxhash for connected
> > flows.
> > 
> > Testing sk_state for TCP_ESTABLISHED covers most of the cases for
> > connected sockets, for a zero cost, since system calls using
> > sock_rps_record_flow() also access sk->sk_prot which is on the
> > same cache line.
> > 
> > A follow up patch will provide a static_key (Jump Label) since most
> > hosts do not even use RFS.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Reported-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> >  include/net/sock.h |   12 +++++++++++-
> >  1 file changed, 11 insertions(+), 1 deletion(-)
> > 
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index 6dfe3aa22b970eecfab4d4a0753804b1cc82a200..a7ddab993b496f1f4060f0b41831a161c284df9e 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -913,7 +913,17 @@ static inline void sock_rps_record_flow_hash(__u32 hash)
> >  static inline void sock_rps_record_flow(const struct sock *sk)
> >  {
> >  #ifdef CONFIG_RPS
> > -	sock_rps_record_flow_hash(sk->sk_rxhash);
> > +	/* Reading sk->sk_rxhash might incur an expensive cache line miss.
> > +	 *
> > +	 * TCP_ESTABLISHED does cover almost all states where RFS
> > +	 * might be useful, and is cheaper [1] than testing :
> > +	 *	IPv4: inet_sk(sk)->inet_daddr
> > +	 * 	IPv6: ipv6_addr_any(&sk->sk_v6_daddr)
> > +	 * OR	an additional socket flag
> > +	 * [1] : sk_state and sk_prot are in the same cache line.
> > +	 */
> > +	if (sk->sk_state == TCP_ESTABLISHED)
> > +		sock_rps_record_flow_hash(sk->sk_rxhash);
> >  #endif
> >  }
> 
> Thank you for the very prompt patch!
> 
> You made me curious about your other idea on this topic, this what you
> initially talked about, right ?

That was what I first thought, but then having an rfs_key would also
help here. I will submit the patch on top of this one, so that final
code looks like :

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1ff5ea6e12214db818c2cfa8a9b8ed5cbddc307c..994f7423a74bd622884c3b646f4123d28697b8ad 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -192,6 +192,7 @@ struct net_device_stats {
 #ifdef CONFIG_RPS
 #include <linux/static_key.h>
 extern struct static_key rps_needed;
+extern struct static_key rfs_needed;
 #endif
 
 struct neighbour;
diff --git a/include/net/sock.h b/include/net/sock.h
index 6dfe3aa22b970eecfab4d4a0753804b1cc82a200..f1f6a07da06facb308a5c76e4de21b804d25ec53 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -913,7 +913,19 @@ static inline void sock_rps_record_flow_hash(__u32 hash)
 static inline void sock_rps_record_flow(const struct sock *sk)
 {
 #ifdef CONFIG_RPS
-	sock_rps_record_flow_hash(sk->sk_rxhash);
+	if (static_key_false(&rfs_needed)) {
+		/* Reading sk->sk_rxhash might incur an expensive cache line miss.
+		 *
+		 * TCP_ESTABLISHED does not cover all states where RFS
+		 * might be useful, but looks cheaper [1] than testing :
+		 *	IPv4: inet_sk(sk)->inet_daddr
+		 * 	IPv6: ipv6_addr_any(&sk->sk_v6_daddr)
+		 * OR	an additional socket flag
+		 * [1] : sk_state and sk_prot are in the same cache line.
+		 */
+		if (sk->sk_state == TCP_ESTABLISHED)
+			sock_rps_record_flow_hash(sk->sk_rxhash);
+	}
 #endif
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index bffb5253e77867b1d6a0ada7cc99f4605e03ad28..1d33ce03365f1e10996ad5274e86bf351a526284 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3447,6 +3447,8 @@ EXPORT_SYMBOL(rps_cpu_mask);
 
 struct static_key rps_needed __read_mostly;
 EXPORT_SYMBOL(rps_needed);
+struct static_key rfs_needed __read_mostly;
+EXPORT_SYMBOL(rfs_needed);
 
 static struct rps_dev_flow *
 set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 0df2aa6525308a365d89f57f6da76d57a24238f0..2a46e4009f62d8c2ac8949789ae9626b0c016a11 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -79,10 +79,13 @@ static int rps_sock_flow_sysctl(struct ctl_table *table, int write,
 
 		if (sock_table != orig_sock_table) {
 			rcu_assign_pointer(rps_sock_flow_table, sock_table);
-			if (sock_table)
+			if (sock_table) {
 				static_key_slow_inc(&rps_needed);
+				static_key_slow_inc(&rfs_needed);
+			}
 			if (orig_sock_table) {
 				static_key_slow_dec(&rps_needed);
+				static_key_slow_dec(&rfs_needed);
 				synchronize_rcu();
 				vfree(orig_sock_table);
 			}
