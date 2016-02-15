From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: sctp: bad hash index calculation
Date: Mon, 15 Feb 2016 16:56:01 +0100
Message-ID: <CACT4Y+ZnJFyF1nU3dSLczwagr=sV+5MFzMMOJXTQmeUOB1NSXA@mail.gmail.com>
References: <CACT4Y+bKiens=uiZ99t+9ThtXi33W_bQLqh_AgWkQeQDmyUE5w@mail.gmail.com>
 <20160215155017.GB24321@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	linux-sctp@vger.kernel.org,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34434 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbcBOP4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 10:56:22 -0500
Received: by mail-wm0-f44.google.com with SMTP id b205so73255807wmb.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 07:56:22 -0800 (PST)
In-Reply-To: <20160215155017.GB24321@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 15, 2016 at 4:50 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
> On Mon, Feb 15, 2016 at 04:11:22PM +0100, Dmitry Vyukov wrote:
>> Hello,
>>
>> While looking into some memory leaks of sctp ports I've noticed that
>> sctp_init initializes port hash table as follows:
>>
>>     /* Allocate and initialize the SCTP port hash table.  */
>>     do {
>>         sctp_port_hashsize = (1UL << order) * PAGE_SIZE /
>>                     sizeof(struct sctp_bind_hashbucket);
>>         if ((sctp_port_hashsize > (64 * 1024)) && order > 0)
>>             continue;
>>         sctp_port_hashtable = (struct sctp_bind_hashbucket *)
>>             __get_free_pages(GFP_KERNEL | __GFP_NOWARN, order);
>>     } while (!sctp_port_hashtable && --order > 0);
>>
>> and then hash index is computed as follows:
>>
>> /* Warning: The following hash functions assume a power of two 'size'. */
>> /* This is the hash function for the SCTP port hash table. */
>> static inline int sctp_phashfn(struct net *net, __u16 lport)
>> {
>>     return (net_hash_mix(net) + lport) & (sctp_port_hashsize - 1);
>> }
>>
>> I don't see what ensures that sctp_port_hashsize is in fact a power-of-2.
>>
>> spinlock_t in sctp_bind_hashbucket can be 2 words in some configs,
>> then sizeof(sctp_bind_hashbucket) == 24, which can render half of hash
>> table unused.
>>
>> struct sctp_bind_hashbucket {
>>         spinlock_t      lock;
>>         struct hlist_head       chain;
>> };
>>
>> Am I missing something?
>>
> You're right, its not.  It seems to me that sctp_port_hashsize is meant to
> simply bound the upper index of the hashtable array, and as such the phashfn
> should not assume that its a power of 2 (i.e. it should simply mod the hash
> value by sctp_port_hashsize rather than and-ing it).  Alternatively we could
> simply use alloc_large_system_hash to allocate this hash table here, the way tcp
> does.  I'm traveling right now, but can take care of this as soon as i get home
> on wednesday

Hi Neil,

Thanks for confirming. It's yours, I don't pretend to fix it sooner.
