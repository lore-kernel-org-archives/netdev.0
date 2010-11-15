From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH] network: return errors if we know tcp_connect failed
Date: Mon, 15 Nov 2010 17:36:40 +0100
Message-ID: <4CE16198.7000709@trash.net>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com>	 <00c201cb81eb$84e18160$8ea48420$@com> <4CDCEE65.3060105@trash.net>	 <017301cb82bf$54540cf0$fcfc26d0$@com>  <4CE10C2A.1050801@trash.net> <1289836066.14282.7.camel@localhost.localdomain> <4CE15885.90003@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020804040006030609050100"
Cc: Hua Zhong <hzhong@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Eric Paris <eparis@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4CE15885.90003@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020804040006030609050100
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

On 15.11.2010 16:57, Patrick McHardy wrote:
> On 15.11.2010 16:47, Eric Paris wrote:
>> I notice the heavy lifting for this is done in 
>> net/ipv4/netfilter/ipt_REJECT.c::send_rest()
>> (and something very similar for IPv6)
>>
>> I really don't want to duplicate that code into SELinux (for obvious
>> reasons) and I'm wondering if anyone has objections to me making it
>> available outside of netlink and/or suggestions on how to make that code
>> available outside of netfilter (aka what header to expose it, and does
>> it still make logical sense in ipt_REJECT.c or somewhere else?)
> 
> I don't think having SELinux sending packets to handle local
> connections is a very elegant design, its not a firewall after
> all. What's wrong with reacting only to specific errno codes
> in tcp_connect()? You could f.i. return -ECONNREFUSED from
> SELinux, that one is pretty much guaranteed not to occur in
> the network stack itself and can be returned directly.
> 
> That would need minor changes to nf_hook_slow so we can
> encode errno values in the upper 16 bits of the verdict,
> as we already do with the queue number. The added benefit
> is that we don't have to return EPERM anymore when f.i.
> rerouting fails.

Patch for demonstration purposes attached. I've modified the
MARK target so it returns NF_DROP with an errno code of
-ECONNREFUSED:

# iptables -A OUTPUT -d 1.2.3.4 -j MARK --set-mark 1
# ping 1.2.3.4
PING 1.2.3.4 (1.2.3.4) 56(84) bytes of data.
ping: sendmsg: Connection refused
# telnet 1.2.3.4
Trying 1.2.3.4...
telnet: Unable to connect to remote host: Connection refused




--------------020804040006030609050100
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="x"

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 89341c3..ef2af8f 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -33,6 +33,8 @@
 
 #define NF_QUEUE_NR(x) ((((x) << NF_VERDICT_BITS) & NF_VERDICT_QMASK) | NF_QUEUE)
 
+#define NF_DROP_ERR(x) (((-x) << NF_VERDICT_BITS) | NF_DROP)
+
 /* only for userspace compatibility */
 #ifndef __KERNEL__
 /* Generic cache responses from hook functions.
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 05b1ecf..bb8f547 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2592,6 +2592,7 @@ int tcp_connect(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *buff;
+	int err;
 
 	tcp_connect_init(sk);
 
@@ -2614,7 +2615,9 @@ int tcp_connect(struct sock *sk)
 	sk->sk_wmem_queued += buff->truesize;
 	sk_mem_charge(sk, buff->truesize);
 	tp->packets_out += tcp_skb_pcount(buff);
-	tcp_transmit_skb(sk, buff, 1, sk->sk_allocation);
+	err = tcp_transmit_skb(sk, buff, 1, sk->sk_allocation);
+	if (err == -ECONNREFUSED)
+		return err;
 
 	/* We change tp->snd_nxt after the tcp_transmit_skb() call
 	 * in order to make this packet get counted in tcpOutSegs.
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 85dabb8..32fcbe2 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -173,9 +173,11 @@ next_hook:
 			     outdev, &elem, okfn, hook_thresh);
 	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
 		ret = 1;
-	} else if (verdict == NF_DROP) {
+	} else if ((verdict & NF_VERDICT_MASK) == NF_DROP) {
 		kfree_skb(skb);
-		ret = -EPERM;
+		ret = -(verdict >> NF_VERDICT_BITS);
+		if (ret == 0)
+			ret = -EPERM;
 	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
 		if (!nf_queue(skb, elem, pf, hook, indev, outdev, okfn,
 			      verdict >> NF_VERDICT_BITS))
diff --git a/net/netfilter/xt_mark.c b/net/netfilter/xt_mark.c
index 2334523..185330c 100644
--- a/net/netfilter/xt_mark.c
+++ b/net/netfilter/xt_mark.c
@@ -30,7 +30,7 @@ mark_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	const struct xt_mark_tginfo2 *info = par->targinfo;
 
 	skb->mark = (skb->mark & ~info->mask) ^ info->mark;
-	return XT_CONTINUE;
+	return NF_DROP_ERR(-ECONNREFUSED);
 }
 
 static bool


--------------020804040006030609050100--
