From: =?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel@gmail.com>
Subject: Re: [PATCH v3 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Wed, 3 Feb 2016 19:17:52 +0100
Message-ID: <CAF8eE=XxUeoe7pC8C6wgOi=GUR4daRNvFq8ZTrUCifZVa5zn+Q@mail.gmail.com>
References: <1454440995-18457-1-git-send-email-bro.devel+kernel@gmail.com>
	<1454440995-18457-3-git-send-email-bro.devel+kernel@gmail.com>
	<1454445306.7627.204.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?Q?P=C3=A5l_Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	=?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel+kernel@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:33965 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933435AbcBCSRx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 13:17:53 -0500
Received: by mail-qg0-f42.google.com with SMTP id u30so22096668qge.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 10:17:53 -0800 (PST)
In-Reply-To: <1454445306.7627.204.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 2, 2016 at 9:35 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> On Tue, 2016-02-02 at 20:23 +0100, Bendik R=C3=B8nning Opstad wrote:
>>
>>   o When packets are scheduled for transmission, RDB replaces the SK=
B to
>>     be sent with a modified SKB containing the redundant data of
>>     previously sent data segments from the TCP output queue.
>
> Really this looks very complicated.

Can you be more specific?

> Why not simply append the new skb content to prior one ?

It's not clear to me what you mean. At what stage in the output engine
do you refer to?

We want to avoid modifying the data of the SKBs in the output queue,
therefore we allocate a new SKB (This SKB is named rdb_skb in the code)=
=2E
The header and payload of the first SKB containing data we want to
redundantly transmit is then copied. Then the payload of the SKBs follo=
wing
next in the output queue is appended onto the rdb_skb. The last payload
that is appended is from the first SKB with unsent data, i.e. the
sk_send_head.

Would you suggest a different approach?

> skb_still_in_host_queue(sk, prior_skb) would also tell you if the skb=
 is
> really available (ie its clone not sitting/waiting in a qdisc on the
> host)

Where do you suggest this should be used?

> Note : select_size() always allocate skb with SKB_WITH_OVERHEAD(2048 =
-
> MAX_TCP_HEADER) available bytes in skb->data.

Sure, rdb_build_skb() could use this instead of the calculated
bytes_in_rdb_skb.

> Also note that tcp_collapse_retrans() is very similar to your needs. =
You
> might simply expand it.

The functionality shared is the copying of data from one SKB to another=
, as
well as adjusting sequence numbers and checksum. Unlinking SKBs from th=
e
output queue, modifying the data of SKBs in the output queue, and chang=
ing
retrans hints is not shared.

To reduce code duplication, the function skb_append_data in tcp_rdb.c c=
ould
be moved to tcp_output.c, and then be called from tcp_collapse_retrans.

Is it something like this you had in mind?


Bendik
