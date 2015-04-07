From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 3/3] RDS: make sure not to loop forever inside
 rds_send_xmit
Date: Tue, 07 Apr 2015 18:27:37 -0400 (EDT)
Message-ID: <20150407.182737.2046311186569701796.davem@davemloft.net>
References: <a757317ae49acd938022254b5b0d899262d56008.1428437150.git.sowmini.varadhan@oracle.com>
	<20150407.172607.869971800253661690.davem@davemloft.net>
	<20150407215605.GN29504@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chien.yen@oracle.com, rds-devel@oss.oracle.com, zab@zabbo.net,
	ajaykumar.hotchandani@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150407215605.GN29504@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 7 Apr 2015 17:56:05 -0400

> On (04/07/15 17:26), David Miller wrote:
>> >  	/*
>> > +	 * we record the send generation after doing the xmit acquire.
>> > +	 * if someone else manages to jump in and do some work, we'll use
>> > +	 * this to avoid a goto restart farther down.
>> > +	 *
>> > +	 * we don't need a lock because the counter is only incremented
>> > +	 * while we have the in_xmit bit held.
>> > +	 */
>> > +	conn->c_send_gen++;
>> > +	send_gen = conn->c_send_gen;
>> 
>> This increment does need to either be changed to be an atomic_t
>> or covered by a lock.
>> 
>> Otherwise two concurrent callers can both try to increment it at
>> the same time, and it only effectively increments once.  That's
>> corrupted state and will break all of the new logic added here.
> I'm afraid I dont follow what race condiiton you are seeing? Prior
> to this line, the "acquire_in_xmit" check would have only allowed
> one thread to successfully increment c_send_gen, right? What did I
> miss?

Then there is locking protecting this counter increment and the
comment is wrong.
