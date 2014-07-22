From: Mihail Dakov <mihail.dakov@ng4t.com>
Subject: Re: AF_PACKET: tx_ring mirrored in rx_ring?
Date: Tue, 22 Jul 2014 15:39:48 +0200
Message-ID: <53CE69A4.4040601@ng4t.com>
References: <53CD1326.5090006@ng4t.com> <53CD1AE5.10408@redhat.com> <53CD2661.8070707@ng4t.com> <53CD2E08.7070204@redhat.com> <20140721203253.Horde.9bpg4-qQqIsddySIO6hXOw1@ssl.lux01.de> <CA+FuTScUC08D_+iHwxVuvWBSDdKgT7bQv-sigwAiopFodFOc=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud15.udmedia.de ([194.117.254.55]:46430 "EHLO
	mail.ud15.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbaGVNjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 09:39:52 -0400
In-Reply-To: <CA+FuTScUC08D_+iHwxVuvWBSDdKgT7bQv-sigwAiopFodFOc=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 07/22/2014 12:35 AM, Willem de Bruijn wrote:
>>>> What'd you mean by local traffic? The packets which are replicated are
>>>> destined to remote machine(s).
>>>
>>> Sure, but you are sending them out via your packet socket.
>>
>> Well yes. It's just that I interpreted local as if they were not going out
>> of the machine. But in fact they do.
> That is a semantic issue. The technical point is that packet
> sockets read not only incoming packets, but also outgoing
> ones. The tap in the egress path (dev_queue_xmit_nit) is taken
> for almost all transmitted packets, included those transmitted
> by a packet socket.
>
> There is logic to avoid looping outgoing packets back into the
> originating socket (and fanout group) by detecting the source
> socket (skb_loop_sk). Other packet sockets will receive the
> outgoing packets, however. This is correct behavior, as it is
> how tcpdump can log all traffic, among others.
>
> You can use PACKET_QDISC_BYPASS on your transmit
> packet socket, as Daniel mentions, or attach a BPF filter to
> your receive socket that filters on !PACKET_OUTGOING, e.g.,:
>
>    struct sock_filter bpf_filter[] = {
>      {BPF_LD | BPF_B | BPF_ABS, 0, 0, (uint32_t) (SKF_AD_OFF + SKF_AD_PKTTYPE)},
>      {BPF_JMP | BPF_JEQ, 1, 0, PACKET_OUTGOING},
>      {BPF_RET, 0, 0, 0x00000000},
>      {BPF_RET, 0, 0, 0x0000ffff},
>    };
>    struct sock_fprog bpf_prog;
>
>    bpf_prog.filter = bpf_filter;
>    bpf_prog.len = sizeof(bpf_filter) / sizeof(struct sock_filter);
>    if (setsockopt(fd, SOL_SOCKET, SO_ATTACH_FILTER, &bpf_prog,
>                   sizeof(bpf_prog))) {
>      error(1, errno, "setsockopt filter");
>    }
Thanks.
