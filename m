From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 2/3] kcm: Kernel Connection Multiplexor module
Date: Tue, 22 Sep 2015 10:26:10 -0700
Message-ID: <CALx6S36H1YL1w4mS4Ee6TSV3nce0J4GT_e7+2h1b=o2nT+0ZUw@mail.gmail.com>
References: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
	<1442788161-2626305-3-git-send-email-tom@herbertland.com>
	<20150922162618.GA15483@Alexeis-MBP-2.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Alex Gartrell <agartrell@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33580 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757931AbbIVR0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 13:26:10 -0400
Received: by iofh134 with SMTP id h134so21488581iof.0
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 10:26:10 -0700 (PDT)
In-Reply-To: <20150922162618.GA15483@Alexeis-MBP-2.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 22, 2015 at 9:26 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Sun, Sep 20, 2015 at 03:29:20PM -0700, Tom Herbert wrote:
>> +Attaching of transport sockets to a multiplexor is performed by calling on
>> +ioctl on a KCM socket for the multiplexor. e.g.:
>> +
>> +  /* From linux/kcm.h */
>> +  struct kcm_attach {
>> +        int fd;
>> +        int bpf_type;
>> +        union {
>> +                int bpf_fd;
>> +                struct sock_fprog fprog;
>> +        };
>> +  };
>> +
>> +  struct kcm_attach info;
>> +
>> +  memset(&info, 0, sizeof(info));
>> +
>> +  info.fd = tcpfd;
>> +  info.bpf_type = KCM_BPF_TYPE_PROG;
>> +  info.bpf_fprog = bpf_prog;
>> +
>> +  ioctl(kcmfd, SIOCKCMATTACH, &info);
>> +
>> +The kcm_attach structure contains:
>> +  fd: file descriptor for TCP socket being attached
>> +  bpf_type: type of BPF program to be loaded this is either:
>> +    KCM_BPF_TYPE_PROG: program load directly for user space
>> +    KCM_BPF_TYPE_FD: Complied rogram to be load for the specified file
>> +                     descriptor (see BPF LLVM and Clang)
>> +  bpf_fprog: contains pointer to user space protocol to load
>> +  bpf_fd: file descriptor for compiled program download
>
> Interesting approach!
> I would only suggest to drop support for classic BPF.
> It's usable to return frame length of http2, but it won't be
> able to parse protocols where fields are little endian.
> Also it doesn't scale, since new cBPF program would be created
> for every KCM socket, whereas with eBPF we can use single program
> for all KCM sockets via single FD.
>
Hi Alexei,

That makes sense, but I think there may be some use cases where we'd
like lightweight methods to program filters. Writing C code for BPF is
extremely cool, but integrating LLVM/Clang into our development
environment may be a pain. We also might want to create a different
program for every socket anyway (like from some template with
parameterization). An eBPF assembler and jit support could be useful
(looks like there might be some work started on both of these
already).

> btw, did you consider to use BPF not only for frame length, but
> also to select KCM socket ? For example for http2 it can pick
> a socket based on stream id, providing affinity and
> further improving performance ?
>
Yes. I am thinking that eBPF can set the stream ID/transactional
identifiers in so_mark and then MUX steers to KCM sockets based on
that. As Sowmini pointed out we need to be weary of HOL blocking in
this...

Tom
