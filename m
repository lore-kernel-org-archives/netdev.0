From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 11058] New: DEADLOOP in kernel network module
Date: Wed, 09 Jul 2008 14:45:16 +0200
Message-ID: <4874B2DC.2070305@trash.net>
References: <bug-11058-10286@http.bugzilla.kernel.org/> <20080708210014.a1d3baf8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020008000508040000070901"
Cc: hemao77@gmail.com, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080708210014.a1d3baf8.akpm@linux-foundation.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020008000508040000070901
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue,  8 Jul 2008 20:13:20 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=11058
>>
>>            Summary: DEADLOOP in kernel network module
>> ...
>> Problem Description:
>>
>> We have seen a deadloop in softirq and we got the cause by creating and
>> analysising the core dump of the kernel.I dont know where to submit a patch ,
>> so I report it here,wish you can apply it to furthur version of linux kernel.
>>
>> The Cause:
>>
>> Both  ctnetlink_del_conntrack() and the tcp_packet() run
>> the code below:
>>
>>     if (del_timer(&ct->timeout))                /*deactive the timer*/
>>        ct->timeout.function((unsigned long) ct);/*remove conntrack from
>> conntrack table*/
>>
>> the ctnetlink_del_conntrack() context is:
>> ................
>>         if (cda[CTA_ID-1]) {
>>                 u_int32_t id = ntohl(*(u_int32_t *)NFA_DATA(cda[CTA_ID-1]));
>>                 if (ct->id != id) {
>>                         ip_conntrack_put(ct);
>>                         return -ENOENT;
>>                 }
>>         }       
>> *       if (del_timer(&ct->timeout))
>> *               ct->timeout.function((unsigned long)ct);
>>
>>         ip_conntrack_put(ct);
>> ...........
>>
>> the tcp_packet() context is:
>> ...........
>>         case TCP_CONNTRACK_SYN_SENT:
>>                 if (old_state < TCP_CONNTRACK_TIME_WAIT)
>>                         break;
>>                 if ((conntrack->proto.tcp.seen[dir].flags &
>>                          IP_CT_TCP_FLAG_CLOSE_INIT)
>>                     || after(ntohl(th->seq),
>>                              conntrack->proto.tcp.seen[dir].td_end)) {  
>>                         /* Attempt to reopen a closed connection.
>>                         * Delete this connection and look up again. */
>>                         write_unlock_bh(&tcp_lock);
>> *                       if (del_timer(&conntrack->timeout))
>> *                               conntrack->timeout.function((unsigned long)
>> *                                                           conntrack);
>>                         return -NF_REPEAT;
>> ......
>>
>> How the DEADLOOP happened?
>>
>>     (1)in ctnetlink_del_conntrack()(runs in system call context): the del_timer
>> is called and then goes to timeout.function.
>>     (2)before timeout.function finish excution(means the conntrack not
>> removed),an interrupt happens and a SYN packet of  the same conntrack
>> comes.CPU goes to irq handle and enventually runs tcp_packet().
>>     (3)in tcp_packet() ,del_timer() will fail because the timer was
>> already deleted. the timeout.function in tcp_packet will not run,
>> -NF_REPEAT is returned, the SYN packet will be passed back again.
>>     (4)Neither side has the chance to run timeout.function,the
>> conntrack remains there,deadloop happen,the SYN packet will be passed back
>> again and again.
>>
>> The fix maybe,add lock the softirq when doing conntrack removing:
>> +++    local_bh_disable();
>>       if (del_timer(&ct->timeout))                /*deactive the timer*/
>>          ct->timeout.function((unsigned long) ct);/*remove conntrack from
>> conntrack table*/
>> +++    local_bh_enable();
>>
>> Thanks, may this be helpful.
>> My email: hemao77@gmail.com
>>
>> It is hard to reproduce , but it really happen on our linux box.
>>
> 
> Thanks.
> 
> Please submit patches via email as described in
> Documentation/SubmittingPatches.  The file ./MAINTAINERS can be used to
> determine which individuals and mailing lists the patch should be sent to.
> 
> But that's for next time - this patch is small enough for the netfilter
> developers to be able to type in again ;)

Good catch, thanks. Basically all del_timer()/timeout.function calls
in conntrack can happen in process context, so we'd have to disable
BHs every time we do this. I think this fix should also work. The
only spot where we return NF_REPEAT is in TCP conntrack, so we can
simply make sure we only do this if we actually managed to kill the
connection.

Jozsef, what do you think?

[patch for review against net-next, I'll backport it later unless
there are objections]


--------------020008000508040000070901
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index d5d76ec..15ce3fb 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -223,23 +223,23 @@ static inline void nf_ct_refresh(struct nf_conn *ct,
 	__nf_ct_refresh_acct(ct, 0, skb, extra_jiffies, 0);
 }
 
-extern void __nf_ct_kill_acct(struct nf_conn *ct,
-				enum ip_conntrack_info ctinfo,
-				const struct sk_buff *skb,
-				int do_acct);
+extern int __nf_ct_kill_acct(struct nf_conn *ct,
+			     enum ip_conntrack_info ctinfo,
+			     const struct sk_buff *skb,
+			     int do_acct);
 
 /* kill conntrack and do accounting */
-static inline void nf_ct_kill_acct(struct nf_conn *ct,
+static inline int nf_ct_kill_acct(struct nf_conn *ct,
 				enum ip_conntrack_info ctinfo,
 				const struct sk_buff *skb)
 {
-	__nf_ct_kill_acct(ct, ctinfo, skb, 1);
+	return __nf_ct_kill_acct(ct, ctinfo, skb, 1);
 }
 
 /* kill conntrack without accounting */
-static inline void nf_ct_kill(struct nf_conn *ct)
+static inline int nf_ct_kill(struct nf_conn *ct)
 {
-	__nf_ct_kill_acct(ct, 0, NULL, 0);
+	return __nf_ct_kill_acct(ct, 0, NULL, 0);
 }
 
 /* These are for NAT.  Icky. */
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 212a088..aad9585 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -848,10 +848,10 @@ acct:
 }
 EXPORT_SYMBOL_GPL(__nf_ct_refresh_acct);
 
-void __nf_ct_kill_acct(struct nf_conn *ct,
-		enum ip_conntrack_info ctinfo,
-		const struct sk_buff *skb,
-		int do_acct)
+int __nf_ct_kill_acct(struct nf_conn *ct,
+		      enum ip_conntrack_info ctinfo,
+		      const struct sk_buff *skb,
+		      int do_acct)
 {
 #ifdef CONFIG_NF_CT_ACCT
 	if (do_acct) {
@@ -862,8 +862,11 @@ void __nf_ct_kill_acct(struct nf_conn *ct,
 		spin_unlock_bh(&nf_conntrack_lock);
 	}
 #endif
-	if (del_timer(&ct->timeout))
+	if (del_timer(&ct->timeout)) {
 		ct->timeout.function((unsigned long)ct);
+		return 1;
+	}
+	return 0;
 }
 EXPORT_SYMBOL_GPL(__nf_ct_kill_acct);
 
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 740acd6..41032d2 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -844,7 +844,11 @@ static int tcp_packet(struct nf_conn *ct,
 			/* Attempt to reopen a closed/aborted connection.
 			 * Delete this connection and look up again. */
 			write_unlock_bh(&tcp_lock);
-			nf_ct_kill(ct);
+			/* The connection might be killed in parallel in process
+			 * context. Don't repeat lookup so it gets a chance to
+			 * complete. */
+			if (!nf_ct_kill(ct))
+				return -NF_DROP;
 			return -NF_REPEAT;
 		}
 		/* Fall through */

--------------020008000508040000070901--
