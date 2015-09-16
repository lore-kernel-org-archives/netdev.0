From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 2/2] bpf: add bpf_redirect() helper
Date: Tue, 15 Sep 2015 21:50:27 -0700
Message-ID: <55F8F513.10803@gmail.com>
References: <1442368295-5204-1-git-send-email-ast@plumgrid.com> <1442368295-5204-3-git-send-email-ast@plumgrid.com> <55F8DD89.5090709@gmail.com> <55F8EBFB.2080009@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:36086 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbbIPEsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 00:48:41 -0400
Received: by oibi136 with SMTP id i136so111802653oib.3
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 21:48:41 -0700 (PDT)
In-Reply-To: <55F8EBFB.2080009@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-09-15 09:11 PM, Alexei Starovoitov wrote:
> On 9/15/15 8:10 PM, John Fastabend wrote:
>> Nice, I like this. But just to be sure I read this correctly this will
>> only work on the ingress qdisc for now right? To get the tx side working
>> will require a bit more care.
> 
> correct.
> For egress I'm waiting for Daniel to resubmit his preclassifier patch
> and I'll hook this skb_do_redirect() there as well.
> Other options are also possible, but preclassifier looks the best for
> this purpose, since it's lockless.
> 

Great, works for me. One other question/observation,

+int skb_do_redirect(struct sk_buff *skb)
+{

[...]

+
+	if (unlikely(!(dev->flags & IFF_UP))) {
+		kfree_skb(skb);
+		return -EINVAL;
+	}


The IFF_UP check is not needed as best I can tell, the dev_queue_xmit()
will check if the qdisc is active and the dev_forward_skb() path will
do a !netif_running check in enqueue_to_backlog() call.

Looks like you can remove the check. I would prefer to let the stack
handle this case using normal mechanisms.

I had to do a bit of tracking but netif_running check equates roughly
to your IFF_UP case via,

> 	__dev_change_flags()
> 		[...]
> 	        if ((old_flags ^ flags) & IFF_UP)
>                 	ret = ((old_flags & IFF_UP) ? __dev_close : __dev_open)(dev);
> 		
> 
> 	__dev_close()
> 		[...]
> 		__dev_close_many()
> 
> 	__dev_close_many()
> 		[...]
>               clear_bit(__LINK_STATE_START, &dev->state);

Seem reasonable? Or did you put it there to work around some specific
case I'm missing?

.John
