From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some issues
Date: Fri, 14 Aug 2015 12:38:21 +0200
Message-ID: <55CDC51D.1060204@iogearbox.net>
References: <20150722131730.GA18037@gmail.com> <20150812082824.GA13385@gmail.com> <20150812.163819.620222685130362816.davem@davemloft.net> <20150814085807.GA30443@gmail.com> <55CDBC84.8020605@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56879 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222AbbHNKi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 06:38:26 -0400
In-Reply-To: <55CDBC84.8020605@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2015 12:01 PM, Daniel Borkmann wrote:
> On 08/14/2015 10:58 AM, Ken-ichirou MATSUZAWA wrote:
>>   Hi,
>>
>> Thank you for taking your time.
>> Please let me explain these with code samples on gist.
>> I can not describe and arrange it well, sorry.
>>
>>      normal socket nflog sample:
>>      https://gist.github.com/chamaken/dc0f80c14862e8061c06/raw/2d6da8fff31ef61af77e68713fdb1d71978746a6/nflog.c
>>
>> set iptables
>>
>>      iptables -A INPUT -p icmp --icmp-type echo-request \
>>          -j NFLOG --nflog-group 2 --nflog-threshold 4
>>
>> monitor nlmon (like netsniff-ng), run this sample and
>> ping -i 0.2 -c 10 from another hosts. This sample only shows receive
>> size and nlmsg_type. Same things can be done with rx mmaped socket.
>>
>>      rx only mmaped nflog sample:
>>      https://gist.github.com/chamaken/dc0f80c14862e8061c06/raw/2d6da8fff31ef61af77e68713fdb1d71978746a6/rxring-nflog.c
>>
>> This sample gets a panic if monitoring nlmon.
>>
>>      panic message:
>>      https://gist.github.com/chamaken/dc0f80c14862e8061c06/raw/2d6da8fff31ef61af77e68713fdb1d71978746a6/mmaped_netlink_panic
>>
>> I think it's because of accessing a skb_shared_info when releasing
>> skb, although mmaped netlink skb does not have a skb_shared_info. I
>> tried to fix this at patch 1 and 2 by introducing helper function
>> which will not access a skb_shared_info.
>>
>> And I think nm_status should be set to UNUSED when releasing it so
>> also tried to fix it patch 3.
>
> Ok, I'm trying to understand the issue: you are saying that whenever
> there's an skb_clone on an netlink mmaped skb, we have the situation
> that skb->data, skb->head etc points to the mmaped user space buffer
> slot, and thus _must_ have no shared info.
>
> Currently, what happens is that the shared info accesses whatever
> memory is there in the mmaped region. So when you already do an
> skb_clone() you should already get into trouble right there f.e. when
> we test for orphaning frags etc (if at the right offset in the mmap
> buffer, the tx_flags member would contain a SKBTX_DEV_ZEROCOPY bit).

Ken-ichirou, have you observed this issue only in relation to nlmon?
Haven't checked yet if there are any upper layer netlink consumers that
would call for some reason into skb_clone() as well. I am thinking that
if taps are indeed the only ones affected, it might probably not be
worth adding that much complexity for a fix itself, but to keep it simple
instead. I don't know if there are any real users of netlink mmap, but
if it would really be needed, we could think about it on a net-next basis?
It seems you have some other, separate fixes in your series, so you might
want to submit them separately against the net tree, instead?

  include/linux/netlink.h  |  4 ++++
  net/netlink/af_netlink.c | 12 +++++++-----
  2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 9120edb..42cdcd8 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -35,6 +35,10 @@ struct netlink_skb_parms {
  #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
  #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)

+static inline bool netlink_skb_is_mmaped(const struct sk_buff *skb)
+{
+	return NETLINK_CB(skb).flags & NETLINK_SKB_MMAPED;
+}

  extern void netlink_table_grab(void);
  extern void netlink_table_ungrab(void);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 67d2104..4307446 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -238,6 +238,13 @@ static void __netlink_deliver_tap(struct sk_buff *skb)

  static void netlink_deliver_tap(struct sk_buff *skb)
  {
+	/* Netlink mmaped skbs must not access shared info, and thus
+	 * are not allowed to be cloned. For now, just don't allow
+	 * them to get inspected by taps.
+	 */
+	if (netlink_skb_is_mmaped(skb))
+		return;
+
  	rcu_read_lock();

  	if (unlikely(!list_empty(&netlink_tap_all)))
@@ -278,11 +285,6 @@ static void netlink_rcv_wake(struct sock *sk)
  }

  #ifdef CONFIG_NETLINK_MMAP
-static bool netlink_skb_is_mmaped(const struct sk_buff *skb)
-{
-	return NETLINK_CB(skb).flags & NETLINK_SKB_MMAPED;
-}
-
  static bool netlink_rx_is_mmaped(struct sock *sk)
  {
  	return nlk_sk(sk)->rx_ring.pg_vec != NULL;
-- 
1.9.3




>> ----
>>
>> With both tx/rx mmaped,
>>
>>      both tx/rx mmaped nflog sample:
>>      https://gist.github.com/chamaken/dc0f80c14862e8061c06/raw/2d6da8fff31ef61af77e68713fdb1d71978746a6/ring-nflog.c
>>
>> This sample will not work, since msg->msg_iter.type in
>> netlink_sendmsg() is set to 1 (WRITE) when this sample calls
>> sendto(). patch 4 fix this by accepting it.
>>
>> ----
>>
>> After applying patch 1 and 2, rx only sample can work but it behaves
>> differ from normal one. patch 5 may fix this.
>>
>> And it also works well with my another code which set frame
>> nm_status to SKIP and passes it to worker threads and the worker
>> threads set status to UNUSED, even though ring becomes full.
>>
>> That my another code may set UNUSED status in random, not
>> sequensially, so that it seems I need to check whole ring.
>>
>> Thanks,
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
