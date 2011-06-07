From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Use unsigned variables for packet lengths in ip[6]_queue.
Date: Tue, 07 Jun 2011 14:59:08 +0200
Message-ID: <4DEE209C.2010104@trash.net>
References: <20110420014221.GC26949@redhat.com>	<20110419.204105.68144653.davem@davemloft.net>	<20110528003651.GA8380@redhat.com> <20110602.135742.1323883827030625599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080706070507080207030206"
Cc: davej@redhat.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, pablo@netfilter.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110602.135742.1323883827030625599.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080706070507080207030206
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

On 02.06.2011 22:57, David Miller wrote:
> From: Dave Jones <davej@redhat.com>
> Date: Fri, 27 May 2011 20:36:51 -0400
> 
>> On Tue, Apr 19, 2011 at 08:41:05PM -0700, David Miller wrote:
>>  > From: Dave Jones <davej@redhat.com>
>>  > Date: Tue, 19 Apr 2011 21:42:22 -0400
>>  > 
>>  > > Not catastrophic, but ipqueue seems to be too trusting of what it gets
>>  > > passed from userspace, and passes it on down to the page allocator,
>>  > > where it will spew warnings if the page order is too high.
>>  > > 
>>  > > __ipq_rcv_skb has several checks for lengths too small, but doesn't
>>  > > seem to have any for oversized ones.   I'm not sure what the maximum
>>  > > we should check for is. I'll code up a diff if anyone has any ideas
>>  > > on a sane maximum.
>>  > 
>>  > Maybe the thing to do is to simply pass __GFP_NOWARN to nlmsg_new()
>>  > in netlink_ack()?
>>  > 
>>  > Anyone else have a better idea?
>>
>> So I went back to this today, and found something that doesn't look right.
>> After adding some instrumentation, and re-running my tests, I found that
>> the reason we were blowing up with enormous allocations was that we
>> were passing down a nlmsglen's like -1061109568
>>
>> Is there any reason for that to be signed ?
>> The nlmsg_len entry of nlmsghdr is a u32, so I'm assuming this is a bug.
>>
>> With the patch below, I haven't been able to reproduce the problem, but
>> I don't know if I've inadvertantly broken some other behaviour somewhere
>> deeper in netlink where this is valid.

This is fine, but I'm wondering whether this can really fix the problem
you've been seeing. Before the packet is reallocated, the length of
nlmsglen - NLMSGLEN(0) - sizeof(struct ipq_peer_msg) is compared to
ipq_peer_msg->data_len, so both values need to be wrong.
ipq_peer_msg->data_len is a size_t, so it's unsigned.

I think what we should additionally do is verify that data_len < 65535
since that's the maximum size of an IP packet.

Using __GFP_NOWARN also makes sense in my opinion since ip_queue
prints a warning anyways and we return an errno code to userspace.
On second thought, we could also simply use GFP_KERNEL, AFAICS
packet reinjection does not happen in atomic context. I'll give
that a try.


--------------080706070507080207030206
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="x"

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index f7f9bd7..8ded42d 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -279,6 +279,9 @@ ipq_mangle_ipv4(ipq_verdict_msg_t *v, struct nf_queue_entry *e)
 
 	if (v->data_len < sizeof(*user_iph))
 		return 0;
+	if (v->data_len > 65535)
+		return -EMSGSIZE;
+
 	diff = v->data_len - e->skb->len;
 	if (diff < 0) {
 		if (pskb_trim(e->skb, v->data_len))
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 065fe40..4ea6a9d 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -279,6 +279,9 @@ ipq_mangle_ipv6(ipq_verdict_msg_t *v, struct nf_queue_entry *e)
 
 	if (v->data_len < sizeof(*user_iph))
 		return 0;
+	if (v->data_len > 65535)
+		return -EMSGSIZE;
+
 	diff = v->data_len - e->skb->len;
 	if (diff < 0) {
 		if (pskb_trim(e->skb, v->data_len))

--------------080706070507080207030206--
