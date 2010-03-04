From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] gianfar: Fix TX ring processing on SMP machines
Date: Thu, 4 Mar 2010 10:34:15 -0600
Message-ID: <DF5053B4-DCD0-4B90-B9D7-E80D0C76CFAE@kernel.crashing.org>
References: <20100303181858.GA458@oksana.dev.rtsoft.ru>
	<20100304.004157.18721737.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	Netdev <netdev@vger.kernel.org>, Martyn Welch <martyn.welch@ge.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	David Miller <davem@davemloft.net>
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20100304.004157.18721737.davem@davemloft.net>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org


On Mar 4, 2010, at 2:41 AM, David Miller wrote:

> From: Anton Vorontsov <avorontsov@ru.mvista.com>
> Date: Wed, 3 Mar 2010 21:18:58 +0300
> 
>> Starting with commit a3bc1f11e9b867a4f49505 ("gianfar: Revive SKB
>> recycling") gianfar driver sooner or later stops transmitting any
>> packets on SMP machines.
>> 
>> start_xmit() prepares new skb for transmitting, generally it does
>> three things:
>> 
>> 1. sets up all BDs (marks them ready to send), except the first one.
>> 2. stores skb into tx_queue->tx_skbuff so that clean_tx_ring()
>>   would cleanup it later.
>> 3. sets up the first BD, i.e. marks it ready.
>> 
>> Here is what clean_tx_ring() does:
>> 
>> 1. reads skbs from tx_queue->tx_skbuff
>> 2. checks if the *last* BD is ready. If it's still ready [to send]
>>   then it it isn't transmitted, so clean_tx_ring() returns.
>>   Otherwise it actually cleanups BDs. All is OK.
>> 
>> Now, if there is just one BD, code flow:
>> 
>> - start_xmit(): stores skb into tx_skbuff. Note that the first BD
>>  (which is also the last one) isn't marked as ready, yet.
>> - clean_tx_ring(): sees that skb is not null, *and* its lstatus
>>  says that it is NOT ready (like if BD was sent), so it cleans
>>  it up (bad!)
>> - start_xmit(): marks BD as ready [to send], but it's too late.
>> 
>> We can fix this simply by reordering lstatus/tx_skbuff writes.
>> 
>> Reported-by: Martyn Welch <martyn.welch@ge.com>
>> Bisected-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
>> Tested-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>> Tested-by: Martyn Welch <martyn.welch@ge.com>
> 
> Applied.

Anton,

Once this makes it into Linus's tree can you make sure we get it added to -stable.

- k
