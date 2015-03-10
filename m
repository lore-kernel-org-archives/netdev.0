From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] can: use sock_efree instead of own destructor
Date: Tue, 10 Mar 2015 08:19:33 -0700
Message-ID: <54FF0B85.7040601@redhat.com>
References: <1425959300-27132-1-git-send-email-fw@strlen.de>	 <54FE8BB0.9050508@hartkopp.net>	 <1425990143.8261.28.camel@edumazet-glaptop2.roam.corp.google.com>	 <54FEF355.305@hartkopp.net> <1425998185.8261.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	mkl@pengutronix.de,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36305 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932065AbbCJPTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 11:19:51 -0400
In-Reply-To: <1425998185.8261.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/2015 07:36 AM, Eric Dumazet wrote:
> On Tue, 2015-03-10 at 14:36 +0100, Oliver Hartkopp wrote:
>> Yes - in connection with sock_rfree() for the read buffer destructur and
>> sock_wfree() for the write buffer it can make sense to name a function
>> sock_efree() as an unassigned destructor - which does not fiddle with rmem nor
>> wmen.
>>
>> But both sock_efree() and sock_edemux() lack some comment - especially when it
>> makes sense to use them from non-INET contexts which Florian suggested.
>>
>> Maybe Alexander can send a patch which adds a comment, as I don't know if I
>> would find the best words for it.
> Please do not top post on netdev.
>
> If you cannot find best words for it, maybe a comment would not be
> useful : Very often, best comments are added by people that had problems
> to understand the code ;)
>
> I do not trust comments, I prefer using "git grep" or tools like that to
> check call sites.
>
> In this particular case this becomes clear, while being concise.
>
> # git grep -n sock_efree
> include/net/sock.h:1526:void sock_efree(struct sk_buff *skb);
> include/net/sock.h:1530:#define sock_edemux(skb) sock_efree(skb)
> net/core/skbuff.c:3625: clone->destructor = sock_efree;
> net/core/sock.c:1658:void sock_efree(struct sk_buff *skb)
> net/core/sock.c:1662:EXPORT_SYMBOL(sock_efree);
> net/ipv4/udp.c:1992:    skb->destructor = sock_efree;

As I recall one of the reasons for leaving it as sock_efree was because 
sock_put just calls sk_free if it has decremented the reference count to 
0.  Also as Eric pointed out the name is actually pretty close to the 
existing destructors sock_edemux and sock_rfree.  The sock_efree name 
was based on the fact that the main consumer is usually either the UDP 
early receive path or the error handler/Timestamp path.

As far as the comments about it not freeing anything take a look at 
sock_rfree and tell me what it is actually freeing?  Last I knew it is 
simply dropping references to memory so that the socket can go ahead and 
either make use of them or close itself once all references have been 
freed.  That is the same thing this does, but it is holding references 
to a single byte of sk_wmem_alloc.

Patches are always welcome if you believe we need additional 
documentation, I had assumed this was pretty straight forward since the 
function was essentially just a wrapper for sock_put so I could use it 
as a destructor.

- Alex
