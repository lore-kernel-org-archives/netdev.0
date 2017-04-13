From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [RFC PATCH 3/7] net: add option to get information about
 timestamped packets
Date: Thu, 13 Apr 2017 12:16:09 -0400
Message-ID: <CAF=yD-+tJpY7XJrqxga=0_kn-FjS0M=yuu59m_ZRRrrcpJCbZw@mail.gmail.com>
References: <20170412141737.5881-1-mlichvar@redhat.com> <20170412141737.5881-4-mlichvar@redhat.com>
 <CAF=yD-Lsbr7f7aPUsFF3gCtFdyR8yb1=VBPJGQuxv_JbrJud6Q@mail.gmail.com> <20170413151806.GA26613@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:36303 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752106AbdDMQQu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 12:16:50 -0400
Received: by mail-qt0-f180.google.com with SMTP id v3so49527825qtd.3
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 09:16:50 -0700 (PDT)
In-Reply-To: <20170413151806.GA26613@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 11:18 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> On Thu, Apr 13, 2017 at 10:37:07AM -0400, Willem de Bruijn wrote:
>> On Wed, Apr 12, 2017 at 10:17 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
>> > Extend the skb_shared_hwtstamps structure with the index of the
>> > real interface which received or transmitted the packet and the length
>> > of the packet at layer 2.
>>
>> The original packet is received along with the timestamp.
>
> But only outgoing packets, right?

Timestamps for incoming packets are also passed alongside the original packet.

>> Why is this L2 length needed?
>
> It's needed for incoming packets to allow converting of preamble
> timestamps to trailer timestamps.

Receiving the mac length of a packet sounds like a feature independent
from timestamping. Either an ioctl similar to SIOCGIFMTU or, if it may
vary due to existince of vlan headers, a new independent cmsg at the
SOL_SOCKET layer.

>> > Add a SOF_TIMESTAMPING_OPT_PKTINFO flag to
>> > the SO_TIMESTAMPING option to allow applications to get this information
>> > as struct scm_ts_pktinfo in SCM_TIMESTAMPING_PKTINFO control message.
>>
>> This patch saves skb->dev->ifindex, which is the same as existing
>> SOF_TIMESTAMPING_OPT_CMSG. See also the bug fix for that
>> feature I sent yesterday: http://patchwork.ozlabs.org/patch/750197/
>
> The main point is that it provides the index of the device which
> received the packet. It does duplicate the functionality of OPT_CMSG +
> IP_PKTINFO for outgoing packets, but I thought it might be useful with
> the TSONLY option.

Agreed. I'd prefer to reuse the existing option for that and just extend it
to work together with TSONLY.

We will have to set serr->header.h4.iif from something other than skb->dev
if the skb was allocated fresh in __skb_tstamp_tx without the device
association.
