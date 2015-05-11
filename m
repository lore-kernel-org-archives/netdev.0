From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code where
 it belongs
Date: Sun, 10 May 2015 22:57:44 -0700
Message-ID: <555044D8.3080606@plumgrid.com>
References: <554F9DE8.3000507@plumgrid.com> <20150510182414.GA4198@salvia> <554FA7A5.5020400@plumgrid.com> <20150510190039.GA4938@salvia> <554FAC3A.40701@plumgrid.com> <20150510192044.GA7173@salvia> <554FB366.7080509@plumgrid.com> <20150510195018.GA7877@salvia> <554FCE24.8020904@iogearbox.net> <554FD12F.2020607@iogearbox.net> <20150510234313.GA3176@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:32852 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbbEKF5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 01:57:47 -0400
Received: by igbpi8 with SMTP id pi8so65824716igb.0
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 22:57:46 -0700 (PDT)
In-Reply-To: <20150510234313.GA3176@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/10/15 4:43 PM, Pablo Neira Ayuso wrote:
>
> The noop is patched to an unconditional branch to skip that code, but
> the code is still there in that path, even if it's dormant.
>
> What the numbers show is rather simple: The more code is in the path,
> the less performance you get, and the qdisc ingress specific code
> embedded there is reducing performance for people that are not using
> qdisc ingress, hence it should go where it belongs. The static key
> cannot save you from that.

hmm, did I miss these numbers ?

My numbers are showing the opposite. There is no degradation whatsoever.
To recap, here are the numbers from my box:
no ingress - 37.6
ingress on other dev - 36.5
ingress on this dev - 28.8
ingress on this dev + u32 - 24.1

after Daniel's two patches:
no ingress - 37.6
ingress on other dev - 36.5
ingress on this dev - 36.5
ingress on this dev + u32 - 25.2

Explanation of the first lines:
'no ingress' means pure netif_receive_skb with drop in ip_rcv.
This is the case when ingress qdisc is not attached to any of the
devices.
Here static_key is off, so:
         if (static_key_false(&ingress_needed)) {
                 ... never reaches here ...
                 skb = handle_ing(skb, &pt_prev, &ret, orig_dev);

So the code path is the same and numbers before and after are
proving it is the case.

'ingress on other dev' means that ingress qdisc is attached to
some other device. Meaning that static_key is now on and
handle_ing() after two patches does:
cl = rcu_dereference_bh(skb->dev->ingress_cl_list);
if (!cl)
   return skb; ... returns here ...

Prior to two Daniel's patches handle_ing() does:
  rxq = rcu_dereference(skb->dev->ingress_queue);
  if (!rxq || rcu_access_pointer(rxq->qdisc) == &noop_qdisc)
     return skb; ... returns here ...

so the number of instructions is the same for 'ingress on other dev'
case too.
Not surprisingly before and after numbers for 'no ingress' and
'ingress on other dev' are exactly the same.

It sounds like you're saying that code that not even being executed
is somehow affecting the speed? How is that possible ?
What kind of benchmark do you run? I really want to get to the bottom
of it. We cannot use 'drive-by reviewing' and 'gut feel' to make
decisions. If you think my numbers are wrong, please rerun them.
I'm using pktgen with 'xmit_mode netif_receive'. If there is some
other benchmark please bring it on. Everyone will benefit.
If you think pktgen as a test is not representative of real numbers,
sure, that's a different discussion. Let's talk what is the right
test to use. Just claiming that inline of a function into
netif_receive_skb is hurting performance is bogus. Inlining hurts
when size of executed code increases beyond I-cache size. That's
clearly not the case here. Compilers moves inlined handle_ing()
into cold path of netif_receive_skb. So for anyone who doesn't
enable ingress qdisc there is no difference, since that code doesn't
even get into I-cache.
Here is snippet from net/core/dev.s:
	/* below is line 3696: if (static_key_false(&ingress_needed)) */
         1:.byte 0x0f,0x1f,0x44,0x00,0
         .pushsection __jump_table,  "aw"
          .balign 8
          .quad 1b, .L1756, ingress_needed       #,
         .popsection
	/* below is line 3702: skb->tc_verd = 0; */
	movw    $0, 150(%rbx)   #, skb_310->tc_verd

As you can see the inlined handle_ing() is not in fall through path
and it's placed by gcc at the end of netif_receive_skb_core at the label
L1756. So I cannot possible see how it can affect performance.
Even if we make handle_ing() twice as big, there is still won't be
any difference for users that don't use ingress qdisc.
