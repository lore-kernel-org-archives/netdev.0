From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Sun, 14 Apr 2013 12:52:16 +0200
Message-ID: <516A8A60.5020003@redhat.com>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com> <1365879412-9541-1-git-send-email-willemb@google.com> <5169D9C8.8010504@redhat.com> <CA+FuTSe1KCPPW=FBXZoTNmri9oPHicuoFeEMKws09PwbyRe-2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Chavent <paul.chavent@onera.fr>,
	Richard Cochran <richardcochran@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4141 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362Ab3DNKxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Apr 2013 06:53:22 -0400
In-Reply-To: <CA+FuTSe1KCPPW=FBXZoTNmri9oPHicuoFeEMKws09PwbyRe-2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/14/2013 02:00 AM, Willem de Bruijn wrote:
> On Sat, Apr 13, 2013 at 6:18 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 04/13/2013 08:56 PM, Willem de Bruijn wrote:
>>>
>>> When transmit timestamping is enabled at the socket level, have
>>> writes to a PACKET_TX_RING record a timestamp for the generated
>>> skbuffs. Tx timestamps are always looped to the application over
>>> the socket error queue.
>>
>>
>> Nitpick: if so, then this should go to net-next (subject line).
>
> Thanks.
>>
>>> The patch also loops software timestamps back into the ring.

Also v2 should probably contain a ``Reported-by''.

>>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>>> ---
>>>    net/core/skbuff.c      |  2 +-
>>>    net/packet/af_packet.c | 42 ++++++++++++++++++++++++++++++++++++++++++
>>>    2 files changed, 43 insertions(+), 1 deletion(-)
>>
>> [...]
>>
>>> +static void __packet_set_timestamp(struct packet_sock *po, void *frame,
>>> +                                  ktime_t tstamp)
>>> +{
>>> +       struct tpacket_hdr *h1;
>>> +       struct tpacket2_hdr *h2;
>>> +       struct timespec ts;
>>> +
>>> +       if (!tstamp.tv64 || !sock_flag(&po->sk,
>>> SOCK_TIMESTAMPING_SOFTWARE))
>>> +               return;

While going a bit more through the code, I'm wondering .. if we want to support
TX timestamps, could we also support SW _and_ HW timestamps e.g. similar as in
sock_recv_timestamp()? I'm asking, because we already allow setting the flags
for it via sock_tx_timestamp(). This might be good, if possible.

Paul, since you've reported / requested this, your use case would be to fill
the ring, trigger a sendto() and then loop through all the frames to check the
tx timestamps for your custom protocol mockup, then fill the returned frames
again, etc.?

>>> +       ts = ktime_to_timespec(tstamp);
>>> +
>>> +       switch (po->tp_version) {
>>> +       case TPACKET_V1:
>>> +               h1 = frame;
>>> +               h1->tp_sec = ts.tv_sec;
>>> +               h1->tp_usec = ts.tv_nsec / NSEC_PER_USEC;
>>> +
>>> +               flush_dcache_page(pgv_to_page(&h1->tp_sec));
>>> +               flush_dcache_page(pgv_to_page(&h1->tp_usec));
>>
>>
>> Hmm, not sure, but could we also flush the dcache only once?
