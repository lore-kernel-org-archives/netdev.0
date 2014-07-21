From: Willem de Bruijn <willemb@google.com>
Subject: Re: AF_PACKET: tx_ring mirrored in rx_ring?
Date: Mon, 21 Jul 2014 18:35:00 -0400
Message-ID: <CA+FuTScUC08D_+iHwxVuvWBSDdKgT7bQv-sigwAiopFodFOc=w@mail.gmail.com>
References: <53CD1326.5090006@ng4t.com> <53CD1AE5.10408@redhat.com>
 <53CD2661.8070707@ng4t.com> <53CD2E08.7070204@redhat.com> <20140721203253.Horde.9bpg4-qQqIsddySIO6hXOw1@ssl.lux01.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: mihail.dakov@ng4t.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f169.google.com ([209.85.220.169]:51768 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551AbaGUWfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 18:35:31 -0400
Received: by mail-vc0-f169.google.com with SMTP id hu12so13590832vcb.14
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 15:35:30 -0700 (PDT)
In-Reply-To: <20140721203253.Horde.9bpg4-qQqIsddySIO6hXOw1@ssl.lux01.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> What'd you mean by local traffic? The packets which are replicated are
>>> destined to remote machine(s).
>>
>>
>> Sure, but you are sending them out via your packet socket.
>
>
> Well yes. It's just that I interpreted local as if they were not going out
> of the machine. But in fact they do.

That is a semantic issue. The technical point is that packet
sockets read not only incoming packets, but also outgoing
ones. The tap in the egress path (dev_queue_xmit_nit) is taken
for almost all transmitted packets, included those transmitted
by a packet socket.

There is logic to avoid looping outgoing packets back into the
originating socket (and fanout group) by detecting the source
socket (skb_loop_sk). Other packet sockets will receive the
outgoing packets, however. This is correct behavior, as it is
how tcpdump can log all traffic, among others.

You can use PACKET_QDISC_BYPASS on your transmit
packet socket, as Daniel mentions, or attach a BPF filter to
your receive socket that filters on !PACKET_OUTGOING, e.g.,:

  struct sock_filter bpf_filter[] = {
    {BPF_LD | BPF_B | BPF_ABS, 0, 0, (uint32_t) (SKF_AD_OFF + SKF_AD_PKTTYPE)},
    {BPF_JMP | BPF_JEQ, 1, 0, PACKET_OUTGOING},
    {BPF_RET, 0, 0, 0x00000000},
    {BPF_RET, 0, 0, 0x0000ffff},
  };
  struct sock_fprog bpf_prog;

  bpf_prog.filter = bpf_filter;
  bpf_prog.len = sizeof(bpf_filter) / sizeof(struct sock_filter);
  if (setsockopt(fd, SOL_SOCKET, SO_ATTACH_FILTER, &bpf_prog,
                 sizeof(bpf_prog))) {
    error(1, errno, "setsockopt filter");
  }
