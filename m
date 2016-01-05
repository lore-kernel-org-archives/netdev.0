From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next 1/5] sctp: add the rhashtable apis for sctp
 global transport hashtable
Date: Tue, 5 Jan 2016 18:10:15 +0800
Message-ID: <CADvbK_evLk8YgYDdNvEoBB-SSqH8s7wWu_K5g=SzP=GOj-TWtw@mail.gmail.com>
References: <cover.1451490447.git.lucien.xin@gmail.com>
	<2c413161eb3a2c74453bd8dc11815af7e237515e.1451490447.git.lucien.xin@gmail.com>
	<20151230174103.GC16270@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=089e013a2f0eacd7090528937118
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Vlad Yasevich <vyasevic@redhat.com>, daniel@iogearbox.net,
	davem <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f193.google.com ([209.85.214.193]:35729 "EHLO
	mail-ob0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbcAEKKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 05:10:17 -0500
In-Reply-To: <20151230174103.GC16270@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--089e013a2f0eacd7090528937118
Content-Type: text/plain; charset=UTF-8

On Thu, Dec 31, 2015 at 1:41 AM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> On Wed, Dec 30, 2015 at 11:50:46PM +0800, Xin Long wrote:
> ...
>> +void sctp_hash_transport(struct sctp_transport *t)
>> +{
>> +     struct sctp_sockaddr_entry *addr;
>> +     struct sctp_hash_cmp_arg arg;
>> +
>> +     addr = list_entry(t->asoc->base.bind_addr.address_list.next,
>> +                       struct sctp_sockaddr_entry, list);
>> +     arg.laddr = &addr->a;
>> +     arg.paddr = &t->ipaddr;
>> +     arg.net   = sock_net(t->asoc->base.sk);
>> +
>> +reinsert:
>> +     if (rhashtable_lookup_insert_key(&sctp_transport_hashtable, &arg,
>> +                                      &t->node, sctp_hash_params) == -EBUSY)
>> +             goto reinsert;
>> +}
>
> This is the nasty situation I mentioned in previous email. It seems that
> a stress test can trigger a double rehash and cause an entry to not be
> added.
>
> This is in fact very near some bugs you caught on rhashtable in the past
> few days/couple of weeks tops.
>
> I'm actually against this loop as is. I may have not been clear with Xin
> about not adding my signature to the patchset due to this.
>
> Please take a look at Xin's emails on thread 'rhashtable: Prevent
> spurious EBUSY errors on insertion' about this particular situation.
> Cc'ing Herbert as he wanted to see the patches for that issue.
>
>   Marcelo
>
without this 'reinsert'.

we can reproduce this issue like this:
1. download the attachment
2. cp sctperf.tar.gz to server and client hosts
3. in each hosts.
#make
4. in server:
#sh saddr.sh $ethx
#./ss
5. in client:
#sh caddr.sh $ethx
#ulimit -n 20000
#./cc

when the number of  connections reach about 1600, this issue will be triggered.

--089e013a2f0eacd7090528937118
Content-Type: application/x-gzip; name="sctperf.tar.gz"
Content-Disposition: attachment; filename="sctperf.tar.gz"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ij18e7qy0

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
--089e013a2f0eacd7090528937118--
