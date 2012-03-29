From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 3/3] tcp: Repair socket queues
Date: Thu, 29 Mar 2012 14:36:34 +0400
Message-ID: <4F743B32.4050107@parallels.com>
References: <4F732FE1.9040906@parallels.com> <4F733062.9020800@parallels.com> <4F7439AE.6050006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:3741 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116Ab2C2Kgm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2012 06:36:42 -0400
In-Reply-To: <4F7439AE.6050006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2012 02:30 PM, Li Yu wrote:
> =E4=BA=8E 2012=E5=B9=B403=E6=9C=8828=E6=97=A5 23:38, Pavel Emelyanov =
=E5=86=99=E9=81=93:
>> Reading queues under repair mode is done with recvmsg call.
>> The queue-under-repair set by TCP_REPAIR_QUEUE option is used
>> to determine which queue should be read. Thus both send and
>> receive queue can be read with this.
>>
>> Caller must pass the MSG_PEEK flag.
>>
>> Writing to queues is done with sendmsg call and yet again --
>> the repair-queue option can be used to push data into the
>> receive queue.
>>
>> When putting an skb into receive queue a zero tcp header is
>> appented to its head to address the tcp_hdr(skb)->syn and
>> the ->fin checks by the (after repair) tcp_recvmsg. These
>> flags flags are both set to zero and that's why.
>>
>> The fin cannot be met in the queue while reading the source
>> socket, since the repair only works for closed/established
>> sockets and queueing fin packet always changes its state.
>>
>> The syn in the queue denotes that the respective skb's seq
>> is "off-by-one" as compared to the actual payload lenght. Thus,
>> at the rcv queue refill we can just drop this flag and set the
>> skb's sequences to precice values. IOW -- emulate the situation
>> when the packet with data and syn is splitted into two -- a
>> packet with syn and a packet with data and the former one is
>> already "eaten".
>>
>> When the repair mode is turned off, the write queue seqs are
>> updated so that the whole queue is considered to be 'already sent,
>> waiting for ACKs' (write_seq =3D snd_nxt<=3D snd_una). From the
>> protocol POV the send queue looks like it was sent, but the data
>> between the write_seq and snd_nxt is lost in the network.
>>
>> This helps to avoid another sockoption for setting the snd_nxt
>> sequence. Leaving the whole queue in a 'not yet sent' state (as
>> it will be after sendmsg-s) will not allow to receive any acks
>> from the peer since the ack_seq will be after the snd_nxt. Thus
>> even the ack for the window probe will be dropped and the
>> connection will be 'locked' with the zero peer window.
>>
>=20
> Do we need to restore various TCP options switch bits. e.g. window
> scale factor, sack_ok and so on.

SACK-s -- yes, this is in TODO list. Various window stuff -- not necess=
ary.
TCP will eventually negotiate proper values again.

> En, I think the recorded mss_cache may be need to restored too.

Same with mss. As far as I understand this one will be re-detected afte=
r
a connection restore.

> Thanks.
>=20
> Yu
