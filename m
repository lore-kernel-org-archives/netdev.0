From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] Revert "net: sctp: Fix a_rwnd/rwnd management to
 reflect real state of the receiver's buffer"
Date: Wed, 16 Apr 2014 15:47:53 -0400
Message-ID: <534EDE69.8090404@gmail.com>
References: <1397504717-19566-1-git-send-email-dborkman@redhat.com> <534C3DC2.9070604@gmail.com> <534E29D4.60100@nsn.com> <CAE8XmWqgcNAHcKnzdUamQ0T+NP27GKSiRv37JEHSQW-=1Fu=2w@mail.gmail.com> <534E473E.20303@nsn.com> <534ED0FD.4040709@gmail.com> <534ED48A.6040502@redhat.com> <534ED8DF.8040808@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Sverdlin <alexander.sverdlin@nsn.com>,
	ext Dongsheng Song <dongsheng.song@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>,
	ext Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:54512 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435AbaDPTr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 15:47:56 -0400
In-Reply-To: <534ED8DF.8040808@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/2014 03:24 PM, Matija Glavinic Pecotic wrote:
> On 04/16/2014 09:05 PM, ext Daniel Borkmann wrote:
>> On 04/16/2014 08:50 PM, Vlad Yasevich wrote:
>>> On 04/16/2014 05:02 AM, Alexander Sverdlin wrote:
>>>> Hi Dongsheng!
>>>>
>>>> On 16/04/14 10:39, ext Dongsheng Song wrote:
>>>>> >From my testing, netperf throughput from 600 Mbit/s drop to 6 Mbit/s,
>>>>> the penalty is 99 %.
>>>>
>>>> The question was, do you see this as a problem of the new rwnd algorithm?
>>>> If yes, how exactly?
>>
>> [ Default config ./test_timetolive from lksctp-test suite triggered
>>   that as well actually it appears, i.e. showing that the app never
>>   woke up from the 3 sec timeout. ]
> 
> We had a different case there. Test wasnt hanging due to decreased performance, but due to fact that with the patch sender created very large message, as opposed to situation before the patch where test message was of much smaller size.
> 
> http://www.spinics.net/lists/linux-sctp/msg03185.html

The problem with the test is that it tries to completely fill the
receive window by using a single SCTP message.  This all goes well
and the test expects a 0-rwnd to be advertised.

The test then consumes said message.  At this point, the test expects
the window to be opened and subsequent messages be sent or timed-out.
This doesn't happen, because the window update is not sent.  So
the sender thinks that the window is closed which it technically is
since we never actually update asoc->rwnd.  But the receive buffer
is empty since we drained the data.
We have a stuck association.

Hard to do when traffic is always flowing one way or the other, but
in a test, it's easy.

-vlad

> 
>>> The algorithm isn't wrong, but the implementation appears to have
>>> a bug with window update SACKs.  The problem is that
>>> sk->sk_rmem_alloc is updated by the skb destructor when
>>> skb is freed.  This happens after we call sctp_assoc_rwnd_update()
>>> which tries to send the update SACK.  As a result, in default
>>> config with per-socket accounting, the test
>>>      if ((asoc->base.sk->sk_rcvbuf - rx_count) > 0)
>>> uses the wrong values for rx_count and results in advertisement
>>> of decreased rwnd instead of what is really available.
