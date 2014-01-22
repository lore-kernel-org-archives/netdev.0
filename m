From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] net: sctp: Fix a_rwnd/rwnd management to reflect real
 state of the receiver's buffer
Date: Wed, 22 Jan 2014 09:18:28 -0500
Message-ID: <52DFD334.7030507@gmail.com>
References: <52D8D544.5050501@nsn.com> <20140122123059.GA9393@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org,
	Alexander Sverdlin <alexander.sverdlin@nsn.com>,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>,
	Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:62547 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755334AbaAVOSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 09:18:34 -0500
In-Reply-To: <20140122123059.GA9393@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2014 07:30 AM, Neil Horman wrote:
> On Fri, Jan 17, 2014 at 08:01:24AM +0100, Matija Glavinic Pecotic wrote:
>>
>> Proposed solution simplifies whole algorithm having on mind
definition from rfc:
>>
>> o  Receiver Window (rwnd): This gives the sender an indication of the
space
>>    available in the receiver's inbound buffer.
>>
>> Core of the proposed solution is given with these lines:
>>
>> sctp_assoc_rwnd_account:
>> 	if ((asoc->base.sk->sk_rcvbuf - rx_count) > 0)
>> 		asoc->rwnd = (asoc->base.sk->sk_rcvbuf - rx_count) >> 1;
>> 	else
>> 		asoc->rwnd = 0;
>>
>> We advertise to sender (half of) actual space we have. Half is in the
braces
>> depending whether you would like to observe size of socket buffer as
SO_RECVBUF
>> or twice the amount, i.e. size is the one visible from userspace,
that is,
>> from kernelspace.
>> In this way sender is given with good approximation of our buffer space,
>> regardless of the buffer policy - we always advertise what we have.
Proposed
>> solution fixes described problems and removes necessity for rwnd
restoration
>> algorithm. Finally, as proposed solution is simplification, some
lines of code,
>> along with some bytes in struct sctp_association are saved.
>>
>> Signed-off-by: Matija Glavinic Pecotic
<matija.glavinic-pecotic.ext@nsn.com>
>> Reviewed-by: Alexander Sverdlin <alexander.sverdlin@nsn.com>
>>
>
>
> General comment - While this seems to make sense to me generally speaking,
> doesn't it currently violate section 6 of the RFC?
>
>
> A SCTP receiver MUST be able to receive a minimum of 1500 bytes in
>    one SCTP packet.  This means that a SCTP endpoint MUST NOT indicate
>    less than 1500 bytes in its Initial a_rwnd sent in the INIT or INIT
>    ACK.
>
> Since we set the initial rwnd value to the larger of sk->sk_rcvbuf/2 or
> SCTP_MIN_RWND (1500 bytes), won't we potentially advertize half that
amount?

Not initially.  Initial window will still be advertized properly.  Once
we receive the first packet and consumed some space, we'll advertize
half of available receive buffer.  It is perfectly OK to advertize a
window smaller the MIN_WINDOW in the middle of the transfer.

> It seems we need to double the minimum socket receive buffer here.

Not here specifically, but yes.  It is already broken and this patch
doesn't change current behavior.  This is something SCTP may need to do
separately.

-vlad

>
> Neil
>
>
