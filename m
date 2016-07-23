From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: Re: [PATCH] net/sctp: always initialise sctp_ht_iter::start_fail
Date: Sat, 23 Jul 2016 16:00:39 +0200
Message-ID: <57937887.6030204@oracle.com>
References: <1469267543-24650-1-git-send-email-vegard.nossum@oracle.com>
 <20160723133929.GG9950@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Xin Long <lucien.xin@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Eric W. Biederman" <ebiederm@xmission.com>, stable@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48292 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbcGWOBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2016 10:01:04 -0400
In-Reply-To: <20160723133929.GG9950@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/23/2016 03:39 PM, Marcelo Ricardo Leitner wrote:
> On Sat, Jul 23, 2016 at 11:52:23AM +0200, Vegard Nossum wrote:
>> seq_read() can call ->start() twice on the same iterator more than once
>> (e.g. once through traverse() and once in seq_read() itself).
>
> But when traverse() returns the error, it goes to Done label, skipping
> the call to ->start() from seq_read(), or am I missing something?

I think you're right.

> Though yes, if sctp_ht_iter memory is actually re-used without
> initializting between seq_read()s, it triggers the issue you described.

The sctp_ht_iter is allocated in
sctp_assocs_seq_open()/sctp_remaddr_seq_open(), so I assume it's
allocated on open().

> How did you trigger this, reading after an error on the file descriptor?

I was using trinity, so I'm not quite sure a priori, but the problem was
100% reproducible before I applied the patch and seeing that it gets
allocated on open() and is never cleared anywhere else, your suggestion
sounds like the most plausible explanation :-)

How about rewording the first paragraph as:

"""
sctp_transport_seq_start() does not currently clear iter->start_fail on
success, but relies on it being zero when it is allocated (by
seq_open_net()).

This can be a problem in the following sequence:

open() -- allocates iter (and implicitly sets iter->start_fail = 0)
read()
  iter->start() -- fails and sets iter->start_fail = 1
  iter->stop() -- doesn't call sctp_transport_walk_stop() (correct)
read() again
  iter->start() -- succeeds, but doesn't change iter->start_fail
  iter->stop() -- doesn't call sctp_transport_walk_stop() (wrong)
"""

Let me know how that sounds.

Thanks for looking so closely at it!


Vegard
