From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH RFC 2/3] kcm: Kernel Connection Multiplexor module
Date: Tue, 22 Sep 2015 09:26:20 -0700
Message-ID: <20150922162618.GA15483@Alexeis-MBP-2.westell.com>
References: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
 <1442788161-2626305-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34805 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752383AbbIVQ0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 12:26:24 -0400
Received: by padhy16 with SMTP id hy16so13554181pad.1
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 09:26:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1442788161-2626305-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 20, 2015 at 03:29:20PM -0700, Tom Herbert wrote:
> +Attaching of transport sockets to a multiplexor is performed by calling on
> +ioctl on a KCM socket for the multiplexor. e.g.:
> +
> +  /* From linux/kcm.h */
> +  struct kcm_attach {
> +        int fd;
> +        int bpf_type;
> +        union {
> +                int bpf_fd;
> +                struct sock_fprog fprog;
> +        };
> +  };
> +
> +  struct kcm_attach info;
> +
> +  memset(&info, 0, sizeof(info));
> +
> +  info.fd = tcpfd;
> +  info.bpf_type = KCM_BPF_TYPE_PROG;
> +  info.bpf_fprog = bpf_prog;
> +
> +  ioctl(kcmfd, SIOCKCMATTACH, &info);
> +
> +The kcm_attach structure contains:
> +  fd: file descriptor for TCP socket being attached
> +  bpf_type: type of BPF program to be loaded this is either:
> +    KCM_BPF_TYPE_PROG: program load directly for user space
> +    KCM_BPF_TYPE_FD: Complied rogram to be load for the specified file
> +                     descriptor (see BPF LLVM and Clang)
> +  bpf_fprog: contains pointer to user space protocol to load
> +  bpf_fd: file descriptor for compiled program download

Interesting approach!
I would only suggest to drop support for classic BPF.
It's usable to return frame length of http2, but it won't be
able to parse protocols where fields are little endian.
Also it doesn't scale, since new cBPF program would be created
for every KCM socket, whereas with eBPF we can use single program
for all KCM sockets via single FD.

btw, did you consider to use BPF not only for frame length, but
also to select KCM socket ? For example for http2 it can pick
a socket based on stream id, providing affinity and
further improving performance ?
