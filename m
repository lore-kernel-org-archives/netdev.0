From: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
Subject: Re: [PATCH] net: sctp: Fix a_rwnd/rwnd management to reflect real
 state of the receiver's buffer
Date: Wed, 22 Jan 2014 20:34:07 +0100
Message-ID: <52E01D2F.5020305@nsn.com>
References: <52D8D544.5050501@nsn.com> <20140122123059.GA9393@hmsreliant.think-freely.org> <52DFD334.7030507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org,
	Alexander Sverdlin <alexander.sverdlin@nsn.com>,
	netdev@vger.kernel.org
To: ext Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:12767 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756093AbaAVUN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 15:13:56 -0500
In-Reply-To: <52DFD334.7030507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Neil, Vlad,

On 01/22/2014 03:18 PM, ext Vlad Yasevich wrote:
> On 01/22/2014 07:30 AM, Neil Horman wrote:
>> On Fri, Jan 17, 2014 at 08:01:24AM +0100, Matija Glavinic Pecotic wrote:
>>>
>>> Proposed solution simplifies whole algorithm having on mind
> definition from rfc:
>>>
>>> o  Receiver Window (rwnd): This gives the sender an indication of the
> space
>>>    available in the receiver's inbound buffer.
>>>
>>> Core of the proposed solution is given with these lines:
>>>
>>> sctp_assoc_rwnd_account:
>>> 	if ((asoc->base.sk->sk_rcvbuf - rx_count) > 0)
>>> 		asoc->rwnd = (asoc->base.sk->sk_rcvbuf - rx_count) >> 1;
>>> 	else
>>> 		asoc->rwnd = 0;
>>>
>>> We advertise to sender (half of) actual space we have. Half is in the
> braces
>>> depending whether you would like to observe size of socket buffer as
> SO_RECVBUF
>>> or twice the amount, i.e. size is the one visible from userspace,
> that is,
>>> from kernelspace.
>>> In this way sender is given with good approximation of our buffer space,
>>> regardless of the buffer policy - we always advertise what we have.
> Proposed
>>> solution fixes described problems and removes necessity for rwnd
> restoration
>>> algorithm. Finally, as proposed solution is simplification, some
> lines of code,
>>> along with some bytes in struct sctp_association are saved.
>>>
>>> Signed-off-by: Matija Glavinic Pecotic
> <matija.glavinic-pecotic.ext@nsn.com>
>>> Reviewed-by: Alexander Sverdlin <alexander.sverdlin@nsn.com>
>>>
>>
>>
>> General comment - While this seems to make sense to me generally speaking,
>> doesn't it currently violate section 6 of the RFC?
>>
>>
>> A SCTP receiver MUST be able to receive a minimum of 1500 bytes in
>>    one SCTP packet.  This means that a SCTP endpoint MUST NOT indicate
>>    less than 1500 bytes in its Initial a_rwnd sent in the INIT or INIT
>>    ACK.
>>
>> Since we set the initial rwnd value to the larger of sk->sk_rcvbuf/2 or
>> SCTP_MIN_RWND (1500 bytes), won't we potentially advertize half that
> amount?
> 
> Not initially.  Initial window will still be advertized properly.  Once
> we receive the first packet and consumed some space, we'll advertize
> half of available receive buffer.  It is perfectly OK to advertize a
> window smaller the MIN_WINDOW in the middle of the transfer.

I agree to this, although we might be in gray area here:

   Advertised Receiver Window Credit (a_rwnd): 32 bits (unsigned
   integer)

      This value represents the dedicated buffer space, in number of
      bytes, the sender of the INIT has reserved in association with
      this window.  During the life of the association, this buffer
      space SHOULD NOT be lessened (i.e., dedicated buffers taken away
      from this association); however, an endpoint MAY change the value
      of a_rwnd it sends in SACK chunks.

this might be considered as taking away buffer space, although I would agree with point below about doubling.

This however opens another question which you should be aware of. This patch brakes regression, two TCs:

test_timetolive and test_sctp_sendrcvmsg.

This is simply due to 'honest' rwnd reporting. Both of these TCs share code in which initial rwnd is set very low, later socket buffer is increased but with counting on the fact that rwnd will stay as initially set. In TCs, this latter rwnd is fetched from the socket and used as value for the message size which in the end breaks it as message to be sent is too big.
What is important difference to current implementation is that changes of SO_RECVBUF will also change a_rwnd. It is not a big problem to add code which will keep the idea, but bound rwnd to initially set rwnd, but we haven't found it mandated by rfc.

Thanks,

Matija 

>> It seems we need to double the minimum socket receive buffer here.
> 
> Not here specifically, but yes.  It is already broken and this patch
> doesn't change current behavior.  This is something SCTP may need to do
> separately.
> 
> -vlad
> 
>>
>> Neil
>>
>>
