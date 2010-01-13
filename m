From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v4] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Wed, 13 Jan 2010 14:49:52 -0500
Message-ID: <4B4E23E0.4000007@gmail.com>
References: <4B49D001.4000302@gmail.com> <4B4DA4F4.6060007@gmail.com> <20100113115617.GA24818@basil.fritz.box> <4B4DE887.6030602@gmail.com> <20100113155323.GB24818@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:53279 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754717Ab0AMTt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 14:49:56 -0500
In-Reply-To: <20100113155323.GB24818@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> On Wed, Jan 13, 2010 at 10:36:39AM -0500, William Allen Simpson wrote:
>> What make command would you suggest to get the interleaved asm?
> 
> make path/to/file.lst
> 
Thank you.  So simple.  I wish I'd asked you first!  (Or that it was
in the README or at kernelnewbies or something.)

The short answer is yes, it saves a bit more than I'd expected!

Of course, much of the savings is due to the elimination of the
various skb->len tests.  But the initial code is hit more often.

My obvious and simple load of doff, save, then multiply by 4, save,
has 2 stores into tcp_header_len -- versus 1 old store into th:

-	th = tcp_hdr(skb);
-
-	if (th->doff < sizeof(struct tcphdr) / 4)
+	/* Check bad doff, compare doff directly to constant value */
+	tcp_header_len = tcp_hdr(skb)->doff;
+	if (tcp_header_len < (sizeof(struct tcphdr) / 4))
  		goto bad_packet;
-	if (!pskb_may_pull(skb, th->doff * 4))
+
+	/* Check too short header and options */
+	tcp_header_len *= 4;
+	if (!pskb_may_pull(skb, tcp_header_len))
  		goto discard_it;

Existing tcp_v4_rcv() initially has 3 extra loads, a shift, and several
register swaps compared to mine.

Eric's suggestion to use an immediate multiply eliminates my store,
but that turns out to be at the cost of many additional indexed loads!

In my version, the compiler has cleverly kept tcp_hdr(skb) in %edi.
Eric's idea ends up using %edi for tcp_header_len, so it recalculates
tcp_hdr(skb) later, and temporarily stores it on the stack, requiring
%edx for the loads and stores, and preventing the usage of %dl for
comparisons, making it about 3 loads and 3 stores and a large number of
other instructions longer....

My later savings is even better, completely obviating my 1 store.
For example:

==old==
	th = tcp_hdr(skb);
	iph = ip_hdr(skb);
	TCP_SKB_CB(skb)->seq = ntohl(th->seq);
c04f2621:	8d 43 20             	lea    0x20(%ebx),%eax
c04f2624:	8b 4f 04             	mov    0x4(%edi),%ecx
c04f2627:	0f c9                	bswap  %ecx
c04f2629:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c04f262c:	89 48 18             	mov    %ecx,0x18(%eax)
	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
c04f262f:	0f b6 4f 0d          	movzbl 0xd(%edi),%ecx
c04f2633:	89 ca                	mov    %ecx,%edx
c04f2635:	d0 ea                	shr    %dl
c04f2637:	83 e2 01             	and    $0x1,%edx
c04f263a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c04f263d:	89 ca                	mov    %ecx,%edx
c04f263f:	0f b6 4f 0c          	movzbl 0xc(%edi),%ecx
c04f2643:	83 e2 01             	and    $0x1,%edx
c04f2646:	03 55 e4             	add    -0x1c(%ebp),%edx
c04f2649:	03 53 50             	add    0x50(%ebx),%edx
c04f264c:	c0 e9 04             	shr    $0x4,%cl
c04f264f:	0f b6 c9             	movzbl %cl,%ecx
c04f2652:	c1 e1 02             	shl    $0x2,%ecx
c04f2655:	29 ca                	sub    %ecx,%edx
c04f2657:	03 55 e8             	add    -0x18(%ebp),%edx
c04f265a:	89 50 1c             	mov    %edx,0x1c(%eax)
c04f265d:	8b 57 08             	mov    0x8(%edi),%edx
				    skb->len - th->doff * 4);

==new==
	th = tcp_hdr(skb);
	iph = ip_hdr(skb);
	TCP_SKB_CB(skb)->seq = ntohl(th->seq);
c04f25f2:	8d 43 20             	lea    0x20(%ebx),%eax
c04f25f5:	8b 4f 04             	mov    0x4(%edi),%ecx
c04f25f8:	0f c9                	bswap  %ecx
c04f25fa:	89 48 18             	mov    %ecx,0x18(%eax)
	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
c04f25fd:	0f b6 57 0d          	movzbl 0xd(%edi),%edx
c04f2601:	d0 ea                	shr    %dl
c04f2603:	83 e2 01             	and    $0x1,%edx
c04f2606:	89 55 e0             	mov    %edx,-0x20(%ebp)
c04f2609:	0f b6 57 0d          	movzbl 0xd(%edi),%edx
c04f260d:	83 e2 01             	and    $0x1,%edx
c04f2610:	03 55 e0             	add    -0x20(%ebp),%edx
c04f2613:	03 53 50             	add    0x50(%ebx),%edx
c04f2616:	2b 55 e8             	sub    -0x18(%ebp),%edx
c04f2619:	01 ca                	add    %ecx,%edx
c04f261b:	89 50 1c             	mov    %edx,0x1c(%eax)
c04f261e:	8b 57 08             	mov    0x8(%edi),%edx
				    skb->len - tcp_header_len);
