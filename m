From: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
Subject: Re: [PATCH net] Revert "net: sctp: Fix a_rwnd/rwnd management to
 reflect real state of the receiver's buffer"
Date: Mon, 21 Apr 2014 21:12:56 +0200
Message-ID: <53556DB8.5070505@nsn.com>
References: <1397504717-19566-1-git-send-email-dborkman@redhat.com> <534C3DC2.9070604@gmail.com> <534E29D4.60100@nsn.com> <CAE8XmWqgcNAHcKnzdUamQ0T+NP27GKSiRv37JEHSQW-=1Fu=2w@mail.gmail.com> <534E473E.20303@nsn.com> <534ED0FD.4040709@gmail.com> <534ED48A.6040502@redhat.com> <534ED8DF.8040808@nsn.com> <534EDE69.8090404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: ext Daniel Borkmann <dborkman@redhat.com>,
	Alexander Sverdlin <alexander.sverdlin@nsn.com>,
	ext Dongsheng Song <dongsheng.song@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: ext Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:48500 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752779AbaDUTO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 15:14:56 -0400
In-Reply-To: <534EDE69.8090404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/2014 09:47 PM, ext Vlad Yasevich wrote:
> On 04/16/2014 03:24 PM, Matija Glavinic Pecotic wrote:
>> On 04/16/2014 09:05 PM, ext Daniel Borkmann wrote:
>>> On 04/16/2014 08:50 PM, Vlad Yasevich wrote:
>>>> On 04/16/2014 05:02 AM, Alexander Sverdlin wrote:
>>>>> Hi Dongsheng!
>>>>>
>>>>> On 16/04/14 10:39, ext Dongsheng Song wrote:
>>>>>> >From my testing, netperf throughput from 600 Mbit/s drop to 6 Mbit/s,
>>>>>> the penalty is 99 %.
>>>>>
>>>>> The question was, do you see this as a problem of the new rwnd algorithm?
>>>>> If yes, how exactly?
>>>
>>> [ Default config ./test_timetolive from lksctp-test suite triggered
>>>   that as well actually it appears, i.e. showing that the app never
>>>   woke up from the 3 sec timeout. ]
>>
>> We had a different case there. Test wasnt hanging due to decreased performance, but due to fact that with the patch sender created very large message, as opposed to situation before the patch where test message was of much smaller size.
>>
>> http://www.spinics.net/lists/linux-sctp/msg03185.html
> 
> The problem with the test is that it tries to completely fill the
> receive window by using a single SCTP message.  This all goes well
> and the test expects a 0-rwnd to be advertised.
> 
> The test then consumes said message.  At this point, the test expects
> the window to be opened and subsequent messages be sent or timed-out.
> This doesn't happen, because the window update is not sent.  So
> the sender thinks that the window is closed which it technically is
> since we never actually update asoc->rwnd.  But the receive buffer
> is empty since we drained the data.
> We have a stuck association.
> 
> Hard to do when traffic is always flowing one way or the other, but
> in a test, it's easy.

I'm not sure we hit exactly this scenario in this test case.

The problem with this TC is that it relied on the fact that once SO_RCVBUF is set on the socket, and later changed, a_rwnd will stay at the initial value (the same what was discussed when this TC was fixed few months ago -> http://www.spinics.net/lists/linux-sctp/msg03185.html).

What happened once rwnd became "honest" is that TC did not use small value to create fill message (fillmsg = malloc(gstatus.sstat_rwnd+RWND_SLOP);) ->  (SMALL_RCVBUF+RWND_SLOP), but due to new behavior, it used later advertised, or what is referred in TC as the original value. This value is even bigger then REALLY_BIG value in TC, and in my case, it is 164k:

> Sending the message of size 163837...

With these parameters, we will deplete receiver in just two sctp packets on lo (~65k of data plus really big overhead due to MAXSEG set to 100). We can confirm this by looking at the assocs state at the time of TC hanging:

glavinic@slon:~$ cat /proc/net/sctp/assocs 
 ASSOC     SOCK   STY SST ST HBKT ASSOC-ID TX_QUEUE RX_QUEUE UID INODE LPORT RPORT LADDRS <-> RADDRS HBINT INS OUTS MAXRT T1X T2X RTXC wmema wmemq sndbuf rcvbuf
f2c0d800 f599c780 0   7   3  8332   13   753877        0    1000 27635 1024   1025  127.0.0.1 <-> *127.0.0.1 	    7500    10    10   10    0    0    15604  1428953  1153600   163840   163840
f2c09800 f599cb40 0   10  3  9101   14        0   327916    1000 27636 1025   1024  127.0.0.1 <-> *127.0.0.1 	    7500    10    10   10    0    0        0        1        0   163840   327680
glavinic@slon:~$ 

What happens is that TC hangs on the send message. Since TC hanged there, we dont get to the point that we start reading and we have locked ourselves forever.

On the other side, I see a possible pitfall with this late rwnd update, especially for the large messages accompanied with large MTUs and when we come close to closing the rwnd, so I'm looking forward for the retest.

Regards,

Matija
 
> -vlad
> 
>>
>>>> The algorithm isn't wrong, but the implementation appears to have
>>>> a bug with window update SACKs.  The problem is that
>>>> sk->sk_rmem_alloc is updated by the skb destructor when
>>>> skb is freed.  This happens after we call sctp_assoc_rwnd_update()
>>>> which tries to send the update SACK.  As a result, in default
>>>> config with per-socket accounting, the test
>>>>      if ((asoc->base.sk->sk_rcvbuf - rx_count) > 0)
>>>> uses the wrong values for rx_count and results in advertisement
>>>> of decreased rwnd instead of what is really available.
> 
