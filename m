From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH] tcp: Add SOF_TIMESTAMPING_TX_EOR and allow MSG_EOR
 in tcp_sendmsg
Date: Sun, 27 Mar 2016 22:42:10 -0700
Message-ID: <20160328054210.GA30968@DHCP.thefacebook.com>
References: <1458859592-751521-1-git-send-email-kafai@fb.com>
 <CAF=yD-JPvjNz=CZH6X=Hj+0vSyTyZcwKJoeTdOZKjx1Ys17DNQ@mail.gmail.com>
 <CAK6E8=ekVGq9E3sZEcZVdSEfTxxZ74W7FdW1YmKS-GFASQbJnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:42958 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753873AbcC1FmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 01:42:25 -0400
Content-Disposition: inline
In-Reply-To: <CAK6E8=ekVGq9E3sZEcZVdSEfTxxZ74W7FdW1YmKS-GFASQbJnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 04:05:51PM -0700, Yuchung Cheng wrote:
> Looks like an interesting and useful patch. Since HTTP2 allows
> multiplexing data stream frames from multiple logical streams on a
> single socket,
> how would you instrument to measure the latency of each stream? e.g.,
>
> sendmsg of data_frame_1_of_stream_a
> sendmsg of data_frame_1_of_stream_b
> sendmsg of data_frame_2_of_stream_a
> sendmsg of data_frame_1_of_stream_c
> sendmsg of data_frame_2_of_stream_b

A quick recall from the end of the commit message:
"One of our use case is at the webserver.  The webserver tracks
the HTTP2 response latency by measuring when the webserver
sends the first byte to the socket till the TCP ACK of the last byte
is received."

It is the server side perception on how long does it take to deliver
the whole response/stream to the client.  Hence, the number of
interleaved streams does not matter.

Some sample use cases are,
comparing TCP sysctl/code changes,
observing encoding/compression impact (e.g. HPACK in HTTP2).

Assuming frame_2 is the end stream for 'a' and 'b':
sendmsg of data_frame_1_of_stream_a
sendmsg of data_frame_1_of_stream_b
sendmsg of data_frame_2_of_stream_a MSG_EOR
sendmsg of data_frame_1_of_stream_c
sendmsg of data_frame_2_of_stream_b MSG_EOR

Are you suggesting other useful ways/metrics should be measured in
this case?
